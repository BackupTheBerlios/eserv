Include list.f
:NONAME S" ..\..\Assign.rules.txt" ; TO $cfgfile
( относительно  conf\http-proxy\plugins\TrafC\%lang%\menu\
  в котором находится причинный html )

: $Bands  S" ..\..\Bands.list.txt" ;
: $Quotas S" ..\..\Quotas.list.txt" ;

VECT ProcessName ( addr u -- )

: (FetchNames) ( -- )
  BEGIN REFILL WHILE NextWord DUP IF ProcessName ELSE 2DROP THEN REPEAT
;
: ForListTxt ( addr u xt -- )
  TO ProcessName
  R/O OPEN-FILE THROW 
  ['] (FetchNames) INCLUDE-FILE-WITH
;
: ForBands ( xt -- )
\ xt ( adrr u -- )
  $Bands ROT ForListTxt 
;
: ForQuotas ( xt -- )
\ xt ( adrr u -- )
  $Quotas ROT ForListTxt 
;
: ForCanals ( xt -- )
  DUP >R ForBands R> ForQuotas
;
: (count_names) ( n a u -- n+1)
  NIP IF 1+ THEN
;
: #Bands ( -- n )
  0 $Bands ['] (count_names) ForListTxt 
;
: #Quotas ( -- n )
  0 $Quotas ['] (count_names) ForListTxt 
;

InVoc{ ACTIONS

: add_rule ( -- a u )
  open-cfg
  " {rule_str}{CRLF}" STR@ addto-cfg 
  close-cfg
  S" Add OK"
;
: ?eof ( -- a u )
  S" _eof" IsSet IF S" \EOF" ELSE S" " THEN
;
: ?prior ( -- a u )
  S" pr_str" EVALUATE >num IF " Priority: {n}" STR@ EXIT THEN S" "
;
0 VALUE ca 0 VALUE cu

: direct_in ( -- )
  " +CanalIn` {ca cu} " uStr @ S+
;
: direct_ot ( -- )
  " +CanalOt` {ca cu} " uStr @ S+
;
: direct_not   ;
: not_selected ;

: (AddCanal) ( a u -- )
  TO cu TO ca
  " radio_{ca cu}" { s }
  s STR@ IsSet IF  s STR@ EVALUATE ( "direct_xxx" ) EVALUATE  THEN
  s STRFREE
;
: AddCanals ( -- a u )
  RefreshStr
  ['] (AddCanal) ForCanals
  uStr @ STR@
;
: add_rule_1  ( -- a u )
  open-cfg
" {select_cond} {cond_str} | {AddCanals} {?prior} {?eof}
" STR@ addto-cfg
  close-cfg
  S" Add OK"
;
}PrevVoc

\ http://localhost:3140/conf/http-proxy/plugins/TrafC/ru/menu/rules_list.html?
\ action=add_rule_1&select_cond=IP%3D&cond_str=&radio_B1=direct_ot&radio_B3=direct_ot&radio_Bccc=direct_in&radio_Q1=not_selected&radio_Q2=direct_in&radio_Qzzz=direct_ot&radio_Qnnn=direct_in&radio_Qooo=direct_in&pr_str=

: (ReadFile) ( -- )
  { \ s }
  BEGIN REFILL WHILE
  SOURCE NIP IF
    [CHAR] | PARSE  0 PARSE 2SWAP
    " <tr><td><input type=checkbox name={''}n{CURSTR @}{''}></td><td>{s}</td><td>{s}</td></tr>{CRLF}"
    uStr @ S+
  THEN         REPEAT
;
: ReadCfg ( -- a u )
  RefreshStr
  ['] (ReadFile) ReadFile
  uStr @ STR@
;
\ ===========================
0 VALUE ca 0 VALUE cu

: SelectName ( a u -- )
  TO cu TO ca
" <tr> <td> {ca cu} </td>
  <td><input type=radio name=radio_{ca cu} value=direct_in></td>
  <td><input type=radio name=radio_{ca cu} value=direct_ot></td>
  <td><input type=radio name=radio_{ca cu} value=not_selected></td></tr>
" uStr @ S+
;
: GetList ( xt1 xt2 -- addr u )
  RefreshStr 
  EXECUTE
  uStr @ STR@
;
\  RefreshStr ' SelectName ForBands uStr STR@
\  ' SelectName' ForBands GetList
