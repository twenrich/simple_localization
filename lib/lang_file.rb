require File.dirname(__FILE__) + '/nested_hash'

module ArkanisDevelopment #:nodoc:
  module SimpleLocalization #:nodoc:
    
    class LangFile
      
      attr_reader :lang_dir, :lang_code, :parts, :data
      
      # Creates a new LangFile object for the language <code>lang_code</code>
      # in the directory <code>lang_dir</code>.
      def initialize(lang_dir, lang_code)
        @lang_dir, @lang_code = lang_dir, lang_code.to_sym
        @parts = []
        @data = NestedHash.new
      end
      
      # This method loads the base YAML language file (eg. <code>de.yml</code>)
      # and all other language file parts (eg. <code>de.app.about.yml</code>)
      # extending the language. These parts are sorted after their length
      # (specifity), the shortes first, and then inserted into the language
      # data. At the end the ruby file belonging to the language is loaded (eg.
      # <code>de.rb</code>).
      def load
        lang_file_name_without_ext = File.join self.lang_dir, self.lang_code.to_s
        @data = NestedHash.from(YAML.load_file("#{lang_file_name_without_ext}.yml"))
        
        @parts = Dir["#{lang_file_name_without_ext}.*.yml"].collect do |file_name|
          File.basename(file_name, '.yml').split('.').slice(1..-1)
        end
        @parts.sort! {|a, b| a.size <=> b.size}
        @parts.each do |file_sections|
          @data[*file_sections] = YAML.load_file "#{lang_file_name_without_ext}.#{file_sections.join('.')}.yml"
        end
        
        require lang_file_name_without_ext if File.exists?("#{lang_file_name_without_ext}.rb")
      end
      
      # Saves the current data back to the language file and it's parts.
      def save
        lang_file_name_without_ext = File.join self.lang_dir, self.lang_code.to_s
        data_to_save = @data.dup
        
        @parts.reverse_each do |file_sections|
          dump_and_save_yaml data_to_save[*file_sections], "#{lang_file_name_without_ext}.#{file_sections.join('.')}.yml"
          data_to_save[*file_sections_without_lang_code] = nil
        end
        
        dump_and_save_yaml @data, "#{lang_file_name_without_ext}.yml"
      end
      
      # Reloads the data from the language file and merges it with the existing
      # data in the memory. In case of a conflict the new entries from the
      # language file overwrite the entries in the memory.
      def reload
        old_data = @data
        self.load
        @data = old_data.merge! @data
      end
      
      protected
      
      # Dumps the data as YAML to a string, removes any leading document marker
      # ('---') and saves the YAML code to the file <code>target_file</code>.
      def dump_and_save_yaml(data, target_file)
        yaml_data = YAML.dump data
        yaml_data.gsub!(/^---\s*/, '')
        File.open target_file, 'wb' do |f|
          f.write yaml_data
        end
      end
      
    end
    
  end
end