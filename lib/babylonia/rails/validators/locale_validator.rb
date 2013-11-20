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
          record.available_locales.each do |lang|
            validations = ActiveRecord::VERSION::MAJOR < 4 ? [:acceptance, :exclusion, :format, :inclusion, :length, :numericality, :presence, :uniqueness] : [:absence, :acceptance, :exclusion, :format, :inclusion, :length, :numericality, :presence, :uniqueness]
            validations.each do |validation|
              add_validator validation, attribute, lang if should_validate?(validation, lang)
            end
          end
    
          validators.each do |validator, attributes|
            if validator == :uniqueness
              Babylonia::Rails::Validators::UniquenessValidator.new(validator_attributes(validator, attributes)).validate(record)
            else
              "ActiveModel::Validations::#{validator.to_s.classify}Validator".constantize.new(validator_attributes(validator, attributes)).validate(record)
            end
          end
        end
  
        private
  
        def add_validator validator, attribute, lang
          @validators ||= {}
          if validator == :uniqueness
            @validators[validator] ||= { attributes: {} }
            @validators[validator][:attributes].merge! lang => attribute
          else
            @validators[validator] ||= { attributes: [] }
            @validators[validator][:attributes] << :"#{attribute}_#{lang}"
          end
        end
  
        def should_validate?(option, lang)
          if [:presence, :absence, :uniqueness, :numericality].include?(option)
            options[option] == true || (options[option].is_a?(Array) && options[option].include?(lang)) || (options[option].is_a?(Hash) && locale_included_in_validation_options?(option, lang))
          else
            options[option].is_a?(Hash) && locale_included_in_validation_options?(option, lang)
          end
        end
    
        def locale_included_in_validation_options?(validation_name, lang)
          options[validation_name][:locales].blank? || options[validation_name][:locales].include?(lang)
        end
  
        def validator_attributes(validator, attributes)
          options[validator].is_a?(Hash) ? options[validator].delete_if{|k,v| k == :locales}.merge(attributes) : attributes
        end
  
      end
    end
  end
end