# Quick'n dirty localization of the Time#strftime method.
# 
# Thanks to Patrick Lenz:
# http://poocs.net/articles/2005/10/04/localization-for-rubys-time-strftime

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