\ 24.Nov.2001 Sat 12:35 Ruv

\ 01.Nov.2002 Fri 09:07

REQUIRE list+ ..\CommonPlugins\plugins\groups_e2\list.f

VOCABULARY E2Groups_Support
GET-CURRENT
ALSO E2Groups_Support DEFINITIONS

USER hGroupsList
( список в памяти потока, перестает жить вместе с потоком )
: Groups+ { a u \ node -- }
  u 8 + ALLOCATE THROW -> node
  u node CELL+ C!
  a node CELL+ 1+ u MOVE
  node hGroupsList list+
;
\ : FreeGroupsList ( -- )
\   hGroupsList dealloc-list
\ ;
: ParseUser ( -- )
    [CHAR] : PARSE User COMPARE-U 0=              IF
    [CHAR] : PARSE Pass base64 COMPARE 0= UID ! THEN
;
: ParseGroup ( -- )
    UID @ 0= IF EXIT THEN
    [CHAR] : PARSE User COMPARE-U 0=  IF
    [CHAR] : PARSE Groups+          THEN
;

VECT Parse
' ParseUser TO Parse

: InterpretE2 ( -- )
  NextWord { a u }
  a u S" Users:"  COMPARE 0= IF ['] ParseUser  TO Parse EXIT THEN
  a u S" Groups:" COMPARE 0= IF ['] ParseGroup TO Parse EXIT THEN
  a u ['] Parse EVALUATE-WITH
;

: CheckGroupName { a u f node -- a u f1 f2 }
  a u  2DUP
  node CELL+ COUNT COMPARE-U IF f TRUE ELSE TRUE FALSE THEN
;

SET-CURRENT

: IsMember  ( groupname-a groupname-u -- f )
  UID @ 0= IF 2DROP FALSE EXIT THEN
  0 ['] CheckGroupName hGroupsList ?List-ForEach ( a u f )
  NIP NIP
;
: IsMember: ( "group" -- flag )
  NextWord IsMember
;
: UsersGroupsFileE2: { \ f }
  ParseStr R/O OPEN-FILE-SHARED
  IF DROP 0 UID ! EXIT THEN -> f
  ['] ParseUser  TO Parse
  BEGIN f FREFILL WHILE InterpretE2 REPEAT
  f CLOSE-FILE THROW
  POSTPONE \
\  \EOF
;

PREVIOUS