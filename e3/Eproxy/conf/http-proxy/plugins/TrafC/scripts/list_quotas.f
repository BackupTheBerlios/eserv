Include list.f

:NONAME S" ..\..\Quotas.list.txt" ; TO $cfgfile
( относительно  conf\http-proxy\plugins\TrafC\%lang%\menu\
  в котором находится причинный html )

: (ReadFile) ( -- )
  { \ s }
  BEGIN REFILL WHILE
  SOURCE NIP IF
    " <tr> <td><input type=checkbox name={''}n{CURSTR @}{''}></td>" -> s
    NextWord " <td>{s}</td>" s S+
    NextWord NextWord 2SWAP  " <td>{s} {s} </td>" s S+
    NextWord NextWord 2SWAP  " <td>{s} {s} </td>" s S+
    " </tr>{CRLF}" s S+
    s uStr @ S+
  THEN         REPEAT
;
: ReadCfg ( -- a u )
  ['] (ReadFile) ReadFile
  uStr @ STR@
;
: quota-name ( -- a u )
  S" quota_name" EVALUATE ['] NextWord EVALUATE-WITH
;

InVoc{ ACTIONS

: add_quota ( -- a u ) { \ h }
  open-cfg
  quota-name DUP IF
    " {s} {volume AsNum} {select_volume} {period AsNum} {select_period} {CRLF}"
    STR@ addto-cfg
    S" Added OK"
  ELSE 2DROP
    S" Add fail, name is unacceptable"
  THEN
  close-cfg
;
}PrevVoc
