# = Localized application
# 
# This feature allows you to use the language file to localize your
# application. You can add your own translation strings to the +app+ section of
# the language file and read them with the +l+ global method. You can use this
# method in your controllers, views, mail templates, simply everywhere.
# 
#   app:
#     title: Simple Localization Rails plugin
#     subtitle: The plugin should make it much easier to localize Ruby on Rails
#     headings:
#       wellcome: Wellcome to the RDoc Documentation of this plugin
# 
#   l(:title) # => "Simple Localization Rails plugin"
#   l(:headings, :wellcome) # => "Wellcome to the RDoc Documentation of this plugin"
# 
# The +l+ method is just like the 
# ArkanisDevelopment::SimpleLocalization::Language#entry method but is limited
# to the +app+ section of the language file.
# 
# To save some work you can narrow down the scope of the +l+ method even
# further by using the +l_scope+ method:
# 
#   app:
#     layout:
#       nav:
#         main:
#           home: Homepage
#           contact: Contact
#           login: Login
# 
#   l :layout, :nav, :main, :home     # => "Homepage"
#   l :layout, :nav, :main, :contact  # => "Contact"
# 
# Same as
# 
#   l_scope :layout, :nav, :main do
#     l :home     # => "Homepage"
#     l :contact  # => "Contact"
#   end
# 
# Please note that it is NOT possible to nest scopes. Each call to +l_scope+
# will overwrite the last scope. When used with a block +l_scope+ will restore
# the previous scope after the block was executed.
# 
# == Used sections of the language file
# 
# This feature uses the +app+ section of the language file. This section is
# reserved for localizing your application and you can create entries in
# this section just as you need it.
# 
#   app:
#     index:
#       title: Wellcome to XYZ
#       subtitle: Have a nice day...
#     projects:
#       title: My Projects
#       subtitle: This is a list of projects I'm currently working on
# 
#   l(:index, :title) # => "Wellcome to XYZ"
#   l(:projects, :subtitle) # => "This is a list of projects I'm currently working on"
# 

module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module LocalizedApplication #:nodoc:
    
    # This module will extend the ArkanisDevelopment::SimpleLocalization::Language
    # class with all necessary class methods.
    module Language
      
      # Class variable to hold the current scope for the +app+ method.
      @@app_scope = []
      
      # The +app+ class method will act like the
      # ArkanisDevelopment::SimpleLocalization::Language#[] operator but
      # restricts the scope on the +app+ section of the language file. The
      # method should be used for application localization and therefor there
      # is no need to access other sections of the language file with this
      # method.
      # 
      #   app:
      #     index:
      #       title: Wellcome to XYZ
      #       subtitle: Have a nice day...
      # 
      #   Language.app(:index, :subtitle) # => "Have a nice day..."
      # 
      # You can restrict the scope even further by using the +app_with_scope+
      # method.
      # 
      #   Language.app_with_scope :index
      #   Language.app :subtitle # => "Have a nice day..."
      # 
      def app(*params)
        @@app_scope ||= []
        self.entry(:app, *(@@app_scope + params)) || self.entry(:app_default_value)
      end
      
      # Narrows down the scope of the +app+ method. Useful if you have a very
      # nested language file:
      # 
      #   app:
      #     layout:
      #       nav:
      #         main:
      #           home: Homepage
      #           contact: Contact
      #           about: About
      # 
      # Usually the calls to the +app+ method would look like this:
      # 
      #   Language.app :layout, :nav, :main, :home     # => "Homepage"
      #   Language.app :layout, :nav, :main, :contact  # => "Contact"
      #   Language.app :layout, :nav, :main, :about    # => "About"
      # 
      # In this situation you can use +app_with_scope+ to save some work:
      # 
      #   Language.app_with_scope :layout, :nav, :main do
      #     Language.app :home     # => "Homepage"
      #     Language.app :contact  # => "Contact"
      #     Language.app :about    # => "About"
      #   end
      # 
      # Every call to the +app+ method inside the block will automaticaly
      # prepended with the language file sections you specified to
      # +app_with_scope+.
      # 
      # PLEASE NOTE: It's currently not possible to nest +app_with_scope+
      # calls. If no block is specified the scope will be set directly and you
      # will have to reset it by your own.
      def app_with_scope(*scope_sections)
        if block_given?
          old_scope = @@app_scope
          @@app_scope = scope_sections
          yield
          @@app_scope = old_scope
        else
          @@app_scope = scope_sections
        end
      end
      
    end
    
    # This module defines global helper methods and therefor will be
    # included into the Object class.
    module GlobalHelpers
      
      # Defines a global shortcut for the Language#app method.
      def l(*sections)
        ArkanisDevelopment::SimpleLocalization::Language.app(*sections)
      end
      
      # The global shortcut for the Language#app_with_scope method.
      def l_scope(*sections, &block)
        ArkanisDevelopment::SimpleLocalization::Language.app_with_scope(*sections, &block)
      end
      
    end
    
    # Localization helpers for the use in controllers only. This module will be
    # mixed into ActionController::Base.
    module ControllerHelpers
      
      # A more specialized version of the <code>GlobalHelpers#l</code> method
      # which returns the localization information at the specified sections
      # but prefixes the sections with the name of the current controller and
      # action.
      # 
      # The main purpose of this method is to avoid unnecessary repeatition of
      # parameters to the <code>GlobalHelpers#l</code> method.
      # 
      # Assume this language file data:
      # 
      #   app:
      #     about:
      #       index:
      #         title: About...
      # 
      # and that we are in the +index+ action of the +about+ controller:
      # 
      #   lc :title # => 'About...'
      #   l :about, :index, :title # => 'About...'
      # 
      def lc(*sections)
        ArkanisDevelopment::SimpleLocalization::Language.app(*([self.controller_name, self.action_name] + sections))
      end
      
    end
    
    # Localization helpers for use in templates only. This module will be mixed
    # into ActionView::Base.
    module TemplateHelpers
      
      # A more specialized version of the <code>GlobalHelpers#l</code> method
      # which returns the localization information at the specified sections
      # but prefixes the sections with the name of the current template.
      # 
      # The main purpose of this method is to avoid unnecessary repeatition of
      # parameters to the <code>GlobalHelpers#l</code> method.
      # 
      # Assume this language file data:
      # 
      #   app:
      #     about:
      #       index:
      #         title: About...
      # 
      # and that we are in the <code>app/views/about/index.rhtml</code>
      # template:
      # 
      #   lc :title # => 'About...'
      #   l :about, :index, :title
      # 
      # Please not that the leading underscore of partial templates is removed.
      # In the template <code>app/view/shared/_message.rhtml</code> the +lc+
      # method will prefix the sections with <code>:app, :shared,
      # :message</code>.
      # 
      def lc(*sections)
        current_template = path_and_extension(template_name).first
        dir, file = File.split(current_template)
        prefix_sections = dir.split '/'
        prefix_sections << file.gsub(/^_/, '')
        ArkanisDevelopment::SimpleLocalization::Language.app(*(prefix_sections + sections))
      end
      
      # Returns the name of the template (relative to the ActionView base dir)
      # from which this method is called.
      # 
      # The call stack is used to get information about the current template.
      # This is not the perfect way but currently the simplest and fastest.
      # 
      # Called in app/views/about/index.rhtml:
      # 
      #   <%= template_name %> # => about/index.rhtml
      # 
      # Called in the partial template app/views/shared/_message.rhtml
      # 
      #   <%= template_name %> # => shared/_messages.rhtml
      # 
      def template_name
        template_path = caller.detect{|level| level.slice @base_path}
        template_path.slice Regexp.new(".*#{Regexp.escape(@base_path)}/(.*)\\:\\d+.*"), 1
      end
      
    end
    
  end
end

ArkanisDevelopment::SimpleLocalization::Language.send :extend, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::Language
Object.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::GlobalHelpers
ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::TemplateHelpers
ActionController::Base.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::ControllerHelpers