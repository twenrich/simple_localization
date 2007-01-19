module ArkanisDevelopment #:nodoc
  module SimpleLocalization #:nodoc
    module Helper
      
      def error_messages_for(object_name)
        object = instance_variable_get("@#{object_name}")
        
        return '' unless object and not object.errors.empty?
        
        localized_object_name = object.class.localized_model_name
        error_count = object.errors.count
        unevaled_error_title = object.errors.count == 1 ? ERROR_TITLE_SINGULAR : ERROR_TITLE_PLURAL
        error_title = eval('"' + unevaled_error_title + '"')
        
        error_list = []
        object.errors.each do |attr, msg|
          error_list << content_tag(:li, object.class.localized_attribute_name(attr) + ' ' + msg)
        end
        
        unless block_given?
          content_tag :div,
            content_tag(:p, eval('"' + error_title + '"')) +
            content_tag(:ul, error_list.join("\n")),
            :class => 'error_messages'
        else
          yield error_title, error_list, localized_object_name, error_count
        end
      end
      
    end
  end
end