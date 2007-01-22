# Localizes the Date class by overwriting its constants with the proper names
# from the language file.
# 
# Uses +silence_warnings+ to prevent const reassignment warnings. We know we're
# doing something bad...

class Date
  silence_warnings do
    MONTHNAMES = [nil] + ArkanisDevelopment::SimpleLocalization::Language[:dates, :monthnames]
    DAYNAMES = ArkanisDevelopment::SimpleLocalization::Language[:dates, :daynames]
    ABBR_MONTHNAMES = [nil] +  ArkanisDevelopment::SimpleLocalization::Language[:dates, :abbr_monthnames]
    ABBR_DAYNAMES = ArkanisDevelopment::SimpleLocalization::Language[:dates, :abbr_daynames]
    
    MONTHS = ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash :section => [:dates, :monthnames], :start_index => 1
    DAYS = ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash :section => [:dates, :daynames], :start_index => 0
    ABBR_MONTHS = ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash :section => [:dates, :abbr_monthnames], :start_index => 1
    ABBR_DAYS = ArkanisDevelopment::SimpleLocalization::Language.convert_to_name_indexed_hash :section => [:dates, :abbr_daynames], :start_index => 0
  end
end