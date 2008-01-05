# Create an initializer for this plugin
File.open "#{File.dirname(__FILE__)}/../../../config/initializers/simple_localization.rb" do |f|
  f.write 'simple_localization :language => :en'
end
