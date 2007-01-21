require File.dirname(__FILE__) + '/test_helper'
require 'active_record'

# Init SimpleLocalization with just the localized_models and
# localized_error_messages features enabled. The localized_error_messages
# feature is enabled to have fully localized error messages.
simple_localization :language => 'de', :only => [:localized_models, :localized_error_messages]

# Localized names for the model and it's attributes.
# The city and state attribute are commented out to test attributes with no
# localization data.
CONTACT_MODEL_NAME = 'Der Kontakt'
CONTACT_ATTRIBUTE_NAMES = {
  :name => 'Der Name',
  # :city => 'Die Stadt',
  # :state => 'Der Staat',
  :phone => 'Die Telefon-Nummer',
  :email_address => 'Die eMail-Adresse'
}

# Create a tableless model. See Rails Weenie:
# http://www.railsweenie.com/forums/2/topics/724
class Contact < ActiveRecord::Base
  
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
  
  localized_names CONTACT_MODEL_NAME, CONTACT_ATTRIBUTE_NAMES
  
end

class LocalizedModelsTest < Test::Unit::TestCase
  
  def test_model_and_attribute_names
    assert_equal Contact.localized_model_name, CONTACT_MODEL_NAME
    assert_equal Contact.human_attribute_name(:name), CONTACT_ATTRIBUTE_NAMES[:name]
  end
  
  def test_error_messages
    @contact = Contact.new :name => 'Stephan Soller',
                           :city => 'HomeSweetHome',
                           :phone => '12345'
    
    assert_equal @contact.valid?, false
    assert_equal @contact.errors.full_messages.size, 1
    assert_equal @contact.errors.full_messages.first, CONTACT_ATTRIBUTE_NAMES[:email_address] + ' ' + ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :empty]
  end
  
end