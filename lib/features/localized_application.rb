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
        self.entry :app, *(@@app_scope + params)
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
    
    # This method will define global shortcut methods and therefor will be
    # included into the Object class.
    module GlobalAccessor
      
      # Defines a global shortcut for the Language#app method.
      def l(*sections)
        ArkanisDevelopment::SimpleLocalization::Language.app(*sections)
      end
      
      # The global shortcut for the Language#app_with_scope method.
      def l_scope(*sections, &block)
        ArkanisDevelopment::SimpleLocalization::Language.app_with_scope(*sections, &block)
      end
      
    end
    
  end
end

ArkanisDevelopment::SimpleLocalization::Language.send :extend, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::Language
Object.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::GlobalAccessor