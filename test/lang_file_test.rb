require File.dirname(__FILE__) + '/test_helper'

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
  
end