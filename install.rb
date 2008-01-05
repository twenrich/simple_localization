# Create an initializer for this plugin
File.open "#{RAILS_ROOT}/config/initializers/simple_localization.rb" do |f|
  f.write 'simple_localization :language => :en'
end
