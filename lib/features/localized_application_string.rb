# = Localized application string

module ArkanisDevelopment::SimpleLocalization #:nodoc:
  module LocalizedApplicationString #:nodoc:
    
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

String.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplicationString
Symbol.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedApplicationString
