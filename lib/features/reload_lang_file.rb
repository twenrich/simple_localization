class ApplicationController < ActionController::Base
  
  before_filter :reload_language
  
  private
  
  def reload_language
    ArkanisDevelopment::SimpleLocalization::Language.reload
  end
  
end
