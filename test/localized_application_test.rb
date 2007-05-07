require File.dirname(__FILE__) + '/test_helper'

# Init SimpleLocalization with just the localized_date_and_time feature
# activated.
simple_localization :lang_file_dir => LANG_FILE_DIR, :language => LANG_FILE, :only => :localized_application

class LocalizedApplicationTest < Test::Unit::TestCase
  
  def setup
    @lang_file = YAML.load_file "#{LANG_FILE_DIR}/#{LANG_FILE}.yml"
    @lang = ArkanisDevelopment::SimpleLocalization::Language
    @test_string = @lang_file['app']['test']['section']
  end
  
  def test_simple_access
    assert_equal @test_string, @lang.app(:test, :section)
  end
  
  def test_lang_access_with_scope
    assert_equal @test_string, @lang.app(:test, :section)
    @lang.app_with_scope :test do
      assert_equal @test_string, @lang.app(:section)
    end
    assert_equal @test_string, @lang.app(:test, :section)
    
    @lang.app_with_scope :test
    assert_equal @test_string, @lang.app(:section)
    @lang.app_with_scope
    assert_equal @test_string, @lang.app(:test, :section)
  end
  
  def test_global_access
    assert_equal @test_string, l(:test, :section)
  end
  
  def test_global_access_with_scope
    assert_equal @test_string, l(:test, :section)
    l_scope :test do
      assert_equal @test_string, l(:section)
    end
    assert_equal @test_string, l(:test, :section)
    
    l_scope :test
    assert_equal @test_string, l(:section)
    l_scope
    assert_equal @test_string, l(:test, :section)
  end
    
end