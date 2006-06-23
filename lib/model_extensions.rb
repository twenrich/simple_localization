module ArkanisDevelopment #:nodoc
	module Localization #:nodoc
		module ModelExtensions #:nodoc
			def self.append_features(base)
				super
				base.extend ClassMethods
			end
			
			module ClassMethods #:nodoc
				@@localized_model_name = 'Das Objekt'
				@@localized_attribute_names = Hash.new
				
				def localized_attribute_names(attribute_names = nil)
					@@localized_attribute_names = Hash.new if not @@localized_attribute_names
					
					if attribute_names
						@@localized_attribute_names.update(attribute_names)
					else
						@@localized_attribute_names
					end
				end
				
				def localized_model_name(name = nil)
					name ? @@localized_model_name = name : @@localized_model_name
				end
				
				def localized_name_for(attribute = nil)
					attribute = attribute.to_sym if attribute.is_a?(String)
					if attribute
						self.localized_attribute_names[attribute]
					else
						self.localized_model_name
					end
				end
			end
		end
	end
end