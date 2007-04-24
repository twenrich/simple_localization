require File.dirname(__FILE__) + '/test_helper'

# Load the specified language file and all features
simple_localization :language => LANG_FILE

class SimpleLocalizationTest < Test::Unit::TestCase
  
  def setup
    @lang_file = YAML.load_file(File.dirname(__FILE__) + "/../languages/#{LANG_FILE}.yml")
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
    assert_nil @lang[:not_existant_key]
  end
  
  def test_lang_file_access_with_format
    assert_equal format(@lang_file['helpers']['distance_of_time_in_words']['n minutes'], 1), @lang[:helpers, :distance_of_time_in_words, 'n minutes', [1]]
  end
  
end
