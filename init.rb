# Load the Language and LangSectionProxy classes and at the end the base file.
# It will define the simple_localization method which will do all necessary
# stuff.
require File.dirname(__FILE__) + '/lib/language'
require File.dirname(__FILE__) + '/lib/lang_section_proxy'
require File.dirname(__FILE__) + '/lib/cached_lang_section_proxy'
require File.dirname(__FILE__) + '/lib/base'

# Preload any features which have to be ready immediately so they can be used
# by models which have observer attected to them (which causes them to be
# loaded before the simple_localization call).
# 
# The list of preloaded modules can be modified by simply defining the
# ArkanisDevelopment::SimpleLocalization::PRELOAD_FEATURES constant by
# yourself. You have to do this before the Rails::Initializer.run call in your
# environment.rb file.
ArkanisDevelopment::SimpleLocalization::PRELOAD_FEATURES.each do |feature|
  require "#{File.dirname(__FILE__)}/lib/features/#{feature}"
end