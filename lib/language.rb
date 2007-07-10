require File.dirname(__FILE__) + '/lang_file'
require File.dirname(__FILE__) + '/errors'

module ArkanisDevelopment #:nodoc:
  module SimpleLocalization #:nodoc:
    
    # This class loads, caches and manages access to the used language files.
    class Language
      
      @@languages = {}
      @@current_language = nil
      
      cattr_accessor :lang_file_dir, :create_missing_key, :missing_value_default, :debug
      self.debug = true
      self.create_missing_key = false
            
      class << self
        
        # Returns the name of the currently used language file.
        def current_language
          @@current_language
        end
        
        # Sets the currently used language file. If the specified language file
        # is not loaded a +LangFileNotLoaded+ exception will be raised
        def current_language=(new_lang)
          if loaded_languages.include? new_lang.to_sym
            @@current_language = new_lang.to_sym
          else
            raise LangFileNotLoaded.new(new_lang, loaded_languages)
          end
        end
        
        alias_method :use, :current_language=
        
        # Returns the language codes of currently loaded languages.
        # 
        #   Language.loaded_languages  # => [:de, :en]
        # 
        def loaded_languages
          @@languages.keys
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
          languages.each do |lang_code|
            lang_file = LangFile.new self.lang_file_dir, lang_code
            lang_file.load
            @@languages[lang_code.to_sym] = lang_file
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
          if @@languages.empty? or not @@languages[language]
            raise LangFileNotLoaded.new(language, loaded_languages)
          end
          
          sections.collect!{|section| section.kind_of?(Numeric) ? section : section.to_s}
          entry = @@languages[language].data[*sections]
          
          entry || begin
            if create_missing_key
              entry = missing_value_default.nil? ? sections.last : missing_value_default
              @@languages[language].create_key(sections, entry)
              return entry
            else
              raise EntryNotFound.new(sections, language) if self.debug
            end
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
