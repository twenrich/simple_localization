# Contributed by Roman Gonzalez
require 'yaml'
require 'config/environment'

module ArkanisDevelopment #:nodoc:
  module SimpleLocalization #:nodoc:
    
    module SLGenerator
      VIEWS_DIR = File.join(RAILS_ROOT, 'app', 'views')
      LANGS_DIR = Language.lang_file_dir
      VIEW_FORMATS = ['erb', 'haml', 'rhtml']
      
      # Define the class methods of this module
      class << self
        
        def generate_localization_yml_files
          view_files = Dir[File.join(VIEWS_DIR, "**/*.{#{VIEW_FORMATS.join(',')}}")]
          language_files = Dir[File.join(LANGS_DIR, '*.yml')]
          
          with_app_hash = get_localization_keys_from(view_files)
          raise with_app_hash.to_yaml
          add_localization_keys_to(language_files, with_app_hash)
        end
        
        def get_localization_keys_from(view_files)
          app_root = { 'app' => {} }
          view_files.each do |file|
            IO.readlines(file).each do |line|
              if line =~ /(\= l |l\()([^\)\[\%]*)/
                puts $2.inspect
		last_child = ''
                last_root = ''
                $2.strip.split(',').compact.inject(app_root['app']) do |root, child|
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
        
        def add_localization_keys_to(yml_files, with_app_hash)
           yml_files.each do |yml|
             new_yml_content = get_new_content_of yml, with_app_hash     
             save_in yml, new_yml_content
           end
        end
        
        def get_new_content_of(yml, with_app_hash)
          new_yml_content = File.read(yml)
          app_hash = YAML::load($1) if new_yml_content =~ /^(app:(.|\s)*)/
          with_app_hash.merge!(app_hash)
          with_new_app_yml = convert_app_hash_to_yml with_app_hash
          new_yml_content.gsub!(/^(app:(.|\s)*)/, with_new_app_yml)
          new_yml_content
        end
        
        def save_in(yml, new_yml_content)
          File.open(yml, 'wb') { |file| file.puts new_yml_content }
        end
        
        def convert_app_hash_to_yml(app_hash) 
           app_yml = YAML::dump(app_hash)
           app_yml = delete_comment_hyphens_from app_yml
           app_yml
        end
        
        def delete_comment_hyphens_from(yml)
          yml.gsub(/^---/, "").strip
        end
        
      end
    end
    
  end
end