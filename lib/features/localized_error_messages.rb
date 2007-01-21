# Overwrites the Active Record default error messages with localized ones from
# the language file.

[:inclusion, :exclusion, :inavlid, :confirmation,
 :accepted, :empty, :blank, :too_long, :too_short,
 :wrong_length, :taken, :not_a_number].each do |msg_name|
  ActiveRecord::Errors.default_error_messages[msg_name] = ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages, msg_name]
end