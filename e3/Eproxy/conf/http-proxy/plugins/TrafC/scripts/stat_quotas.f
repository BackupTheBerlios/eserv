Include list.f
Include file_list.f

: b_filemask S" *quotas.log" ; ' b_filemask TO filemask

S" quotas.log" MMDD- " {s}" VALUE vLogName

: LogName ( -- a u )  
  vLogName STR@
;
: LogFile ( -- a u )
  " {dir}{LogName}" STR@
;
: CheckCFG
  LogFile FILE-EXIST 0= IF
  GetFileList 2DROP
  uCurrFile @ ?DUP IF TO vLogName THEN
                        THEN
; CheckCFG \ *** !

' LogFile TO $cfgfile


: SelectCfg
  S" logfile_selected" IsSet  IF
  S" logfile_selected" EVALUATE 
  S" .." SEARCH IF 2DROP EXIT THEN
  vLogName STR!               THEN
; SelectCfg


: SkipWords ( n -- )
  BEGIN DUP WHILE NextWord 2DROP 1- REPEAT DROP
;
: SkipStat ( -- )
  2 SkipWords
;

VECT Accepted? ( canal_name-a canal_name-u -- flag )

: Accepted1? ( canal_name-a canal_name-u -- flag )
  S" ShowAll" EVALUATE EVALUATE IF 2DROP TRUE EXIT THEN
  " accept_{s}" STR@ IsSet
; ' Accepted1? TO Accepted?

070 VALUE TableTimeWidth
150 VALUE  TableCellWidth


: (GetHeader) ( -- )
  REFILL IF
    1 SkipWords
    " <tr><th width={TableTimeWidth}> Time </th>" uStr @ S+
    BEGIN NextWord DUP WHILE

      2DUP Accepted? IF

        2DUP
        " <th width={TableCellWidth} colspan=2><small><a href=state_quota.f?q={s}>{s}</a></small></th>" uStr @ S+
        
      ELSE 2DROP     THEN

      SkipStat
    REPEAT 2DROP
    " </tr>{CRLF}" uStr @ S+
  THEN
;
: GetHeader ( -- a u )
  RefreshStr
  ['] (GetHeader) ReadFile
  uStr @ STR@
;

: (#Canals) ( -- n )
  0 
  REFILL IF
    1 SkipWords    BEGIN
    NextWord DUP   WHILE
    Accepted? IF 1 ELSE 0 THEN +
    SkipStat       REPEAT 2DROP
  THEN
;
: #Canals ( -- n )
  ['] (#Canals) ReadFile
;
: TableWidth ( -- n )
  #Canals TableCellWidth * TableTimeWidth +
;
: (GetNames1) ( -- ) \ ->  <tr><th>on/off</th><th>Канал</th></tr>
  REFILL IF
    1 SkipWords
    BEGIN NextWord DUP WHILE
      2DUP 2DUP
      " <tr><td> <input type=checkbox name=accept_{s}></td>
<td><a href=state_quota.f?q={s}>{s}</a></td</tr>
" uStr @ S+
      SkipStat
    REPEAT 2DROP
    " {CRLF}" uStr @ S+
  THEN
;
: GetNames1 ( -- a u )
  RefreshStr
  ['] (GetNames1) ReadFile
  uStr @ STR@
;


: (GetNames2) { a u -- }
  a u S" .." COMPARE a u S" ." COMPARE AND 0=
  IF EXIT THEN a u
      2DUP 2DUP
      " <tr><td> <input type=checkbox name=accept_{s}></td>
<td><a href=state_quota.f?q={s}>{s}</a></td</tr>
"     uStr @ S+
;
: GetNames2 ( -- a u )
  RefreshStr
  S" ..\..\DATA\trafc\canals\save\quotas\*" +ModuleDirName
  ['] (GetNames2) FIND-FILES
  uStr @ STR@
;

' GetNames2 ->VECT GetNames


\ time  name1 stat1 util1 name2 stat2 util2... name_n stat_n util_n

: ParseTime ( -- )
  NextWord " <td width={TableTimeWidth}> <small> {s} </small> </td> "  
  uStr @ S+  
;
: ParseStat ( -- ) \  Байт/интервал  % 
  NextWord  >NUM
  " <td width={TableCellWidth 2/} align=right>{n}</td>"
  uStr @ S+

  NextWord ( % ) >NUM
  98 OVER U< IF DROP 98 THEN
  98 OVER - SWAP ( %  %- )
  " <td width={TableCellWidth 2/}><img border=0 src=tx.BMP width={n}% height=10><img border=0 src=txem.BMP width={n}% height=10></td>"
  uStr @ S+
;

: ParseCanals ( -- )
  BEGIN NextWord ( name ) DUP WHILE
  Accepted? IF ParseStat ELSE SkipStat THEN
  REPEAT  2DROP
;
: ParseAsLog  ( -- )
  " <tr>"           uStr @ S+
  ParseTime
  ParseCanals
  " </tr>{CRLF}"    uStr @ S+
;
: (ReadFile) ( -- )
  BEGIN REFILL WHILE  SOURCE NIP IF ParseAsLog THEN REPEAT
\  20 0 DO REFILL  DROP ParseAsLog  LOOP
\  REFILL  DROP ParseAsLog
;
: GetStat ( -- a u )
  RefreshStr
  ['] (ReadFile) ReadFile
  uStr @ STR@
;
