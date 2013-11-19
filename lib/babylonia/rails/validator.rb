class LanguagesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if options[:present]
      is     = record.send(:"#{attribute}_hash").delete_if{|k,v| v.empty? }.keys.sort
      should = options[:present].sort
      unless is == should
        record.errors[attribute] << (options[:message] || "should also be translated in #{(should - is).map(&:upcase).to_sentence}")
      end
    end
    
    if options[:length].is_a?(Range)
      all          = record.send(:"#{attribute}_hash").keys.sort
      in_range     = record.send(:"#{attribute}_hash").dup.delete_if{|k,v| !options[:length].include?(v.size) }.keys.sort
      unless all.empty? || all == in_range
        record.errors[attribute] << (options[:message] || "should be between #{options[:length].first} and #{options[:length].last} characters for #{(all - in_range).map(&:upcase).to_sentence}")
      end
    end
  end
end