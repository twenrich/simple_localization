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

class Date
    MONTHNAMES = [nil] + %w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember)
    DAYNAMES = %w(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag)
    ABBR_MONTHNAMES = [nil] +  %w(Jan Feb Mär Apr Mai Jun Jul Aug Sep Oct Nov Dez)
    ABBR_DAYNAMES = %w(Son Mon Din Mit Don Fri Sam)

    MONTHS = {'Januar' => 1, 'Februar' => 2, 'März' => 3, 'April' => 4, 'Mai' => 5, 'Juni' => 6, 'Juli' => 7, 'August' => 8, 'September'=> 9, 'Oktober' =>10, 'November' =>11, 'Dezember' =>12}
    DAYS = {'Sonntag' => 0, 'Montag' => 1, 'Dienstag' => 2, 'Mittwoch'=> 3, 'Donnerstag' => 4, 'Freitag' => 5, 'Samstag' => 6}
    ABBR_MONTHS = {'Jan' => 1, 'Feb' => 2, 'Mär' => 3, 'Apr' => 4, 'Mai' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' =>10, 'Nov' =>11, 'Dez' =>12}
    ABBR_DAYS = {'Son' => 0, 'Mon' => 1, 'Din' => 2, 'Mit' => 3, 'Don' => 4, 'Fri' => 5, 'Sam' => 6}
end