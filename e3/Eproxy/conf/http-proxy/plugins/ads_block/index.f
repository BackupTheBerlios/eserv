VARIABLE uAdsBlock

: SendBlankGif
  200 TO vHttpReplyCode
  " HTTP/1.0 200 OK
Content-Type: image/gif
Content-Length: 45
Connection: Keep-Alive

" FPUTS S" conf\http-proxy\plugins\ads_block\blank.gif" FILE FPUT
;
: AllowUrl:
  URL =~ IF \EOF THEN
;
: DenyUrl:
  URL =~ IF S" SendBlankGif" SetAction \EOF THEN
;
: AllowHost:
  TARGET-HOST =~ IF \EOF THEN
;
: DenyHost:
  TARGET-HOST =~ IF S" SendBlankGif" SetAction \EOF THEN
;
