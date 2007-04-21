# = Localized models by using the language file
# 
# This feature provides a way to localize ActiveRecord models based on
# translated model and attribute names in the language file. Where the
# +localized_models+ feature depends on translated names written in the
# source code of the models this feature reads all necessary strings from the
# loaded language file.
# 
# This feature is the right choice if your application should support multiple
# languages, but only one at runtime. If your application is strictly developed
# for just one language +localized_models+ is the better choice.
# 
# To localize a model with this feature just add the necessary section to the
# languge file. How to do this is descriped in the next chapter.
# 
# == Used sections of the language file
# 
# The localized model and attribute names for this feature are located in the
# +models+ section of the language file. The following example localizes the
# +Computer+ model and it's attributes +name+, +description+, +ip_address+ and
# +user+.
# 
#   models:
#     computer:
#       name: Der Computer
#       attributes:
#         name: Der Name
#         description: Die Beschreibung
#         ip_address: Die IP-Adresse
#         user: Der Besitzer
# 
# This feature will convert the name of the model class (+Compuer+) using
# String#underscore (results in +computer+) and will look in the corresponding
# subsection of the +models+ section. Each model section in turn contains the
# name of the model ("Der Computer") and a map translating the model
# attributes.

module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module LocalizedModelsByLangFile
    
    # This method adds the +localized_model_name+ and the
    # +human_attribute_name+ to the ActiveRecord::Base class.
    # 
    # +localized_model_name+ looks for the localized model name in the language
    # file and +human_attribute_name+ looks for the localized attribute names.
    # +localized_model_name+ returns +nil+ if no matching entry could be found.
    # +human_attribute_name+ calls the super method if no entry matches and
    # therefore falls back to Rails default behavior.
    def self.included(base)
      class << self
        
        def localized_model_name
          Language[:models, self.class_name.underscore.to_sym, :name]
        end
        
        def human_attribute_name(attribute_key_name)
          localized_attributes = Language[:models, self.class_name.underscore.to_sym, :attributes]
          localized_attributes ? localized_attributes[attribute_key_name.to_s] : super
        end
        
      end
    end
    
  end
end

ActiveRecord::Base.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedModelsByLangFile