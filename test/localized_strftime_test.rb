require File.dirname(__FILE__) + '/test_helper'

# Init SimpleLocalization with just the localized_strftime and localized_dates
# features enabled. The localized_dates feature is necessary for localized_strftime
# to have an effect.
simple_localization :language => 'de', :only => [:localized_strftime, :localized_dates]

class LocalizedStrftimeTest < Test::Unit::TestCase
  
  def test_time_strftime
    test_time = Time.utc 2007, 1, 1
    
    #  strftime format meaning:
    #  
    #  %a - The abbreviated weekday name (``Sun'')
    #  %A - The  full  weekday  name (``Sunday'')
    #  %b - The abbreviated month name (``Jan'')
    #  %B - The  full  month  name (``January'')
    
    assert_equal test_time.strftime("%a"), ArkanisDevelopment::SimpleLocalization::Language[:dates, :abbr_daynames][1]
    assert_equal test_time.strftime("%A"), ArkanisDevelopment::SimpleLocalization::Language[:dates, :daynames][1]
    assert_equal test_time.strftime("%b"), ArkanisDevelopment::SimpleLocalization::Language[:dates, :abbr_monthnames][0]
    assert_equal test_time.strftime("%B"), ArkanisDevelopment::SimpleLocalization::Language[:dates, :monthnames][0]
  end
  
end