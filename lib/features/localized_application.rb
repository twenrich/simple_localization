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
      
      # Class variable to hold the scope stack of the +app_with_scope+ method.
      @@app_scope_stack = []
      
      # Basically the same as the +app_not_scoped+ method but +app_scoped+ does
      # respect the scope set by the +app_with_scope+ method.
      # 
      # Assuming the following language file data:
      # 
      #   app_default_value: No translation available
      #   app:
      #     index:
      #       title: Welcome to XYZ
      #       subtitle: Have a nice day...
      # 
      # The following code would output:
      # 
      #   Language.app_with_scope :index do
      #     Language.app_scoped :title            # => "Welcome to XYZ"
      #     Language.app_scoped :subtitle         # => "Have a nice day..."
      #     Language.app_scoped "I don't exist"   # => "I don't exist"
      #   end
      #   
      #   Language.app_scoped :index, :title    # => "Welcome to XYZ"
      #   Language.app_scoped :not_existing_key # => "No translation available"
      # 
      def app_scoped(*keys)
        self.app_not_scoped(*(@@app_scope_stack.flatten + keys))
      end
      
      # This class method is used to access entries used by the localized
      # application feature. Since the +app+ section of the language file is
      # reserved for this feature this method restricts the scope of the entries
      # available to the +app+ section. The method should only be used for
      # application localization and therefor there is no need to access other
      # sections of the language file with this method.
      # 
      #   app_default_value: No translation available
      #   app:
      #     index:
      #       title: Welcome to XYZ
      #       subtitle: Have a nice day...
      # 
      #   Language.app_not_scoped(:index, :subtitle) # => "Have a nice day..."
      # 
      # If the specified entry does not exists a default value is returned. If
      # the last argument specified is a string this string is returned as
      # default value. Assume the same language file data as above:
      # 
      #   Language.app_not_scoped(:index, "Welcome to my app") # => "Welcome to my app"
      # 
      # The <code>"Welcome to my app"</code> entry doesn't exists in the
      # language file. Because the last argument is a string it will returned as
      # a default value. If the last argument isn't a string the method will
      # return the +app_default_value+ entry of the language file. Again, same
      # language file data as above:
      # 
      #   Language.app_not_scoped(:index, :welcome) # => "No translation available"
      # 
      # The <code>:welcome</code> entry does not exists. The last argument isn't
      # a string and therefore the value of the +app_default_value+ entry is
      # returned. If this fall back entry does not exists +nil+ is returned.
      # 
      # This method does not respect the scope set by the +with_app_scope+
      # method. This is done by the +app_scoped+ method.
      def app_not_scoped(*keys)
        self.entry(:app, *keys) || begin
          substitution_args = if keys.last.kind_of?(Array)
            keys.pop
          elsif keys.last.kind_of?(Hash)
            [keys.pop]
          else
            []
          end
          if keys.last.kind_of?(String)
            self.substitute_entry keys.last, *substitution_args
          else
            self.entry(:app_default_value)
          end
        end
      end
      
      # Narrows down the scope of the +app_scoped+ method. Useful if you have a
      # very nested language file and don't want to use the +lc+ helpers:
      # 
      #   app:
      #     layout:
      #       nav:
      #         main:
      #           home: Homepage
      #           contact: Contact
      #           about: About
      # 
      # Usually the calls to the +app_scoped+ method would look like this:
      # 
      #   Language.app_scoped :layout, :nav, :main, :home     # => "Homepage"
      #   Language.app_scoped :layout, :nav, :main, :contact  # => "Contact"
      #   Language.app_scoped :layout, :nav, :main, :about    # => "About"
      # 
      # In this situation you can use +with_app_scope+ to save some work:
      # 
      #   Language.with_app_scope :layout, :nav, :main do
      #     Language.app_scoped :home     # => "Homepage"
      #     Language.app_scoped :contact  # => "Contact"
      #     Language.app_scoped :about    # => "About"
      #   end
      # 
      # Every call to the +app_scoped+ method inside the block will
      # automatically be prefixed with the sections you specified to the
      # +with_app_scope+ method.
      def with_app_scope(*scope_sections, &block)
        @@app_scope_stack.push scope_sections
        begin
          yield
        ensure
          @@app_scope_stack.pop
        end
      end
      
      # Added aliases for backward compatibility (pre 2.4 versions).
      alias_method :app, :app_scoped
      alias_method :app_with_scope, :with_app_scope
      
    end
    
    # This module defines global helper methods and therefor will be
    # included into the Object class.
    module GlobalHelpers
      
      # Defines a global shortcut for the Language#app_scoped method.
      def l(*sections)
        ArkanisDevelopment::SimpleLocalization::Language.app_scoped(*sections)
      end
      
      # The global shortcut for the Language#with_app_scope method.
      def l_scope(*sections, &block)
        ArkanisDevelopment::SimpleLocalization::Language.with_app_scope(*sections, &block)
      end
      
    end
    
    # Localization helpers for the use in controller classes only (not in
    # actions!). This module will extend the ActionController::Base class.
    module ControllerHelpers
      
      # A more specialized version of the <code>GlobalHelpers#l</code> method
      # which returns the localization information at the specified sections
      # but prefixes the sections with the name of the current controller.
      # 
      # The main purpose of this method is to avoid unnecessary repetition of
      # parameters to the <code>GlobalHelpers#l</code> method.
      # 
      # Assume this language file data:
      # 
      #   app:
      #     about:
      #       area_title: About this app...
      #         
      # 
      # and that the following code is written directly in the +AboutController+
      # class:
      # 
      #   lc :area_title # => 'About this app...'
      #   l :about, :area_title # => 'About this app...'
      # 
      # Based on it's current context (the +about+ controller) the lc method
      # automatically added the <code>:about</code> scope.
      def lc(*sections)
        ArkanisDevelopment::SimpleLocalization::Language.app_not_scoped(*([self.controller_name] + sections))
      end
      
    end
    
    # Localization helpers for the use in controllers only. This module will be
    # mixed into ActionController::Base and therefore be available to actions
    # (as an instance method).
    module ControllerActionHelpers
      
      # A more specialized version of the <code>GlobalHelpers#l</code> method
      # which returns the localization information at the specified sections
      # but prefixes the sections with the name of the current controller and
      # action.
      # 
      # The main purpose of this method is to avoid unnecessary repetition of
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
      # Based on it's current context (+about+ controller and +index+ action)
      # the lc method automatically added the <code>:about, :index</code> scope.
      def lc(*sections)
        ArkanisDevelopment::SimpleLocalization::Language.app_not_scoped(*([self.controller_name, self.action_name] + sections))
      end
      
    end
    
    # Localization helpers for use in templates only. This module will be mixed
    # into ActionView::Base.
    module TemplateHelpers
      
      # A more specialized version of the <code>GlobalHelpers#l</code> method
      # which returns the localization information at the specified sections
      # but prefixes the sections with the name of the current template.
      # 
      # The main purpose of this method is to avoid unnecessary repetition of
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
      # The lc method automatically added the :about, :index prefix based on the
      # name of the current view.
      # 
      # Please not that the leading underscore of partial templates is removed.
      # In the template <code>app/view/shared/_message.rhtml</code> the +lc+
      # method will prefix the sections with <code>:app, :shared,
      # :message</code>.
      def lc(*sections)
        current_template = path_and_extension(template_file_name).first
        dir, file = File.split(current_template)
        prefix_sections = dir.split '/'
        prefix_sections << file.gsub(/^_/, '')
        ArkanisDevelopment::SimpleLocalization::Language.app_not_scoped(*(prefix_sections + sections))
      end
      
      # Returns the file name of the template (relative to the ActionView base
      # dir) from which this method is called.
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
      def template_file_name
        template_path = caller.detect{|level| level.slice @base_path}
        template_path.slice Regexp.new(".*#{Regexp.escape(@base_path)}/(.*)\\:\\d+.*"), 1
      end
      
    end
    
  end
end

ArkanisDevelopment::SimpleLocalization::Language.send :extend, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::Language

Object.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::GlobalHelpers
ActionController::Base.send :extend, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::ControllerHelpers
ActionController::Base.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::ControllerActionHelpers
ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::TemplateHelpers
