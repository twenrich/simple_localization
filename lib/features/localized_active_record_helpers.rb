# = Localized ActiveRecord helpers
# 
# Overwrites the default +error_messages_for+ helper with an localized version
# which reads the header and description paragraph from the language file. The
# error messages itself are localized by the +localized_models+ and
# +localized_error_messages+ features.
# 
# It also gives you the possibility to define your own way of generating
# the HTML output by specifying a block:
# 
#   error_messages_for :record do |objects, header_message, description, error_messages, localized_object_name, count|
#     content_tag(:p, header_message) +
#     content_tag(:ul, error_messages.collect{|msg| content_tag :li, msg}.join("\n"))
#   end
# 
# == Used sections of the language file
# 
# This feature uses the +error_messages_for+ section inside the +helpers+
# section of the language file:
# 
#   helpers:
#     error_messages_for:
#       heading:
#         1: '1 error prohibited this %s from being saved'
#         n: '%d errors prohibited this %s from being saved'
#       description: 'There were problems with the following fields:'
# 
# To make the pluralization of the heading easier you can specify an entry for
# every number of errors. If there is no matching entry for the current error
# count the +n+ entry will be used. The description paragraph is just a simple
# sentence.

module ArkanisDevelopment::SimpleLocalization #:nodoc
  module ActiveRecordHelper #:nodoc
    
    # Provides a localized version of the +error_messages_for+ helper. This
    # helper just localizes the heading and first paragraph of the error box.
    # The error messages itself are localized by the +localized_models+ and
    # +localized_error_messages+ features.
    # 
    # It also gives you the possibility to define your own way of generating
    # the HTML output by specifying a block:
    # 
    #   error_messages_for :record do |objects, header_message, description, error_messages, localized_object_name, count|
    #     content_tag(:p, header_message) +
    #     content_tag(:ul, error_messages.collect{|msg| content_tag :li, msg}.join("\n"))
    #   end
    # 
    def error_messages_for(*params)
      options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
      count   = objects.inject(0) {|sum, object| sum + object.errors.count }
      
      unless count.zero?
        html = {}
        
        [:id, :class].each do |key|
          if options.include?(key)
            value = options[key]
            html[key] = value unless value.blank?
          else
            html[key] = 'errorExplanation'
          end
        end
        
        lang = Language[:helpers, :error_messages_for].symbolize_keys
        localized_object_name = if options[:object_name]
          options[:object_name]
        elsif objects.first.class.respond_to?(:localized_model_name)
          objects.first.class.localized_model_name
        else
          params.first.to_s.gsub('_', ' ')
        end
        
        header_message_mask = lang[:heading][count] || lang[:heading]['n']
        header_message = format header_message_mask, count, localized_object_name
        description = lang[:description]
        error_messages = objects.collect{|object| object.errors.full_messages}.flatten
        
        unless block_given?
          content_tag(:div,
            content_tag(options[:header_tag] || :h2, header_message) <<
              content_tag(:p, description) <<
              content_tag(:ul, error_messages.collect{|msg| content_tag(:li, msg)}.join("\n")),
            html
          )
        else
          yield objects, header_message, description, error_messages, localized_object_name, count
        end
      else
        ''
      end
    end
    
  end
end

ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::ActiveRecordHelper