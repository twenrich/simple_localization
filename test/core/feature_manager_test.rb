require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

# Define a mock for the feature manager
class FeatureManagerMock < ArkanisDevelopment::SimpleLocalization::FeatureManager
  
  def read_available_features
    [:feature_a, :feature_b, :feature_c, :feature_d]
  end
  
  def reset
    self.send :initialize
  end
  
end


class FeatureManagerTest < Test::Unit::TestCase
  
  def setup
    @manager = FeatureManagerMock.instance
    @manager.reset
    @feature_list = [:feature_a, :feature_b, :feature_c, :feature_d]
  end
  
  def test_available_features
    assert_equal @feature_list, @manager.all_features
  end
  
  def test_plugin_init_features
    assert @manager.plugin_init_features.empty?
  end
  
end
