\ проверка существования файла по маске (заимствовано у rvm)
: MyFileExists ( addr u -- flag )
  { fa fu \ fdat fnam }
  /WIN32_FIND_DATA ALLOCATE THROW -> fdat	\ выделить память под структуру
  256 ALLOCATE THROW -> fnam			\ выделить память под имя файла
  0 fnam fu + C!				\ сразу поставить ограничитель
  fa fnam fu CMOVE				\ скопировать имя файла
  fdat fnam FindFirstFileA			\ выполнить поиск файла
  DUP -1 <>					\ скопировать дескриптор и проверить на правильность
  IF
    TRUE					\ для первой проверки
    BEGIN
      fdat dwFileAttributes @ FILE_ATTRIBUTE_DIRECTORY AND AND	\ либо это каталог, либо больше ничего не найдено
    WHILE
      fdat OVER FindNextFileA 0<> 		\ искать следующий файл
    REPEAT
    FindClose DROP				\ закрыть поиск
    fdat dwFileAttributes @ FILE_ATTRIBUTE_DIRECTORY AND 0=	\ найден ли хоть один файл?
  ELSE
    DROP FALSE					\ нет таких файлов
  THEN
  fnam FREE THROW fdat FREE THROW		\ освободить память
;

\ обработка одной записи списка пересылки почты
: (MyCheckEmailForward) ( -- )
  " {SMTP[Out]}\{FIELD2}\{FIELD3}\*.*" STR@ MyFileExists	\ есть ли файлы на отправку?
  IF
     S" smtp\delivery\RunSendMailAppForward" EvalRules	\ да, инициировать отправку
  THEN
;
