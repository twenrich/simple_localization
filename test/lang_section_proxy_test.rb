require File.dirname(__FILE__) + '/test_helper'

class LangSectionProxyTest < Test::Unit::TestCase
  
  include ArkanisDevelopment::SimpleLocalization
  
  def test_proxy_array
    data = [1, 2, 3, 4, 5]
    proxy = LangSectionProxy.new :mock_lang_data => data
    assert_array_equal data, proxy
  end
  
  def test_proxy_hash
    data = {:a => 1, :b => 'text'}
    proxy = LangSectionProxy.new :mock_lang_data => data
    assert_hash_equal data, proxy
  end
  
  def test_proxy_hash_with_transformation
    orignial_data = {:a => 'first', :b => 'second', :c => 'third'}
    lang_data = {:a => 'erster', :c => 'dritter'}
    proxy = LangSectionProxy.new :mock_lang_data => lang_data, :orginal_receiver => orignial_data do |localized, original|
      localized.reverse_merge original
    end
    
    merged_data = lang_data.reverse_merge orignial_data
    assert_hash_equal merged_data, proxy
  end
  
  protected
  
  def assert_array_equal(expected_array, proxy)
    assert_equal expected_array.size, proxy.size
    expected_array.each_index do |index|
      assert_equal expected_array[index], proxy[index]
    end
    assert_equal expected_array.sort, proxy.sort
  end
  
  def assert_hash_equal(expected_hash, proxy)
    assert_equal expected_hash.size, proxy.size
    expected_hash.keys do |key|
      assert_equal expected_hash[key], proxy[key]
    end
  end
  
end