# Extends Active Recrod model with the ability to store localization
# informations.

module ArkanisDevelopment::SimpleLocalization #:nodoc
  module ActiveRecordExtensions #:nodoc
    
    def self.included(base)
      base.extend ClassMethods
    end
    
		module ClassMethods #:nodoc
      
      # This method is used to add localization information to a model. As the
      # first parameter the localized model name is expected. The second
      # parameter is a hash of attribute names, each specifying the localized
      # name of the attribute.
      # 
      # This example adds german names to the model and it's attributes.
      # 
      #   class Computer < ActiveRecord::Base
      #     belongs_to :user
      #     
      #     validates_presence_of :name, :ip_address, :user
      #     
      #     localized_names 'Der Computer',
      #       :name => 'Der Name',
      #       :description => 'Die Beschreibung',
      #       :ip_address => 'Die IP-Adresse',
      #       :user => 'Der Besitzer'
      #     
      #   end
      # 
      # These names will be used by the extended error_messages_for helper to
      # construct the corresponding error messages.
      # 
      # To access the localized model name use the class method
      # +localized_model_name+. The +human_attribute_name+ method will also be
      # overwritten so you'll get the localized names from it if available.
    
      def localized_names(model_name, attribute_names = {})
        class<<self
          attr_accessor :localized_model_name, :localized_attribute_names
          
          def human_attribute_name(attribute_key_name)
            self.localized_attribute_names[attribute_key_name.to_sym] || super
          end
        end
        
        self.localized_model_name = model_name
        self.localized_attribute_names = attribute_names
      end
      
		end
		
	end
end

ActiveRecord::Base.send :include, ArkanisDevelopment::SimpleLocalization::ActiveRecordExtensions