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
  
  def test_get_app_file_in_context
    assert_equal './script/../config/..', RAILS_ROOT
    
    with_lc_test_stack :model_class do
      assert_equal ['models', 'entry', nil], get_app_file_in_context
    end
    with_lc_test_stack :model_method do
      assert_equal ['models', 'entry', 'before_save'], get_app_file_in_context
    end
    with_lc_test_stack :controller_class do
      assert_equal ['controllers', 'about_controller', nil], get_app_file_in_context
    end
    with_lc_test_stack :controller_method do
      assert_equal ['controllers', 'about_controller', 'index'], get_app_file_in_context
    end
    with_lc_test_stack :view do
      assert_equal ['views', 'about/index', '_run_rhtml_47app47views47about47index46rhtml'], get_app_file_in_context
    end
  end
  
  def test_lc_in_view
    with_lc_test_stack :model_class do
      assert_equal ['models', 'entry', nil], get_app_file_in_context
    end
    with_lc_test_stack :model_method do
      assert_equal ['models', 'entry', 'before_save'], get_app_file_in_context
    end
    with_lc_test_stack :controller_class do
      assert_equal ['controllers', 'about_controller', nil], get_app_file_in_context
    end
    with_lc_test_stack :controller_method do
      assert_equal ['controllers', 'about_controller', 'index'], get_app_file_in_context
    end
    with_lc_test_stack :view do
      assert_equal ['views', 'about/index', '_run_rhtml_47app47views47about47index46rhtml'], get_app_file_in_context
    end
    
    #assert_equal @lang_file['app']['about']['index']['symbol'], lc(:symbol)
    #assert_equal @lang_file['app']['about']['index']['a string'], lc('a string')
    #assert_equal @lang_file['app']['about']['index']['with substitution %s'], lc('with substitution %s')
    #assert_equal format(@lang_file['app']['about']['index']['with substitution %s'], 'var'), lc('with substitution %s', ['var'])
  end
  
  private
  
  def with_lc_test_stack(stack_name)
    stacks = {
      :model_class => ["/home/steven/working_copies/simple_localization/rails_1.2/config/environment.rb:14:in `a_context_sensitive_helper'", "./script/../config/../app/models/entry.rb:5", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:203:in `load_without_new_constant_marking'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:203:in `load_file'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:202:in `load_file'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:94:in `require_or_load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:248:in `load_missing_constant'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:452:in `const_missing'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:464:in `const_missing'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/inflector.rb:250:in `constantize'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/core_ext/string/inflections.rb:148:in `constantize'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/observer.rb:143:in `observed_class'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/observer.rb:166:in `observed_classes'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/observer.rb:149:in `initialize'", "/usr/local/lib/ruby/1.8/singleton.rb:95:in `new'", "/usr/local/lib/ruby/1.8/singleton.rb:95:in `instance'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/observer.rb:38:in `instantiate_observers'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/observer.rb:36:in `each'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/observer.rb:36:in `instantiate_observers'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/initializer.rb:212:in `load_observers'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/initializer.rb:108:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/initializer.rb:43:in `send'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/initializer.rb:43:in `run'", "/home/steven/working_copies/simple_localization/rails_1.2/config/environment.rb:19", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `gem_original_require'", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:155:in `rails'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:112:in `cloaker_'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:138:in `call'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:138:in `listener'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:98:in `cloaker_'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:51:in `call'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:51:in `initialize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:83:in `new'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:83:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/command.rb:211:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:243", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/commands/servers/mongrel.rb:60", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `gem_original_require'", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/commands/server.rb:39", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `gem_original_require'", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `require'", "script/server:3"],
      :model_method => ["/home/steven/working_copies/simple_localization/rails_1.2/config/environment.rb:14:in `a_context_sensitive_helper'", "./script/../config/../app/models/entry.rb:8:in `before_save'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/callbacks.rb:348:in `send'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/callbacks.rb:348:in `callback'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/callbacks.rb:241:in `create_or_update'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/base.rb:1545:in `save_without_validation'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/validations.rb:752:in `save_without_transactions'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/transactions.rb:129:in `save'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/connection_adapters/abstract/database_statements.rb:59:in `transaction'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/transactions.rb:95:in `transaction'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/transactions.rb:121:in `transaction'", "/usr/local/lib/ruby/gems/1.8/gems/activerecord-1.15.3/lib/active_record/transactions.rb:129:in `save'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/scaffolding.rb:146:in `update'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:1095:in `send'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:1095:in `perform_action_without_filters'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:632:in `call_filter'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:638:in `call_filter'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:438:in `call'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:637:in `call_filter'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:638:in `call_filter'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:438:in `call'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:637:in `call_filter'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:619:in `perform_action_without_benchmark'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/benchmarking.rb:66:in `perform_action_without_rescue'", "/usr/local/lib/ruby/1.8/benchmark.rb:293:in `measure'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/benchmarking.rb:66:in `perform_action_without_rescue'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/rescue.rb:83:in `perform_action'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:430:in `send'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:430:in `process_without_filters'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:624:in `process_without_session_management_support'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/session_management.rb:114:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:330:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/dispatcher.rb:41:in `dispatch'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:78:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:76:in `synchronize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:76:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:618:in `process_client'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:617:in `each'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:617:in `process_client'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `initialize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `new'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `initialize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `new'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:271:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:270:in `each'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:270:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:127:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/command.rb:211:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:243", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/commands/servers/mongrel.rb:60", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `gem_original_require'", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/commands/server.rb:39", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `gem_original_require'", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `require'", "script/server:3"],
      :controller_class => ["/home/steven/working_copies/simple_localization/rails_1.2/config/environment.rb:14:in `a_context_sensitive_helper'", "./script/../config/../app/controllers/about_controller.rb:3", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:203:in `load_without_new_constant_marking'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:203:in `load_file'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:202:in `load_file'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:94:in `require_or_load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:248:in `load_missing_constant'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:452:in `const_missing'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:464:in `const_missing'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/inflector.rb:250:in `constantize'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/core_ext/string/inflections.rb:148:in `constantize'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/routing.rb:1284:in `recognize'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/dispatcher.rb:40:in `dispatch'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:78:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:76:in `synchronize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:76:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:618:in `process_client'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:617:in `each'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:617:in `process_client'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `initialize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `new'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `initialize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `new'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:271:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:270:in `each'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:270:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:127:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/command.rb:211:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:243", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/commands/servers/mongrel.rb:60", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `gem_original_require'", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/commands/server.rb:39", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `gem_original_require'", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `require'", "script/server:3"],
      :controller_method => ["/home/steven/working_copies/simple_localization/rails_1.2/config/environment.rb:14:in `a_context_sensitive_helper'", "./script/../config/../app/controllers/about_controller.rb:6:in `index'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:1095:in `send'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:1095:in `perform_action_without_filters'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:632:in `call_filter'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:638:in `call_filter'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:438:in `call'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:637:in `call_filter'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:619:in `perform_action_without_benchmark'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/benchmarking.rb:66:in `perform_action_without_rescue'", "/usr/local/lib/ruby/1.8/benchmark.rb:293:in `measure'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/benchmarking.rb:66:in `perform_action_without_rescue'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/rescue.rb:83:in `perform_action'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:430:in `send'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:430:in `process_without_filters'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:624:in `process_without_session_management_support'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/session_management.rb:114:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:330:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/dispatcher.rb:41:in `dispatch'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:78:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:76:in `synchronize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:76:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:618:in `process_client'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:617:in `each'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:617:in `process_client'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `initialize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `new'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `initialize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `new'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:271:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:270:in `each'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:270:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:127:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/command.rb:211:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:243", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/commands/servers/mongrel.rb:60", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `gem_original_require'", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/commands/server.rb:39", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `gem_original_require'", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `require'", "script/server:3"],
      :view => ["/home/steven/working_copies/simple_localization/rails_1.2/config/environment.rb:14:in `a_context_sensitive_helper'", "./script/../config/../app/views/about/index.rhtml:3:in `_run_rhtml_47app47views47about47index46rhtml'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_view/base.rb:326:in `send'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_view/base.rb:326:in `compile_and_render_template'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_view/base.rb:301:in `render_template'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_view/base.rb:260:in `render_file_without_localization'", "./script/../config/../vendor/plugins/simple_localization/lib/features/localized_templates.rb:48:in `render_file'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:806:in `render_file'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:711:in `render_with_no_layout'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/layout.rb:247:in `render_without_benchmark'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/benchmarking.rb:50:in `render'", "/usr/local/lib/ruby/1.8/benchmark.rb:293:in `measure'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/benchmarking.rb:50:in `render'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:1096:in `perform_action_without_filters'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:632:in `call_filter'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:638:in `call_filter'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:438:in `call'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:637:in `call_filter'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:619:in `perform_action_without_benchmark'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/benchmarking.rb:66:in `perform_action_without_rescue'", "/usr/local/lib/ruby/1.8/benchmark.rb:293:in `measure'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/benchmarking.rb:66:in `perform_action_without_rescue'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/rescue.rb:83:in `perform_action'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:430:in `send'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:430:in `process_without_filters'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/filters.rb:624:in `process_without_session_management_support'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/session_management.rb:114:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/actionpack-1.13.3/lib/action_controller/base.rb:330:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/dispatcher.rb:41:in `dispatch'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:78:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:76:in `synchronize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/rails.rb:76:in `process'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:618:in `process_client'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:617:in `each'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:617:in `process_client'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `initialize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `new'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:736:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `initialize'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `new'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel.rb:720:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:271:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:270:in `each'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/configurator.rb:270:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:127:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/lib/mongrel/command.rb:211:in `run'", "/usr/local/lib/ruby/gems/1.8/gems/mongrel-1.0.1/bin/mongrel_rails:243", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:488:in `load'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/commands/servers/mongrel.rb:60", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `gem_original_require'", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:342:in `new_constants_in'", "/usr/local/lib/ruby/gems/1.8/gems/activesupport-1.4.2/lib/active_support/dependencies.rb:495:in `require'", "/usr/local/lib/ruby/gems/1.8/gems/rails-1.2.3/lib/commands/server.rb:39", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `gem_original_require'", "/usr/local/lib/ruby/site_ruby/1.8/rubygems/custom_require.rb:27:in `require'", "script/server:3"]
    }
    
    raise "Unkown stack name #{stack_name.inspect}" unless stacks.include?(stack_name)
    
    backup = $lc_test_get_app_file_in_context_stack
    $lc_test_get_app_file_in_context_stack = stacks[stack_name]
    yield
    $lc_test_get_app_file_in_context_stack = backup
  end
  
end
