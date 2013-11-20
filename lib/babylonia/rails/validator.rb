# Rails each validator for locales
# @params [Hash] options
# @option [Hash] locales The validations to do on the locales of an attribute
class LocalesValidator < ActiveModel::EachValidator
  attr_reader :validators
  
  def validate_each(record, attribute, value)
    @validators = {}
    record.available_locales.each do |lang|
      [:presence, :absence, :numericality, :format, :inclusion, :exclusion, :length].each do |validation|
        add_validator validation, attribute, lang if should_validate?(validation, lang)
      end
    end
    
    validators.each do |validator, attributes|
      "ActiveModel::Validations::#{validator.to_s.classify}Validator".constantize.new(validator_attributes(validator, attributes)).validate(record)
    end if validators
  end
  
  private
  
  def add_validator validator, attribute, lang
    @validators ||= {}
    @validators[validator] ||= { attributes: [] }
    @validators[validator][:attributes] << :"#{attribute}_#{lang}"
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