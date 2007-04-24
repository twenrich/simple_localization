require File.dirname(__FILE__) + '/test_helper'

class LangSectionProxyTest < Test::Unit::TestCase
  
  include ArkanisDevelopment::SimpleLocalization
  
  def test_proxy_array
    data = [1, 2, 3, 4, 5]
    proxy = LangSectionProxy.new :param_not_needed, :mock_lang_data => data
    assert_equal data.size, proxy.size
    assert_equal data[0], proxy[0]
    assert_equal data.sort, proxy.sort
  end
  
  def test_proxy_hash
    data = {:a => 1, :b => 'text'}
    proxy = LangSectionProxy.new :param_not_needed, :mock_lang_data => data
    assert_equal data.size, proxy.size
    assert_equal data[:a], proxy[:a]
    assert_equal data[:b], proxy[:b]
  end
  
  def test_proxy_hash_with_reverse_merge
    orignial_data = {:a => 'first', :b => 'second', :c => 'third'}
    lang_data = {:a => 'erster', :c => 'dritter'}
    proxy = LangSectionProxy.new :param_not_needed, :mock_lang_data => lang_data, :reverse_merge_with => orignial_data
    
    merged_data = lang_data.reverse_merge orignial_data
    assert_equal merged_data.size, proxy.size
    merged_data.keys.each do |key|
      assert_equal merged_data[key], proxy[key]
    end
  end
  
end