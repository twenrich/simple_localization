require 'singleton'

module ArkanisDevelopment #:nodoc:
  module SimpleLocalization #:nodoc:
    
    SUPPRESS_FEATURES ||= []
    
    class FeatureManager
      include Singleton
      
      def initialize
        @all_features = read_available_features
        @plugin_init_features = []
        @disabled_features = SUPPRESS_FEATURES
      end
      
      # Mark the specified features for preload, meaning it's necessary to load
      # them during plugin initialization.
      def preload(*features)
        @plugin_init_features.concat features
      end
      
      # Disable the specified features. This removes the these features from the
      # list of available features and from the list of features to preload.
      def disable(*features)
        @disabled_features.concat features
      end
      
      # Returns all available features.
      def all_features
        @all_features
      end
      
      # Returns the features that are requested to be loaded during plugin
      # initialization.
      def plugin_init_features
        @plugin_init_features - @disabled_features
      end
      
      # Returns the features that can be loaded  
      def localization_init_features
        @all_features - @disabled_features
      end
      
      private
      
      def read_available_features
        Dir[File.dirname(__FILE__) + '/features/*.rb'].collect { |path| File.basename(path, '.rb').to_sym }
      end
      
    end
    
  end
end
