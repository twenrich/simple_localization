require File.dirname(__FILE__) + '/test_helper'
require 'active_record'

# Init SimpleLocalization with just the localized_error_messages feature
# activated.
simple_localization :language => 'de', :only => :localized_error_messages

class LocalizedErrorMessagesTest < Test::Unit::TestCase
  
  def test_error_message_constants
    [:inclusion, :exclusion, :inavlid, :confirmation,
     :accepted, :empty, :blank, :too_long, :too_short,
     :wrong_length, :taken, :not_a_number].each do |msg_name|
      assert_equal ActiveRecord::Errors.default_error_messages[msg_name],
        ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, msg_name]
    end
  end
  
end