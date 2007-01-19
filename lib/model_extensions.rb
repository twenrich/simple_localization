module ArkanisDevelopment #:nodoc
  module Localization #:nodoc
    module ModelExtensions #:nodoc
      def self.included(base)
				base.extend ClassMethods
			end
			
			module ClassMethods #:nodoc
        
        def localized_names(model_name, attribute_names = {})
          #logger.info "Simple Localization: extending model class #{self.name}.\n" +
          #  "Model name: #{model_name}\n" +
          #  "Attribute names:\n" + attribute_names.collect{|attr, name| "  #{attr}: #{name}"}.join("\n")
          
          class<<self
            attr_accessor :localized_model_name, :localized_attribute_names
            
            def localized_attribute_name(attr)
              self.localized_attribute_names[attr.to_sym] || human_attribute_name(attr)
            end
          end
          
          self.localized_model_name = model_name
          self.localized_attribute_names = attribute_names
        end
        
			end
		end
	end
end