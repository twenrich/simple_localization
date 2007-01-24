require File.dirname(__FILE__) + '/test_helper'

# Init SimpleLocalization with just the localized_date_and_time feature
# activated.
simple_localization :language => LANG, :only => :localized_date_and_time

class LocalizedDatesTest < Test::Unit::TestCase
  
  def setup
    @language = ArkanisDevelopment::SimpleLocalization::Language
    @test_date = Date.new 2007, 1, 1
    @test_time = Time.utc 2007, 1, 1
  end
  
  def test_date_constants
    assert_equal Date::MONTHNAMES, [nil] + @language[:dates, :monthnames]
    assert_equal Date::DAYNAMES, @language[:dates, :daynames]
    assert_equal Date::ABBR_MONTHNAMES, [nil] +  @language[:dates, :abbr_monthnames]
    assert_equal Date::ABBR_DAYNAMES, @language[:dates, :abbr_daynames]
    
    assert_equal Date::MONTHS, @language.convert_to_name_indexed_hash(:section => [:dates, :monthnames], :start_index => 1)
    assert_equal Date::DAYS, @language.convert_to_name_indexed_hash(:section => [:dates, :daynames], :start_index => 0)
    assert_equal Date::ABBR_MONTHS, @language.convert_to_name_indexed_hash(:section => [:dates, :abbr_monthnames], :start_index => 1)
    assert_equal Date::ABBR_DAYS, @language.convert_to_name_indexed_hash(:section => [:dates, :abbr_daynames], :start_index => 0)
  end
  
  def test_date_strftime
    #  strftime format meaning:
    #  
    #  %a - The abbreviated weekday name (``Sun'')
    #  %A - The  full  weekday  name (``Sunday'')
    #  %b - The abbreviated month name (``Jan'')
    #  %B - The  full  month  name (``January'')
    
    assert_equal @test_date.strftime("%a"), @language[:dates, :abbr_daynames][1]
    assert_equal @test_date.strftime("%A"), @language[:dates, :daynames][1]
    assert_equal @test_date.strftime("%b"), @language[:dates, :abbr_monthnames][0]
    assert_equal @test_date.strftime("%B"), @language[:dates, :monthnames][0]
  end
  
  def test_date_conversions
    @language[:dates, :date_formats].each do |name, format|
      assert_equal @test_date.to_formatted_s(name.to_sym), @test_date.strftime(format)
    end
  end
  
  def test_time_strftime
    #  strftime format meaning:
    #  
    #  %a - The abbreviated weekday name (``Sun'')
    #  %A - The  full  weekday  name (``Sunday'')
    #  %b - The abbreviated month name (``Jan'')
    #  %B - The  full  month  name (``January'')
    
    assert_equal @test_time.strftime("%a"), @language[:dates, :abbr_daynames][1]
    assert_equal @test_time.strftime("%A"), @language[:dates, :daynames][1]
    assert_equal @test_time.strftime("%b"), @language[:dates, :abbr_monthnames][0]
    assert_equal @test_time.strftime("%B"), @language[:dates, :monthnames][0]
  end
  
  def test_time_conversions
    @language[:dates, :time_formats].each do |name, format|
      assert_equal @test_time.to_formatted_s(name.to_sym), @test_time.strftime(format)
    end
  end
  
end