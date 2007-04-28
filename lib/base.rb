# This is the base file of the Simple Localization plugin. It is loaded at
# application startup and defines the +simple_localization+ method which should
# be used in the environment.rb file to configure and initialize the
# localization.

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
  
  RAILS_DEFAULT_LOGGER.debug "Initialized Simple Localization plugin:\n" +
    "  language: #{ArkanisDevelopment::SimpleLocalization::Language.current_language}, lang_file_dir: #{ArkanisDevelopment::SimpleLocalization::Language.lang_file_dir}\n" +
    "  features: #{enabled_features.join(', ')}"
end
