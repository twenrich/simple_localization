module ArkanisDevelopment::SimpleLocalization #:nodoc
  
  class Configuration
    @@config = {
      :language => 'de',
      :class_based_field_error_proc => true
    }
    
    def self.[](option)
      @@config[option.to_sym]
    end
    
    def self.update(new_config)
      @@config.merge!(new_config.symbolize_keys)
    end
  end
  
  class Language
    @@cached_lang_file = {}
    @@current_lang_code = nil
    
    def self.[](*sections)
      sections.inject(@@cached_lang_file) do |memo, section|
        memo = memo[section.to_s]
      end
    end
    
    def self.load(lang_code)
      @@cached_lang_file = YAML.load_file(File.dirname(__FILE__) + '/../languages/#{lang_code}.yml')
      @@current_lang_code = lang_code
    end
  end
  
end

def simple_localization(options = {})
  options.assert_valid_keys(:language, :class_based_field_error_proc)
  ArkanisDevelopment::SimpleLocalization::Configuration.update(options)
end