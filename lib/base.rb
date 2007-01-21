module ArkanisDevelopment
  module SimpleLocalization #:nodoc
    
    # This class loads, caches and manages the language file.
    class Language
      @@cached_language_data = nil
      @@current_language = nil
      
      # Searches the localization file for the specified entry. It's possible to
      # specify neasted entries by using more than one parameter.
      # 
      #   Language[:active_record_messages, :not_a_number] # => "ist keine Zahl."
      # 
      # This will return the not_a_number entry within the active_record_messages
      # entry. The YAML in the language file looks like this:
      # 
      #   active_record_messages:
      #     not_a_number: ist keine Zahl.
      # 
      def self.[](*sections)
        sections.inject(@@cached_language_data) do |memo, section|
          memo[section.to_s]
        end
      end
      
      # Loads a language file and caches it.
      # 
      # The language files can be found in the languages directory of the plugin.
      # 
      #   Language.load :de
      # 
      # This will load the file languages/de.yaml and caches it in the class.
      def self.load(language)
        @@cached_language_data = YAML.load_file(File.dirname(__FILE__) + "/../languages/#{language}.yml")
        @@current_language = language
      end
      
      # Reader method to get the currently loaded language.
      def self.current_language
        @@current_language
      end
      
      # Just a little helper for the date localization (used in the
      # localized_dates feature). Converts arrays into hashes with the array
      # values as keys and their indexes as values. Takes and optional start
      # index.
      # 
      # The source array will be read from the specified section of the language
      # file.
      # 
      # The YAML in the language file:
      # 
      #   dates:
      #     abbr_daynames: [Son, Mon, Din, Mit, Don, Fri, Sam]
      # 
      # The method call:
      # 
      #   Language.convert_to_name_indexed_hash :section => [:dates, abbr_daynames]
      #                                         :start_index => 1
      #   # => {"Son" => 1, "Mon" => 2, "Din" => 3, "Mit" => 4, "Don" => 5, "Fri" => 6, "Sam" => 7}
      # 
      def self.convert_to_name_indexed_hash(options)
        options.assert_valid_keys :section, :start_index
        
        array = self[*options[:section]]
        array.inject({}) do |memo, day_name|
          memo[day_name] = array.index(day_name) + (options[:start_index] || 0)
          memo
        end
      end
      
    end
    
  end
end

# The main method of the SimpleLocalization plugin used to initialize and
# configure the plugin. Usually it is called in the environment.rb file.
# 
#   simple_localization :language => 'de', :class_based_field_error_proc => fase
# 
# The +:language+ option specifies the name of the language file you want to
# use. You can also use the options to specify if a specific feature (the files
# inside the feature directory) should be loaded or not. By default all
# features will be loaded. To prevent a feature from beeing loaded you can
# specify an option with the name of the featur and a value of +false+.
# 
# In the example above this prevents the "class_based_field_error_proc" feature
# (the class_based_field_error_proc.rb file in the features directory) from
# beeing loaded.
# 
# Alternativly you can specify the :exept option with a list of features which
# should not be loaded:
# 
#   simple_localization :language => 'de', :except => [:localized_models, :localized_strftime]
# 
# This will load all features except the "localized_models" and
# "localized_strftime" features. The opposite way (only specify features which
# sould be loaded) is also possible. Use the :only option for this.
# 
#   simple_localization :language => 'de', :only => [:localized_dates, :localized_models]
# 
# This will only load the "localized_dates" and "localized_models" features,
# ignoring all others.
def simple_localization(options)
  available_features = Dir[File.dirname(__FILE__) + '/features/*.rb'].collect{|path| File.basename(path, '.rb').to_sym}
  default_options = available_features.inject({:language => 'de'}){|memo, feature| memo[feature.to_sym] = true; memo}
  options = default_options.update(options)
  
  language = options.delete :language
  ArkanisDevelopment::SimpleLocalization::Language.load language
  
  if options[:only]
    enabled_features = available_features & Array(options[:only])
  elsif options[:except]
    enabled_features = available_features - Array(options[:except])
  else
    enabled_features = options.collect{|feature, enabled| feature if enabled}.compact
  end
  
  enabled_features.each do |feature|
    require File.dirname(__FILE__) + "/features/#{feature}"
  end
end