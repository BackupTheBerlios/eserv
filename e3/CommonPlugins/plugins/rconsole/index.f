
: Quit ( -- )
  S0 @ SP!
  H-STDIN H-STDOUT H-STDERR { in out err }
  BEGIN
    ." < Remote console >" CR
    \ CONSOLE-HANDLES
    in  TO H-STDIN
    out TO H-STDOUT
    err TO H-STDERR
    0 TO SOURCE-ID
    [COMPILE] [
    ['] MAIN1 CATCH
    ['] ERROR  CATCH IF DROP EXIT THEN  \ (*)
    ( S0 @ SP! R0 @ RP! \ стеки не сбрасываем, т.к. это за нас делает CATCH :)
  AGAIN
;
:NONAME ( n -- )  TO vClientSocket  Quit ; TASK: QuitTask

: RConsole ( -- )

  0 0 StdinWH StdinRH CreatePipe ERR THROW
  0 0 StdoutWH StdoutRH CreatePipe ERR THROW

  H-STDIN >R
  H-STDOUT >R
  H-STDERR >R

  StdinRH  @ TO H-STDIN
  StdoutWH @ TO H-STDOUT
  H-STDOUT TO H-STDERR

  StdinRH @ . StdoutWH @ . CR
  StdinWH @ . StdoutRH @ . CR

  vClientSocket QuitTask START >R  
  StdinWH @ StdoutRH @ vClientSocket MAP-HANDLES

  CloseConnection

  R> DUP STOP  CloseHandle ( ERR THROW ) DROP

  R> TO H-STDERR
  R> TO H-STDOUT
  R> TO H-STDIN

  StdinWH @ CLOSE-FILE THROW
  StdinRH @ CLOSE-FILE THROW
  StdoutWH @ CLOSE-FILE THROW
  StdoutRH @ CLOSE-FILE THROW
;
