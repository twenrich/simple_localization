# = Localized number helpers
# 
# Localizes the number helpers of Rails by loading the default options from the
# language file.
# 
# The only exception here is the +number_to_currency+ helper which is
# reimplemented. This is neccessary in order to overwrite the required strings
# with proper localized ones from the language file.
# 
# == Used sections of the language file
# 
#   numbers:
#     separator: '.'
#     delimiter: ','
#     precision: 3
# 
# The +numbers+ section contains the default options common to most number
# helpers (+number_to_currency+, +number_to_percentage+,
# +number_with_delimiter+ and +number_with_precision+).
# 
#   helpers:
#     number_to_currency:
#       precision: 2
#       unit: '$'
#     number_to_phone:
#       area_code: false
#       delimiter: '-'
#       extension: 
#       country_code: 
# 
# The +number_to_currency+ section contains new default options for the
# +number_to_currency+ helper. In case of a conflict the options you specify
# here will overwrite the options specified in the +numbers+ section.
# 
# The +number_to_phone+ section contains the default options for the
# +number_to_phone+ helper. You can use all options this helper accepts.

module ArkanisDevelopment::SimpleLocalization #:nodoc
  module LocalizedNumberHelpers
    
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

ActionView::Base.send :include, ArkanisDevelopment::SimpleLocalization::LocalizedNumberHelpers