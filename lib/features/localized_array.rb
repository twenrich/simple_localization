class Array
  
  alias :to_sentence_without_localization :to_sentence
  
  def to_sentence(options = {})
    options = Language[:arrays, :to_sentence].symbolize_keys.update(options)
    super number, options
  end
  
end