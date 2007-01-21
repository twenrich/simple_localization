require File.dirname(__FILE__) + '/test_helper'

# Init SimpleLocalization with just the localized_dates feature activated.
simple_localization :language => 'de', :only => :localized_dates

class LocalizedDatesTest < Test::Unit::TestCase
  
  def test_date_constants
    assert_equal Date::MONTHNAMES, [nil] + ArkanisDevelopment::SimpleLocalization::Language[:dates, :monthnames]
    assert_equal Date::DAYNAMES, ArkanisDevelopment::SimpleLocalization::Language[:dates, :daynames]
    assert_equal Date::ABBR_MONTHNAMES, [nil] +  ArkanisDevelopment::SimpleLocalization::Language[:dates, :abbr_monthnames]
    assert_equal Date::ABBR_DAYNAMES, ArkanisDevelopment::SimpleLocalization::Language[:dates, :abbr_daynames]
    
    assert_equal Date::MONTHS, ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash(:section => [:dates, :monthnames], :start_index => 1)
    assert_equal Date::DAYS, ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash(:section => [:dates, :daynames], :start_index => 0)
    assert_equal Date::ABBR_MONTHS, ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash(:section => [:dates, :abbr_monthnames], :start_index => 1)
    assert_equal Date::ABBR_DAYS, ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash(:section => [:dates, :abbr_daynames], :start_index => 0)
  end
  
  def test_date_strftime
    test_date = Date.new 2007, 1, 1
    
    #  strftime format meaning:
    #  
    #  %a - The abbreviated weekday name (``Sun'')
    #  %A - The  full  weekday  name (``Sunday'')
    #  %b - The abbreviated month name (``Jan'')
    #  %B - The  full  month  name (``January'')
    
    assert_equal test_date.strftime("%a"), ArkanisDevelopment::SimpleLocalization::Language[:dates, :abbr_daynames][1]
    assert_equal test_date.strftime("%A"), ArkanisDevelopment::SimpleLocalization::Language[:dates, :daynames][1]
    assert_equal test_date.strftime("%b"), ArkanisDevelopment::SimpleLocalization::Language[:dates, :abbr_monthnames][0]
    assert_equal test_date.strftime("%B"), ArkanisDevelopment::SimpleLocalization::Language[:dates, :monthnames][0]
  end
  
end