######################################################################
#	Elog.cgi
#	Основной программный модуль системы обработки статистики Elog
#
#	20 февраля 2003 года				ООО "ЛЭНК"
######################################################################

use strict 'refs';					# жесткие ограничения на использование ссылок
my $Feedback = "admins\@lankgroup.ru";		# электронный адрес для обратной связи
my $PrintHTTPHead = 1;					# флаг вывода заголовка HTTP/1.0

######################################################################
#	DisplayHTTPHeader
#	Функция вывода основного заголовка HTTP.
######################################################################

sub DisplayHTTPHeader ($;$) {
   my $Header = shift;					# код возврата
   my $Charset = shift;
   print ("HTTP/1.0 " . $Header . "\n") if ($PrintHTTPHead);	# вывести заголовок HTTP
   print ("Content-type: text/html" . ($Charset ? ("; charset=" . $Charset) : "") . "\n\n");	# вывести признак HTML-страницы
}

######################################################################
#	DisplayError
#	Функция передачи браузеру сообщения об ошибке инициализации.
######################################################################

sub DisplayError ($@) {
   my $ErrorText = shift;				# основная строка сообщения
   my $Reason = join ("<br>\n", @_);		# собрать строку сообщения
   DisplayHTTPHeader ("200 OK");			# вывести заголовок HTTP
   print <<ERRORPAGE;
<html><head>
<title>System Error</title>
</head><body bgcolor='#FFFFFF' text='#000000'>
<h1 align='center'>$ErrorText</h1>
<p>$Reason</p>
<p>If the problem persists please inform server administrator
<a href='mailto:$Feedback?subject=CC+Problem'>$Feedback</a>.</p>
</body></html>
ERRORPAGE
}

######################################################################
#	Загрузка основных библиотек.
######################################################################

eval {
   require "./Misc_lib.pl";				# библиотека "разных" функций
   require "./HTML_lib.pl";				# библиотека поддержки HTML
   require "./DateTime_lib.pl";			# библиотека работы с датами
   require "./CGI_lib.pl";				# библиотека поддержки CGI
   require "./Elog_lib.pl";				# основная библиотека поддержки
};
if ($@) {							# ошибка загрузки библиотек
   DisplayError ("Error loading runtime libraries", split ("\n", $@));	# сообщить об ошибке
   exit;
}

######################################################################
#	Загрузка конфигурации.
######################################################################

local $Environment = Environment->Load (0);	# загрузить рабочую среду
my $Error = $Environment->Error ();			# признак ошибки
if ($Error) {						# среда не загружена
   DisplayError ("Error loading configuration data", $Error);	# сообщить об ошибке
   exit;
}

######################################################################
#	Настройка пользовательских параметров.
######################################################################

local $CGI = CGI->Parse ();				# выполнить разбор запроса
$Error = $CGI->Error ();				# признак ошибки
if ($Error) {						# непорядок с запросом
   DisplayError ("Error processing request", $Error);	# сообщить об ошибке
   exit;
}

local $Cookies = Cookies->Parse ();			# разобрать плюшки
$Environment->AttachUserSettings ($CGI, $Cookies);	# получить пользовательские настройки

my $Action = $CGI->RetrieveValue ("a");		# код операции
$Action = "i" if (!defined ($Action));		# операция по умолчанию
if ($Action eq "i") {					# вывод формы запроса
   eval { require "./Elog_Index.pl"; };		# подключить процедуру испольнения
} elsif ($Action eq "p") {				# обработка запроса
   eval { require "./Elog_Parse.pl"; };		# подключить процедуру испольнения
} else {							# неизвестная операция
}
if ($@) {
   DisplayError ("Error loading runtime libraries", split ("\n", $@));	# сообщить об ошибке
   exit;
}
ProcessRequest ($Action);				# выполнить запрос
