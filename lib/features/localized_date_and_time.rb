# Localizes the Date and the Time classes.
# 
# In detail it will overwrite the month and day name constants of the Date
# class with the proper names from the language file. Here +silence_warnings+
# gets used to prevent const reassignment warnings. We know we're doing
# something bad...
# 
# Also updated the date formates of the Date class with the ones of the
# language file.
# 
# Next on the Time class is localized. More specifically it's +strftime+
# method. This is based on the quick'n dirty localization from Patrick Lenz:
# http://poocs.net/articles/2005/10/04/localization-for-rubys-time-strftime
# 
# As done with the date formats of the Date class the time formats of the Time
# class will be updated, too. Again with ones from the language file.

class Date
  silence_warnings do
    MONTHNAMES = [nil] + ArkanisDevelopment::SimpleLocalization::Language[:dates, :monthnames]
    DAYNAMES = ArkanisDevelopment::SimpleLocalization::Language[:dates, :daynames]
    ABBR_MONTHNAMES = [nil] +  ArkanisDevelopment::SimpleLocalization::Language[:dates, :abbr_monthnames]
    ABBR_DAYNAMES = ArkanisDevelopment::SimpleLocalization::Language[:dates, :abbr_daynames]
    
    MONTHS = ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash :section => [:dates, :monthnames], :start_index => 1
    DAYS = ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash :section => [:dates, :daynames], :start_index => 0
    ABBR_MONTHS = ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash :section => [:dates, :abbr_monthnames], :start_index => 1
    ABBR_DAYS = ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash :section => [:dates, :abbr_daynames], :start_index => 0
  end
end

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
  ArkanisDevelopment::SimpleLocalization::Language[:dates, :date_formats].symbolize_keys
)

class Time
  
  alias :strftime_without_localization :strftime
  
  def strftime(format)
    format = format.dup
    format.gsub!(/%a/, Date::ABBR_DAYNAMES[self.wday])
    format.gsub!(/%A/, Date::DAYNAMES[self.wday])
    format.gsub!(/%b/, Date::ABBR_MONTHNAMES[self.mon])
    format.gsub!(/%B/, Date::MONTHNAMES[self.mon])
    self.strftime_without_localization(format)
  end
  
end

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  ArkanisDevelopment::SimpleLocalization::Language[:dates, :time_formats].symbolize_keys
)