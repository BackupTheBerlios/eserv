######################################################################
#	Elog_Parse.pl
#	Выборка и представление заказанных статистических данных.
#
#	19 марта 2003 года				ООО "ЛЭНК"
######################################################################

my $CurrentTime;						# хранение текущего времени

######################################################################
#	DisplayState
#	Процедура вывода текущего состояния в окно браузера.
######################################################################

sub DisplayState ($) {
   my $Message = HTML->JSCode (shift);		# текст сообщения
   my $InsideScript = qq(window.status = "$Message";);	# текст скрипта
   print HTML->Script (Param => { Language => "Javascript" }, Text => $InsideScript);	# вывести скрипт установки сообщения
}

######################################################################
#	ModeHeader
#	Процедура определения наименования колонки режима
######################################################################

sub ModeHeader ($) {
   my $Mode = shift;					# код режима
   return "Хост" if ($Mode eq "h");
   return "IP-адрес" if ($Mode eq "i");
   return "Пользователь" if ($Mode eq "u");
   return "Объект";
}

######################################################################
#	ProcessRequest
#	Основная процедура исполнения запроса.
######################################################################
#	Запись статистики представляет собой массив следующего формата:
#	[0] - ключ сортировки;
#	[1] - общая длительность запросов в миллисекундах;
#	[2] - принято байт;
#	[3] - передано байт;
#	[4] - общее число запросов;
#	[5] - число успешных запросов (коды ответа 1xx, 2xx, 3xx);
#	[6] - объект, по которому считается статистика;
#	[7] - хост (используется при подсчете по объектам).
######################################################################

sub ProcessRequest ($) {
   my $Action = shift;					# код операции
   my $CountMode = $Environment->Mode;		# режим подсчета статистики
   my $SortMode = $Environment->Sort;		# режим сортировки
   Runtime->BeginPage ("Elog - статистика работы Eserv/3");	# вывести начало страницы
   $| = 1;							# сбрасывать буфера

#	Настройка фильтрации, подготовка аккумуляторов

   DisplayState ("Начало обработки");		# вывести стартовое сообщение
   $CurrentTime = time;					# зафиксировать текущее время
   my $FileCount = 0;					# счетчик обработанных файлов
   my $StartTime = substr ($Environment->StartDate->ToInternalString (), 8);	# время начала обработки
   my $EndTime = substr ($Environment->EndDate->ToInternalString (), 8);	# время окончания обработки
   my $StartDay = Date->ToJulian ($Environment->StartDate->Month,
     $Environment->StartDate->Day, $Environment->StartDate->Year);	# дата начала обработки
   my $EndDay = Date->ToJulian ($Environment->EndDate->Month,
     $Environment->EndDate->Day, $Environment->EndDate->Year);	# дата окончания обработки
   my $HostFilter = $Environment->Host;		# фильтр по хосту
   my $UserFilter = $Environment->User;		# фильтр по пользователю
   my $PeerIPFilter = $Environment->PeerIP;	# фильтр по IP-адресу
   my $IgnoreHosts = $Environment->IgnoreHosts;	# системный антифильтр по хостам
   my $HotActions = $Environment->HotActions;	# системный фильтр по событиям
   my ($TotalGet, $TotalPost, $TotalTime) = (0, 0, 0);	# аккумуляторы итоговых сумм
   my %Stat = ();						# таблица статистики

#	Чтение данных из файлов статистики

   for (my $CurrentDay = $StartDay;
     ($CurrentDay < $EndDay) || (($CurrentDay == $EndDay) && !$EndTime); ++$CurrentDay) {	# все даты с начальной по конечную
	local *LOGFILE;					# локальные файловые операции
	my $FileName;
	{
	   my ($CMonth, $CDay, $CYear);		# временные переменные
	   ($CMonth, $CDay, $CYear, undef) = Date->FromJulian ($CurrentDay);	# разобрать дату на составляющие
	   $FileName = sprintf ("%04d%02d%02d", $CYear, $CMonth, $CDay) . "stat.log";	# имя файла
	}
	if (open (LOGFILE, $Environment->LogDataPath . "/" . $FileName)) {	# файл открылся
	   DisplayState ("Обрабатывается файл " . $FileName . ", всего обработано: " . $FileCount);	# вывести сообщение
	   $CurrentTime = time;				# зафиксировать текущее время
	   while (my $LogLine = <LOGFILE>) {	# пока файл читается
		{
		   my $NewTime = time;			# проверить текущее время
		   if ($NewTime > $CurrentTime + 60) {	# прошла минута
			DisplayState ("Обрабатывается файл " . $FileName .
			  ", всего обработано: " . $FileCount);	# вывести сообщение
			$CurrentTime = time;		# зафиксировать текущее время
		   }
		}
		chomp ($LogLine);				# убрать конец строки
		my @LogLine = split (/ /, $LogLine);	# разбить строку на составляющие
		pop (@LogLine) if (@LogLine > 10);	# удалить лишний элемент строки
		$LogLine = pop (@LogLine);		# выбрать Content-Type
		$LogLine = $1 if ($LogLine =~ m/(.*),$/);		# отрезать ненужную запятую
		push (@LogLine, $LogLine);		# положить обратно
		my $Got = ($CurrentDay != $StartDay) && ($CurrentDay != $EndDay);	# признак попадания под фильтр
		if (!$Got) {				# пограничное число
		   my @Time = localtime ($LogLine[0]);	# время
		   my $Time = sprintf ("%02d%02d%02d", $Time[2], $Time[1], $Time[0]);	# время во внутреннем представлении 
		   $Got = (($CurrentDay == $StartDay) && ($Time >= $StartTime)) ||
		     (($CurrentDay == $EndDay) && ($Time <= $EndTime));	# дополнительный фильтр по времени
		}
		my @Actions;				# события и коды ошибок
		my @Hosts;					# хосты
		if ($Got) {					# попадание под фильтр
		   @Actions = split (/\//, $LogLine[3]);	# события
		   $Actions[0] = uc ($Actions[0]);	# привести к верхнему регистру
		   $Got = $HotActions->{$Actions[0]} + 0;	# наложить фильтр по событиям
		}
		if ($Got) {					# все еще попадает
		   @Hosts = split (/\//, $LogLine[8]);	# хосты
		   $Hosts[1] = lc ($Hosts[1]);	# привести к нижнему регистру
		   $Got = !($IgnoreHosts->{$Hosts[1]} + 0);	# наложить фильтр по хостам
		}
		$Got = (($HostFilter eq "") || ($HostFilter eq $Hosts[1])) if ($Got);	# пользовательский фильтр по хосту
		if ($Got) {					# все еще попадает
		   $LogLine[7] = lc ($LogLine[7]);	# привести полдьзователя к нижнему регистру
		   $Got = (($UserFilter eq "") || ($UserFilter eq $LogLine[7]));	# пользовательский фильтр по пользователю
		}
		$Got = (($PeerIPFilter eq "") || ($PeerIPFilter eq $LogLine[2])) if ($Got);	# пользовательский фильтр по IP-адресу
		if ($Got) {					# строка попадает под анализ
		   my $RecordKey = $LogLine[2];	# пусть будет IP-адрес
		   if ($CountMode eq "h") {		# подсчет по хостам
			$RecordKey = $Hosts[1];		# ключом является хост
		   } elsif ($CountMode eq "o") {	# подсчет по объектам
			$RecordKey = $LogLine[6];	# ключом является полный URL объекта
		   } elsif ($CountMode eq "u") {	# подсчет по пользователям
			$RecordKey = $LogLine[7];	# ключом является пользователь
		   }
		   $Stat{$RecordKey} = [ "", 0, 0, 0, 0, 0, $RecordKey, $Hosts[1] ]
		     unless (exists ($Stat{$RecordKey}));	# создать новую запись статистики
		   my $StatRecord = $Stat{$RecordKey};	# прямая ссылка на массив
		   $StatRecord->[1] += $LogLine[1];	# счетчик длительности запросов
		   $TotalTime += $LogLine[1];
		   my @Sizes = split (/\//, $LogLine[4]);	# параметры размеров
		   $StatRecord->[2] += $Sizes[0];	# счетчик принятых байт
		   $TotalGet += $Sizes[0];
		   $StatRecord->[3] += ($Sizes[1] + 0);	# счетчик переданных байт
		   $TotalPost += ($Sizes[1] + 0);
		   ++$StatRecord->[4];			# нарастить общее число запросов
		   ++$StatRecord->[5] if ($Actions[1] =~ m/^[1-3]/);	# нарастить счетчик успешных запросов
		   my $SortKey = $LogLine[2];		# пусть будет IP-адрес
		   if ($SortMode eq "h") {		# сортировка по хостам
			$SortKey = $Hosts[1];		# ключом является хост
		   } elsif ($SortMode eq "o") {	# сортировка по объектам
			$SortKey = $LogLine[6];		# ключом является полный URL объекта
		   } elsif ($SoftMode eq "u") {	# сортировка по пользователям
			$SortKey = $LogLine[7];		# ключом является пользователь
		   } elsif ($SortMode eq "g") {	# сортировка по размеру принятого
			$SortKey = $StatRecord->[2];	# ключом является подсчитанный объем
		   } elsif ($SortMode eq "p") {	# сортировка по размеру отправленного
			$SortKey = $StatRecord->[3];	# ключом является подсчитанный объем
		   } elsif ($SortMode eq "t") {	# сортировка по длительности исполнения
			$SortKey = $StatRecord->[1];	# ключом является подсчитанная длительность
		   }
		   $StatRecord->[0] = $SortKey;	# записать ключ сортировки
		}
	   }
	   close (LOGFILE);				# закрыть файл
	   ++$FileCount;					# нарастить счетчик
	   DisplayState ("Всего обработано: " . $FileCount);	# вывести сообщение
	   $CurrentTime = time;				# зафиксировать текущее время
	} else {
	   my $NewTime = time;				# проверить текущее время
	   if ($NewTime > $CurrentTime + 60) {	# прошла минута
		DisplayState ("Всего обработано: " . $FileCount);	# вывести сообщение
		$CurrentTime = time;			# зафиксировать текущее время
	   }
	}
   }

#	Сортировка

   my @Stat;						# массив для сортировки
   if ($Environment->Reverse) {			# сотрировка по убыванию
	if ($SortMode =~ m/(g|p|t)/) {		# сортировка по числам
	   @Stat = sort { $b->[0] <=> $a->[0] } values (%Stat);	# отсортировать массив статистики
	} else {
	   @Stat = sort { $b->[0] cmp $a->[0] } values (%Stat);	# отсортировать массив статистики
	}
   } else {
	if ($SortMode =~ m/(g|p|t)/) {		# сортировка по числам
	   @Stat = sort { $a->[0] <=> $b->[0] } values (%Stat);	# отсортировать массив статистики
	} else {
	   @Stat = sort { $a->[0] cmp $b->[0] } values (%Stat);	# отсортировать массив статистики
	}
   }
   %Stat = ();						# исходный хэш больше не нужен

#	Подготовка ссылок для дальнейшей детализации

   my $LinkIndex = 0;					# неизвестно, надо ли формировать ссылки
   my $BaseLink = "";					# заготовка для ссылки
   {
	my ($NewCountMode, $NewFilter);		# для формирования ссылок на дальнейшую детализацию
	my $NewSortMode = $SortMode;			# по умолчанию режим сортировки сохраняется
	my %Filters = ();					# параметры фильтрации
	$Filters{"h"} = $HostFilter if ($HostFilter ne "");	# есть фильтр по хосту
	$Filters{"i"} = $PeerIPFilter if ($PeerIPFilter ne "");	# есть фильтр по IP-адресу
	$Filters{"u"} = $UserFilter if ($UserFilter ne "");	# есть фильтр по пользователю
	if ($CountMode eq "h") {			# статистика считалась по хостам
	   $NewCountMode = (($UserFilter eq "") && ($PeerIPFilter eq "")) ? "i" : "o";	# новый режим подсчета статистики
	   $NewSortMode = $NewCountMode if ($SortMode eq $CountMode);	# сортировка меняется, если была по хостам
	   $NewFilter = "h";				# накладывается фильтр по хосту
	   $LinkIndex = 6;				# индекс элемента массива для извлечения фильтра
	   delete ($Filters{"h"}) if (exists ($Filters{"h"}));	# а существующий фильтр убрать
	} elsif ($CountMode eq "i") {			# статистика считалась по IP-адресам
	   $NewCountMode = ($HostFilter eq "") ? "h" : "o";	# новый режим подсчета статистики
	   $NewSortMode = $NewCountMode if ($SortMode eq $CountMode);	# сортировка меняется, если была по хостам
	   $NewFilter = "i";				# накладывается фильтр по IP-адресу
	   $LinkIndex = 6;				# индекс элемента массива для извлечения фильтра
	   delete ($Filters{"i"}) if (exists ($Filters{"i"}));	# а существующий фильтр убрать
	} elsif ($CountMode eq "u") {			# статистика считалась по пользователям
	   $NewCountMode = ($HostFilter eq "") ? "h" : "o";	# новый режим подсчета статистики
	   $NewSortMode = $NewCountMode if ($SortMode eq $CountMode);	# сортировка меняется, если была по хостам
	   $NewFilter = "u";				# накладывается фильтр по пользователю
	   $LinkIndex = 6;				# индекс элемента массива для извлечения фильтра
	   delete ($Filters{"u"}) if (exists ($Filters{"u"}));	# а существующий фильтр убрать
	} else {						# осталась статистка по объектам
	   if ($HostFilter eq "") {			# есть куда фильтровать
		$NewCountMode = "o";			# статистика продолжает считаться по объектам
		$NewFilter = "h";				# накладывается фильтр по хосту
		$LinkIndex = 7;				# индекс элемента массива для извлечения фильтра
	   }
	}
	if ($LinkIndex) {					# ссылка формируется
	   $BaseLink = $Environment->CGIURL . "/Elog.cgi?a=i&amp;m=" . $NewCountMode .
	     "&amp;s=" . $NewSortMode . "&amp;r=" . $Environment->Reverse . "&amp;dd=" .
	     $Environment->StartDate->ToInternalString () . "," .
	     $Environment->EndDate->ToInternalString ();	# заготовка статической части ссылки
	   while (my ($Key, $Value) = each (%Filters)) {	# все оставшиеся фильтры
		$Value =~ s/(?![a-zA-Z0-9._])(.)/"%" . sprintf ("%02x", ord ($1))/ge;	# перекодировать нехорошие символы
		$BaseLink .= "&amp;" . $Key . "=" . HTML->HTMLCode ($Value);	# поместить в ссылку
	   }
	   $BaseLink .= "&amp;" . $NewFilter . "=";		# и добавить заготовку переменного фильтра
	}
   }

#	Вывод шапки отчета

   print HTML->Paragraph (Text => "Статистика работы Eserv/3", Param => { class => "title" });	# вывести заголовок
   {
	my $MonthNames = [ "января", "февраля", "марта", "апреля", "мая", "июня", "июля",
	  "августа", "сентября", "октября", "ноября", "декабря" ];	# вспомогательная таблица месяцев
	my $DateFormat = "\aD \aT \aC, \a2H:\a2I";	# строка форматирования даты-времени
	my @Filters = ();					# массив визуализации параметров отбора
	push (@Filters, "Дата и время: с " .
	  HTML->HTMLCode ($Environment->StartDate->Format ($DateFormat, $MonthNames)) . " по " .
	  HTML->HTMLCode ($Environment->EndDate->Format ($DateFormat, $MonthNames)));	# отбор по дате и времени
	push (@Filters, "Хост: " . HTML->HTMLCode ($HostFilter)) if ($HostFilter ne "");	# отбор по хосту
	push (@Filters, "IP-адрес: " . HTML->HTMLCode ($PeerIPFilter)) if ($PeerIPFilter ne "");	# отбор по IP-адресу
	push (@Filters, "Пользователь: " . HTML->HTMLCode ($UserFilter)) if ($UserFilter ne "");	# отбор по пользователю
	print HTML->Paragraph (Text => join (HTML->Break (), @Filters));	# вывести параметры отбора
   }
   print HTML->Table (BeginOnly => 1, Param => { class => "tborder", width => "100%",
     border => 0, cellspacing => 0, cellpadding => 0 });	# начать таблицу-рамку
   print HTML->Tr (BeginOnly => 1), HTML->Td (BeginOnly => 1);	# начать строку и ячейку
   print HTML->Table (BeginOnly => 1, Param => { width => "100%", border => 0,
     cellspacing => 1, cellpadding => 2 });	# начать вложенную таблицу
   print HTML->Tr (Param => { class => "thead" }, Text =>
     HTML->Td (Param => { align => "center" }, Text => HTML->Bold (Text => "N")) .
     HTML->Td (Param => { align => "center" },
      Text => HTML->Bold (Text => ModeHeader ($CountMode))) .
     HTML->Td (Param => { align => "center" }, Text => HTML->Bold (Text => "Передано")) .
     HTML->Td (Param => { align => "center" }, Text => HTML->Bold (Text => "Принято")) .
     HTML->Td (Param => { align => "center" }, Text => HTML->Bold (Text => "Длительность")) .
     HTML->Td (Param => { align => "center" }, Text => HTML->Bold (Text => "Доступность")));	# вывести заголовочную строку

#	Вывод таблицы

   my $LineCount = 0;					# счетчик выведенных строк
   my $Stat;						# ссылка на запись статистики
   for $Stat (@Stat) {					# все записи
	++$LineCount;					# нарастить счетчик строк
	my $Object = HTML->HTMLCode ($Stat->[6]);	# имя отображаемого объекта
	if ($LinkIndex) {					# требуется ссылка
	   my $ActiveFilter = $Stat->[$LinkIndex];	# код изменяемого фильтра
	   $ActiveFilter =~ s/(?![a-zA-Z0-9._])(.)/"%" . sprintf ("%02x", ord ($1))/ge;	# перекодировать нехорошие символы
	   $Object = HTML->Anchor (Param => { href => $BaseLink . HTML->HTMLCode ($ActiveFilter),
	     target => "_blank" }, Text => $Object);	# навернуть ссылку
	}
	print HTML->Tr (Param => { class => ("alt1", "alt2")[$LineCount & 1] }, Text =>
	  HTML->Td (Param => { align => "right" }, Text => $LineCount) .
	  HTML->Td (Param => { align => "left" }, Text => $Object) .
	  HTML->Td (Param => { align => "right" }, Text => $Stat->[3] . " (" .
	   sprintf ("%05.2f", ($TotalPost) ? $Stat->[3] * 100 / $TotalPost: 0) . "%)") .
	  HTML->Td (Param => { align => "right" }, Text => $Stat->[2] . " (" .
	   sprintf ("%05.2f", ($TotalGet) ? $Stat->[2] * 100 / $TotalGet : 0) . "%)") .
	  HTML->Td (Param => { align => "right" }, Text => $Stat->[1] . " (" .
	   sprintf ("%05.2f", ($TotalTime) ? $Stat->[1] * 100 / $TotalTime : 0) . "%)") .
	  HTML->Td (Param => { align => "right" }, Text =>
	   sprintf ("%05.2f", ($Stat->[4]) ? $Stat->[5] * 100 / $Stat->[4] : 0) . "%"));	# вывести строку
   }

#	Завершение вывода

   print HTML->Tr (Param => { class => "thead" }, Text =>
     HTML->Td (Param => { align => "center" }, Text => "&nbsp;") .
     HTML->Td (Param => { align => "right" }, Text => HTML->Bold (Text => "Всего:")) .
     HTML->Td (Param => { align => "right" }, Text => HTML->Bold (Text => $TotalPost)) .
     HTML->Td (Param => { align => "right" }, Text => HTML->Bold (Text => $TotalGet)) .
     HTML->Td (Param => { align => "right" }, Text => HTML->Bold (Text => $TotalTime)) .
     HTML->Td (Param => { align => "center" }, Text => "&nbsp;"));	# вывести заголовочную строку
   print HTML->Table (EndOnly => 1);		# закрыть таблицу
   print HTML->Td (EndOnly => 1), HTML->Tr (EndOnly => 1),  HTML->Table (EndOnly => 1);	# закрыть таблицу-рамку
   DisplayState ("Обработка завершена");		# вывести финальное сообщение
   Runtime->EndPage ();					# закрыть страницу
}

1;
