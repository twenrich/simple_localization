require File.dirname(__FILE__) + '/test_helper'

# Load the specified language file and no features
simple_localization :lang_file_dir => LANG_FILE_DIR, :language => LANG_FILE, :only => []

class LanguageTest < Test::Unit::TestCase
  
  def setup
    @lang_file = YAML.load_file "#{LANG_FILE_DIR}/#{LANG_FILE}.yml"
    @lang = ArkanisDevelopment::SimpleLocalization::Language
  end
  
  def test_if_language_file_is_loaded
    assert_equal LANG_FILE.to_sym, @lang.current_language
  end
  
  def test_about_lang
    info_from_class = @lang.about
    assert_equal info_from_class, @lang.about(LANG_FILE)
    @lang_file['about'].each do |key, value|
      assert_equal value, info_from_class[key.to_sym]
    end
  end
  
  def test_lang_file_access
    assert_equal @lang_file['dates']['monthnames'], @lang[:dates, :monthnames]
    assert_nil @lang[:not_existant_key]
    assert_raise ArkanisDevelopment::SimpleLocalization::LangFileNotLoaded do
      @lang.entry :not_loaded_lang, :dates, :monthnames
    end
  end
  
  def test_lang_file_access_with_format
    assert_equal format(@lang_file['helpers']['distance_of_time_in_words']['n minutes'], 1), @lang[:helpers, :distance_of_time_in_words, 'n minutes', [1]]
  end
  
  def test_simple_lang_section_proxy
    assert_equal @lang_file['dates']['monthnames'], ArkanisDevelopment::SimpleLocalization::LangSectionProxy.new(:sections => [:dates, :monthnames])
  end
  
end
