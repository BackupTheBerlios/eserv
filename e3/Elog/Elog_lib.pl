######################################################################
#	Elog_lib.pl
#	Основная библиотека поддержки системы обработки статистики
#	Elog
#
#	19 марта 2003 года				ООО "ЛЭНК"
######################################################################


######################################################################
#	Runtime
#	Класс вспомогательных функций
######################################################################

package Runtime;

######################################################################
#	BeginPage
#	Вывод начального фрагмента HTML-страницы.
#	Вызов:
#		Runtime->BeginPage (Title)
#	Параметры:
#		Title - заголовок страницы.
######################################################################

sub BeginPage {
   shift;							# имя класса не требуется
   my $Title = shift;					# заголовок страницы
   ::DisplayHTTPHeader ("200 OK", "windows-1251");	# вывести заголовок HTTP
   print HTML->BeginPage (Title => $Title, Charset => "windows-1251",
     Body => { bgcolor => "#F7FBFF", text => "#000000", link => "#000080",
      alink => "#C00000", vlink => "#4040C0" });	# вывести теги начала страницы
   print HTML->Style (Style => { "select, input, textarea, td, p" => { "font-family" => "Arial",
     "font-size" => "10pt" },
     td => { "vertical-align" => "top" },
     hr => { color => "#404040" },
     ".title" => { color => "#800000", "font-size" => "12pt", "font-weight" => "bold",
      "text-align" => "center" },
     ".subtitle" => { color => "#008080", "font-weight" => "bold" },
     ".subtitlec" => { color => "#008080", "font-weight" => "bold", "text-align" => "center" },
     ".copyright" => { "font-size" => "8pt", "text-align" => "center" },
     ".thead" => { color => "#000080", "background-color" => "#C0E0FF" },
     ".tborder" => { "background-color" => "#404040" },
     ".alt1" => { "background-color" => "#F7FFF7" },
     ".alt2" => { "background-color" => "#F7FBFB" }});	# вывести таблицу стилей для Internet Explorer
   print HTML->Style (Style => { "select, input, textarea, td, p" => { fontfamily => "'Arial'",
     fontsize => "10pt" },
     td => { verticalalign => "top" },
     hr => { color => "#404040" },
     ".title" => { color => "#800000", fontsize => "12pt", fontweight => "bold",
      textalign => "center" },
     ".subtitle" => { color => "#008080", fontweight => "bold" },
     ".subtitlec" => { color => "#008080", fontweight => "bold", textalign => "center" },
     ".copyright" => { fontsize => "8pt", textalign => "center" },
     ".thead" => { color => "#000080", backgroundcolor => "#C0E0FF" },
     ".tborder" => { backgroundcolor => "#404040" },
     ".alt1" => { backgroundcolor => "#F7FFF7" },
     ".alt2" => { backgroundcolor => "#F7FBFB" }});	# вывести таблицу стилей для Netscape Navigator
}

######################################################################
#	EndPage
#	Вывод финального фрагмента HTML-страницы.
######################################################################

sub EndPage {
   print HTML->Paragraph (Param => { class => "copyright" }, Text => "Elog 1.0 RC1" .
     HTML->Break () . "&copy; " .
     HTML->Anchor (Param => { href => "mailto:dimisaev\@mail.ru" }, Text => "Дмитрий Исаев") .
      " 1999, идея" . HTML->Break () . "&copy; " .
     HTML->Anchor (Param => { href => "http://www.lankgroup.ru/", target => "_blank"},
     Text => "ООО &quot;ЛЭНК&quot;") . " 2003");	# вывести копирайт
   print HTML->EndPage ();				# закрыть страницу
}


######################################################################
#	Environment
#	Класс функций настройки рабочей среды
######################################################################

package Environment;

######################################################################
#	Load
#	Настройка рабочей среды по данным конфигурационных файлов.
#	Вызов:
#		Environment->Load ([SoftErrors])
#	Параметры:
#		SoftErrors - флаг блокировки ошибок загрузки.
#	Возвращает ссылку на вновь созданный или исходный объект
#	Environment.
######################################################################

sub Load {
   my $Self = shift;					# ссылка на объект или имя класса
   my $SoftErrors = shift () + 0;			# флаг блокировки ошибок
   if (ref ($Self) eq "") {				# вызван метод класса
	my $New = { error => "", logdatapath => "", cgiurl => "", noncgiurl => ".",
	  hotactions => "", ignorehosts => "",
	  startdate => undef, enddate => undef,
	  host => "", peerip => "", user => "", mode => "h", sort => "g", reverse => 1 };	# создать новый объект
	$Self->{"timezone"} = Time->SystemTimeOffset ();	# получить системное значение смещения времени
	$Self = bless ($New, $Self);			# привязать к классу
   }
   $Self->{"inipath"} = ".";				# по умолчанию поиск в текущем каталоге
   if (!$Self->_ReadIni ("config.ini", qw (IniPath))) {	# прочитать главный описатель конфигурации не удалось
	$Self->{"error"} = "Error reading configuration file config.ini";
	return $Self;					# вернуть ссылку
   }
   if (!$Self->_ReadIni ("path.ini", qw (LogDataPath))) {	# не удалось прочитать таблицу раскладки
	if (!$SoftErrors) {				# ошибка не блокирована
	   $Self->{"error"} =
	     "Error reading configuration file " . $Self->{"inipath"} . "/path.ini";
	   return $Self;					# вернуть ссылку
	}
   }
   if (!$SoftErrors && ($Self->{"logdatapath"} eq "")) {	# не заданы важные пути
	$Self->{"error"} = "Undefined critical data path in " . $Self->{"inipath"} . "/path.ini";
	return $Self;
   }
   if (!$Self->_ReadIni ("setup.ini", qw (CGIURL NonCGIURL HotActions IgnoreHosts TimeZone))) {	# не удалось прочитать настройки
	$Self->{"error"} =
	  "Error reading configuration file " . $Self->{"inipath"} . "/setup.ini";
   }
   my %HotActions = map { uc ($_) => 1 } split (/ /, $Self->{"hotactions"});	# таблица обрабатываемых событий
   my %IgnoreHosts = map { lc ($_) => 1 } split (/ /, $Self->{"ignorehosts"});	# таблица игнорируемых хостов
   $Self->{"hotactions"} = \%HotActions;		# заменить строки ссылками на хэши
   $Self->{"ignorehosts"} = \%IgnoreHosts;
   if (!defined ($Self->{"startdate"})) {		# параметры фильтрации по дате-времени еще не заданы
	my $DayTime = DateTime->Now ($Self->{"timezone"})->MidNight ();	# полночь текущего дня
	$Self->{"startdate"} = $DayTime->GoDay (1 - $DayTime->Day ());	# первое число месяца
	$Self->{"enddate"} = $DayTime->Copy ()->GoMonth (1);	# начало месяца
   }
   return $Self;						# вернуть ссылку
}

######################################################################
#	AttachUserSettings
#	Метод подключения пользовательских установок.
#	Вызов:
#		Object->AttachUserSettings (CGI, Cookies)
#	Параметры:
#		CGI	  - ссылка на объект CGI;
#		Cookies - ссылка на объект Cookies.
######################################################################

sub AttachUserSettings {
   my $Self = shift;					# ссылка на объект
   my $CGI = shift;					# ссылка на CGI
   my $Cookies = shift;					# ссылка на Cookies
   my $Temp = $CGI->RetrieveValue ("h");		# фильтр по хостам
   $Temp = $Cookies->RetrieveValue ("h") if (!defined ($Temp));	# взять из долговременных настроек
   $Self->{"host"} = lc ($Temp) if (defined ($Temp));	# содержится в настройках
   $Temp = $CGI->RetrieveValue ("i");		# фильтр по IP-адресам
   $Temp = $Cookies->RetrieveValue ("i") if (!defined ($Temp));	# взять из долговременных настроек
   $Self->{"peerip"} = $Temp if (defined ($Temp));	# содержится в настройках
   $Temp = $CGI->RetrieveValue ("u");		# фильтр по пользователям
   $Temp = $Cookies->RetrieveValue ("u") if (!defined ($Temp));	# взять из долговременных настроек
   $Self->{"user"} = lc ($Temp) if (defined ($Temp));	# содержится в настройках
   $Temp = $CGI->RetrieveValue ("m");		# режим анализа
   $Temp = $Cookies->RetrieveValue ("m") if (!defined ($Temp));	# взять из долговременных настроек
   $Self->{"mode"} = $Temp if (defined ($Temp));	# содержится в настройках
   $Temp = $CGI->RetrieveValue ("s");		# режим сортировки
   $Temp = $Cookies->RetrieveValue ("s") if (!defined ($Temp));	# взять из долговременных настроек
   $Self->{"sort"} = $Temp if (defined ($Temp));	# содержится в настройках
   $Temp = $CGI->RetrieveValue ("r");		# флаг обращения сортировки
   $Temp = $Cookies->RetrieveValue ("r") if (!defined ($Temp));	# взять из долговременных настроек
   $Self->{"reverse"} = $Temp if (defined ($Temp));	# содержится в настройках
   if ($CGI->Count ("sd")) {				# дата и время переданы из формы
	my ($SD, $SM, $SY, $SH, $SI, $ED, $EM, $EY, $EH, $EI) =
	  Misc->Define ($CGI->RetrieveValue ("sd"), $CGI->RetrieveValue ("sm"),
	  $CGI->RetrieveValue ("sy"), $CGI->RetrieveValue ("sh"), $CGI->RetrieveValue ("si"),
	  $CGI->RetrieveValue ("ed"), $CGI->RetrieveValue ("em"), $CGI->RetrieveValue ("ey"),
	  $CGI->RetrieveValue ("eh"), $CGI->RetrieveValue ("ei"));		# выбрать
	my ($StartDate, $EndDate) =
	  sort (DateTime->Create ($SY, $SM, $SD, $SH, $SI, 0)->ToInternalString (),
	  DateTime->Create ($EY, $EM, $ED, $EH, $EI, 0)->ToInternalString ());	# отсортированные штампы времени
	$Self->{"startdate"} = DateTime->FromInternalString ($StartDate);	# сформировать штампы
	$Self->{"enddate"} = DateTime->FromInternalString ($EndDate);
   } else {
	$Temp = $CGI->RetrieveValue ("dd");		# передаваемые штампы времени
	$Temp = $Cookies->RetrieveValue ("dd") if (!defined ($Temp));	# взять из долговременных настроек
	if (defined ($Temp)) {				# существуют
	   my ($StartDate, $EndDate) = sort (split (/,/, $Temp));	# разбить на начальную и конечную и заодно отсортировать
	   $Self->{"startdate"} = DateTime->FromInternalString ($StartDate);	# сформировать штампы
	   $Self->{"enddate"} = DateTime->FromInternalString ($EndDate);
	}
   }
}

######################################################################
#	_ReadIni
#	Чтение конфигурационного файла.
#	Вызов:
#		Object->_ReadIni (File[, List])
#	Параметры:
#		File - имя конфигурационного файла. Файл ищется в
#		       каталоге, задаваемом параметром IniPath;
#		List - список проверяемых ключевых слов. Если список
#		       пуст, файл считывается в настройку целиком.
#	Возвращает ненулевое значение, если файл успешно прочитан, и
#	нулевое в противном случае.
######################################################################

sub _ReadIni {
   my $Self = shift;					# ссылка на объект
   my $File = shift;					# имя конфигурационного файла
   my %KeyList = map { (lc ($_) => 1) } @_;	# таблица ключевых слов
   local *CONFIG;						# местные операции с файлами
   return 0 if (!open (CONFIG, $Self->{"inipath"} . "/" . $File));	# файл не открылся - ошибка
   while (my $String = <CONFIG>) {			# до конца файла
	chomp ($String);					# отсечь конец строки
	if ($String =~ m/\t/) {				# строка правильного формата
	   my ($Name, $Value) = split (/\t/, $String, 2);	# разбить на имя и значение
	   $Name = lc ($Name);				# привести к нижнему регистру
	   $Self->{$Name} = $Value if (!%KeyList || $KeyList{$Name});	# нет фильтрации или параметр попадает
	}
   }
   close (CONFIG);					# закрыть файл
   return 1;						# выполнено
}

######################################################################
#	AUTOLOAD
#	Вспомогательная функция получения значений настроечных параметров
######################################################################

use vars qw ($AUTOLOAD %AllowedParameters);
for (qw (inipath logdatapath cgiurl noncgiurl hotactions ignorehosts host peerip user
  timezone startdate enddate mode sort reverse error)) {
   $AllowedParameters{$_} = 1; }			# сформировать таблицу параметров

sub AUTOLOAD {
   my $Name = lc ($AUTOLOAD);				# имя вызываемого метода
   $Name =~ s/.*:://;					# убрать лишнее
   return $_[0]->{$Name} if (exists ($AllowedParameters{$Name}));	# значение допустимого параметра
   return undef;						# нет такого параметра
}

1;
