require File.dirname(__FILE__) + '/../test_helper'

# Load the specified language file and no features
simple_localization :lang_file_dir => LANG_FILE_DIR, :language => [:de, :en], :only => []

class MultipleLanguagesTest < Test::Unit::TestCase
  
  def setup
    @lang_files = {
      :de => YAML.load_file("#{LANG_FILE_DIR}/de.yml"),
      :en => YAML.load_file("#{LANG_FILE_DIR}/en.yml")
    }
    @lang = ArkanisDevelopment::SimpleLocalization::Language
    @lang.use :de
  end
  
  def test_if_language_files_are_loaded
    assert @lang.loaded_languages.include?(:de), 'Language "de" isn\'t loaded but should be'
    assert @lang.loaded_languages.include?(:en), 'Language "en" isn\'t loaded but should be'
    assert_current_language :de
  end
  
  def test_about_lang_for_current_language
    info_from_class = @lang.about
    @lang_files[:de]['about'].each do |key, value|
      assert_equal value, info_from_class[key.to_sym]
    end
  end
  
  def test_about_lang_with_all_languages
    [:de, :en].each do |lang_file_name|
      info_from_class = @lang.about lang_file_name
      @lang_files[lang_file_name]['about'].each do |key, value|
        assert_equal value, info_from_class[key.to_sym]
      end
    end
  end
  
  def test_lang_file_access
    assert_equal @lang_files[:de]['dates']['monthnames'], @lang[:dates, :monthnames]
    assert_equal @lang_files[:de]['dates']['monthnames'], @lang.find(:de, :dates, :monthnames)
    assert_equal @lang_files[:en]['dates']['monthnames'], @lang.find(:en, :dates, :monthnames)
    
    @lang.debug = true
    assert_raise ArkanisDevelopment::SimpleLocalization::EntryNotFound do
      @lang[:not_existant_key]
    end
    
    @lang.debug = false
    assert_nil @lang[:not_existant_key]
    @lang.debug = true
  end
  
  def test_lang_switching
    assert_current_language :de
    assert_equal @lang_files[:de]['dates']['monthnames'], @lang[:dates, :monthnames]
    
    @lang.use :en
    assert_current_language :en
    assert_equal @lang_files[:en]['dates']['monthnames'], @lang[:dates, :monthnames]
    
    @lang.use :de
    assert_current_language :de
    assert_equal @lang_files[:de]['dates']['monthnames'], @lang[:dates, :monthnames]
  end
  
  def test_raise_on_invalid_lang_switch
    assert_current_language :de
    assert_raise ArkanisDevelopment::SimpleLocalization::LangFileNotLoaded do
      @lang.use :not_existing
    end
    assert_current_language :de
  end
  
  def test_lang_switching_with_proxy
    proxy = ArkanisDevelopment::SimpleLocalization::LangSectionProxy.new :sections => [:dates, :monthnames]
    
    assert_current_language :de
    assert_equal @lang_files[:de]['dates']['monthnames'], proxy
    
    @lang.use :en
    assert_current_language :en
    assert_equal @lang_files[:en]['dates']['monthnames'], proxy
  end
  
  protected
  
  def assert_current_language(lang)
    assert_equal lang, @lang.current_language
  end
  
end
