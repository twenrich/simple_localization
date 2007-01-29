require File.dirname(__FILE__) + '/test_helper'

# Load the specified language file and all features
simple_localization :language => LANG

class SimpleLocalizationTest < Test::Unit::TestCase
  
  def setup
    @lang_file = YAML.load_file(File.dirname(__FILE__) + "/../languages/#{LANG}.yml")
    @lang = ArkanisDevelopment::SimpleLocalization::Language
  end
  
  def test_if_language_file_is_loaded
    assert_equal LANG, @lang.current_language
  end
  
  def test_about_lang
    info_from_class = @lang.about
    @lang_file['about'].each do |key, value|
      assert_equal value, info_from_class[key.to_sym]
    end
  end
  
  def test_lang_file_access
    assert_equal @lang_file['dates']['monthnames'], @lang[:dates, :monthnames]
  end
  
end
