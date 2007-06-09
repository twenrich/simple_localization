namespace :localization do
   desc "Generate yml with localization keys from views"
   task :yml do
      require File.join(File.dirname(__FILE__), '../sl_generator')
      SLGenerator.generate_localization_yml_files
   end
end 
