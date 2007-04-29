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
    # +human_attribute_name+ to the ActiveRecord::Base class. The original
    # +human_attribute_name+ is still available as +human_attribute_name_without_localization+.
    # 
    # +localized_model_name+ returns the localized model name from the language
    # file. If no localized name is available +nil+ is returned.
    # 
    # The new +human_attribute_name+ looks for the localized name of the
    # attribute. If the language file does not contain a matching entry the
    # requrest will be redirected to the original +human_attribute_name+ method.
    # 
    # Note: since we are extending ActiveRecord::Base it's possible to call both
    # methods directly on the base class (the +scaffold+ method does this indirectly
    # on the +human_attribute_name+ method using Column#human_name). In this case we
    # simply don't know which table or model we belong to and therefore we can't
    # access the localized data. To prevent error messages in this situation
    # ("undefined method `abstract_class?' for Object:Class" because Base#table_name
    # doesn't work here) +localized_model_name+ returns +nil+ and
    # +human_attribute_name+ delegates the request to it's former non localized
    # version (which doesn't need to know the table name because it simply asks the
    # Inflector).
    def self.included(base)
      class << base
        
        def localized_model_name
          return nil if self == ActiveRecord::Base
          Language[:models, self.class_name.underscore.to_sym, :name]
        end
        
        alias_method :human_attribute_name_without_localization, :human_attribute_name
        
        def human_attribute_name(attribute_key_name)
          return human_attribute_name_without_localization(attribute_key_name) if self == ActiveRecord::Base
          localized_attributes = Language[:models, self.class_name.underscore.to_sym, :attributes] || {}
          localized_attributes[attribute_key_name.to_s] || human_attribute_name_without_localization(attribute_key_name)
        end
        
      end
    end
    
  end
end

# This little bit of code is necessary to get this feature and scaffold to
# work together. By default the default input block would call the columns
# +human_name+ method to get the display name of the column. Sadly this method
# calls the +human_attribute_name+ method direclty on the ActiveRecord::Base
# class.
# 
# Usually this won't be a problem because without localization the
# +human_attribute_name+ method simply asks the Inflector for the name and does
# not need such fancy things as the table name or the model class. However with
# localization we need the name of the model class to get the localized data
# out of the language file. So this is a problem.
# 
# To solve this the following code patches the +all_input_tags+ and
# +default_input_block+ methods of the +ActiveRecordHelper+ module in a way
# that allows access to the model class and thus the localization data.
module ActionView::Helpers::ActiveRecordHelper
    
    private
    
    alias_method :all_input_tags_without_localization, :all_input_tags
    alias_method :default_input_block_without_localization, :default_input_block
    
    # To get this feature and scaffold to work together we need this method to
    # pass the real record object to the default input block (which in turn
    # needs this objects class to access the localized data).
    # 
    # To make this as painless as possible the method now also accepts blocks
    # which take 3 parameters. The third parameter is the real record object.
    def all_input_tags(record, record_name, options)
      input_block = options[:input_block] || default_input_block
      if input_block.arity == 2
        record.class.content_columns.collect{ |column| input_block.call(record_name, column) }.join("\n")
      else
        record.class.content_columns.collect{ |column| input_block.call(record_name, column, record) }.join("\n")
      end
    end
    
    # Set a new default input block for the +all_input_tags+ method. This block
    # accepts the third (+record+ object) parameter and uses it to access the
    # localized data of the records class.
    def default_input_block
      Proc.new { |record_name, column, record| %(<p><label for="#{record_name}_#{column.name}">#{record.class.human_attribute_name(column.name)}</label><br />#{input(record_name, column.name)}</p>) }
    end
    
end

ActiveRecord::Base.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedModelsByLangFile