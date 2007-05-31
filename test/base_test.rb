require File.dirname(__FILE__) + '/test_helper'

class BaseTest < Test::Unit::TestCase
  
  def test_preload_features
    assert_equal [:localized_models], ArkanisDevelopment::SimpleLocalization::PRELOAD_FEATURES
    loaded_features = simple_localization :lang_file_dir => LANG_FILE_DIR, :language => LANG_FILE, :only => []
    assert_equal ArkanisDevelopment::SimpleLocalization::PRELOAD_FEATURES, loaded_features
  end
  
end
