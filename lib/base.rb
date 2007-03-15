# This is the base file of the Simple Localization plugin. It is loaded at
# application startup and defines the +simple_localization+ method which should
# be used in the environment.rb file to configure and initialize the
# localization.
# 
# It also defines the Language class which manages the used language file.

module ArkanisDevelopment #:nodoc:
  module SimpleLocalization #:nodoc:
    
    # This class loads, caches and manages the used language file.
    class Language
      
      @@cached_language_data = nil
      
      cattr_accessor :lang_file_dir, :current_language
      
      # Searches the language file for the specified entry. It's possible to
      # specify neasted entries by using more than one parameter.
      # 
      #   Language[:active_record_messages, :not_a_number] # => "ist keine Zahl."
      # 
      # This will return the +not_a_number+ entry within the +active_record_messages+
      # entry. The YAML in the language file looks like this:
      # 
      #   active_record_messages:
      #     not_a_number: ist keine Zahl.
      # 
      def self.[](*sections)
        unless @@cached_language_data
          raise 'Can not access language data. It seems there is no language ' +
            'file loaded. Please call the simple_localization method at the ' +
            'end of your environment.rb file to initialize Simple Localization.'
        end
        
        sections.inject(@@cached_language_data) do |memo, section|
          memo[(section.kind_of?(Numeric) ? section : section.to_s)] if memo
        end
      end
      
      # Loads a language file and caches it.
      # 
      # The path to the language files can be specified in the +lang_file_dir+
      # attribute. Relative paths will be used as they are but absolute paths
      # will be relative to the root directory of the plugin.
      # 
      #   Language.load :de
      # 
      # This will load the file <code>de.yaml</code> in the language file
      # directory and caches it in the class.
      def self.load(language)
        if self.lang_file_dir.starts_with? '/'
          lang_file_without_ext = File.dirname(__FILE__) + "/..#{self.lang_file_dir}/#{language}"
        else
          lang_file_without_ext = "#{self.lang_file_dir}/#{language}"
        end
        @@cached_language_data = YAML.load_file "#{lang_file_without_ext}.yml"
        require lang_file_without_ext if File.exists?("#{lang_file_without_ext}.rb")
        self.current_language = language
      end
      
      # Returns a hash with the meta data of the language file. Entries not
      # present in the language file will default to +nil+.
      # 
      #   Language.about
      #   # => {
      #          :language => 'Deutsch',
      #          :author => 'Stephan Soller',
      #          :comment => 'Deutsche Sprachdatei. Kann als Basis für neue Sprachdatein dienen.',
      #          :website => 'http://www.arkanis-development.de/',
      #          :email => nil, # happens if no email is specified in the language file.
      #          :date => '2007-01-20'
      #        }
      # 
      def self.about
        defaults = {
          :language => nil,
          :author => nil,
          :comment => nil,
          :website => nil,
          :email => nil,
          :date => nil
        }
        
        defaults.update self[:about].symbolize_keys
      end
      
      # Just a little helper for the date localization (used in the
      # +localized_date_and_time+ feature). Converts arrays into hashes with
      # the array values as keys and their indexes as values. Takes and
      # optional start index which defaults to 0.
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
      #   Language.convert_to_name_indexed_hash :section => [:dates, :abbr_daynames]
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
#   simple_localization :language => :de, :class_based_field_error_proc => fase
# 
# With the <code>:language</code> option you can specify the name of the
# language file (without extension) you want to use. You can also use the
# options to specify if a specific feature (the files inside the +features+
# directory) should be loaded or not. By default all features will be loaded.
# To prevent a feature from beeing loaded you can specify an option with the
# name of the feature and a value of +false+.
# 
# In the example above this prevents the <code>class_based_field_error_proc</code>
# feature (the <code>class_based_field_error_proc.rb</code> file in the
# <code>features</code> directory) from beeing loaded.
# 
# Alternativly you can specify the <code>:exept</code> option with a list of
# features which should not be loaded:
# 
#   simple_localization :language => :de, :except => [:localized_models, :localized_date_and_time]
# 
# This will load all features except the +localized_models+ and
# +localized_date_and_time+ features. The opposite way (only specify features
# which sould be loaded) is also possible by using the <code>:only</code>
# option.
# 
#   simple_localization :language => :de, :only => [:localized_models, :localized_date_and_time]
# 
# This will only load the +localized_models+ and +localized_date_and_time+
# features, ignoring all others.
# 
# If you use this plugin to localize you application (with the
# +localized_application+ feature) it may also come in handy to move the
# directory containing the language files to a more important place. This can
# be done with the <code>:lang_file_dir</code> option:
# 
#   simple_localization :language => :de, :lang_file_dir => "#{RAILS_ROOT}/app/languages", :only => [:localized_application]
#   simple_localization :language => :de, :lang_file_dir => "#/languages", :only => [:localized_application]
# 
# Relative paths are used as they are, absolute paths will be relative to the
# root directory of the Simple Localization plugin. The first example expects
# the language files in the <code>app/languages</code> directory of your rails
# application. The second example is the default value and expects the language
# files in the +languages+ directory of the Simple Localization plugin.
def simple_localization(options)
  available_features = Dir[File.dirname(__FILE__) + '/features/*.rb'].collect{|path| File.basename(path, '.rb').to_sym}
  
  default_options = {:language => 'de', :lang_file_dir => '/languages'}
  default_options = available_features.inject(default_options){|memo, feature| memo[feature.to_sym] = true; memo}
  options = default_options.update(options)
  
  ArkanisDevelopment::SimpleLocalization::Language.lang_file_dir = options.delete(:lang_file_dir)
  ArkanisDevelopment::SimpleLocalization::Language.load(options.delete(:language))
  
  if options[:only]
    enabled_features = available_features & Array(options[:only])
  elsif options[:except]
    enabled_features = available_features - Array(options[:except])
  else
    enabled_features = available_features & options.collect{|feature, enabled| feature if enabled}.compact
  end
  
  enabled_features.each do |feature|
    require File.dirname(__FILE__) + "/features/#{feature}"
  end
end