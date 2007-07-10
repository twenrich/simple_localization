# = Localized application extensions

module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module LocalizedApplicationExtensions #:nodoc:
    
    # A shortcut for the LocalizedApplication::GlobalHelpers#l method. It'll use
    # the value of the string or the name of the symbol as the key to query. Any
    # arguments supplied to this method will be used to format the entry.
    # 
    # Assume the following language file data:
    # 
    #   app:
    #     welcome: Welcome to my page
    #     footer: 'Done by %s'
    #     Welcome to this test page: Willkommen auf dieser Testseite
    #     'This page was created by %s': Diese Seite wurde von %s erstellt
    # 
    # And here's some sample code:
    # 
    #   :welcome.l        # => "Welcome to my page"
    #   :footer.l 'Mr. X' # => "Done by Mr. X"
    #   :unknown.l        # => nil
    # 
    # You can also use this method on strings. However editing the string would
    # result in a new key and therefore a new entry in the language file. Once
    # an entry is created please don't modify the string. Maintenance could
    # become very annoying in this case.
    # 
    # However the value of the string will be used as a default value if the
    # specified entry does not exist. This could come in quite handy sometimes.
    # 
    #   "Welcome to this test page".l           # => "Willkommen auf dieser Testseite"
    #   "This page was created by %s".l 'Mr. X' # => "Diese Seite wurde von Mr. X erstellt"
    #   "This text isn't localized".l           # => "This text isn't localized"
    # 
    def l(*format_args)
      app_args = [self.to_s]
      app_args << {:values => format_args} unless format_args.empty?
      Language.app_scoped *app_args
    end
    
    def lc(*format_args)
      app_args = get_app_file_in_context.split '/'
      app_args << self.to_s
      app_args << {:values => format_args} unless format_args.empty?
      Language.app_not_scoped *app_args
    end
    
    protected
    
    def get_app_file_in_context
      latest_app_file = caller.detect{|level| level.slice /#{Regexp.escape(RAILS_ROOT)}\/app\/(controllers|views)\//}
      latest_app_file.gsub! /^#{Regexp.escape(RAILS_ROOT)}\/app\/(controllers|views)\//, ''
      latest_app_file.gsub! /#{Regexp.escape(File.extname(latest_app_file))}$/, ''
    end
    
  end
end

String.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplicationExtensions
Symbol.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplicationExtensions
