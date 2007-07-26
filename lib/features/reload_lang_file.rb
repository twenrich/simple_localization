# = Reload language files
# 
# Reloads all language files of the Simple Localization plugin on each request.
# This is very useful for the development environment. To increase performance
# this feature should not be used in test or production environment.
# 
# == Used sections of the language file
# 
# This feature does not use sections from the lanuage file.

class ApplicationController < ActionController::Base
  
  before_filter :reload_language
  
  private
  
  def reload_language
    ArkanisDevelopment::SimpleLocalization::Language.reload
  end
  
end
