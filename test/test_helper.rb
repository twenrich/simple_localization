# Load all necessary libraries, gems and the init script.
require 'rubygems'
require 'test/unit'
require 'active_record'
require 'action_view'
require File.dirname(__FILE__) + '/../init'

# Set the LANG constant to the LANG environment variable. This is the name of
# the used language file. Defaults to 'de'.
LANG = ENV['LANG'] || 'de'

# Define the +assert_contains+ helper used in some of the test cases.
class Test::Unit::TestCase
  
  protected
  
  def assert_contains(subject, search_string)
    assert subject[search_string], "'#{subject}' should contain '#{search_string}' but doesn\'t"
  end
  
end