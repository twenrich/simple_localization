module ArkanisDevelopment::SimpleLocalization #:nodoc
  module NumberHelper #:nodoc
    
    def number_to_currency(number, options = {})
      options = (Language[:numbers] + Language[:helpers, :number_to_currency]).update(options)
      super number, options
    end
    
    def number_to_percentage(number, options = {})
      options = Language[:numbers].update(options)
      super number, options
    end
    
    def number_to_phone(number, options = {})
      options = Language[:helpers, :number_to_phone].update(options)
      super number, options
    end
    
    def number_with_delimiter(number, delimiter = Language[:numbers, :delimiter], separator = Language[:numbers, :separator])
      super number, delimiter, separator
    end
    
    def number_with_precision(number, precision = 3)
      super.gsub '.', Language[:numbers, :separator]
    end
    
  end
end

ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::NumberHelper