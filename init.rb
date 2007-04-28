# Load the Language and LangSectionProxy classes and at the end the base file.
# It will define the simple_localization method which will do all necessary
# stuff.
require File.dirname(__FILE__) + '/lib/language'
require File.dirname(__FILE__) + '/lib/lang_section_proxy'
require File.dirname(__FILE__) + '/lib/cached_lang_section_proxy'
require File.dirname(__FILE__) + '/lib/base'