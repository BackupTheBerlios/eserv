######################################################################
#	CGI_lib.pl
#	Библиотека работы с параметрами CGI-вызова
#
#	21 августа 2001					ООО "ЛЭНК"
######################################################################

######################################################################
#	CGI
#	Класс описания набора параметров CGI-вызова
######################################################################

package CGI;

######################################################################
#	Parse
#	Разборка параметров CGI-вызова
#	Вызов:
#		CGI->Parse ([Path])
#	Параметры:
#		Path - путь к каталогу для хранения файлов. Если не
#		       задан, содержимое файлов хранится в памяти.
#	Возвращает ссылку на вновь созданный объект CGI.
#
#	Источник:
# Perl Routines to Manipulate CGI input
# S.E.Brenner@bioc.cam.ac.uk
# $Id: CGI_lib.pl,v 1.1 2003/12/28 16:27:15 spf Exp $
#
# Copyright (c) 1996 Steven E. Brenner  
# Unpublished work.
# Permission granted to use and modify this library so long as the
# copyright above is maintained, modifications are documented, and
# credit is given for any use of the library.
#
# Thanks are due to many people for reporting bugs and suggestions
# especially Meng Weng Wong, Maki Watanabe, Bo Frese Rasmussen,
# Andrew Dalke, Mark-Jason Dominus, Dave Dittrich, Jason Mathews
#
# For more information, see:
#     http://www.bio.cam.ac.uk/cgi-lib/
######################################################################

sub Parse {
   my $Class = shift;					# имя класса
   my $Path = shift;					# путь в каталог для хранения файлов
   $Path = "" if (!defined ($Path));		# никакой записи
   my $Self = { parameters => {}, files => [], error => "" };	# заготовка объекта
   bless ($Self, $Class);				# привязать к классу
   binmode (STDIN);					# перевести в двоичный режим
   binmode (STDOUT);
   binmode (STDERR);
   my $Method = $ENV{"REQUEST_METHOD"};		# метод вызова
   my $Type = $ENV{"CONTENT_TYPE"};			# вид данных
   my $Len  = $ENV{"CONTENT_LENGTH"};		# разммер данных


   if (!defined ($Method) || ($Method eq "") || ($Method =~ m/^GET$/i) || 
     ($Type =~ m#^application/x-www-form-urlencoded$#i)) {	# простой вызов
	my $CmdFlag = 0;					# параметры командной строки не добавляются
	my $In = "";					# строка запроса
	if (!defined ($Method) || ($Method eq "")) {	# метод неизвестен
	   $In = $ENV{"QUERY_STRING"} if (defined ($ENV{"QUERY_STRING"}));	# строка запроса
	   $CmdFlag = 1;					# и взять параметры из командной строки
	} elsif ($Method =~ m/^(GET|HEAD)$/i) {	# самые простые методы
	   $In = $ENV{"QUERY_STRING"};
	} elsif ($Method =~ m/^POST$/i) {		# отправлена форма
	   my $Got = sysread (STDIN, $In, $Len);	# прочитать содержимое формы
	   if ($Got < $Len) {				# прочитано меньше, чем ожидалось
		$Self->{"error"} =
		  "Broken CGI request: wanted " . $Len . " bytes, read " . $Got . " bytes";
		return $Self;				# прервать обработку
	   }
	} else {
	   $Self->{"error"} = "Unknown CGI request method: " . $Method;	# неизвестный метод - обработка невозможна
	   return $Self;					# прервать обработку
	}

	my @In = split (/[&;]/, $In);			# разбить запрос на параметры
	push (@In, @ARGV) if ($CmdFlag);		# добавить параметры командной строки
	for (@In) {						# все параметры запроса
	   if (defined ($_)) {				# параметр определен
		s/\+/ /g;					# перекодировать
		my ($Name, $Value) = split (/=/, $_, 2);	# разобрать на имя и значение
		$Value = "" if (!defined ($Value));	# пустое значение для флагового параметра
		$Name =~ s/%([A-Fa-f0-9]{2})/pack ("c", hex ($1))/ge;	# свернуть шестнадцатиричные представления
		$Value =~ s/%([A-Fa-f0-9]{2})/pack ("c", hex ($1))/ge;
		$Self->Store (CGIParameter->New ($Name, $Value));	# заложить в коллекцию
	   }
	}
	return $Self;					# обработано
   } 

   if ($Type =~ m#^multipart/form-data#) {	# форма с вложением файлов
	if ($Method ne "POST") {			# недопустимый метод для такого типа данных
	   $Self->{"error"} = "Invalid CGI request method for multipart/form-data: " . $Method;	# это не может быть обработано
	   return $Self;
	}
	my ($Boundary) = $Type =~ m/boundary="([^"]+)"/;	# выделить разделитель полей
	($Boundary) = $Type =~ m/boundary=(\S+)/ if (!defined ($Boundary) || ($Boundary eq ""));
	if (!defined ($Boundary) || ($Boundary eq "")) {	# разделитель не найден
	   $Self->{"error"} =
	     "Boundary not provided for multipart CGI request: probably a server bug";
	   return $Self;					# прервать обработку
	}
	$Boundary =  "--" . $Boundary;		# истинный вид разделителя
	$BLen = length ($Boundary);			# и его размер
	my $BufferSize = $BLen + 8198;		# размер буфера
	$BufferSize = $BLen * 2 if ($BufferSize < $BLen * 2);
	my ($In, $Left) = ("", $Len);
	{
	   my ($Error, $Value, $Flag) =
	     CGI->_ReadValue (\$In, \$Left, $BufferSize, $Boundary, $BLen);	# найти первый разделитель
	   if ($Error ne "") {				# ошибка
		$Self->{"error"} = $Error;		# зафиксировать ошибку
		return $Self;				# прервать обработку
	   }
	}
	$Boundary = "\r\n" . $Boundary;		# разделителю предшествует конец строки
	$BLen += 2;						# учесть
	{
	   my $Serial = 0;				# последовательный номер файла
	   my $Finish = 0;				# финиш еще не настал
	   while (!$Finish) {				# пока выполнение возможно
		my ($Error, $Name, $FileName, $FileType) =
		  CGI->_ParseHeader (\$In, \$Left, $BufferSize, \$Finish);	# прочитать заголовок
		if ($Error ne "") {			# ошибка
		   $Self->{"error"} = $Error;		# зафиксировать
		   $Finish = 1;				# отметить завершение
		}
		if (!$Finish) {				# не конец
		   my @Parameters = (\$In, \$Left, $BufferSize, $Boundary, $BLen);	# основные параметры вызова
		   push (@Parameters, $Path, \$Serial) if (defined ($FileName));	# дополнительные параметры для файла
		   my ($Error, $Value, $Stored) = CGI->_ReadValue (@Parameters);	# прочитать значение
		   if ($Error ne "") {			# ошибка
			$Self->{"error"} = $Error;	# зафиксировать
			$Finish = 1;			# отметить завершение
		   } else {
			$Self->Store (CGIParameter->New ($Name, $Value, $FileName, $FileType,
			  $Stored));			# занести параметр в таблицу
			push (@{$Self->{"files"}}, $Value) if ($Stored);	# временно запомнить имя файла
		   }
		}
	   }
	}
	if ($Self->{"error"} ne "") {			# ошибка разбора
	   unlink (@{$Self->{"files"}}) if (@{$Self->{"files"}});	# удалить хранимые файлы
	   @{$Self->{"files"}} = ();			# ничего не хранится
	}
	return $Self;					# обработано
   }

   $Self->{"error"} = "Unknown Content-Type of CGI request: " . $Type;	# неизвестный тип данных для запроса
   return $Self;
}

######################################################################
#	_ParseHeader
#	Разбор заголовка очередного параметра
#	Вызов:
#		CGI->_ParseHeader (Buffer, Length, Limit, Finish)
#	Параметры:
#		Buffer - ссылка на буфер ввода;
#		Length - ссылка на длину читаемых данных;
#		Limit  - ограничение на длину данных;
#		Finish - ссылка на признак завершения работы.
#	Возвращает массив значений:
#		Error	   - описатель ошибки. Если ошибки нет, то
#			     пустая строка;
#		Name	   - имя очередного параметра;
#		FileName - имя файла, если параметр является файлом;
#		Type	   - Content-Type, если параметр является файлом.
######################################################################

sub _ParseHeader {
   shift;							# ссылку на класс пропустить
   my $In = shift;					# ссылка на буфер
   my $Left = shift;					# ссылка на размер остатка данных
   my $Limit = shift;					# ограничение размера считывания
   my $Finish = shift;					# ссылка на признак завершения работы
   my $Head = "";						# начало заголовка
   {
	my $EndHead;
	my $NotFirst = 0;					# флаг первого прохода
	my $NotEnd = 1;					# флаг незавершенного заголовка
	while ($NotEnd) {					# заголовок еще не кончился
	   my $Breaker = 0;				# позиция отреза
	   if ($NotFirst) {				# не первый проход
		$Breaker = length ($$In);		# позиция отреза
		if ($Breaker > 4) {			# можно резать
		   $$In = substr ($$In, -4);		# опустошить буфер
		   $Breaker = 4;				# строго с этой позиции
		}
	   }
	   if ($NotFirst || (length ($$In) < 4)) {	# требуется чтение данных
		my $Error = CGI->_ReadPart ($In, $Left, $Limit);	# читать очередной фрагмент
		return ($Error, undef, undef, undef) if ($Error ne "");	# ошибка чтения
		return ("Broken CGI request: final boundary not found", undef, undef, undef)
		  if (length ($$In) < 4);		# прочитано все
	   }
	   if (!$NotFirst) {				# первый проход
		if ($$In =~ m/^--\r\n/) {		# встречен финальный разделитель
		   $$Finish = 1;				# установить признак завершения
		   return ("", undef, undef, undef);	# выполнено
		}
		$NotFirst = 1;				# первый проход завершен
	   }
	   $EndHead = index ($$In, "\r\n\r\n");	# найти ограничитель
	   if ($EndHead == -1) {			# не найден
		$EndHead = length ($$In);		# закачать весь буфер
	   } else {
		$NotEnd = 0;				# финиш
	   }
	   $Head .= substr ($$In, $Breaker, $EndHead - $Breaker);	# следующий фрагмент заголовка
	}
	$$In = substr ($$In, $EndHead + 4);		# отрезать лишнее
   }
   {
	my ($CDisp, $CType) = ("", "");
	for (split (/\r\n/, $Head)) {			# по всем строкам заголовка
	   $CDisp = $_ if (m/^\s*Content-Disposition:/i);	# строка с именем параметра
	   $CType = $_ if (m/^\s*Content-Type:/i);	# строка с описанием Content-Type
	}
	my ($FileName, $FileType) = (undef, undef);	# может, это и не файл
	my ($Name) = $CDisp =~ m/\bname="([^"]+)"/i;	# выделить имя параметра
	($Name) = $CDisp =~ m/\bname=([^\s:;]+)/i if (!defined ($Name) || ($Name eq ""));
	$Name = "" if (!defined ($Name));		# пусть будет безымянный параметр
	if ($CDisp =~ m/\bfilename=/) {		# файл
	   ($FileName) = $CDisp =~ m/\bfilename="([^"]*)"/i;	# выделить имя файла
	   ($FileName) = $CDisp =~ m/\bfilename=([^\s:;]+)/i
	     if (!defined ($FileName) || ($FileName eq ""));
	   if (defined ($FileName) && ($FileName ne "")) {	# выделено
		($FileType) = $CType =~ m/^\s*Content-type:\s*"([^"]+)"/i;	# выделить Content-Type
		($FileType) = $CType =~ m/^\s*Content-Type:\s*([^\s:;]+)/i
		  if (!defined ($FileType) || ($FileType eq ""));
	   }
	}
	return ("", $Name, $FileName, $FileType);	# вернуть выбранные параметры
   }
}

######################################################################
#	_ReadValue
#	Чтение значения параметра
#	Вызов:
#		CGI->_ReadValue (Buffer, Length, Limit, Boundary, BLen[,
#				Path, Serial])
#	Параметры:
#		Buffer   - ссылка на буфер ввода;
#		Length   - ссылка на длину читаемых данных;
#		Limit	   - ограничение на длину данных;
#		Boundary - шаблон строки-разделителя;
#		BLen	   - длина строки-разделителя;
#		Path	   - путь для хранения файла;
#		Serial   - ссылка на порядковый номер временного файла.
#	Возвращает массив значений:
#		Error  - описатель ошибки. Если ошибки нет, то пустая
#			   строка;
#		Value  - значение параметра или имя временного файла;
#		Stored - признак хранения файла на диске
######################################################################

sub _ReadValue {
   shift;							# ссылку на класс пропустить
   my $In = shift;					# ссылка на буфер
   my $Left = shift;					# ссылка на размер остатка данных
   my $Limit = shift;					# ограничение размера считывания
   my $Boundary = shift;				# шаблон строки-разделителя
   my $BLen = shift;					# длина строки-разделителя и предшествующих переводов строки
   my $Path = shift;					# путь для хранения файла
   my $Serial = shift;					# ссылка на порядковый номер временного файла
   my $Value = "";					# возвращаемое значение
   {
	my $EndVal;
	my $NotFirst = 0;					# флаг первого прохода
	my $NotEnd = 1;					# флаг незавершенного чтения
	while ($NotEnd) {					# данные еще не кончились
	   my $Breaker = 0;				# позиция отреза
	   if ($NotFirst) {				# не первый проход
		$Breaker = length ($$In);		# позиция отреза
		if ($Breaker > $BLen) {			# можно резать
		   $$In = substr ($$In, -$BLen);	# опустошить буфер
		   $Breaker = $BLen;			# строго с этой позиции
		}
	   }
	   if ($NotFirst || (length ($$In) < $BLen)) {	# требуется чтение данных
		my $Error = CGI->_ReadPart ($In, $Left, $Limit);	# читать очередной фрагмент
		return ($Error, "", 0) if ($Error ne "");	# ошибка чтения
		return ("Broken CGI request: final boundary not found", "", 0)
		  if (length ($$In) < $BLen);		# прочитано все
	   }
	   $EndVal = index ($$In, $Boundary);	# найти разделитель
	   if ($EndVal == -1) {				# не найден
		$EndVal = length ($$In);		# закачать весь буфер
	   } else {
		$NotEnd = 0;				# финиш
	   }
	   $Value .= substr ($$In, $Breaker, $EndVal - $Breaker) if ($EndVal > $Breaker);	# следующий фрагмент данных
	   $NotFirst = 1;					# первый проход завершен
	}
	$$In = substr ($$In, $EndVal + $BLen);	# отрезать лишнее
   }
   {
	my $Stored = 0;					# данные пока не записаны
	if (defined ($Path) && ($Path ne "")) {	# задан режим сохранения
	   my $FileName = $Path . "/CGI-temp." . $$ . "." . $$Serial;	# сформировать имя для временного файла
	   ++$$Serial;					# нарастить порядковый номер
	   my $ErrorFlag = 0;				# ошибок не зафиксировано
	   local *STORED;					# местные операции с файлами
	   if (open (STORED, ">" . $FileName)) {	# файл открылся
		binmode (STORED);				# перевести в двоичный режим
		my ($Offset, $ToWrite) = (0, length ($Value));	# подготовка к записи
		while ($Offset < $ToWrite) {		# пока есть чего записывать
		   my $PartSize = $ToWrite - $Offset;	# величина остатка
		   $PartSize = 32768 if ($PartSize > 32768);	# ограничить
		   my $Written = syswrite (STORED, $Value, $PartSize, $Offset);	# записать очередной фрагмент
		   if (!$Written) {			# запись не получилась
			$ErrorFlag = 1;			# отметить ошибку
			$Offset = $ToWrite;		# прервать запись
		   } else {
			$Offset += $Written;		# корректировать позицию
		   }
		}
		close (STORED);				# закрыть файл
		if ($ErrorFlag) {				# ошибка записи
		   unlink ($FileName);			# удалить файл
		} else {
		   $Stored = 1; $Value = $FileName;	# возвращается имя файла и флаг хранения
		}
	   }
	}
	return ("", $Value, $Stored);			# вернуть результат
   }
}

######################################################################
#	_ReadPart
#	Считывание части входных данных
#	Вызов:
#		CGI->_ReadPart (Buffer, Length, Limit)
#	Параметры:
#		Buffer - ссылка на буфер ввода;
#		Length - ссылка на длину читаемых данных;
#		Limit  - ограничение на длину данных.
#	Возвращает описатель ошибки. Если ошибки нет, возвращается
#	пустая строка.
######################################################################

sub _ReadPart {
   shift;							# ссылку на класс пропустить
   my $In = shift;					# ссылка на буфер
   my $Left = shift;					# ссылка на размер остатка данных
   my $Limit = shift;					# ограничение размера считывания
   my $Wanted = $Limit - length ($$In);		# сколько можно прочитать
   $Wanted = $$Left if ($$Left < $Wanted);	# весь остаток
   return "" if ($Wanted <= 0);			# буфер полон или читать нечего
   my $Buffer = "";					# буфер для считывания
   my $Got = sysread (STDIN, $Buffer, $Wanted);	# прочитать сколько надо
   return "Broken CGI request: wanted " . $Wanted . " bytes, read " . $Got . " bytes"
     if ($Got < $Wanted);				# ошибка - прочитано слишком мало
   $$In .= $Buffer;					# соединить фрагменты
   $$Left -= $Got;					# фрагмент прочитан
   return "";						# без ошибок
}

######################################################################
#	Files
#	Вызов:
#		Object->Files ()
#	Возвращает список сохраненных на диске файлов.
######################################################################

sub Files { return @{$_[0]->{"files"}}; }		# вернуть список файлов

######################################################################
#	Parameters
#	Вызов:
#		Object->Parameters ()
#	Возвращает список имен принятых параметров.
######################################################################

sub Parameters { return keys (%{$_[0]->{"parameters"}}); }	# вернуть имена всех параметров

######################################################################
#	Count
#	Подсчет числа описания параметра
#	Вызов:
#		Object->Count (Name)
#	Параметры:
#		Name - имя параметра.
#	Возвращает число определений параметра с данным именем.
######################################################################

sub Count {
    my $Self = shift;					# ссылка на объект
    my $Name = shift;					# имя параметра
    my $Param = $Self->{"parameters"}->{$Name};	# ссылка на массив одноименных параметров
    return (defined ($Param) ? scalar (@$Param) : 0);	# число параметров
}

######################################################################
#	Retrieve
#	Вызов:
#		Object->Retrieve (Name[, Index])
#	Параметры:
#		Name  - имя параметра;
#		Index - индекс параметра в массиве одноименных. Если не
#			  задан, предполагается нулевой элемент.
#	В списковом контексте возвращает массив ссылок на одноименные
#	параметры. В скалярном контексте возвращает ссылку на параметр
#	в соответствии с индексом. Если такого элемента или параметра
#	нет, возвращается неопределенное значение.
######################################################################

sub Retrieve {
   my $Self = shift;					# ссылка на объект
   my $Name = shift;					# имя параметра
   my $Index = shift () + 0;				# индекс в массиве
   my $Param = $Self->{"parameters"}->{$Name};	# ссылка на массив одноименных параметров
   return undef if (!defined ($Param));		# нет такого параметра
   return (wantarray) ? @$Param : $Param->[$Index];	# вернуть требуемое
}

######################################################################
#	RetrieveValue
#	Вызов:
#		Object->RetrieveValue (Name[, Index])
#	Параметры:
#		Name  - имя параметра;
#		Index - индекс параметра в массиве одноименных. Если не
#			  задан, предполагается нулевой элемент.
#	Возвращает значение параметра. Если параметр отсутствует,
#	возвращается неопределенное значение.
######################################################################

sub RetrieveValue {
   my $Self = shift;					# ссылка на объект
   my $Name = shift;					# имя параметра
   my $Index = shift () + 0;				# индекс в массиве
   my $Param = $Self->{"parameters"}->{$Name};	# ссылка на массив одноименных параметров
   return undef if (!defined ($Param));		# нет такого параметра
   $Param = $Param->[$Index];				# ссылка на искомое значение
   return undef if (!defined ($Param));		# нет такого параметра
   return $Param->Value ();				# вернуть значение
}

######################################################################
#	Store
#	Вызов:
#		Object->Store (Parameter)
#	Параметры:
#		Parameter - ссылка на объект типа параметр.
#	Добавляет новый параметр в коллекцию.
######################################################################

sub Store {
   my $Self = shift;					# ссылка на объект
   my $Param = shift;					# ссылка на добавляемый параметр
   my $Collection = $Self->{"parameters"};	# ссылка на коллекцию параметров
   my $ParamName = $Param->Name ();			# имя параметра
   $Collection->{$ParamName} = [] if (!defined ($Collection->{$ParamName}));	# создать пустую коллекцию для имени
   push (@{$Collection->{$ParamName}}, $Param);	# добавить в список
}

######################################################################
#	Error
#	Вызов:
#		Object->Error ()
#	Возвращает описание ошибки разбора.
######################################################################

sub Error { return $_[0]->{"error"}; }

######################################################################


######################################################################
#	CGIParameter
#	Класс описания одного параметра CGI-вызова
######################################################################

package CGIParameter;

######################################################################
#	New
#	Конструктор параметра CGI-вызова
#	Вызов:
#		CGIParameter->New (Name, Value[, FileName, Type, Stored])
#	Параметры:
#		Name	   - наименование параметра;
#		Value	   - значение параметра;
#		FileName - исходное имя файла, если параметр является
#			     файлом;
#		Type	   - Content-Type, если параметр является файлом;
#		Stored   - признак хранения файла на диске, если параметр
#			     является файлом.
#	Возвращает ссылку на вновь созданный объект.
######################################################################

sub New {
   my $Class = shift;					# имя класса
   my $Name = shift;					# имя параметра
   my $Value = shift;					# значение параметра
   my $FileName = shift;				# имя файла
   my $Type = shift;					# Content-Type
   my $Stored = shift () + 0;				# признак хранения на диске
   my $Self = { name => $Name, value => $Value };	# имя и значение обязательны
   if (defined ($FileName) && ($FileName ne "")) {	# это файл
	$Self->{"filename"} = $FileName;		# зафиксировать имя файла
	$Self->{"type"} = $Type if (defined ($Type) && ($Type ne ""));	# и Content-Type
	$Self->{"stored"} = $Stored;			# признак хранения на диске
   }
   return bless ($Self, $Class);			# привязать к классу
}

######################################################################
#	Name
#	Вызов:
#		Object->Name ()
#	Возвращает имя параметра.
######################################################################

sub Name { return $_[0]->{"name"}; }

######################################################################
#	Value
#	Вызов:
#		Object->Value ()
#	Возвращает значение параметра.
######################################################################

sub Value { return $_[0]->{"value"}; }

######################################################################
#	IsFile
#	Метод определения, является ли параметр файлом
#	Вызов:
#		Object->IsFile ()
#	Возвращает ненулевое значение, если объект является файлом,
#	и нулевое в противном случае.
######################################################################

sub IsFile { return (exists ($_[0]->{"filename"})) ? 1 : 0; }

######################################################################
#	IsStored
#	Метод определения, хранится ли файл на диске
#	Вызов:
#		Object->IsStored ()
#	Возвращает ненулевое значение, если объект является файлом и
#	хранится на диске, и нулевое в противном случае.
######################################################################

sub IsStored { return (exists ($_[0]->{"filename"})) ? $_[0]->{"stored"} : 0; }

######################################################################
#	FileName
#	Вызов:
#		Object->FileName ()
#	Возвращает имя файла параметра.
######################################################################

sub FileName { return $_[0]->{"filename"}; }

######################################################################
#	Type
#	Вызов:
#		Object->Type ()
#	Возвращает Content-Type параметра.
######################################################################

sub Type { return (exists ($_[0]->{"type"})) ? $_[0]->{"type"} : ""; }

######################################################################


######################################################################
#	Cookies
#	Класс описания набора параметров Cookie
######################################################################

package Cookies;

######################################################################
#	Parse
#	Разборка параметров Cookie
#	Вызов:
#		Cookies->Parse ()
#	Возвращает ссылку на вновь созданный объект Cookies.
#
#	Источник:
# Perl Routines to Manipulate Web Browser Cookies
# kovacsp@egr.uri.edu
# $Id: CGI_lib.pl,v 1.1 2003/12/28 16:27:15 spf Exp $
#
# Copyright (c) 1998 Peter D. Kovacs  
# Unpublished work.
# Permission granted to use and modify this library so long as the
# copyright above is maintained, modifications are documented, and
# credit is given for any use of the library.
#
# Portions of this library are taken, without permission (and much 
# appreciated), from the cgi-lib.pl.  You may get that at 
# http://cgi-lib.stanford.edu/cgi-lib
######################################################################

sub Parse {
   my $Class = shift;					# имя класса
   my $Self = {};						# создать заготовку объекта
   bless ($Self, $Class);				# привязать к классу
   if (exists ($ENV{"HTTP_COOKIE"})) {		# "плюшки" имеются
	for (split (/; /, $ENV{"HTTP_COOKIE"})) {	# перебор всех плюшек
	   s/\+/ /g;					# перекодировать
	   my ($Name, $Value) = split (/=/, $_, 2);	# разобрать на имя и значение
	   $Name =~ s/%([A-Fa-f0-9]{2})/pack ("c", hex ($1))/ge;	# свернуть шестнадцатиричные представления
	   $Value =~ s/%([A-Fa-f0-9]{2})/pack ("c", hex ($1))/ge;
	   $Self->Store (Cookie->New ($Name, $Value));	# заложить в коллекцию
	}
   }
   return $Self;						# вернуть ссылку на новый объект
}

######################################################################
#	Parameters
#	Вызов:
#		Object->Parameters ()
#	Возвращает список имен принятых параметров.
######################################################################

sub Parameters { return keys (%{$_[0]->{"parameters"}}); }	# вернуть имена всех параметров

######################################################################
#	Count
#	Подсчет числа описания параметра
#	Вызов:
#		Object->Count (Name)
#	Параметры:
#		Name - имя параметра.
#	Возвращает число определений параметра с данным именем.
######################################################################

sub Count {
   my $Self = shift;					# ссылка на объект
   my $Name = shift;					# имя параметра
   my $Param = $Self->{$Name};			# ссылка на массив одноименных параметров
   return (defined ($Param) ? scalar (@$Param) : 0);	# число параметров
}

######################################################################
#	Retrieve
#	Вызов:
#		Object->Retrieve (Name[, Index])
#	Параметры:
#		Name  - имя параметра;
#		Index - индекс параметра в массиве одноименных. Если не
#			  задан, предполагается нулевой элемент.
#	В списковом контексте возвращает массив ссылок на одноименные
#	параметры. В скалярном контексте возвращает ссылку на параметр
#	в соответствии с индексом. Если такого элемента или параметра
#	нет, возвращается неопределенное значение.
######################################################################

sub Retrieve {
   my $Self = shift;					# ссылка на объект
   my $Name = shift;					# имя параметра
   my $Index = shift () + 0;				# индекс в массиве
   my $Param = $Self->{$Name};			# ссылка на массив одноименных параметров
   return undef if (!defined ($Param));		# нет такого параметра
   return (wantarray) ? @$Param : $Param->[$Index];	# вернуть требуемое
}

######################################################################
#	RetrieveValue
#	Вызов:
#		Object->RetrieveValue (Name[, Index])
#	Параметры:
#		Name  - имя параметра;
#		Index - индекс параметра в массиве одноименных. Если не
#			  задан, предполагается нулевой элемент.
#	Возвращает значение параметра. Если параметр отсутствует,
#	возвращается неопределенное значение.
######################################################################

sub RetrieveValue {
   my $Self = shift;					# ссылка на объект
   my $Name = shift;					# имя параметра
   my $Index = shift () + 0;				# индекс в массиве
   my $Param = $Self->{$Name};			# ссылка на массив одноименных параметров
   return undef if (!defined ($Param));		# нет такого параметра
   $Param = $Param->[$Index];				# ссылка на искомое значение
   return undef if (!defined ($Param));		# нет такого параметра
   return $Param->Value ();				# вернуть значение
}

######################################################################
#	Store
#	Вызов:
#		Object->Store (Parameter)
#	Параметры:
#		Parameter - ссылка на объект типа параметр.
#	Добавляет новый параметр в коллекцию.
######################################################################

sub Store {
   my $Self = shift;					# ссылка на объект
   my $Param = shift;					# ссылка на добавляемый параметр
   my $ParamName = $Param->Name ();			# имя параметра
   $Self->{$ParamName} = [] if (!exists ($Self->{$ParamName}));	# создать пустую коллекцию для имени
   push (@{$Self->{$ParamName}}, $Param);		# добавить в список
}

######################################################################


######################################################################
#	Cookie
#	Класс описания одного параметра Cookie
######################################################################

package Cookie;

######################################################################
#	New
#	Конструктор параметра Cookie
#	Вызов:
#		Cookie->New (Name, Value)
#	Параметры:
#		Name	 - наименование параметра;
#		Value	 - значение параметра;
#	Возвращает ссылку на вновь созданный объект.
######################################################################

sub New {
   my $Class = shift;					# имя класса
   my $Name = shift;					# имя параметра
   my $Value = shift;					# значение параметра
   my $Self = { name => $Name, value => $Value };	# имя и значение обязательны
   return bless ($Self, $Class);			# привязать к классу
}

######################################################################
#	Name
#	Вызов:
#		Object->Name ()
#	Возвращает имя параметра.
######################################################################

sub Name { return $_[0]->{"name"}; }

######################################################################
#	Value
#	Вызов:
#		Object->Value ()
#	Возвращает значение параметра.
######################################################################

sub Value { return $_[0]->{"value"}; }

1;
