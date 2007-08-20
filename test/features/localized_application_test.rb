require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

# Init SimpleLocalization with just the localized_date_and_time feature
# activated.
simple_localization :lang_file_dir => LANG_FILE_DIR, :language => LANG_FILE, :only => :localized_application

class LocalizedApplicationTest < Test::Unit::TestCase
  
  include ArkanisDevelopment::SimpleLocalization::LocalizedApplication::ContextSensetiveHelpers
  
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
  
  def test_emulate_caller_with_method
    emulate_caller_with_method 'test.rb', 4, 'emulated_method' do
      assert_equal "test.rb:4:in `emulated_method'", caller.first
    end
  end
  
  def test_get_app_file_in_context
    emulate_caller_with_method "#{RAILS_ROOT}/app/views/about/index.rhtml", 25, '_run_rhtml_47app47views47about47index46rhtml' do
      dir, file, method = get_app_file_in_context
      assert_equal 'views', dir
      assert_equal 'about/index', file
      assert_equal '_run_rhtml_47app47views47about47index46rhtml', method
    end
  end
  
  def test_lc_in_view
    emulate_caller_with_method "#{RAILS_ROOT}/app/views/about/index.rhtml", 25, '_run_rhtml_47app47views47about47index46rhtml' do
      assert_equal @lang_file['app']['about']['index']['symbol'], lc(:symbol)
      assert_equal @lang_file['app']['about']['index']['a string'], lc('a string')
      assert_equal @lang_file['app']['about']['index']['with substitution %s'], lc('with substitution %s')
      assert_equal format(@lang_file['app']['about']['index']['with substitution %s'], 'var'), lc('with substitution %s', ['var'])
    end
  end
  
=begin
  def test_get_app_file_in_context_of_class
    eval <<-EOD, nil, "#{RAILS_ROOT}/app/controllers/pages.rb", 25
      class TestGetAppFileInContextOfClass
        extend ArkanisDevelopment::SimpleLocalization::LocalizedApplication::ContextSensetiveHelpers
        puts caller.inspect
        $get_app_file_in_context_of_class_result = get_app_file_in_context
      end
    EOD
    puts $get_app_file_in_context_of_class_result.inspect
  end
=end
  
  protected
  
  # Adds the specified file and line to the callstack and executes the given
  # block.
  def emulate_caller_with_method(file, line = 1, method = 'test', &block)
    block.instance_eval "alias #{method.to_sym}  :call"
    eval "block.#{method}", self.send(:binding), file, line
  end
  
end
