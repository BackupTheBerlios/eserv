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
  ( ������ ������ Unauthorized: ����������� �� �����:������ ��������
    �������, �� �� ����������� �������������� ������� black_list,
    ������� ��� ������ �������������� ������ � ������������, � �����
    �������� � ������� � �������)
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
        IF ( ��� �������, UID ��� ����������, �.�. ����������� �������� ����� -
             IP-����������� ��� � ������� black_list, 
             ����� ��� ��������� ���������� ������� )
           NextWord 2DROP TRUE Time?
           IF Authorized \EOF ( ��� ������� ��������� )
           ELSE Unauthorized_temp POSTPONE \ THEN
        ELSE ( ��� �������, �� ����� ��� ���������, ���� �� ����� user
               � ��������� � ����������� ������� � ��������� � ������ ������
               � ����������� �� �������)
              >IN @ -> in ( �������� ��� ������� ����������� )
              NextWord 2DROP TRUE Time?
              IF ( ������� �����������, ����� �������� �������������� )
                 in >IN !
                 User Pass ParseStr AuthorizeInDomain DUP UID !
                 IF Authorized \EOF
                 ELSE ( ������ �� ������, ����������� )
                    in >IN ! Unauthorized POSTPONE \
                 THEN
              ELSE ( ������� �� �����������, ����������� ���������� )
                 Unauthorized_temp POSTPONE \
              THEN
        THEN
     ELSE ( ��� �� ������� ) Unauthorized POSTPONE \ THEN
  ELSE POSTPONE \ THEN
;
: UrlAuthGroup: { \ in } \ url groupname domain rules
  URL =~ 
  IF >IN @ -> in ( ����� ��� ����� ���������� )
     User IsMemberOfGroupInDomain:
     IF UID @
        IF ( ������ �������, UID ��� ����������, �.�. ����������� �������� ����� -
             IP-����������� ��� � ������� black_list, 
             ����� ��� ��������� ���������� ������� )
           TRUE Time?
           IF Authorized \EOF ( ��� ������� ��������� )
           ELSE Unauthorized_temp POSTPONE \ THEN
        ELSE ( ������ �������, �� ����� ��� ���������, ���� �� ����� user
               � ��������� � ����������� ������� � ��������� � ������ ������
               � ����������� �� �������)
              TRUE Time?
              IF ( ������� �����������, ����� �������� �������������� )
                 in >IN ! ParseStr 2DROP
                 User Pass ParseStr AuthorizeInDomain DUP UID !
                 IF Authorized \EOF
                 ELSE ( ������ �� ������, ����������� )
                    in >IN ! ParseStr 2DROP Unauthorized POSTPONE \
                 THEN
              ELSE ( ������� �� �����������, ����������� ���������� )
                 Unauthorized_temp POSTPONE \
              THEN
        THEN
     ELSE ( ������ �� ������� )
          in >IN ! ParseStr 2DROP
          Unauthorized POSTPONE \
     THEN
  ELSE POSTPONE \ THEN
;
: DenyUrlAuthUser: { \ in } \ url username domain rules
  URL =~ 
  IF User =~
     IF UID @
        IF ( ��� �������, UID ��� ����������, �.�. ����������� �������� ����� -
             IP-����������� ��� � ������� black_list, 
             ����� ��� ��������� ���������� ������� )
           NextWord 2DROP TRUE Time?
           IF Unauthorized_temp \EOF ( ��� ������� ��������� )
           ELSE Authorized POSTPONE \ THEN
        ELSE ( ��� �������, �� ����� ��� ���������, ���� �� ����� user
               � ��������� � ����������� ������� � ��������� � ������ ������
               � ����������� �� �������)
              >IN @ -> in ( �������� ��� ������� ����������� )
              NextWord 2DROP TRUE Time?
              IF ( ������� �����������, ����� �������� �������������� )
                 in >IN !
                 User Pass ParseStr AuthorizeInDomain DUP UID !
                 IF Unauthorized_temp \EOF
                 ELSE ( ������ �� ������, ����������� )
                    in >IN ! Unauthorized POSTPONE \
                 THEN
              ELSE ( ������� �� �����������, ����������� ���������� )
                 Authorized POSTPONE \
              THEN
        THEN
     ELSE ( ��� �� ������� ) Authorized POSTPONE \ THEN
  ELSE POSTPONE \ THEN
;
: DenyUrlAuthGroup: { \ in } \ url groupname domain rules
  URL =~ 
  IF >IN @ -> in ( ����� ��� ����� ���������� )
     User IsMemberOfGroupInDomain:
     IF UID @
        IF ( ������ �������, UID ��� ����������, �.�. ����������� �������� ����� -
             IP-����������� ��� � ������� black_list, 
             ����� ��� ��������� ���������� ������� )
           TRUE Time?
           IF Unauthorized_temp \EOF ( ��� ������� ��������� )
           ELSE Authorized POSTPONE \ THEN
        ELSE ( ������ �������, �� ����� ��� ���������, ���� �� ����� user
               � ��������� � ����������� ������� � ��������� � ������ ������
               � ����������� �� �������)
              TRUE Time?
              IF ( ������� �����������, ����� �������� �������������� )
                 in >IN ! NextWord 2DROP
                 User Pass ParseStr AuthorizeInDomain DUP UID !
                 IF Unauthorized_temp \EOF
                 ELSE ( ������ �� ������, ����������� )
                    in >IN ! NextWord 2DROP Unauthorized POSTPONE \
                 THEN
              ELSE ( ������� �� �����������, ����������� ���������� )
                 Authorized POSTPONE \
              THEN
        THEN
     ELSE ( ������ �� ������� )
          Authorized POSTPONE \
     THEN
  ELSE POSTPONE \ THEN
;
