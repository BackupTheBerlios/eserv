: DoList ( xt list -- )
  SWAP >R @
  BEGIN
    DUP
  WHILE
    DUP R@ SWAP >R EXECUTE
    R> @
  REPEAT R> 2DROP
;
: NodeValue CELL+ @ ;

: inList ( addr u list -- flag )
  ROT ROT 2>R @
  BEGIN
    DUP
  WHILE
    DUP NodeValue XCOUNT 2R@ COMPARE 0= IF DROP 2R> 2DROP TRUE EXIT THEN
    @
  REPEAT 2R> 2DROP
;
: FreeList ( list -- )
  DUP @
  BEGIN
    DUP
  WHILE
    DUP @ SWAP FREE THROW
  REPEAT SWAP !
;
: AddNode ( value list -- )
  2 CELLS ALLOCATE THROW >R
  SWAP R@ CELL+ !
  DUP @ R@ !
  R> SWAP !
;

: COPYBUFC ( addr1 u1 -- addr2 )
  DUP CELL+ CHAR+ ALLOCATE THROW DUP >R CELL+ SWAP DUP >R MOVE
  R> R> SWAP 2DUP + CELL+ 0 SWAP C!
  OVER !
;
