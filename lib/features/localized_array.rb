# Localizes the +to_sentence+ method of the Array class by loading the default
# options from the language file.

class Array
  
  def to_sentence(options = {})
    options = ArkanisDevelopment::SimpleLocalization::Language[:arrays, :to_sentence].symbolize_keys.update(options)
    super options
  end
  
end