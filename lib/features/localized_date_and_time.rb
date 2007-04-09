# = Localized Date and Time classes
# 
# This feature will overwrite the month and day name constants of the Date
# class with the proper names from the language file. Here +silence_warnings+
# gets used to prevent const reassignment warnings. We know we're doing
# something bad...
# 
# Also updates the date formates of the Date class with the ones from the
# language file.
# 
# Next on the Time class is localized. More specifically it's +strftime+
# method. This is based on the quick'n dirty localization from Patrick Lenz:
# http://poocs.net/articles/2005/10/04/localization-for-rubys-time-strftime.
# It's a bit modified to respect the '%%' escape sequence.
# 
# As done with the date formats of the Date class the time formats of the
# Time class will be updated, too. Again with ones from the language file.
# 
# == Used sections of the language file
# 
# The necessary localized strings are read from the +dates+ section of the
# language file:
# 
#   dates:
#     monthnames: [January, February, March, April, May, June, July, August, September, October, November, December]
#     daynames: [Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]
#     abbr_monthnames: [Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]
#     abbr_daynames: [Sun, Mon, Tue, Wed, Thu, Fri, Sat]
#     date_formats:
#       short: '%e %b'
#       long: '%B %e, %Y'
#     time_formats:
#       short: '%d %b %H:%M'
#       long: '%B %d, %Y %H:%M'
# 
# The +monthnames+, +daynames+, +abbr_monthnames+ and +abbr_daynames+ entries
# will overwrite the corresponding constants of the Date class. The
# +date_formats+ and +time_formats+ entries are used to update the formats
# available to the +to_formated_s+ method.

ArkanisDevelopment::SimpleLocalization::Features.each_time_after_loading_lang_file do
  
  class Date
    silence_warnings do
      MONTHNAMES = [nil] + ArkanisDevelopment::SimpleLocalization::Language[:dates, :monthnames]
      DAYNAMES = ArkanisDevelopment::SimpleLocalization::Language[:dates, :daynames]
      ABBR_MONTHNAMES = [nil] + ArkanisDevelopment::SimpleLocalization::Language[:dates, :abbr_monthnames]
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
  
end

class Time
  
  alias :strftime_without_localization :strftime
  
  # Quick'n dirty localization of the Time#strftime method based on the work of
  # Patrick Lenz: http://poocs.net/articles/2005/10/04/localization-for-rubys-time-strftime.
  # It's a bit modified to respect the '%%' escape sequence.
  def strftime(format)
    format = ' ' + format.dup
    format.gsub!(/([^%])%a/) {$1 + Date::ABBR_DAYNAMES[self.wday]}
    format.gsub!(/([^%])%A/) {$1 + Date::DAYNAMES[self.wday]}
    format.gsub!(/([^%])%b/) {$1 + Date::ABBR_MONTHNAMES[self.mon]}
    format.gsub!(/([^%])%B/) {$1 + Date::MONTHNAMES[self.mon]}
    format = format[1, format.length]
    self.strftime_without_localization(format)
  end
  
end

ArkanisDevelopment::SimpleLocalization::Features.each_time_after_loading_lang_file do
  
  ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
    ArkanisDevelopment::SimpleLocalization::Language[:dates, :time_formats].symbolize_keys
  )
  
end