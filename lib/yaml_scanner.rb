module ArkanisDevelopment #:nodoc:
  module SimpleLocalization #:nodoc:
    
    Struct.new 'YamlPointer', :line, :level, :syck_map
    
    class YamlScanner
      
      def initialize(yaml_code)
        @yaml_code = yaml_code.split "\n"
        @parsed_yaml = YAML.parse yaml_code
        @pointers = Struct::YamlPointer.new 0, 0, @parsed_yaml
      end
      
      def scan(key)
        syck_key, syck_value = @pointer.syck_map.value.to_a.detect {|syck_key, syck_value| syck_key.value == key}
        return nil unless syck_key and syck_value
        
        yaml_key_code = reconstruct_yaml_key(syck_key)
        @yaml_code.each_with_index do |line, line_number|
          if line.starts_with? "#{indention_for_level}#{yaml_key_code}:"
            @line = line_number
            break
          end
        end
      end
      
      def increase_level
        @pointer.line += 1
        @pointer.
      end
      
      protected
      
      # Returns the indention spaces for the current level.
      def indention_for_level
        @indent * @level
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
      
    end
    
  end
end
