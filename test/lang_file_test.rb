require File.dirname(__FILE__) + '/test_helper'
#require 'fileutils'

class LangFileTest < Test::Unit::TestCase
  
  def test_simple_loading
    lang_file = ArkanisDevelopment::SimpleLocalization::LangFile.new LANG_FILE_DIR, :en
    assert_equal LANG_FILE_DIR, lang_file.lang_dir
    assert_equal :en, lang_file.lang_code
    assert_kind_of ArkanisDevelopment::SimpleLocalization::NestedHash, lang_file.data
    assert lang_file.data.empty?, 'Language data should be empty because the lang file is not yet loaded, but it contains data.'
    
    lang_file.load
    assert_kind_of ArkanisDevelopment::SimpleLocalization::NestedHash, lang_file.data
    assert_equal 'English', lang_file.data['about', 'language']
  end
  
  def test_multipart_loading
    lang_file = ArkanisDevelopment::SimpleLocalization::LangFile.new LANG_FILE_DIR, :de
    lang_file.load
    assert_equal 'Deutsch', lang_file.data['about', 'language']
    assert_equal 'Titel', lang_file.data['app', 'about', 'title']
    assert_equal 'Deutschland', lang_file.data['countries', 'Germany']
  end
  
  def test_save
    with_copied_lang_files do |lang_dir_for_test|
      
      lang_file = ArkanisDevelopment::SimpleLocalization::LangFile.new lang_dir_for_test, :de
      lang_file.load
      
      lang_file.data['about', 'language'] = 'Deutsch geändert'
      lang_file.data['app', 'about', 'title'] = 'Titel geändert'
      lang_file.data['countries', 'Germany'] = 'Deutschland geändert'
      lang_file.save
      
      de_data = YAML.load_file("#{lang_dir_for_test}/de.yml")
      de_app_about_data = YAML.load_file("#{lang_dir_for_test}/de.app.about.yml")
      de_countries_data = YAML.load_file("#{lang_dir_for_test}/de.countries.yml")
      
      assert_equal 'Deutsch geändert', de_data['about']['language']
      assert_nil de_data['app']['about']
      assert_nil de_data['countries']
      assert_equal 'Titel geändert', de_app_about_data['title']
      assert_nil de_app_about_data['about']
      assert_nil de_app_about_data['app']
      assert_nil de_app_about_data['countries']
      assert_equal 'Deutschland geändert', de_countries_data['Germany']
      assert_nil de_countries_data['about']
      assert_nil de_countries_data['app']
      
    end
  end
  
  def test_reload
    with_copied_lang_files do |lang_dir_for_test|
      
      lang_file = ArkanisDevelopment::SimpleLocalization::LangFile.new lang_dir_for_test, :de
      lang_file.load
      
      # Add a new entry and edit an entry of the memory data
      lang_file.data['app', 'test', 'new_from_mem'] = 'Neuer Eintrag (in memory)'
      lang_file.data['app', 'test', 'section'] = 'Geänderte Zeichenkette (in memory)'
      
      # Add a new entry and an changed entry to the base lang file
      file_data = YAML.load_file "#{lang_dir_for_test}/de.yml"
      file_data['app']['test']['new_from_file'] = 'Neuer Eintrag (in file)'
      file_data['app']['test']['section'] = 'Geänderte Zeichenkette (in file)'
      File.open("#{lang_dir_for_test}/de.yml", 'wb'){|f| YAML.dump(file_data, f)}
      
      assert_equal 'Neuer Eintrag (in memory)', lang_file.data['app', 'test', 'new_from_mem']
      assert_equal 'Geänderte Zeichenkette (in memory)', lang_file.data['app', 'test', 'section']
      
      lang_file.reload
      
      assert_equal 'Neuer Eintrag (in memory)', lang_file.data['app', 'test', 'new_from_mem']
      assert_equal 'Neuer Eintrag (in file)', lang_file.data['app', 'test', 'new_from_file']
      assert_equal 'Geänderte Zeichenkette (in file)', lang_file.data['app', 'test', 'section']
      
    end
  end
  
  protected
  
  def with_copied_lang_files(temp_dir = nil)
    temp_dir = "#{File.dirname(__FILE__)}/lang_files_for_running_test" unless temp_dir
    FileUtils.cp_r LANG_FILE_DIR, temp_dir
    yield temp_dir
    FileUtils.rm_r temp_dir
  end
  
end