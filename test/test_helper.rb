# Load all necessary libraries, gems and the init script.
require 'rubygems'
require 'test/unit'
require 'logger'
require_gem 'rails'
require 'active_record'
require 'action_view'
require File.dirname(__FILE__) + '/../init'

# Set the LANG constant to the LANG environment variable. This is the name of
# the used language file the tests will use. Defaults to 'de'.
LANG_FILE = ENV['LANG_FILE'] || 'de'

# Emulate the default Rails logger and send it's output to STDOUT.
RAILS_DEFAULT_LOGGER = Logger.new(File.dirname(__FILE__) + '/test.log')

# Mimic the Rails version interface. This makes it also possible to test
# features for different rails versions.
module Rails
  module VERSION
    MAJOR, MINOR, TINY = (ENV['RAILS'] || '1.2.3').split('.')
  end
end

# Define the +assert_contains+ helper used in some of the test cases.
class Test::Unit::TestCase
  
  protected
  
  def assert_contains(subject, search_string)
    assert subject[search_string], "'#{subject}' should contain '#{search_string}' but doesn\'t"
  end
  
end