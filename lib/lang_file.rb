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
        @data = NestedHash.new do raise EntryNotFound end
      end
      
      # This method loads the base YAML language file (eg. <code>de.yml</code>)
      # and all other language file parts (eg. <code>de.app.about.yml</code>)
      # extending the language. These parts are sorted after their length
      # (specifity), the shortes first, and then inserted into the language
      # data. At the end the ruby file belonging to the language is loaded (eg.
      # <code>de.rb</code>).
      def load
        lang_file_name_without_ext = get_lang_file_name_without_ext
        @data.clear
        @data.merge! YAML.load_file("#{lang_file_name_without_ext}.yml")
        
        # Split the file names of the parts by dot (without lang code and yml
        # extension) and sort them by the number of elements.
        @parts = Dir["#{lang_file_name_without_ext}.*.yml"].collect do |file_name|
          File.basename(file_name, '.yml').split('.').slice(1..-1)
        end
        @parts.sort! {|a, b| a.size <=> b.size}
        
        @parts.each do |file_sections|
          @data[*file_sections] = YAML.load_file "#{lang_file_name_without_ext}.#{file_sections.join('.')}.yml"
        end
        
        require lang_file_name_without_ext if File.exists?("#{lang_file_name_without_ext}.rb")
      end
      
      # Reloads the data from the language file and merges it with the existing
      # data in the memory. In case of a conflict the new entries from the
      # language file overwrite the entries in the memory.
      def reload
        old_data = @data
        self.load
        @data = old_data.merge! @data
      end
      
      # Saves the current memory data back to the language file and it's parts.
      # This method replaces the language files with generated YAML code. As a
      # result the language files become somehow untidy.
      def save
        lang_file_name_without_ext = get_lang_file_name_without_ext
        data_to_save = @data.dup
        
        @parts.reverse_each do |file_sections|
          dump_and_save_yaml data_to_save[*file_sections], "#{lang_file_name_without_ext}.#{file_sections.join('.')}.yml"
          data_to_save[*file_sections] = nil
        end
        
        dump_and_save_yaml data_to_save, "#{lang_file_name_without_ext}.yml"
      end
      
      
      def create_key(keys, value = nil)
        keys.collect!{|key| key.to_s}
        lang_file_name_without_ext = get_lang_file_name_without_ext
        
        # Get the part where the new key belongs to
        target_part = @parts.reverse.detect{|file_sections| file_sections & keys == file_sections}
        if target_part
          target_file_name = "#{lang_file_name_without_ext}.#{target_part.join('.')}.yml"
          keys = keys - target_part
        else
          target_file_name = "#{lang_file_name_without_ext}.yml"
        end
        
        # Read all lines from the target part and search the last existing key
        lines = nil
        File.open(target_file_name, 'rb'){|f| lines = f.readlines}
        keys_left_to_search = keys.dup
        currently_searched_key = keys_left_to_search.first
        level = 0
        current_line = 0
        
        lines.each_with_index do |line, line_number|
          if !line.nil? and line.starts_with?(('  ' * level) + currently_searched_key)
            current_line = line_number
            level += 1
            keys_left_to_search.shift
            currently_searched_key = keys_left_to_search.first
            break if currently_searched_key.nil?
          end
        end
        
        # Ok, we got the last matching key, now search the last line of this
        # keys section. After this the current_line variable points to the first
        # line of the next section.
        current_line += 1
        lines.each_with_index do |line, line_number|
          next unless line_number > current_line
          if line.starts_with?('  ' * level)
            current_line = line_number
          else
            break
          end
        end
        
        # Add all not already existing keys to the lines array. The specified
        # value will be added to the last key if the value is not nil.
        begin 
          key = keys_left_to_search.shift
          val = (keys_left_to_search.empty? and value) ? ": #{value}\n" : ":\n"
          line = ('  ' * level) + key + val if key 
          current_line += 1
          lines.insert(current_line, line)
          level += 1
        end until keys_left_to_search.empty?
        
        File.open(target_file_name, 'wb'){|f| f.write lines}
      end
      
      protected
      
      # Generates the name of the base language file (without any file
      # extension). 
      def get_lang_file_name_without_ext
        File.join self.lang_dir, self.lang_code.to_s
      end
      
      # Extracts the key out of a line of YAML code by parsing it partially.
      # If the line does not contain a key +nil+ is returned.
      def yaml_get_key_of_line(line)
        matches = line.strip.scan(/(.*):.*/)
        return unless matches
        
        key = matches.flatten.first
        begin
          YAML.parse(key).value
        rescue ArgumentError
          key
        end
      end
      
      def yaml_escape(string)
        "'#{string.gsub("'", "''")}'"
      end
      
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
