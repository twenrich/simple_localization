# Require all files from the lib directory
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require(file) }

# Include modules into the corresponding classes
ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::Helper
ActiveRecord::Base.send :include, ArkanisDevelopment::SimpleLocalization::ModelExtensions