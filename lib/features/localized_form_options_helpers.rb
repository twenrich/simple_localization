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
# 
# == Notes
# 
# This feature keeps a private copy of the original +COUNTRIES+ constant in
# it's +LocalizedFormOptionsHelpers+ module. This backup is used to create a
# localized list each time a language file is loaded. If you manipulate the
# <code>ActionView::Helpers::FormOptionsHelper::COUNTRIES</code> constant by
# yourself after calling the +simple_localization+ method these changes are
# lost each time a language file is loaded.
# 
# If you don't plan to switch to another language file during runtime this
# won't be a problem. If you do, please make your changes to the +COUNTRIES+
# constant before calling the +simple_localization+ method.

module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module LocalizedFormOptionsHelpers
    ORIGINAL_COUNTRIES = ActionView::Helpers::FormOptionsHelper::COUNTRIES
  end
end

silence_warnings do
  ActionView::Helpers::FormOptionsHelper::COUNTRIES = ArkanisDevelopment::SimpleLocalization::CachedLangSectionProxy.new :sections => [:countries],
  :orginal_receiver => ActionView::Helpers::FormOptionsHelper::COUNTRIES do |localized, orginal|
    orginal.collect{|original_country| localized[original_country] || original_country}
  end
end