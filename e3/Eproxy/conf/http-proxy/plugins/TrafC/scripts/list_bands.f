Include list.f

:NONAME S" ..\..\Bands.list.txt" ; TO $cfgfile
( относительно  conf\http-proxy\plugins\TrafC\%lang%\menu\
  в котором находится причинный html )

: (ReadFile) ( -- )
  BEGIN REFILL WHILE
  SOURCE NIP IF
    NextWord \ name
    NextWord \ cps
    2SWAP
    " <tr> <td><input type=checkbox name={''}n{CURSTR @}{''}></td> <td>{s}</td> <td>{s}</td> </tr>{CRLF}"
   uStr @ S+
  THEN         REPEAT
;
: ReadCfg ( -- a u )
  ['] (ReadFile) ReadFile
  uStr @ STR@
;
: band-name ( -- a u )
  S" band_name" EVALUATE 
  ['] NextWord EVALUATE-WITH
;

InVoc{ ACTIONS

: add_band ( -- a u ) { \ h }
  open-cfg
  band-name DUP IF
    " {s} {band_cps AsNum} {CRLF}"
    STR@ addto-cfg
    S" Added OK"
  ELSE 2DROP
    S" Add fail, name is unacceptable"
  THEN
  close-cfg
;
}PrevVoc
