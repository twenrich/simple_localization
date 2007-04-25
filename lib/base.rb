
# This is the base file of the Simple Localization plugin. It is loaded at
# application startup and defines the +simple_localization+ method which should
# be used in the environment.rb file to configure and initialize the
# localization.
# 
# It also defines the Language class which manages the used language file.

module ArkanisDevelopment #:nodoc:
  module SimpleLocalization #:nodoc:
    
    # This class loads, caches and manages the used language files.
    class Language
      
      @@cached_language_data = {}
      
      cattr_accessor :lang_file_dir, :current_language, :loaded_languages
      
      # Searches the language file for the specified entry. It's possible to
      # specify neasted entries by using more than one parameter.
      # 
      #   Language[:active_record_messages, :not_a_number] # => "ist keine Zahl."
      # 
      # This will return the +not_a_number+ entry within the +active_record_messages+
      # entry. The YAML code in the language file looks like this:
      # 
      #   active_record_messages:
      #     not_a_number: ist keine Zahl.
      # 
      def self.[](*args)
        if args.last.kind_of?(Array)
          format_args = args.delete_at(-1)
          sections = args
          format(self.entry(self.current_language, *sections), format_args)
        else
          sections = args
          self.entry(self.current_language, *sections)
        end
      end
      
      def self.entry(language, *sections)
        if @@cached_language_data.empty? or not @@cached_language_data[language]
          raise 'Can not access language data. It seems the selected language ' +
            "#{language}' is not loaded. Please call the simple_localization " +
            'method at the end of your environment.rb file to initialize ' +
            'Simple Localization or modify this call to include the selected ' +
            'language.'
        end
        
        sections.inject(@@cached_language_data[language]) do |memo, section|
          memo[(section.kind_of?(Numeric) ? section : section.to_s)] if memo
        end
      end
      
      # Loads the specified language files, caches them and selects the first
      # one as the active language.
      # 
      # The path to the language files can be specified in the +lang_file_dir+
      # attribute.
      # 
      #   Language.load :de, :en
      # 
      # This will load the files <code>de.yaml</code> and <code>en.yaml</code>
      # in the language file directory and caches them in a class variable. It
      # also selects <code>:de</code> as the active language.
      def self.load(*languages)
        languages.each do |language|
          lang_file_without_ext = "#{self.lang_file_dir}/#{language}"
          @@cached_language_data[language.to_sym] = YAML.load_file "#{lang_file_without_ext}.yml"
          require lang_file_without_ext if File.exists?("#{lang_file_without_ext}.rb")
        end
        self.current_language = languages.first
      end
      
      # Changes the used language by loading the specified language file (using
      # the +load+ method). It also asks all features to update the ncessary
      # stuff.
      # 
      # You should use this method if you want to switch the localized language
      # at runtime.
      def self.switch_to(language)
        self.load(language)
        Features.update
        RAILS_DEFAULT_LOGGER.info "Changed Simple Localization language to '#{language}'"
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
    
    # This little thing is a big part of the magic of doing things behind Rails
    # back. Basically it mimics an variable (ie. number, array, hash, ...) by
    # redirecting all calls to it. The target object will be accessed by the
    # Language#[] accessor and therefore will always return the data for the
    # currently selcted language without replacing the proxy object.
    # 
    # This is useful if Rails stors the target data only in a constant. With
    # this proxy the constant can be replaced once (with a proxy) and will
    # always return the language data of the currently selected language.
    class LangSectionProxy
      
      # Read the specified options and save them to the instance variables.
      # You can specify a block if you want to combine the original data with
      # the localized one (ie. merging the old data with the localized data).
      def initialize(options, &transformation)
        default_options = {:sections => nil, :orginal_receiver => nil, :mock_lang_data => nil}
        options.reverse_merge! default_options
        options.assert_valid_keys default_options.keys
        
        @sections = options[:sections]
        @orginal_receiver = options[:orginal_receiver]
        @mock_lang_data = options[:mock_lang_data]
        @transformation = transformation
      end
      
      # Generates the receiver which will receive the messages.
      def receiver
        receiver = @mock_lang_data || Language[*@sections]
        receiver = @transformation.call receiver, @orginal_receiver if @transformation.respond_to?(:call)
        receiver
      end
      
      # Intercept all messages and send them to the receiver.
      def method_missing(name, *args)
        self.receiver.send name, *args
      end
      
    end
    
    class CachedLangSectionProxy < LangSectionProxy
      
      @@instances = []
      
      def self.clear_caches
        @@instances.each{|instance| instance.clear_cache}
      end
      
      @cached_targets = {}
      
      def initialize(*lang_file_sections)
        super
        @@instances << self
      end
      
      def clear_cache
        @cached_targets = {}
      end
      
      def receiver
        cached = @cached_targets[Language.current_language]
        (cached || (@cached_targets[Language.current_language] = Language[*@lang_file_sections])).send name, *args
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
# 
# This example expects the language files in the <code>app/languages</code>
# directory of your rails application. By default the language files are
# located in the +languages+ directory of the Simple Localization plugin.
def simple_localization(options)
  available_features = Dir[File.dirname(__FILE__) + '/features/*.rb'].collect{|path| File.basename(path, '.rb').to_sym}
  
  default_options = {:language => 'de', :lang_file_dir => "#{File.dirname(__FILE__)}/../languages"}
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
  
  ArkanisDevelopment::SimpleLocalization::Features.update
  
  RAILS_DEFAULT_LOGGER.debug "Initialized Simple Localization plugin:\n" +
    "  language: #{ArkanisDevelopment::SimpleLocalization::Language.current_language}, lang_file_dir: #{ArkanisDevelopment::SimpleLocalization::Language.lang_file_dir}\n" +
    "  features: #{enabled_features.join(', ')}"
end
