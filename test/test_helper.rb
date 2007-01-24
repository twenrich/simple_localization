# Load all necessary libraries, gems and the init script.
require 'rubygems'
require 'test/unit'
require 'active_record'
require File.dirname(__FILE__) + '/../init'

# Set the LANG constant to the LANG environment variable. This is the name of
# the used language file. Defaults to 'de'.
LANG = ENV['LANG'] || 'de'