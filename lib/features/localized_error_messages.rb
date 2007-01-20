# Overwrites the Active Record default error messages with localized ones from
# the language file.

ActiveRecord::Errors.default_error_messages = {
	:inclusion => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :inclusion],
	:exclusion => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :exclusion],
	:inavlid => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :inavlid],
	:confirmation => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :confirmation],
	:accepted => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :accepted],
	:empty => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :empty],
	:blank => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :blank],
	:too_long => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :too_long],
	:too_short => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :too_short],
	:wrong_length => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :wrong_length],
	:taken => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :taken],
	:not_a_number => ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, :not_a_number]
}