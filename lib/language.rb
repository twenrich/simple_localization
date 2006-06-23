ActiveRecord::Errors.default_error_messages = {
	:inclusion => 'ist nicht in Liste gültiger Optionen enthalten.',
	:exclusion => 'ist reserviert.',
	:inavlid => 'ist ungültig.',
	:confirmation => 'simmt mit der Bestätigung nicht überein.',
	:accepted => 'muss akzeptiert werden.',
	:empty => "darf nicht leer sein.",
	:blank => "darf nicht leer sein.",
	:too_long => 'ist zu lang (maximal %d Zeichen).',
	:too_short => 'ist zu kurz (mindestens %d Zeichen).',
	:wrong_length => 'hat die falsche Länge (es sollten %d Zeichen sein).',
	:taken => 'ist bereits vergeben.',
	:not_a_number => 'ist keine Zahl.'
}

Date::MONTHNAMES = [
	nil, 'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
	'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
]