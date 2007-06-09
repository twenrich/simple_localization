require 'yaml'
require "config/environment"

module SLGenerator
  VIEWS_DIR = File.join(RAILS_ROOT, "app/views")
  YML_DIR = ::ArkanisDevelopment::SimpleLocalization::Language.lang_file_dir
  VIEW_FORMATS = ['erb', 'haml', 'rhtml']
  
  def self.get_localization_keys_from(view_files, yml_files)
    app_root = { 'app' => {} }
    view_files.each do |file|
      IO.readlines(file).each do |l|
        if l =~ /l\((.*?)\)/
          last_child = ''
          last_root = ''
          $1.split(',').inject(app_root['app']) do |root, child|
             child = child.strip[1..child.length]
             root.store(child, {}) unless root.key?(child)
             last_child = child
             last_root = root
             root[child]
          end
          last_root[last_child] = 'TODO'
        end
      end
    end
    app_root    
  end

  def self.add_localization_keys_to(yml_files, with_app_hash)
     yml_files.each do |yml|
       new_yml_content = get_new_content_of yml, with_app_hash     
       save_in yml, new_yml_content
     end
  end

  def self.get_new_content_of(yml, with_app_hash)
    new_yml_content = File.read(yml)
    app_hash = YAML::load($1) if new_yml_content =~ /^(app:(.|\s)*)/
    with_app_hash.merge!(app_hash)
    with_new_app_yml = convert_app_hash_to_yml with_app_hash
    new_yml_content.gsub!(/^(app:(.|\s)*)/, with_new_app_yml)
    new_yml_content
  end

  def self.save_in(yml, new_yml_content)
    File.open(yml, 'w') { |file| file.puts new_yml_content }
  end

  def self.convert_app_hash_to_yml(app_hash) 
     app_yml = YAML::dump(app_hash)
     app_yml = delete_comment_hyphens_from app_yml
     app_yml
  end

  def self.delete_comment_hyphens_from(yml)
    yml.gsub(/^---/, "").strip
  end
  
  def self.view_file_collection
    view_files = Dir[File.join(VIEWS_DIR,"**/*.{#{VIEW_FORMATS.join(',')}}")]
    view_files
  end
  
  def self.yml_file_collection
    yml_files = Dir[File.join(YML_DIR, '*.yml')]
    yml_files
  end

  def self.generate_localization_yml_files
    with_app_hash = get_localization_keys_from(view_file_collection, yml_file_collection)
    add_localization_keys_to(yml_file_collection, with_app_hash)
  end
end