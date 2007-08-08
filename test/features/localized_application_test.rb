require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

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
    assert_equal @test_string, @lang.app_scoped(:test, :section)
    assert_equal @test_string, @lang.app_not_scoped(:test, :section)
  end
  
  def test_lang_access_with_scope
    assert_equal @test_string, @lang.app_scoped(:test, :section)
    @lang.with_app_scope :test do
      assert_equal @test_string, @lang.app_scoped(:section)
      assert_equal @test_string, @lang.app_not_scoped(:test, :section)
    end
    assert_equal @test_string, @lang.app_scoped(:test, :section)
  end
  
  def test_lang_access_with_lang_file_default_value
    assert_equal @lang_file['app_default_value'], @lang.app_not_scoped(:not, :existing, :entry)
    assert_equal @lang_file['app_default_value'], @lang.app_not_scoped(:tests, :emtpy)
  end
  
  def test_lang_access_with_string_default_value
    assert_equal 'entry', @lang.app_not_scoped(:not, :existing, 'entry')
    assert_equal 'default with substitution', @lang.app_not_scoped(:not, :existing, :section, 'default with %s', ['substitution'])
    assert_equal 'default with substitution', @lang.app_not_scoped(:not, :existing, :section, 'default with :replace', :replace => 'substitution')
  end
  
  def test_lang_access_with_nested_scope
    very_nested_test_entry = @lang_file['app']['test']['nested']['another test']
    assert_equal @test_string, @lang.app_scoped(:test, :section)
    @lang.with_app_scope :test do
      assert_equal @test_string, @lang.app_scoped(:section)
      assert_equal very_nested_test_entry, @lang.app_scoped(:nested, 'another test')
      @lang.with_app_scope :nested do
        assert_equal very_nested_test_entry, @lang.app_scoped('another test')
        assert_equal very_nested_test_entry, @lang.app_not_scoped(:test, :nested, 'another test')
      end
      assert_equal very_nested_test_entry, @lang.app_scoped(:nested, 'another test')
    end
    assert_equal @test_string, @lang.app_scoped(:test, :section)
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
  end
  
  def test_backward_compatibilty_aliases
    assert_equal @test_string, @lang.app(:test, :section)
    @lang.app_with_scope :test do
      assert_equal @test_string, @lang.app(:section)
    end
  end
    
end
