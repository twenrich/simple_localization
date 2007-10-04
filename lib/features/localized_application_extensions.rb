# = Localized application extensions

require File.expand_path(File.dirname(__FILE__) + '/localized_application')

module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module LocalizedApplicationExtensions #:nodoc:
    
    include ArkanisDevelopment::SimpleLocalization::LocalizedApplication::ContextSensetiveHelpers
    
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
    def l(*args)
      app_args = [self.to_s]
      if args.first.kind_of?(Hash)
        app_args << args.first
      else
        app_args << args unless args.empty?
      end
      Language.app_scoped *app_args
    end
    
    def lc(*args)
      app_args = get_scope_of_context
      app_args << self.to_s
      if args.first.kind_of?(Hash)
        app_args << args.first
      else
        app_args << args unless args.empty?
      end
      Language.app_not_scoped *app_args
    end
    
  end
end

String.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplicationExtensions
Symbol.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplicationExtensions
