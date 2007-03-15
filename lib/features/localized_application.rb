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
# ArkanisDevelopment::SimpleLocalization::Language#[] operator but is limited
# to the +app+ section of the language file.
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
      def app(*params)
        self[:app, *params]
      end
      
    end
    
    # This method will define global shortcut methods and therefor will be
    # included into the Object class.
    module GlobalAccessor
      
      # Defines a global shortcut for the Language#app method.
      def l(*sections)
        ArkanisDevelopment::SimpleLocalization::Language.app(*sections)
      end
      
    end
    
  end
end

ArkanisDevelopment::SimpleLocalization::Language.send :extend, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::Language
Object.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplication::GlobalAccessor