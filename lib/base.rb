# This is the base file of the Simple Localization plugin. It is loaded at
# application startup and defines the +simple_localization+ method which should
# be used in the environment.rb file to configure and initialize the
# localization.

module ArkanisDevelopment #:nodoc:
  module SimpleLocalization #:nodoc:
    
    # An array of features which should not be preloaded. If this constant is
    # already defined it will not be overwritten. This provides a way to
    # exclude features from preloading. You'll just have to define this
    # constant by yourself before the Rails::Initializer.run call in your
    # environment.rb file.
    begin
      SUPPRESS_FEATURES
    rescue NameError
      SUPPRESS_FEATURES = []
    end
    
    # A list of features loaded directly in the <code>init.rb</code> of the
    # plugin. This is necessary for some features to work with rails observers.
    PRELOAD_FEATURES = [:localized_models] - Array(SUPPRESS_FEATURES).flatten
    
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
  
  default_options = {
    :language => :de,
    :languages => nil,
    :lang_file_dir => "#{File.dirname(__FILE__)}/../languages",
    :debug => nil
  }
  default_options = available_features.inject(default_options){|memo, feature| memo[feature.to_sym] = true; memo}
  options = default_options.update(options)
  languages = [options.delete(:languages), options.delete(:language)].flatten.compact.uniq
  
  unless options[:debug].nil?
    ArkanisDevelopment::SimpleLocalization::Language.debug = options[:debug]
  else
    ArkanisDevelopment::SimpleLocalization::Language.debug = (ENV['RAILS_ENV'] != 'production')
  end
  
  ArkanisDevelopment::SimpleLocalization::Language.lang_file_dir = options.delete(:lang_file_dir)
  ArkanisDevelopment::SimpleLocalization::Language.load(languages)
  
  if options[:only]
    enabled_features = available_features & Array(options[:only])
  elsif options[:except]
    enabled_features = available_features - Array(options[:except])
  else
    enabled_features = available_features & options.collect{|feature, enabled| feature if enabled}.compact
  end
  
  preloaded_features = ArkanisDevelopment::SimpleLocalization::PRELOAD_FEATURES
  suppressed_features = Array(ArkanisDevelopment::SimpleLocalization::SUPPRESS_FEATURES)
  unwanted_features = preloaded_features - enabled_features
  to_load_features = enabled_features - preloaded_features - suppressed_features
  
  unless unwanted_features.empty?
    RAILS_DEFAULT_LOGGER.warn "Simple Localization plugin configuration:\n" +
      "  You don't want the feature #{unwanted_features.join(', ')} to be loaded.\n" +
      "  However to work with rails observers these features are loaded at the end of the plugins init.rb.\n" +
      '  To suppress a preloaded feature please look into the plugins readme file (chapter "Preloaded features").'
  end
  
  to_load_features.each do |feature|
    require File.dirname(__FILE__) + "/features/#{feature}"
  end
  
  loaded_features = (enabled_features + preloaded_features).uniq
  
  RAILS_DEFAULT_LOGGER.debug "Initialized Simple Localization plugin:\n" +
    "  language: #{languages.join(', ')}, lang_file_dir: #{ArkanisDevelopment::SimpleLocalization::Language.lang_file_dir}\n" +
    "  features: #{loaded_features.join(', ')}"
  
  loaded_features
end
