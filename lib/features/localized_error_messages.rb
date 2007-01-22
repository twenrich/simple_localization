# Overwrites the Active Record default error messages with localized ones from
# the language file.

ActiveRecord::Errors.default_error_messages.update(
  ArkanisDevelopment::SimpleLocalization::Language[:active_record_messages].symbolize_keys
)