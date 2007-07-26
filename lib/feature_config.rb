# This file contains the default configuration for the features and plugin
# options. It creates the necessary constants to disable preloaded features and
# maintains the list of features which need to be preloaded. It also does some
# environment specific setup stuff.

require File.dirname(__FILE__) + '/language'

module ArkanisDevelopment #:nodoc:
  module SimpleLocalization
    
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
    
    # Remove the reload_lang_file feature from the loading list if we're not in
    # the development environment. This feature eats some performance so it
    # should only be used when it's useful and disabled otherwise.
    if ENV['RAILS_ENV'] != 'debug'
      Language.features -= [:reload_lang_file]
    end
    
    # Set the debug option to true for the development and test environments.
    # Debug mode will raise nice entry format errors (see localized_application
    # feature) which exactly show whats wrong with an entry. However in a
    # production environment we should avoid these nice HTTP 500 errors...
    if ENV['RAILS_ENV'] != 'production'
      Language.debug = true
    end
    
  end
end
