######################################################################
#	Elog_Index.pl
#	Вывод формы выбора параметров отбора статистики для системы
#	Elog
#
#	19 марта 2003 года				ООО "ЛЭНК"
######################################################################

######################################################################
#	ProcessRequest
#	Основная процедура исполнения запроса.
######################################################################

sub ProcessRequest ($) {
   my @MonthNames = ("января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа",
     "сентября", "октября", "ноября", "декабря");	# вспомогательная таблица месяцев
   Runtime->BeginPage ("Elog - статистика работы Eserv/3");	# вывести начало страницы
   print HTML->Paragraph (Text => "Задайте режим обработки", Param => { class => "title" });	# вывести заголовок
   print HTML->Form (BeginOnly => 1, Param => { target => "_blank",
     action => ($Environment->CGIURL . "/Elog.cgi"), method => "GET", name => "QueryForm" });	# начать форму
   print HTML->Table (BeginOnly => 1, Param => { class => "tborder", width => "100%",
     border => 0, cellspacing => 0, cellpadding => 0 });	# начать таблицу-рамку
   print HTML->Tr (BeginOnly => 1), HTML->Td (BeginOnly => 1);	# начать строку и ячейку
   print HTML->Table (BeginOnly => 1, Param => { width => "100%", border => 0,
     cellspacing => 1, cellpadding => 5 });	# начать вложенную таблицу
   print HTML->Tr (Param => { class => "thead" }, Text =>
     HTML->Td (Param => { colspan => 2, align => "center" }, Text =>
     HTML->Bold (Text => "Представление")));	# вывести заголовочную строку
   print HTML->Tr (Param => { class => "alt1" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "Выводить данные по:") .
     HTML->Td (Text =>
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "m", value => "h" },
        Flags => { checked => ($Environment->Mode eq "h") }) . "хостам &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "m", value => "i" },
        Flags => { checked => ($Environment->Mode eq "i") }) . "IP-адресам &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "m", value => "u" },
        Flags => { checked => ($Environment->Mode eq "u") }) . "пользователям &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "m", value => "o" },
        Flags => { checked => ($Environment->Mode eq "o") }) . "объектам")));	# вывести строку выбора вида статистики
   print HTML->Tr (Param => { class => "alt2" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "Сортировать данные по:") .
     HTML->Td (Text =>
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "h" },
        Flags => { checked => ($Environment->Sort eq "h") }) . "хостам &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "i" },
        Flags => { checked => ($Environment->Sort eq "i") }) . "IP-адресам &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "u" },
        Flags => { checked => ($Environment->Sort eq "u") }) . "пользователям &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "o" },
        Flags => { checked => ($Environment->Sort eq "o") }) . "объектам &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "g" },
        Flags => { checked => ($Environment->Sort eq "g") }) . "размеру принятого &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "p" },
        Flags => { checked => ($Environment->Sort eq "p") }) . "размеру отправленного &nbsp; ") .
      HTML->NoBr (Text =>
	 HTML->Input (Param => { type => "radio", name => "s", value => "t" },
        Flags => { checked => ($Environment->Sort eq "t") }) . "затраченному времени") .
      HTML->Hr (Param => { size => 1, width => "100%" }, Flags => { noshade => 1 }) .
      HTML->NoBr (Text =>
       HTML->Input (Param => { type => "radio", name => "r", value => 0 },
        Flags => { checked => !$Environment->Reverse }) . "по возрастанию &nbsp; ") .
      HTML->NoBr (Text =>
       HTML->Input (Param => { type => "radio", name => "r", value => 1 },
        Flags => { checked => $Environment->Reverse }) . "по убыванию")));	# вывести строку вида сортировки
   print HTML->Tr (Param => { class => "thead" }, Text =>
     HTML->Td (Param => { colspan => 2, align => "center"}, Text =>
     HTML->Bold (Text => "Отбор")));		# вывести заголовочную строку
   print HTML->Tr (Param => { class => "alt1" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "Дата и время:") .
     HTML->Td (Text =>
      HTML->NoBr (Text => "с &nbsp;" .
       HTML->Select (Param => { name => "sd" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => $_ },
	     Flags => { selected => ($Environment->StartDate->Day == $_)
       }) . $_ } (1..31))) .
       HTML->Select (Param => { name => "sm" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => $_ },
	     Flags => { selected => ($Environment->StartDate->Month == $_)
       }) . $MonthNames[$_ - 1] } (1..12))) .
       HTML->Input (Param => { name => "sy", value => $Environment->StartDate->Year, size => 4,
        maxlength => 4 }) . " " .
       HTML->Select (Param => { name => "sh" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => sprintf ("%02d", $_) },
	     Flags => { selected => ($Environment->StartDate->Hour == $_)
       }) . sprintf ("%02d", $_) } (0..23))) . ":" .
       HTML->Select (Param => { name => "si" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => sprintf ("%02d", $_) },
	     Flags => { selected => ($Environment->StartDate->Minute == $_)
       }) . sprintf ("%02d", $_) } (0..59))) .
       " &nbsp; ") .
      HTML->NoBr (Text => "по &nbsp;" .
       HTML->Select (Param => { name => "ed" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => $_ },
	     Flags => { selected => ($Environment->EndDate->Day == $_)
       }) . $_ } (1..31))) .
       HTML->Select (Param => { name => "em" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => $_ },
	     Flags => { selected => ($Environment->EndDate->Month == $_)
       }) . $MonthNames[$_ - 1] } (1..12))) .
       HTML->Input (Param => { name => "ey", value => $Environment->EndDate->Year, size => 4,
        maxlength => 4 }) . " " .
       HTML->Select (Param => { name => "eh" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => sprintf ("%02d", $_) },
	     Flags => { selected => ($Environment->EndDate->Hour == $_)
       }) . sprintf ("%02d", $_) } (0..23))) . ":" .
       HTML->Select (Param => { name => "ei" }, Text =>
       join ("", map {
	   HTML->Option (Param => { value => sprintf ("%02d", $_) },
	     Flags => { selected => ($Environment->EndDate->Minute == $_)
       }) . sprintf ("%02d", $_) } (0..59))))));	# отбор по дате и времени
   print HTML->Tr (Param => { class => "alt2" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "Хост:") .
     HTML->Td (Text =>
     HTML->Input (Param => { type => "text", name => "h",
     value => HTML->HTMLCode ($Environment->Host), size => 80, maxlength => 80 })));	# отбор по хосту
   print HTML->Tr (Param => { class => "alt1" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "IP-адрес:") .
     HTML->Td (Text =>
     HTML->Input (Param => { type => "text", name => "i",
     value => HTML->HTMLCode ($Environment->PeerIP), size => 80, maxlength => 80 })));	# отбор по IP-адресу
   print HTML->Tr (Param => { class => "alt2" }, Text =>
     HTML->Td (Param => { class => "subtitle" }, Flags => { nowrap => 1 },
     Text => "Пользователь:") .
     HTML->Td (Text =>
     HTML->Input (Param => { type => "text", name => "u",
     value => HTML->HTMLCode ($Environment->User), size => 80, maxlength => 80 })));	# отбор по пользователю
   print HTML->Table (EndOnly => 1);		# закрыть таблицу
   print HTML->Td (EndOnly => 1), HTML->Tr (EndOnly => 1),  HTML->Table (EndOnly => 1);	# закрыть таблицу-рамку
   print HTML->Input (Param => { type => "hidden", name => "a", value => "p" });	# код действия
   print HTML->Paragraph (Param => { align => "center" }, Text =>
     HTML->Input (Param => { type => "submit", value => "Выполнить" }) . " &nbsp; " .
     HTML->Input (Param => { type => "reset", value => "Очистить" }));	# вывести кнопки
   print HTML->Form (EndOnly => 1);			# закрыть форму
   Runtime->EndPage ();				# закрыть страницу
}

1;
