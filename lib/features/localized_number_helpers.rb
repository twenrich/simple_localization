# Localizes the number helpers of Rails by loading the default options from the
# language file.
# 
# The only exception here is the +number_to_currency+ helper which is
# reimplemented. This is neccessary in order to overwrite the required strings
# with proper localized ones from the language file.

module ArkanisDevelopment::SimpleLocalization #:nodoc
  module NumberHelper #:nodoc
    
    def number_to_currency(number, options = {})
      options = Language[:numbers].update(Language[:helpers, :number_to_currency]).update(options)
      options = options.stringify_keys
      precision, unit, separator, delimiter = options.delete("precision") { 2 }, options.delete("unit") { "$" }, options.delete("separator") { "." }, options.delete("delimiter") { "," }
      separator = "" unless precision > 0
      begin
        parts = number_with_precision(number, precision).split(Language[:numbers, :separator])
        unit + number_with_delimiter(parts[0], delimiter) + separator + parts[1].to_s
      rescue
        number
      end
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
    
    def number_with_precision(number, precision = Language[:numbers, :precision])
      super(number, precision).gsub '.', Language[:numbers, :separator]
    end
    
  end
end

ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::NumberHelper