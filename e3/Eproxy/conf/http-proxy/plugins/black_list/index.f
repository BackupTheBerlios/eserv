VARIABLE uBlackList

: User~? ( "[mask]" -- flag )
  NextWord ?DUP 
  IF User 2SWAP DUP 1- MLEN ! WildCMP-U 0=
  ELSE DROP TRUE THEN
;
: Time? ( flag1 -- flag2 )
  >IN @ NextWord NIP
  IF >IN ! 1 PARSE EVALUATE AND
  ELSE DROP THEN
;

: NotBlockUrl:
  URL =~ IF User~? Time? IF \EOF THEN ELSE POSTPONE \ THEN
;
: BlockUrl:
  URL =~ IF User~? Time? IF NotFound \EOF THEN ELSE POSTPONE \ THEN
;
: NotBlockHost:
  TARGET-HOST =~ IF User~? Time? IF \EOF THEN ELSE POSTPONE \ THEN
;
: BlockHost:
  TARGET-HOST =~ IF User~? Time? IF NotFound \EOF THEN ELSE POSTPONE \ THEN
;

\ =================
USER $AUTH-DATA
USER $REALM
: REALM $REALM @ STR@ ;

: Authorization { \ in }
  >IN @ -> in
  BL SKIP BL PARSE S" Basic" COMPARE 0=
  IF
    BL SKIP BL PARSE BasicAuthorization
    User Pass SetUser UID 0!
  ELSE in >IN ! 1 PARSE $AUTH-DATA S!
  THEN
;
: TCP_DENIED
  " HTTP/1.0 407 Unauthorized
Server: {PROG-NAME}
Content-Type: text/html
Proxy-Authenticate: Basic realm={REALM}
Proxy-Connection: close

Unauthorized ({REALM})
" FPUTS TRUE TO vStopProtocol
  407 TO vHttpReplyCode
;
: Unauthorized ( -- )
  S" TCP_DENIED" SetAction
  ParseStr $REALM S!
;
: Authorized
  S" TCP_MISS" SetAction uACTION_CNT 0!
;
: Unauthorized_temp
  ( особый случай Unauthorized: авторизация по имени:паролю пройдена
    успешно, но не выполняются дополнительные условия black_list,
    поэтому нет смысла переспрашивать пароль у пользователя, а нужно
    отказать в доступе к ресурсу)
  NotFound
;

IN-PROTOCOL: HTTP-PROXY

: PROXY-AUTHORIZATION:
  Authorization
;

PROTOCOL;

: UrlAuthUser: { \ in } \ url username domain rules
  URL =~ 
  IF User =~
     IF UID @
        IF ( имя совпало, UID уже установлен, т.е. авторизация пройдена ранее -
             IP-авторизация или в строках black_list, 
             нужно еще проверить выполнение правила )
           NextWord 2DROP TRUE Time?
           IF Authorized \EOF ( все условия выполнены )
           ELSE Unauthorized_temp POSTPONE \ THEN
        ELSE ( имя совпало, но нужно еще проверить, есть ли такой user
               с указанным в авторизации паролем в указанном в строке домене
               и выполняется ли правило)
              >IN @ -> in ( сохраним для попытки авторизации )
              NextWord 2DROP TRUE Time?
              IF ( правило выполняется, будем пытаться авторизоваться )
                 in >IN !
                 User Pass ParseStr AuthorizeInDomain DUP UID !
                 IF Authorized \EOF
                 ELSE ( пароль не совпал, переспросим )
                    in >IN ! Unauthorized POSTPONE \
                 THEN
              ELSE ( правило не выполняется, авторизация бесполезна )
                 Unauthorized_temp POSTPONE \
              THEN
        THEN
     ELSE ( имя не совпало ) Unauthorized POSTPONE \ THEN
  ELSE POSTPONE \ THEN
;
: UrlAuthGroup: { \ in } \ url groupname domain rules
  URL =~ 
  IF >IN @ -> in ( домен нам позже пригодится )
     User IsMemberOfGroupInDomain:
     IF UID @
        IF ( группа совпала, UID уже установлен, т.е. авторизация пройдена ранее -
             IP-авторизация или в строках black_list, 
             нужно еще проверить выполнение правила )
           TRUE Time?
           IF Authorized \EOF ( все условия выполнены )
           ELSE Unauthorized_temp POSTPONE \ THEN
        ELSE ( группа совпала, но нужно еще проверить, есть ли такой user
               с указанным в авторизации паролем в указанном в строке домене
               и выполняется ли правило)
              TRUE Time?
              IF ( правило выполняется, будем пытаться авторизоваться )
                 in >IN ! ParseStr 2DROP
                 User Pass ParseStr AuthorizeInDomain DUP UID !
                 IF Authorized \EOF
                 ELSE ( пароль не совпал, переспросим )
                    in >IN ! ParseStr 2DROP Unauthorized POSTPONE \
                 THEN
              ELSE ( правило не выполняется, авторизация бесполезна )
                 Unauthorized_temp POSTPONE \
              THEN
        THEN
     ELSE ( группа не совпала )
          in >IN ! ParseStr 2DROP
          Unauthorized POSTPONE \
     THEN
  ELSE POSTPONE \ THEN
;
: DenyUrlAuthUser: { \ in } \ url username domain rules
  URL =~ 
  IF User =~
     IF UID @
        IF ( имя совпало, UID уже установлен, т.е. авторизация пройдена ранее -
             IP-авторизация или в строках black_list, 
             нужно еще проверить выполнение правила )
           NextWord 2DROP TRUE Time?
           IF Unauthorized_temp \EOF ( все условия выполнены )
           ELSE Authorized POSTPONE \ THEN
        ELSE ( имя совпало, но нужно еще проверить, есть ли такой user
               с указанным в авторизации паролем в указанном в строке домене
               и выполняется ли правило)
              >IN @ -> in ( сохраним для попытки авторизации )
              NextWord 2DROP TRUE Time?
              IF ( правило выполняется, будем пытаться авторизоваться )
                 in >IN !
                 User Pass ParseStr AuthorizeInDomain DUP UID !
                 IF Unauthorized_temp \EOF
                 ELSE ( пароль не совпал, переспросим )
                    in >IN ! Unauthorized POSTPONE \
                 THEN
              ELSE ( правило не выполняется, авторизация бесполезна )
                 Authorized POSTPONE \
              THEN
        THEN
     ELSE ( имя не совпало ) Authorized POSTPONE \ THEN
  ELSE POSTPONE \ THEN
;
: DenyUrlAuthGroup: { \ in } \ url groupname domain rules
  URL =~ 
  IF >IN @ -> in ( домен нам позже пригодится )
     User IsMemberOfGroupInDomain:
     IF UID @
        IF ( группа совпала, UID уже установлен, т.е. авторизация пройдена ранее -
             IP-авторизация или в строках black_list, 
             нужно еще проверить выполнение правила )
           TRUE Time?
           IF Unauthorized_temp \EOF ( все условия выполнены )
           ELSE Authorized POSTPONE \ THEN
        ELSE ( группа совпала, но нужно еще проверить, есть ли такой user
               с указанным в авторизации паролем в указанном в строке домене
               и выполняется ли правило)
              TRUE Time?
              IF ( правило выполняется, будем пытаться авторизоваться )
                 in >IN ! NextWord 2DROP
                 User Pass ParseStr AuthorizeInDomain DUP UID !
                 IF Unauthorized_temp \EOF
                 ELSE ( пароль не совпал, переспросим )
                    in >IN ! NextWord 2DROP Unauthorized POSTPONE \
                 THEN
              ELSE ( правило не выполняется, авторизация бесполезна )
                 Authorized POSTPONE \
              THEN
        THEN
     ELSE ( группа не совпала )
          Authorized POSTPONE \
     THEN
  ELSE POSTPONE \ THEN
;
