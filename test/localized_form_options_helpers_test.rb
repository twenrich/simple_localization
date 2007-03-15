require File.dirname(__FILE__) + '/test_helper'

# Init SimpleLocalization with just the localized_form_options_helpers feature
# activated.
simple_localization :language => LANG, :only => :localized_form_options_helpers

class LocalizedFormOptionsHelpersTest < Test::Unit::TestCase
  
  include ActionView::Helpers::FormOptionsHelper
  include ArkanisDevelopment::SimpleLocalization::LocalizedFormOptionsHelpers
  
  def test_country_options_for_select
    html_options = country_options_for_select
    
    ArkanisDevelopment::SimpleLocalization::Language[:countries].each do |original_name, localized_name|
      assert_contains html_options, localized_name
    end
  end
  
end