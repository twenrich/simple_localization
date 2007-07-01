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
# available to the +to_formated_s+ method of the Date and Time classes.

module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module LocalizedDateAndTime
    
    # Just a little helper to handle the language file data more easily.
    # Converts arrays into hashes with the array values as keys and their
    # indexes as values. Takes and optional start index which defaults to 0.
    # 
    #   convert_to_name_indexed_hash ['Son', 'Mon', 'Din', 'Mit', 'Don', 'Fri', 'Sam'], 1
    #   # => {"Son" => 1, "Mon" => 2, "Din" => 3, "Mit" => 4, "Don" => 5, "Fri" => 6, "Sam" => 7}
    # 
    def self.convert_to_name_indexed_hash(array, start_index = 0)
      array.inject({}) do |memo, element|
        memo[element] = array.index(element) + start_index
        memo
      end
    end
    
  end
end

class Date
  silence_warnings do
    MONTHNAMES = ArkanisDevelopment::SimpleLocalization::CachedLangSectionProxy.new :sections => [:dates, :monthnames] do |localized_data|
      [nil] + localized_data
    end
    DAYNAMES = ArkanisDevelopment::SimpleLocalization::CachedLangSectionProxy.new :sections => [:dates, :daynames]
    ABBR_MONTHNAMES = ArkanisDevelopment::SimpleLocalization::CachedLangSectionProxy.new :sections => [:dates, :abbr_monthnames] do |localized_data|
      [nil] + localized_data
    end
    ABBR_DAYNAMES = ArkanisDevelopment::SimpleLocalization::CachedLangSectionProxy.new :sections => [:dates, :abbr_daynames]
    
    MONTHS = ArkanisDevelopment::SimpleLocalization::CachedLangSectionProxy.new :sections => [:dates, :monthnames] do |localized_data|
      ArkanisDevelopment::SimpleLocalization::LocalizedDateAndTime.convert_to_name_indexed_hash localized_data, 1
    end
    DAYS = ArkanisDevelopment::SimpleLocalization::CachedLangSectionProxy.new :sections => [:dates, :daynames] do |localized_data|
      ArkanisDevelopment::SimpleLocalization::LocalizedDateAndTime.convert_to_name_indexed_hash localized_data
    end
    ABBR_MONTHS = ArkanisDevelopment::SimpleLocalization::CachedLangSectionProxy.new :sections => [:dates, :abbr_monthnames] do |localized_data|
      ArkanisDevelopment::SimpleLocalization::LocalizedDateAndTime.convert_to_name_indexed_hash localized_data, 1
    end
    ABBR_DAYS = ArkanisDevelopment::SimpleLocalization::CachedLangSectionProxy.new :sections => [:dates, :abbr_daynames] do |localized_data|
      ArkanisDevelopment::SimpleLocalization::LocalizedDateAndTime.convert_to_name_indexed_hash localized_data
    end
    
    #make them optional to let default formatting be used. 
    begin
      DATE_FORMAT = ArkanisDevelopment::SimpleLocalization::Language[:dates, :default_formats, :date]
      USE_DEFAULT_DATE = false
    rescue ArkanisDevelopment::SimpleLocalization::EntryNotFound
      USE_DEFAULT_DATE = true
    end
    begin
      TIME_FORMAT = ArkanisDevelopment::SimpleLocalization::Language[:dates, :default_formats, :time]
      USE_DEFAULT_TIME = false
    rescue ArkanisDevelopment::SimpleLocalization::EntryNotFound
      USE_DEFAULT_TIME = true
    end
    begin
      DATE_TIME_FORMAT = ArkanisDevelopment::SimpleLocalization::Language[:dates, :default_formats, :datetime]
      USE_DEFAULT_DATE_TIME = false
    rescue ArkanisDevelopment::SimpleLocalization::EntryNotFound
      USE_DEFAULT_DATE_TIME = true
    end
  end
end

silence_warnings do
  ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS = ArkanisDevelopment::SimpleLocalization::CachedLangSectionProxy.new :sections => [:dates, :date_formats],
    :orginal_receiver => ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS do |localized, orginal|
      orginal.merge localized.symbolize_keys
  end
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
    format.gsub!(/([^%])%c/) {$1 + Date::Date::DATE_TIME_FORMAT} if !Date::USE_DEFAULT_DATE_TIME
    format.gsub!(/([^%])%x/) {$1 + Date::DATE_FORMAT} if !Date::USE_DEFAULT_DATE
    format.gsub!(/([^%])%X/) {$1 + Date::TIME_FORMAT} if !Date::USE_DEFAULT_TIME
    format = format[1, format.length]
    self.strftime_without_localization(format)
  end
  
end

silence_warnings do
  ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS = ArkanisDevelopment::SimpleLocalization::CachedLangSectionProxy.new :sections => [:dates, :time_formats],
    :orginal_receiver => ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS do |localized, orginal|
      orginal.merge localized.symbolize_keys
  end
end