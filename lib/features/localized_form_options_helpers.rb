# = Localized country names
# 
# Localizes the country list of the FormOptionsHelper module. This country list
# is used by some helpers of this module (ie. +country_options_for_select+).
# 
# == Used sections of the language file
# 
#   countries:
#     Germany: Deutschland
# 
# This feature uses the +countries+ section of the language file. This section
# contains a map used to replace the default countries with the ones specified.
# This is a simple replace operation so you don't need to translate all
# countries for this feature to work.

module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module LocalizedFormOptionsHelpers
    ORIGINAL_COUNTRIES = ActionView::Helpers::FormOptionsHelper::COUNTRIES
  end
end

ArkanisDevelopment::SimpleLocalization::Features.each_time_after_loading_lang_file do
  
  ActionView::Helpers::FormOptionsHelper::COUNTRIES = ArkanisDevelopment::SimpleLocalization::LocalizedFormOptionsHelpers.ORIGINAL_COUNTRIES.collect do |orginal_country|
    ArkanisDevelopment::SimpleLocalization::Language[:countries][orginal_country] || orginal_country
  end
  
end

=begin
module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module LocalizedFormOptionsHelpers
    
    COUNTRIES = ActionView::Helpers::FormOptionsHelper::COUNTRIES
    Language[:countries].each do |original_name, localized_name|
      index = COUNTRIES.index original_name
      COUNTRIES[index] = localized_name
    end
    COUNTRIES.sort!
    
  end
end

ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedFormOptionsHelpers
=end