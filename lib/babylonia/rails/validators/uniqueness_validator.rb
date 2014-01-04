require 'active_record'

module Babylonia
  module Rails
    module Validators
      class LocaleUniquenessValidator < ::ActiveRecord::Validations::UniquenessValidator
        
        def validate record
          (is_active_record_4? ? attributes : attributes.first).each do |locale, attribute|
            value = record.read_attribute_for_validation :"#{attribute}_#{locale}"
            next if (value.nil? && options[:allow_nil]) || (value.blank? && options[:allow_blank])
            validate_each record, attribute, locale, value
          end
        end
        
        def validate_each record, attribute, locale, value
          finder_class = find_finder_class_for record
          table = finder_class.arel_table

          relation = build_relation finder_class, table, attribute, locale, value
          relation = relation.and table[finder_class.primary_key.to_sym].not_eq(record.id) if record.persisted?
          
          relation = if is_active_record_4?
            scope_relation record, table, relation
          else
            scope_relation_for_active_record_3 relation, options
          end
          
          relation = finder_class.unscoped.where relation
          relation = relation.merge options[:conditions] if options[:conditions]

          if relation.exists?
            add_uniqueness_validation_error record, options, attribute, locale, value
          end
        end

      protected
      
        # Copy from rails uniqueness validator
        # The check for an existing value should be run from a class that
        # isn't abstract. This means working down from the current class
        # (self), to the first non-abstract class. Since classes don't know
        # their subclasses, we have to build the hierarchy between self and
        # the record's class.
        def find_finder_class_for record #:nodoc:          
          class_hierarchy = [record.class]

          while class_hierarchy.last != @klass && class_hierarchy.last.superclass
            class_hierarchy.push(class_hierarchy.last.superclass)
          end
        
          class_hierarchy.detect { |klass| !klass.abstract_class? }
        end

        def build_relation klass, table, attribute, locale, value #:nodoc:
          column = klass.columns_hash[attribute.to_s]
          value  = build_yaml_dump_value klass, value, column, locale
          
          if !options[:case_sensitive] && value && column.text?
            table[attribute].lower.matches("%#{value.respond_to?(:expr) ? value.expr : value.downcase}%")
          else
            value = klass.connection.case_sensitive_modifier(value) unless value.nil?
            table[attribute].matches("%#{value.expr}%")
          end
        end
        
        def build_yaml_dump_value klass, value, column, locale
          value  = klass.connection.type_cast(value, column)
          value  = YAML.dump(locale => value).gsub(/\A[^\n]+/, '')
          value  = value.to_s[0, column.limit] if value && column.limit && column.text?
          
          value
        end
        
        def add_uniqueness_validation_error record, options, attribute, locale, value #:nodoc:
          error_options = options.except :case_sensitive, :scope, :conditions
          error_options[:value] = value

          record.errors.add :"#{attribute}_#{locale}", :taken, error_options
        end
        
        def scope_relation_for_active_record_3 relation, options  #:nodoc:
          Array.wrap(options[:scope]).each do |scope_item|
            scope_value = record.read_attribute scope_item
            relation = relation.and table[scope_item].eq(scope_value)
          end
          
          relation
        end
        
        def is_active_record_4? #:nodoc:
          ActiveRecord::VERSION::MAJOR > 3
        end
      end
    end
  end
end
