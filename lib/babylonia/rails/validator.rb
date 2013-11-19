class LanguagesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    validate_languages_present(record, attribute, options[:present].sort) if options[:present]
    validate_length_in_range(record, attribute, options[:length]) if options[:length].is_a?(Range)
  end
  
  private
  
  def validate_languages_present(record, attribute, languages)
    is     = record_attribute_languages(record, attribute)
    unless is == languages
      record.errors[attribute] << (options[:message] || "should also be translated in #{(languages - is).map(&:upcase).to_sentence}")
    end
  end
  
  def validate_length_in_range(record, attribute, range)
    all          = record_attribute_languages(record, attribute)
    in_range     = keys_not_matching(record, attribute){|k,v| !range.include?(v.size) }
    unless all.empty? || all == in_range
      record.errors[attribute] << (options[:message] || "should be between #{range.first} and #{range.last} characters for #{(all - in_range).map(&:upcase).to_sentence}")
    end
  end
  
  def keys_not_matching record, attribute, &block
    not_matching = record_attribute_hash(record, attribute).dup.delete_if &block
    not_matching.keys.sort
  end
  
  def record_attribute_hash record, attribute
    record.send(:"#{attribute}_hash")
  end
  
  def record_attribute_languages record, attribute
    record.send(:"#{attribute}_languages").sort
  end
end