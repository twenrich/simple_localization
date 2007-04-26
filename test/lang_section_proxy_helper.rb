class LanguageMock
  
  @@data = {}
  cattr_accessor :data
  
  @@current_language = :en
  cattr_accessor :current_language
  
  def self.[](*args)
    @@data[@@current_language]
  end
  
  def self.current_lang_data=(new_data)
    @@data[@@current_language] = new_data
  end
  
  def self.current_lang_data
    @@data[@@current_language]
  end
  
end