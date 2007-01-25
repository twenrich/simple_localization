# Overwrites the default +error_messages_for+ helper with an localized version.

module ArkanisDevelopment::SimpleLocalization #:nodoc
  module ActiveRecordHelper #:nodoc
    
    # Provides a localized version of the +error_messages_for+ helper. This
    # helper just localizes the first paragraph of the error box. The error
    # messages are localized by the +localize_models+ feature.
    # 
    # This helper returns a slightly more universal HTML code than the original
    # did:
    # 
    #   <div class="error_messages">
    #     <p>Das Objekt konnte wegen einem Fehler nicht gespeichert werden.</p>
    #     <ul>
    #       <li>Der Name darf nicht leer sein.</li>
    #     </ul>
    #   </div>
    # 
    # If this doesn't fit your purpose you can specify a block which defines
    # the output of the helper:
    # 
    #   error_messages_for :record do |object, error_title, error_messages, localized_object_name, error_count|
    #     content_tag(:p, error_title) +
    #     content_tag(:ul, error_messages.collect{|msg| content_tag :li, msg}.join("\n"))
    #   end
    # 
    def error_messages_for(object_name)
      object = instance_variable_get("@#{object_name}")
      
      return '' unless object and not object.errors.empty?
      
      localized_object_name = object.class.localized_model_name
      error_count = object.errors.count
      
      localization_string = object.errors.count == 1 ? :singular : :plural
      error_title = format(Language[:helpers, :error_messages_for, localization_string], h(localized_object_name), error_count)
      
      error_messages = []
      object.errors.each do |attr, msg|
        error_messages << object.class.human_attribute_name(attr) + ' ' + msg
      end
      
      unless block_given?
        content_tag :div,
          content_tag(:p, error_title) +
          content_tag(:ul, error_messages.collect{|msg| content_tag :li, msg}.join("\n")),
          :class => 'error_messages'
      else
        yield object, error_title, error_messages, localized_object_name, error_count
      end
    end
    
  end
end

ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::ActiveRecordHelper