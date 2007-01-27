# Localizes the country list of the FormOptionsHelper module. This country list
# is used by some helpers of this module (ie. +country_options_for_select+).

module ArkanisDevelopment::SimpleLocalization #:nodoc
  module FormOptionsHelper #:nodoc
    
    COUNTRIES = ActionView::Helpers::FormOptionsHelper::COUNTRIES
    Language[:countries].each do |original_name, localized_name|
      index = COUNTRIES.index original_name
      COUNTRIES[index] = localized_name
    end
    COUNTRIES.sort!
    
  end
end

ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::FormOptionsHelper