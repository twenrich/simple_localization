require File.dirname(__FILE__) + '/test_helper'

class FakeModelWithDate
  
  attr_reader :date
  
  def initialize
    @date = Date.new 2007, 1, 1
  end
  
end

# Init SimpleLocalization with just the localized_date_helpers feature
# activated.
simple_localization :language => LANG_FILE, :only => :localized_date_helpers

class LocalizedDateHelpersTest < Test::Unit::TestCase
  
  include ActionView::Helpers::DateHelper
  include ArkanisDevelopment::SimpleLocalization::LocalizedDateHelpers
  
  def test_date_select
    @record = FakeModelWithDate.new
    html_output = date_select(:record, :date)
    ArkanisDevelopment::SimpleLocalization::Language[:dates, :monthnames].each do |month_name|
      assert_contains html_output, month_name
    end
  end
  
  def test_distance_of_time_in_words
    from, to = Time.now, 10.hours.from_now
    output_mask = ArkanisDevelopment::SimpleLocalization::Language[:helpers, :distance_of_time_in_words]['about n hours']
    expected_output = format(output_mask, ((from - to).abs / 60 / 60).round)
    
    assert_equal expected_output, distance_of_time_in_words(from, to)
    assert_equal expected_output, distance_of_time_in_words_to_now(10.hours.ago)
  end
  
end