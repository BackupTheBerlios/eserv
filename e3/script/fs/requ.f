\ 31.Mar.2002 Sun 13:57 

\ 28.Jun.2002 Fri 16:01  под Eproxy

REQUIRE [DEFINED] lib\include\tools.f

[UNDEFINED] HOLDS [IF]
: HOLDS ( addr u -- )
  SWAP OVER + SWAP 0 ?DO DUP I - 1- C@ HOLD LOOP DROP
;
[THEN]

 WARNING @ WARNING 0!

: SOURCE-NAME ( -- addr u )
  CURFILE @ DUP IF ASCIIZ> ELSE 0 THEN
;
: SOURCE-NAME! ( addr u -- )
  HEAP-COPY CURFILE !
;
\ =======================================
\ core-ext. работа со строками.
\ строка - полное файловое имя.

: is_path_delimiter ( c -- flag )
  DUP [CHAR] \ = SWAP [CHAR] / = OR
;
CHAR \ 
CONSTANT path_delimiter ( -- c )

: CUT-PATH ( a u -- a u1 )
\ из строки "path\name" выделить строку "path\"
  OVER +
  BEGIN 2DUP <> WHILE DUP C@ is_path_delimiter 0= WHILE 1- REPEAT 1+ THEN
  OVER -
;
\ =======================================
\ core-ext. работа с файлами (по имени)

: FILE-EXIST ( addr u -- flag )
  R/O OPEN-FILE-SHARED ?DUP
  IF NIP DUP 2 = SWAP 3 = OR 0= \ ~ruv
  ELSE CLOSE-FILE THROW TRUE
  THEN
;
\ =======================================
\ поиск файла 

: +Path ( addr u path-a path-u -- addr2 u2 )
\ вернуть путь\имя  в PAD
  DUP IF 2DUP + 1- C@ is_path_delimiter 0= ELSE 0 THEN >R
  2SWAP
  <# HOLDS R> IF path_delimiter HOLD THEN HOLDS 0. #>
  2DUP + 0!
;
: +SourcePath ( addr u -- addr2 u2 )
  SOURCE-NAME CUT-PATH +Path
;
: FIND-FULLNAME ( a1 u1 -- a u )
  2DUP +SourcePath      2DUP FILE-EXIST IF 2SWAP 2DROP EXIT THEN 2DROP
  2DUP FILE-EXIST IF EXIT THEN
[DEFINED] +LibraryDirName [IF]
  2DUP +LibraryDirName  2DUP FILE-EXIST IF 2SWAP 2DROP EXIT THEN 2DROP
[THEN]
  2DUP +ModuleDirName   2DUP FILE-EXIST IF 2SWAP 2DROP EXIT THEN 2DROP
  2 ( ERROR_FILE_NOT_FOUND ) THROW
;
[DEFINED] INCLUDED_STD [IF]
: Included ( i*x c-addr u -- j*x ) \ 94 FILE
  FIND-FULLNAME INCLUDED_STD
;
[ELSE]
: Included ( i*x c-addr u -- j*x ) \ 94 FILE
  FIND-FULLNAME INCLUDED
;
[THEN]

: Include ( i*x "filename" -- j*x )
  NextWord 2DUP + 0 SWAP C! Included
;
\ =======================================
\ подключение с проверкой по заданному слову
\ для предупреждения повторных включений

: Required ( waddr wu laddr lu -- )
  2SWAP SFIND IF DROP 2DROP EXIT THEN 2DROP
  Included
;
: Require ( "word" "libpath" -- )
  NextWord NextWord 2DUP + 0 SWAP C!
  Required
;

 WARNING !
