REQUIRE /WIN32_FIND_DATA  conf/http/plugins/list_dir/findfile.f

: LS-DIR ( addr u xt -- )
\ addr u - имя искомого файла или шаблон
\ xt ( data -- ) - процедура вызываемая для каждого файла
  { addr u xt \ data id err }

  uOtherWriteStat @ uWSTAT !

  0 addr u + C!
  /WIN32_FIND_DATA ALLOCATE THROW -> data
  data /WIN32_FIND_DATA ERASE
  data addr FindFirstFileA -> id
  id -1 = IF data FREE DROP EXIT THEN
  data xt EXECUTE
  BEGIN
    data id FindNextFileA err 0= AND
  WHILE
    data xt ['] EXECUTE CATCH -> err
    err IF 2DROP THEN
  REPEAT
  id FindClose DROP
  data FREE DROP

  uOtherWriteStat @ uWSTAT @ - uWSTAT !
  err THROW
;
: HTTP-LS1 { data \ isDir }
   data dwFileAttributes @ FILE_ATTRIBUTE_DIRECTORY AND FILE_ATTRIBUTE_DIRECTORY =
   -> isDir
   data nFileSizeLow @ 0 <# #S 15 PAD HLD @ - - 0 MAX 0 ?DO BL HOLD LOOP #> FPUT
   data ftLastWriteTime
   >R
   /SYSTEMTIME ALLOCATE THROW DUP /SYSTEMTIME ERASE
   DUP R> FileTimeToSystemTime DROP >R
   <<# BL HOLD TIME&DATE NIP NIP NIP NIP NIP R@ wYear W@ =
       IF R@ wMinute W@ #N## #: R@ wHour W@ #N##
       ELSE R@ wYear W@ S>D # # # # 2DROP BL HOLD THEN
       BL HOLD
       R@ wDay W@ #N## BL HOLD
       R@ wMonth W@ DateM>S HOLDS BL HOLD
       R> FREE DROP
   #> FPUT
   data cFileName ASCIIZ>
   isDir IF " {s}/" STR@ THEN
   2DUP
   " <a href={''}{s}{''}>{s}</a><br>{CRLF}" FPUTS
;

: HTTP-LS ( addr u -- )
  ['] HTTP-LS1 LS-DIR
;
: LIST_DIR
  PATH_INFO NIP 1 >
  IF 403 PostResponse
     S" conf\http\plugins\list_dir\forbidden.pat" EVAL-FILE FPUT
     StopProtocol
  ELSE
  200 PostResponse
  " HTTP/1.0 200 Directory
Content-Type: text/html
Connection: close

<html><body><h2>Directory {URI}</h2><pre>
"
  FPUTS
  " {FILENAME}*" STR@ ['] HTTP-LS CATCH
  StopProtocol
  ?DUP IF THROW ELSE S" </pre></body></html>" FPUT THEN
  THEN
;
: ListDir ( -- )
  S" LIST_DIR" $ACTION S!
\  ParseStr ...
;
