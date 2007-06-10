# Contributed by Roman Gonzalez
namespace :localization do
  desc 'Extract the localization entries from views and add them to the language file'
  task :extract_entries do
    require File.join(File.dirname(__FILE__), 'sl_generator')
    ArkanisDevelopment::SimpleLocalization::SLGenerator.generate_localization_yml_files
  end
end