\ ���������������� ������.
\ list+  - �� ������������ ������, � ������ ���������.

\ 08.07.2000  Ruv
\ 14.Apr.2001
\ ������� ���������  List-ForEach - xt �� ��������� flag
\ ������ ��������� ������ ?List-ForEach

( 
 0 \ struct node
 4   -- link
 ... -- body
)

: list+  ( a-elem  hList -- )  \ �������� _����_ ( node) � ������.
\ hList @  - ����� ���������� ������������ ��������.
  >R  R@ @  ?DUP IF  ( a-chnl a-last )
    OVER  !  ( a-chnl )
  THEN ( a-chnl )
  R> !
;

: ?List-ForEach  ( xt hList -- )
\ xt ( node -- flag )  \ ����������, ���� true
    BEGIN
      @ DUP  
    WHILE
        2DUP 2>R SWAP EXECUTE 0= IF RDROP RDROP EXIT THEN 2R>
    REPEAT 2DROP
;

: List-ForEach  ( xt hList -- )
\ xt ( node -- )
    BEGIN
      @ DUP  
    WHILE
        2DUP 2>R SWAP EXECUTE 2R>
    REPEAT 2DROP
;

:NONAME  . CR ;  ( S: xt )
: .list  ( list -- )  LITERAL  ( :da) SWAP List-ForEach ;

 ( example
VARIABLE hList  0 hList !

HERE 0 ,  hList list+
HERE 0 ,  hList list+
HERE 0 ,  hList list+

\ :NONAME  . .S CR  TRUE ;  hList  List-ForEach

hList .list

\ )
