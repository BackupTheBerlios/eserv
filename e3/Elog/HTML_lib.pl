######################################################################
#	HTML_lib.pl
#	Библиотека формирования HTML-тегов
#
#	5 марта 2003					ООО "ЛЭНК"
######################################################################

package HTML;

######################################################################
#	BeginPage
#	Формирование начальных тегов HTML-страницы:
#	<html>, <head>, <title>, <meta>, <body>
#	Вызов:
#		HTML->BeginPage (Title => s, Charset => s, HTTP-Equiv => r,
#			Name => r, Body => r)
#	Параметры:
#		Title	     - заголовок страницы;
#		Charset    - номер кодовой страницы для вывода;
#		HTTP-Equiv - ссылка на хэш или массив параметров тега
#				 meta http-equiv;
#		Name	     - ссылка на хэш или массив параметров тега
#				 meta name;
#		Body	     - ссылка на хэш или массив параметров
#				 тега body;
#		Style	     - ссылка на хэш или массив параметров стиля
#				 тега body
######################################################################

sub BeginPage {
   shift;							# имя класса не требуется
   my %Parameters = HTML->_GetParameters (\@_, 1);	# параметры вызова
   my $String = "<html><head>\n<meta name='Generator' content='Script'>\n";	# обязательный заголовок
   $String .= "<title>" . $Parameters{"title"} . "</title>\n"
     if (defined ($Parameters{"title"}));		# вывести титул
   my %Data = HTML->_GetParameters ($Parameters{"http-equiv"}, 0);	# параметры HTTP
   $Data{"Content-Type"} = "text/html; charset=" . $Parameters{"charset"}
     if (defined ($Parameters{"charset"}) || ($Parameters{"charset"} ne ""));	# задана кодовая страница
   while (my ($Param, $Value) = each (%Data)) {	# все переданные параметры
	$String .= "<meta http-equiv='" . $Param . "' content='" . $Value . "'>\n";
   }
   %Data = HTML->_GetParameters ($Parameters{"name"}, 0);	# информация о документе
   while (my ($Param, $Value) = each (%Data)) {	# все переданные параметры
	$String .= "<meta name='" . $Param . "' content='" . $Value . "'>\n";
   }
   return $String . "</head>\n" . HTML->_GenericTag (Tag => "body", BeginOnly => 1,
     Param => $Parameters{"body"}, Style => $Parameters{"style"}) . "\n"; # добавить тег body и завершить
}

######################################################################
#	EndPage
#	Формирование завершающих тегов HTML-страницы
#	Вызов:
#		HTML->EndPage
######################################################################

sub EndPage { return "</body></html>\n"; }

######################################################################
#	Script
#	Формирование тега описания скрипта
#	Вызов:
#		HTML->Script (Text => s, BeginOnly => n, EndOnly => n,
#			Param => r)
#		Text	    - текст скрипта;
#		BeginOnly - флаг формирования только открывающего тега;
#		EndOnly   - флаг формирования только закрывающего тега;
#		Param	    - ссылка на массив или хэш параметров тега.
######################################################################

sub Script {
   shift;							# имя класса не требуется
   my %Parameters = HTML->_GetParameters (\@_, 1);	# параметры вызова
   my %Param = HTML->_GetParameters ($Parameters{"param"}, 1);	# получить параметры собственно тега
   $Param{"language"} = "JavaScript" if (!defined ($Param{"language"}));	# язык по умолчанию
   my $JavaFlag = ($Param{"language"} =~ m/^(javascript|js|jscript)\b/i);	# флаг JavaScript
   my $String = "";					# обрабатываемая строка
   if (!$Parameters{"endonly"}) {			# начало разрешено
	$String .= HTML->_GenericTag (Tag => "script", Param => \%Param, BeginOnly => 1);	# открыть тег
	$String .= "<!--" if ($JavaFlag);		# комментарий для JavaScript
	$String .= "\n";					# отбить строку
   }
   $String .= $Parameters{"text"} if (defined ($Parameters{"text"}) && !$Parameters{"beginonly"} && !$Parameters{"endonly"});	# текст внутри тега
   if (!$Parameters{"beginonly"}) {			# завершение разрешено
	$String .= "\n";					# отбить строку
	$String .= "//-->" if ($JavaFlag);		# комментарий для JavaScript
	$String .= "</script>";				# закрывающий тег
   }
   return $String;					# вернуть результат
}

######################################################################
#	Style
#	Формирование таблицы стилей
# 	Вызов:
#		HTML->Style (Param => r, Flags => r, Import => r,
#			Style => r)
#	Параметры:
#		Param  - ссылка на массив или хэш основных параметров
#			   таблицы стилей;
#		Flags  - ссылка на массив или хэш флаговых параметров
#			   таблицы стиля;
#		Import - ссылка на массив URL импортируемых таблиц;
#		Style  - ссылка на массив или хэш, содержащий
#			   описываемую таблицу стилей, вида
#			   ("tag" => r, ...), где
#			   "tag" - ссылка на массив или хэш, задающий
#				     параметры строки стиля.
######################################################################

sub Style {
   shift;							# имя класса не требуется
   my %Parameters = HTML->_GetParameters (\@_, 1);	# параметры вызова
   my $String = HTML->_GenericTag (Tag => "style", Param => $Parameters{"param"},
     Flags => $Parameters{"flags"}, BeginOnly => 1) . "<!--\n";	# сформировать управляющий тег
   {
	my $Import = $Parameters{"import"};		# список импортируемых таблиц
	if (ref ($Import) eq "ARRAY") {		# ссылка правильная
	   for (@$Import) {				# все URL
		$String .= "\@import URL('" . $_ . "');\n" if (defined ($_) && ($_ ne ""));	# составить таблицу
	   }
	}
   }
   {
	my %Param = HTML->_GetParameters ($Parameters{"style"}, 0);	# получить параметры стиля
	while (my ($Code, $Value) = each (%Param)) {	# все строки таблицы
	   my %Styler = HTML->_GetParameters ($Value, 0);	# взять в свой хэш
	   my @Styler = ();				# строка пока пустая
	   while (my ($Param, $Value) = each (%Styler)) {	# все параметры строки
		push (@Styler, $Param . ": " . $Value);	# заготовку в массив
	   }
	   $String .= $Code . " {" . join ("; ", @Styler) . "}\n" if (@Styler);	# вывести строку стиля
	}
   }
   return $String . "--></style>";			# закрыть таблицу стиля
}

######################################################################
#	_GenericTag
#	Вспомогательная функция конструирования тега HTML
#	Вызов:
#		HTML->_GenericTag (Tag => s, Text => s, BeginOnly => n,
#			EndOnly => n, Param => r, Flags => r, Style => r)
#	Параметры:
#		Tag	    - имя тега;
#		Text	    - текст, заключаемый внутрь тега
#				(<tag>Text</tag>);
#		BeginOnly - флаг формирования только открывающего тега;
#		EndOnly   - флаг формирования только закрывающего тега;
#		Param	    - ссылка на массив или хэш параметров тега;
#		Flags	    - ссылка на массив или хэш флаговых параметров
#				тега;
#		Style	    - ссылка на массив или хэш параметров стиля
#				тега.
######################################################################

sub _GenericTag {
   shift;							# имя класса не требуется
   my %Parameters = HTML->_GetParameters (\@_, 1);	# параметры вызова
   my $String = "";					# строка для сборки тега
   if (defined ($Parameters{"tag"}) && ($Parameters{"tag"} ne "")) {	# имя тега задано
	if (!$Parameters{"endonly"}) {		# начало разрешено
	   $String .= "<" . $Parameters{"tag"};	# имя тега
	   my %Data = HTML->_GetParameters ($Parameters{"param"}, 1);	# параметры тега
	   while (my ($Param, $Value) = each (%Data)) {	# все параметры
		$String .= " " . $Param;
		$String .= "='" . $Value . "'" if (defined ($Value));	# параметр, имеющий значение
	   }
	   %Data = HTML->_GetParameters ($Parameters{"flags"}, 1);	# флаговые параметры тега
	   while (my ($Param, $Value) = each (%Data)) {	# все флаги
		$String .= " " . $Param if ($Value);	# добавить флаг
	   }
	   %Data = HTML->_GetParameters ($Parameters{"style"}, 1);	# параметры тега
	   my @Styler = ();				# ничего пока не задано
	   while (my ($Param, $Value) = each (%Data)) {	# все параметры строки
		push (@Styler, $Param . ": " . $Value);	# заготовку в массив
	   }
	   $String .= " style='" . join ("; ", @Styler) . "'" if (@Styler);	# добавить стилевой параметр
	   $String .= ">";				# завершить тег
	}
	$String .= $Parameters{"text"} if (defined ($Parameters{"text"}) && !$Parameters{"beginonly"} && !$Parameters{"endonly"});	# текст внутри тега
	$String .= "</" . $Parameters{"tag"} . ">" if (!$Parameters{"beginonly"});	# завершение тега
   }
   return $String;
}

######################################################################
#	_GetParameters
#	Вспомогательная функция выборки параметров в хэш из массива
#	или хэша
#	Вызов:
#		HTML->_GetParameters (ref, ic)
#	Параметры:
#		ref - предполагаемая ссылка на массив или хэш;
#		ic  - флаг преобразования ключей будущего хэша к
#		      нижнему регистру.
######################################################################

sub _GetParameters {
   shift;							# имя класса не требуется
   my $Reference = shift;				# предполагаемая ссылка
   my $IgnoreCase = shift;				# флаг игнорирования регистра
   if ($IgnoreCase) {					# игнорировать регистр
	if (ref ($Reference) eq "ARRAY") {		# работа с массивом
	   my %TempHash = @$Reference;		# взять в промежуточный хэш
	   $Reference = \%TempHash;			# подменить ссылку
	}
	if (ref ($Reference) eq "HASH") {		# параметры в хэше
	   my @TempArray = ();				# временный массив
	   while (my ($Code, $Value) = each (%$Reference)) {	# все параметры
		push (@TempArray, lc ($Code), $Value);	# перенести в массив
	   }
	   return @TempArray;				# вернуть результат
	}
   } else {
	return @$Reference if (ref ($Reference) eq "ARRAY");	# вернуть массив
	return %$Reference if (ref ($Reference) eq "HASH");	# вернуть хэш
   }
   return ();						# брать нечего
}

######################################################################
#	HTMLCode
#	Кодирование специальных символов HTML
#	Вызов:
#		HTML->HTMLCode (array)
#	Параметры:
#		array - массив перекодируемых строк
######################################################################

sub HTMLCode {
   shift;							# имя класса не требуется
   my @TheMessage = @_;					# перекодируемые строки
   @TheMessage = @$_[0] if (ref ($_[0]) eq "ARRAY");	# при передаче по ссылке
   for (@TheMessage) {
	s/&/&amp;/g;					# амперсанд
	s/</&lt;/g;						# левая угловая скобка
	s/>/&gt;/g;						# правая угловая скобка
	s/"/&quot;/g;					# кавычки
	s/'/&\#039;/g;					# апостроф
	s/\|/&\#124;/g;					# символ конвейера
	s/\n\r/<p>/g;					# возврат каретки и перевод строки
	s/\n/<br>/g;					# перевод строки один
	s/\r//g;						# возврат каретки один
   }
   return (wantarray) ? @TheMessage : $TheMessage[0];	# вернуть результат
}

######################################################################
#	HTMLDecode
#	Обрратное декодирование специальных символов HTML
#	Вызов:
#		HTML->HTMLDecode (array)
#	Параметры:
#		array - массив перекодируемых строк
######################################################################

sub HTMLDecode {
   shift;							# имя класса не требуется
   my @TheMessage = @_;					# перекодируемые строки
   @TheMessage = @$_[0] if (ref ($_[0]) eq "ARRAY");	# при передаче по ссылке
   for (@TheMessage) {
	s/<br>/\n/g;					# перевод строки один
	s/<p>/\n\r/g;					# возврат каретки и перевод строки
	s/&\#124;/\|/g;					# символ конвейера
	s/&\#039;/'/g;					# апостроф
	s/&quot;/"/g;					# кавычки
	s/&gt;/>/g;						# правая угловая скобка
	s/&lt;/</g;						# левая угловая скобка
	s/&amp;/&/g;					# амперсанд
   }
   return (wantarray) ? @TheMessage : $TheMessage[0];	# вернуть результат
}

######################################################################
#	JSCode
#	Кодирование специальных символов для скриптов JavaScript
#	Вызов:
#		HTML->JSCode (array)
#	Параметры:
#		array - массив перекодируемых строк
######################################################################

sub JSCode {
   shift;						# имя класса не требуется
   my @TheMessage = @_;				# перекодируемые строки
   @TheMessage = @$_[0] if (ref ($_[0]) eq "ARRAY");	# при передаче по ссылке
   for (@TheMessage) {
	s/\\/\\\\/g;				# обратная косая
	s/"/\\"/g;					# кавычки
	s/\n/\\n/g;					# перевод строки
	s/\r/\\r/g;					# возврат каретки
   }
   return (wantarray) ? @TheMessage : $TheMessage[0];	# вернуть результат
}

######################################################################
#	AUTOLOAD
#	Вспомогательная функция построения известных тегов
######################################################################

use vars qw ($AUTOLOAD %ComplexTags %SimpleTags %UniqueTags);
%ComplexTags = (anchor => "a", bold => "b", emphasied => "em", italic => "i", paragraph => "p",
  underline => "u");					# псевдонимы некоторых тегов
for (qw (a address b big blockquote bq button caption center cite code colgroup comment
  dd dfn dir div dl dt em fieldset font form frameset h1 h2 h3 h4 h5 h6 i iframe kbd label
  layer legend li listing map marquee menu nobr noframes nolayer noscript object ol p plaintext
  pre s samp select small span strike strong sub sup table tbody td textarea tfoot th thead tr
  tt u ul var xmp)) {
   $ComplexTags{$_} = $_; }				# сформировать таблицу доступных тегов
%SimpleTags = (break => "br", image => "img", softbreak => "wbr");	# псевдонимы некоторых тегов
for (qw (area base basefont bgsound br col embed frame hr img input link option param wbr)) {
   $SimpleTags{$_} = $_; }				# сформировать таблицу доступных тегов
%UniqueTags = (beginpage => \&BeginPage, endpage => \&EndPage, script => \&Script,
  style => \&Style,					# таблица уникальных тегов
  htmlcode => \&HTMLCode, htmldecode => \&HTMLDecode, javacode => \&JSCode, jscode => \&JSCode,
  javascriptcode => \&JSCode);			# и вспомогательных процедур

sub AUTOLOAD {
   shift;							# имя класса не требуется
   my $Tag = lc ($AUTOLOAD);				# имя вызываемого метода
   $Tag =~ s/.*:://;					# убрать лишнее
   return HTML->_GenericTag (@_, Tag => $ComplexTags{$Tag}) if (exists ($ComplexTags{$Tag}));	# вернуть парный тег
   return HTML->_GenericTag (@_, Tag => $SimpleTags{$Tag}, BeginOnly => 1, EndOnly => 0)
     if (exists ($SimpleTags{$Tag}));		# вернуть простой тег
   return $UniqueTags{$Tag}->("", @_) if (exists ($UniqueTags{$Tag}));	# вернуть уникальный тег
   return "";						# оставить без обработки
}

1;
