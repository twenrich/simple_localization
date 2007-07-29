require File.dirname(__FILE__) + '/nested_hash'

module ArkanisDevelopment #:nodoc:
  module SimpleLocalization #:nodoc:
    
    class LangFile
      
      attr_reader :lang_file_dirs, :lang_code, :yaml_parts, :ruby_parts, :data
      
      # Creates a new LangFile object for the language <code>lang_code</code>
      # which looks for source files in the directories specified in
      # <code>lang_file_dirs</code>.
      # 
      #   LangFile.new :en, 'lang_files'
      #   LangFile.new :en, ['lang_files', 'plugins/lang_files', 'some_dir/with_even_more_lang_files']
      # 
      # The first example will look for <code>en*.yml</code> language files
      # which are located in the <code>lang_file</code> directory.
      # 
      # The second example will look for <code>en*.yml</code> language files,
      # too. However not only in the <code>lang_files</code> directory but also
      # in the directories <code>plugins/lang_files</code> and
      # <code>some_dir/with_even_more_lang_files</code>. The language files are
      # loaded in the order the directories are specified. So entries of
      # language files in the <code>some_dir/with_even_more_lang_files</code>
      # directory will overwrite any previous entries with the same name. Adding
      # new keys to the language file goes in reverse order. A new key for
      # <code>en.yml</code> will be added to
      # <code>some_dir/with_even_more_lang_files/en.yml</code>.
      def initialize(lang_code, lang_file_dirs)
        @lang_code, @lang_file_dirs = lang_code.to_sym, Array(lang_file_dirs)
        @yaml_parts, @ruby_parts = [], []
        # Create a new NestedHash but raise an EntryNotFound exception as
        # default action (if no matching key is found).
        @data = NestedHash.new do raise EntryNotFound end
      end
      
      # This method loads the base YAML language file (eg. <code>de.yml</code>)
      # and all other language file parts (eg. <code>de.app.about.yml</code>)
      # extending the language. These parts are sorted after their length
      # (specifity), the shortes first, and then inserted into the language
      # data. At the end the ruby file belonging to the language is loaded (eg.
      # <code>de.rb</code>).
      def load
        @yaml_parts, @ruby_parts = lookup_parts
        @data.clear
        sort_yaml_parts_for_loading(@yaml_parts).each do |yaml_part|
          yaml_data = YAML.load_file(yaml_part)
          part_sections = File.basename(yaml_part, '.yml').split('.')
          part_sections.delete_at 0 # delete the 'en' at the beginning
          if part_sections.empty?
            @data.merge! yaml_data
          else
            begin
              target_section = @data[*part_sections]
              raise EntryNotFound unless target_section.respond_to? :merge!
              target_section.merge! yaml_data
            rescue EntryNotFound
              @data[*part_sections] = yaml_data
            end
          end
        end
        
        @ruby_parts.each do |ruby_part|
          Kernel.load ruby_part
        end
      end
      
      # Reloads the data from the language file and merges it with the existing
      # data in the memory. In case of a conflict the new entries from the
      # language file overwrite the entries in the memory.
      def reload
        old_data = @data.dup
        self.load
        @data = old_data.merge! @data
      end
      
      def create_key(keys, value = nil)
        keys.collect!{|key| key.to_s}
        target_part, keys = find_part_for_new_entry keys
        puts "keys: #{keys.inspect}, target_part: #{target_part.inspect}"
        
        yaml_code = File.read target_part
        target_line, level, keys_left_to_create = find_line_for_new_entry keys, yaml_code
        puts [target_line, level, keys_left_to_create].inspect
        
        # Add all not already existing keys to the lines array. The specified
        # value will be added to the last key if the value is not nil.
        lines = yaml_code.split "\n"
        begin 
          key = keys_left_to_create.shift
          val = (keys_left_to_create.empty? and value) ? ": #{yaml_escape(value)}" : ":"
          new_line = ('  ' * level) + yaml_escape(key) + val if key 
          lines.insert(target_line, new_line)
          target_line += 1
          level += 1
        end until keys_left_to_create.empty?
        
        new_source_of_yaml_part = lines.join("\n") + "\n"
        puts "\n" + ('-' * 20) + "\n" + new_source_of_yaml_part + "\n" + ('-' * 20)
        begin
          YAML.parse new_source_of_yaml_part
        rescue ArgumentError => e
          raise ProducedInvalidYamlError.new(e)
        end
        
        File.open(target_part, 'wb'){|f| f.write new_source_of_yaml_part}
      end
      
      protected
      
      # Searches the directories in @lang_file_dirs for YAML and Ruby language
      # file parts. It also properly sorts the found parts to get the desired
      # loading order.
      # 
      # In order to load the language file parts in the proper order more
      # specific parts are loaded later, e.g. en.yml is loaded before en.app.yml
      # because en.app.yml is more specific about the section where it's content
      # should go (in the app section of the english language file).
      # 
      # If the same part (e.g. en.app.yml) exists in two language file
      # directories the order of the @lang_file_dirs array (e.g. <code>['dir1',
      # 'dir2']</code>) is important. <code>dir1/en.app.yml</code> is loaded
      # first and after it <code>dir2/en.app.yml</code> is loaded and will
      # eventually overwrite data added by the file in dir1.
      # 
      # The sense behind all this is that the language file directory in the
      # app/languages folder of the Rails application should be the last in the
      # @lang_file_dirs array. Therefore it can overwrite any entries added by
      # previous language file (e.g. the ones shipped with the plugin or some
      # language files added by other plugins).
=begin
      def lookup_and_sort_parts(order)
        yaml_parts = []
        ruby_parts = []
        
        self.lang_file_dirs.each do |lang_file_dir|
          lang_files = Dir.glob(File.join(lang_file_dir, "#{self.lang_code}*.yml"))
          lang_files.collect! {|lang_file| File.basename(lang_file, '.yml').split('.')}
          lang_files.sort! {|a, b| a.size <=> b.size}
          lang_files.each do |lang_file|
            yaml_parts << File.join(lang_file_dir, lang_file.join('.') + '.yml')
          end
          ruby_parts += Dir.glob(File.join(lang_file_dir, "#{self.lang_code}*.rb"))
        end
        
        [yaml_parts, ruby_parts]
      end
=end
      
      # Just searches for the YAML and Ruby parts. The YAML parts are NOT
      # correctly sorted by this method. The Ruby parts are in proper order.
      # 
      # To sort the YAML parts please use the sort_yaml_parts_for_loading or
      # sort_yaml_parts_for_writing methods.
      def lookup_parts
        yaml_parts = ActiveSupport::OrderedHash.new
        ruby_parts = []
        
        self.lang_file_dirs.each do |lang_file_dir|
          yaml_parts_in_this_dir = Dir.glob(File.join(lang_file_dir, "#{self.lang_code}*.yml"))
          yaml_parts[lang_file_dir] = yaml_parts_in_this_dir.collect {|part| File.basename(part)}
          ruby_part_in_this_dir = File.join(lang_file_dir, "#{self.lang_code}.rb")
          ruby_parts << ruby_part_in_this_dir if File.exists?(ruby_part_in_this_dir)
        end
        
        [yaml_parts, ruby_parts]
      end
      
      # Sorts the specified YAML parts in proper loading order. That means first
      # by directories and then by the specificity of the parts. Specificity is
      # the number of section names contained in the file name of the part. More
      # section names results in a higher specificity.
      def sort_yaml_parts_for_loading(yaml_parts)
        ordered_yaml_parts = []
        yaml_parts.each do |lang_file_dir, parts_in_this_dir|
          parts_in_this_dir.sort_by{|part| File.basename(part, '.yml').split('.').size}.each do |part|
            ordered_yaml_parts << File.join(lang_file_dir, part)
          end
        end
        ordered_yaml_parts
      end
      
      # Sorts the YAML parts in proper write order. That means they are orderd
      # first by their specificity and then by the language file directory
      # priority.
      def sort_yaml_parts_for_writing(yaml_parts)
        lang_file_dirs_by_parts = ActiveSupport::OrderedHash.new
        yaml_parts.each do |lang_file_dir, parts_in_this_dir|
          parts_in_this_dir.each do |part|
            lang_file_dirs_by_parts[part] = (lang_file_dirs_by_parts[part] || []) << lang_file_dir
          end
        end
        
        ordered_yaml_parts = []
        lang_file_dirs_by_parts.keys.sort_by{|key| key.split('.').size}.reverse.each do |part|
          lang_file_dirs_by_parts[part].reverse.each do |lang_file_dir|
            ordered_yaml_parts << File.join(lang_file_dir, part)
          end
        end
        
        ordered_yaml_parts
      end
      
      # Searches the YAML part to which the specified key should be written to.
      # 
      # It searches the YAML parts in reverse order and uses the first one which
      # matches as much of the keys array as possible. If we have the parts
      # <code>en.yml</code> and <code>en.app.yml</code> the new entry
      # <code>['app', 'new']</code> would go to <code>en.app.yml</code> because
      # it's name contains more sections of the new key then
      # <code>en.yml</code>.
      # 
      # Thanks to the <code>lookup_and_sort_parts</code> methods the currenty
      # used parts are already correctly ordered. If possible the new entry goes
      # to the last directory specified in @lang_file_dirs (therefore the
      # reverse order in the source code). If there isn't a matching part in
      # there the parts of the next directory will be tested.
      # 
      # Since the last directory in @lang_file_dirs should be the +languages+
      # directory in our Rails application the new entry should be added there
      # if possible.
      def find_part_for_new_entry(keys)
        #puts "looking for #{keys.inspect}"
        file_sections = []
        target_part = sort_yaml_parts_for_writing(@yaml_parts).detect do |part|
          file_sections = File.basename(part, '.yml').split('.')
          file_sections.delete_at 0 # delete the 'en' at the beginning
          #puts "  testing #{part.inspect}: fs #{file_sections.inspect}, fs&k: #{(file_sections & keys).inspect}"
          file_sections & keys == file_sections
        end
        
        # if the target part matches 2 sections remove the first two elements in keys
        file_sections.size.times do keys.shift end
        
        [target_part, keys]
      end
      
      # Searches the line where a new entry should be added. Returns the line
      # number (first line is 0) where the entry should be added, the level of
      # intention the new entry will need and the keys that still need to be
      # inserted into the language file.
      def find_line_for_new_entry(keys, yaml_code)
        # Load all lines of the part and parse it as YAML. We then use the
        # parsed YAML structure to check if a key exists and track it's position
        # by searching through the lines.
        lines = yaml_code.split "\n"
        parsed_yaml = YAML.parse yaml_code
        
        keys_left_to_search = keys.dup
        current_line = 0
        level = 0
        
        # Only analyse the YAML code if the YAML parser actually finds something
        # to parse (read: if the file is not empty).
        if parsed_yaml
          
          puts "searching for keys #{keys.inspect}"
          current_yaml_map = YAML.parse yaml_code
          keys.each do |key|
            puts "  key #{key.inspect}"
            current_yaml_map.value.each do |syck_key, syck_value|
              puts "    checking syck key #{syck_key.value}"
              if syck_key.value == key
                key_yaml_code = reconstruct_yaml_key(syck_key) + ':'
                puts "      start line scan: current line #{current_line}"
                lines.each_with_index do |line, index|
                  current_line = index if index >= current_line and line.starts_with?(('  ' * level) + key_yaml_code)
                end
                puts "      found key: #{key_yaml_code.inspect}, current line: #{current_line} #{lines[current_line].inspect}"
                keys_left_to_search.shift
                current_yaml_map = syck_value
                level += 1
                break
              end
            end
          end
          
          puts "last matching key: line #{current_line}, level #{level}, keys left: #{keys_left_to_search}"
          raise EntryAlreadyExistsError if keys_left_to_search.empty?
          
          # Ok, we got the last matching key, now search the last line of this
          # keys section. After this the current_line variable points to the first
          # line of the next section.
          lines.each_with_index do |line, line_number|
            next unless line_number > current_line
            if line.starts_with?('  ' * level)
              current_line = line_number
            else
              break
            end
          end
          
          # Increment the current line because it should point to the line where
          # the new entry should be added at.
          current_line += 1
          
        end

        [current_line, level, keys_left_to_search]
      end
      
      # Generates the name of the base language file (without any file
      # extension). 
      def get_lang_file_name_without_ext
        File.join self.lang_dir, self.lang_code.to_s
      end
      
      # Tries to reconstruct the YAML code of the given Syck node by analysing
      # the style of the node and quote the node value if necessary.
      def reconstruct_yaml_key(syck_node)
        case syck_node.instance_variable_get :@style
        when :plain
          syck_node.value
        when :quote1
          "'" + syck_node.value.gsub("'", "''") + "'"
        when :quote2
          '"' + syck_node.value.gsub('"', '""') + '"'
        end
      end
      
      # Quotes the specified key name if it contains special YAML chars.
      def yaml_escape(string)
        if string.starts_with?(' ') and not string.scan(/!&|:%/).empty?
          "'" + string.gsub("'", "''") + "'"
        else
          string
        end
      end
      
    end
    
  end
end
