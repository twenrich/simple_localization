require File.dirname(__FILE__) + '/test_helper'

LANG_FILE ||= 'de'

# Init SimpleLocalization with just the localized_models and
# localized_error_messages features enabled. The localized_error_messages
# feature is enabled to have fully localized error messages.
simple_localization :lang_file_dir => LANG_FILE_DIR, :language => LANG_FILE, :only => [:localized_models_by_lang_file]

# Create a tableless model. See Rails Weenie:
# http://www.railsweenie.com/forums/2/topics/724
# The localized_models_test uses a tableless model called Contact. To not mess
# up validation code (validates_presence_of called twice) this model has
# another name.
class Address < ActiveRecord::Base
  
  def self.columns() @columns ||= []; end
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
  
  column :name,          :string
  column :city,          :string
  column :state,         :string
  column :phone,         :string
  column :email_address, :string
  
  validates_presence_of :name, :email_address
  
end

class LocalizedModelsByLangFileTest < Test::Unit::TestCase
  
  def setup
    # Load the lang file data directly form the YAML file.
    lang_file_data = YAML.load_file "#{LANG_FILE_DIR}/#{LANG_FILE}.yml"
    @model_name = lang_file_data['models']['address']['name']
    @attribute_names = lang_file_data['models']['address']['attributes'].symbolize_keys
  end
  
  def test_localized_model_name
    assert_equal @model_name, Address.localized_model_name
  end
  
  def test_localized_human_attribute_name
    assert_equal @attribute_names[:name], Address.human_attribute_name('name')
    assert_equal @attribute_names[:phone], Address.human_attribute_name('phone')
    assert_equal @attribute_names[:email_address], Address.human_attribute_name('email_address')
  end
  
  def test_default_human_attribute_name
    assert_equal 'city'.humanize, Address.human_attribute_name('city')
    assert_equal 'state'.humanize, Address.human_attribute_name('state')
  end
  
  # This one tests what happens if the +localized_model_name+ and overwritten
  # +human_attribute_name+ methods are called directly on the
  # ActiveRecord::Base class. The +scaffold+ method does this indirectly. See
  # the note of the +LocalizedModelsByLangFile+ +included+ method.
  def test_direct_base_call
    assert_nil ActiveRecord::Base.localized_model_name
    assert_not_equal @attribute_names[:name], ActiveRecord::Base.human_attribute_name('name')
    assert_equal 'name'.humanize, ActiveRecord::Base.human_attribute_name('name')
  end
  
end