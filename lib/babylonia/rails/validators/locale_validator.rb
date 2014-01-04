# Rails each validator for locales
# @params [Hash] options
# @option [Hash] locales The validations to do on the locales of an attribute
require 'active_model'

module Babylonia
  module Rails
    module Validators
      class LocalesValidator < ::ActiveModel::EachValidator
        attr_reader :validators
  
        def validate_each(record, attribute, value)
          @validators = {}
          record.available_locales.each do |locale|
            validations = active_record_validations_array
            validations.each do |validation|
              add_validator validation, attribute, locale if should_validate? validation, locale
            end
          end
    
          validators.each do |validator, attributes|
            if validator == :uniqueness
              validate_with_babylonia_uniqueness_validator! record, validator, attributes
            else
              validate_with_rails_validator! record, validator, attributes
            end
          end
        end
  
        private
        
        def validate_with_babylonia_uniqueness_validator! record, validator, attributes
          Babylonia::Rails::Validators::LocaleUniquenessValidator.new(validator_attributes(validator, attributes)).validate(record)
        end
        
        def validate_with_rails_validator! record, validator, attributes
          "ActiveModel::Validations::#{validator.to_s.classify}Validator".constantize.new(validator_attributes(validator, attributes)).validate(record)
        end
  
        def add_validator validator, attribute, locale #:nodoc:
          @validators ||= {}
          if validator == :uniqueness
            @validators[validator] ||= { attributes: {} }
            @validators[validator][:attributes].merge! locale => attribute
          else
            @validators[validator] ||= { attributes: [] }
            @validators[validator][:attributes] << :"#{attribute}_#{locale}"
          end
        end
  
        def should_validate? option, locale #:nodoc:   
          if complex_validation_options? option
            validation_required_for_locale?(option, options, locale) || locale_included_in_validation_options?(option, options, locale)
          else
            locale_included_in_validation_options?(option, options, locale)
          end
        end
        
        def complex_validation_options? option
          [:presence, :absence, :uniqueness, :numericality].include? option
        end
        
        def validation_required_for_locale? option, options, locale #:nodoc:
          options[option] == true || (options[option].is_a?(Array) && options[option].include?(locale))
        end
    
        def locale_included_in_validation_options? option, options, locale #:nodoc:
          options[option].is_a?(Hash) && (options[option][:locales].blank? || options[option][:locales].include?(locale))
        end
  
        def validator_attributes validator, attributes #:nodoc:
          options[validator].is_a?(Hash) ? options[validator].delete_if{|k,v| k == :locales}.merge(attributes) : attributes
        end
        
        def active_record_validations_array
          [is_active_record_4? && :absence, :acceptance, :exclusion, :format, :inclusion, :length, :numericality, :presence, :uniqueness].compact
        end
        
        def is_active_record_4? #:nodoc:
          ActiveRecord::VERSION::MAJOR > 3
        end
  
      end
    end
  end
end