# = Localized application string

module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module LocalizedApplicationString #:nodoc:
    
    def l(*format_args)
      Language.entry
    end
    
    def lc(*format_args)
    end
    
  end
end

