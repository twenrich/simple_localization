module ArkanisDevelopment #:nodoc:
  module SimpleLocalization #:nodoc:
    
    # Custom error class raised if the uses tries to select a language file
    # which is not loaded. Also stores the name of the failed language file and
    # a list of the loaded ones.
    # 
    #   begin
    #     Language.about :xyz
    #   rescue LangFileNotLoaded => e
    #     e.failed_lang   # => :xyz
    #     e.loaded_langs  # => [:de, :en]
    #   end
    # 
    class LangFileNotLoaded < StandardError
      
      attr_reader :failed_lang, :loaded_langs
      
      def initialize(failed_lang, loaded_langs)
        @failed_lang, @loaded_lang = failed_lang, loaded_langs
        super "The language file \"#{failed_lang}\" is not loaded (currently " +
          "loaded: #{loaded_langs.join(', ')}). Please call the " +
          'simple_localization method at the end of your environment.rb ' +
          'file to initialize Simple Localization or modify this call to ' +
          'include the selected language.'
      end
      
    end
    
    # This error is raised if a requested entry could not be found. This error
    # also stores the requested entry and the language for which the entry
    # could not be found.
    # 
    #   begin
    #     Language.find :en, :nonsens, :void
    #   rescue EntryNotFound => e
    #     e.requested_entry  # => [:nonsens, :void]
    #     e.language         # => :en
    #   end
    # 
    class EntryNotFound < StandardError
      
      attr_reader :requested_entry, :language
      
      def initialize(requested_entry, language)
        @requested_entry, @language = Array(requested_entry), language
        super "The requested entry '#{@requested_entry.join('\' -> \'')}' could " +
          "not be found in the language '#{@language}'."
      end
      
    end
    
    # Error raised if the format method for a language file entry fails. The
    # main purpose of this error is to make debuging easier if format fails.
    # Therefore the detailed error message.
    # 
    #   Language.use :en
    #   
    #   begin
    #     Language.entry :active_record_messages, :too_short, ['a']
    #   rescue EntryFormatError => e
    #     e.language            # => :en
    #     e.entry               # => [:active_record_messages, :too_short]
    #     e.entry_content       # => 'is too short (minimum is %d characters)'
    #     e.format_values       # => ['a']
    #     e.original_exception  # => #<ArgumentError: invalid value for Integer: "a">
    #   end
    # 
    class EntryFormatError < StandardError
      
      attr_reader :language, :entry, :entry_content, :format_values, :original_exception
      
      def initialize(language, entry, entry_content, format_values, original_exception)
        @language, @entry, @entry_content, @format_values, @original_exception = language, entry, entry_content, format_values, original_exception
        super "An error occured while formating the language file entry '#{@entry.join('\' -> \'')}'.\n" +
          "Format string: '#{@entry_content}'\n" +
          "Format arguments: #{@format_values.collect{|v| v.inspect}.join(', ')}\n" +
          "Original exception: #{@original_exception.inspect}"
      end
      
    end
    
    # This class loads, caches and manages the used language files.
    class Language
      
      @@cached_language_data = {}
      @@current_language = nil
      
      cattr_accessor :lang_file_dir, :debug
      self.debug = true
      
      class << self
        
        # Returns the name of the currently used language file.
        def current_language
          @@current_language
        end
        
        # Sets the currently used language file. If the specified language file
        # is not loaded a +LangFileNotLoaded+ will be raised
        def current_language=(new_lang)
          if loaded_languages.include? new_lang.to_sym
            @@current_language = new_lang.to_sym
          else
            raise LangFileNotLoaded.new(new_lang, loaded_languages)
          end
        end
        
        alias_method :use, :current_language=
        
        # Returns the list of currently loaded languages.
        # 
        #   Language.loaded_languages  # => [:de, :en]
        # 
        def loaded_languages
          @@cached_language_data.keys
        end
        
        # Loads the specified language files and caches them. If currently no
        # language is selected the first one of the specified files will be
        # selected.
        # 
        # The path to the language files can be specified in the +lang_file_dir+
        # attribute.
        # 
        #   Language.load :de, :en
        # 
        # This will load the files <code>de.yml</code> and <code>en.yml</code>
        # in the language file directory and caches them in a class variable.
        # If existing the files <code>de.rb</code> and <code>en.rb</code> will
        # be executed. It also selects <code>:de</code> as the active language.
        def load(*languages)
          languages.flatten!
          languages.each do |language|
            lang_file_without_ext = "#{self.lang_file_dir}/#{language}"
            @@cached_language_data[language.to_sym] = YAML.load_file "#{lang_file_without_ext}.yml"
            require lang_file_without_ext if File.exists?("#{lang_file_without_ext}.rb")
          end
          self.use languages.first if current_language.nil?
        end
        
        # Searches the cached data of the specified language for the entry
        # defined by +sections+.
        # 
        # If the specified language file is not loaded an +LangFileNotLoaded+
        # exception is raised. If the entry is not found +nil+ is returned.
        # 
        #   Language.find :de, :active_record_messages, :not_a_number  # => "ist keine Zahl."
        # 
        def find(language, *sections)
          language = language.to_sym
          if @@cached_language_data.empty? or not @@cached_language_data[language]
            raise LangFileNotLoaded.new(language, loaded_languages)
          end
          
          entry = sections.inject(@@cached_language_data[language]) do |memo, section|
            memo[(section.kind_of?(Numeric) ? section : section.to_s)] if memo
          end
          
          entry || begin
            raise EntryNotFound.new(sections, language) if self.debug
          end
        end
        
        # Returns the specified entry from the currently used language file. It's
        # possible to specify neasted entries by using more than one parameter.
        # 
        #   Language.entry :active_record_messages, :too_short  # => "ist zu kurz (mindestens %d Zeichen)."
        # 
        # This will return the +too_short+ entry within the +active_record_messages+
        # entry. The YAML code in the language file looks like this:
        # 
        #   active_record_messages:
        #     too_short: ist zu kurz (mindestens %d Zeichen).
        # 
        # If the specified language file is not loaded an +LangFileNotLoaded+
        # exception is raised. If the entry is not found +nil+ is returned.
        # 
        # This method also integrates +format+. To format an entry specify an
        # array with the format options as the last paramter:
        # 
        #   Language.entry :active_record_messages, :too_short, [10] # => "ist zu kurz (mindestens 10 Zeichen)."
        # 
        def entry(*args)
          if args.last.kind_of?(Hash)
            options = {:values => nil}.merge args.delete_at(-1)
            options.assert_valid_keys :values
            format_values = Array(options[:values])
          end
          
          if args.last.kind_of?(Array)
            format_values = args.delete_at(-1)
          end
          
          lang_entry = self.find(self.current_language, *args)
          
          if format_values
            begin
              format(lang_entry, *format_values)
            rescue StandardError => e
              self.debug ? raise(EntryFormatError.new(self.current_language, args, lang_entry, format_values, e)) : lang_entry
            end
          else
            lang_entry
          end
        end
        
        alias_method :[], :entry
        
        # Returns a hash with the meta data of the specified language (defaults
        # to the currently used language). Entries not present in the language
        # file will default to +nil+. If the specified language file is not
        # loaded an +LangFileNotLoaded+ exception is raised.
        # 
        #   Language.about :de
        #   # => {
        #          :language => 'Deutsch',
        #          :author => 'Stephan Soller',
        #          :comment => 'Deutsche Sprachdatei. Kann als Basis für neue Sprachdatein dienen.',
        #          :website => 'http://www.arkanis-development.de/',
        #          :email => nil, # happens if no email is specified in the language file.
        #          :date => '2007-01-20'
        #        }
        # 
        def about(lang = self.current_language)
          lang = lang.to_sym
          
          defaults = {
            :language => nil,
            :author => nil,
            :comment => nil,
            :website => nil,
            :email => nil,
            :date => nil
          }
          
          defaults.update self.find(lang, :about).symbolize_keys
        end
        
      end
      
    end
    
  end
end