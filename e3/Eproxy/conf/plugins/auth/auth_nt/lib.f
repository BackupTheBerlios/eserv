WINAPI: NetLocalGroupEnum       NETAPI32.DLL
WINAPI: NetGroupEnum            NETAPI32.DLL
WINAPI: NetUserEnum             NETAPI32.DLL
WINAPI: NetUserGetLocalGroups   NETAPI32.DLL
WINAPI: NetUserGetGroups        NETAPI32.DLL
WINAPI: NetLocalGroupAddMembers NETAPI32.DLL
WINAPI: NetLocalGroupDelMembers NETAPI32.DLL
WINAPI: NetUserAdd              NETAPI32.DLL
WINAPI: NetUserDel              NETAPI32.DLL
WINAPI: NetLocalGroupAdd        NETAPI32.DLL
WINAPI: NetLocalGroupDel        NETAPI32.DLL
WINAPI: NetLocalGroupGetMembers NETAPI32.DLL
WINAPI: NetApiBufferFree        NETAPI32.DLL


' AUTH-PARAMS uAuthServer !

: ForEachGroup { xt \ totalentries entriesread bufptr -- }
  0 ^ totalentries ^ entriesread 
  -1 ( MAX_PREFERRED_LENGTH) ^ bufptr
  0 ( level) AuthServer >UNICODE DROP ( server)
  NetLocalGroupEnum 0= ( NERR_Success)
  IF bufptr entriesread 0 ?DO I CELLS OVER + @ xt EXECUTE LOOP DROP THEN
  bufptr NetApiBufferFree DROP

  0 -> totalentries 0 -> entriesread 0 -> bufptr
  0 ^ totalentries ^ entriesread 
  -1 ( MAX_PREFERRED_LENGTH) ^ bufptr
  0 ( level) AuthServer >UNICODE DROP ( server)
  NetGroupEnum 0= ( NERR_Success)
  IF bufptr entriesread 0 ?DO I CELLS OVER + @ xt EXECUTE LOOP DROP THEN
  bufptr NetApiBufferFree DROP
;
: ForEachUser { xt \ totalentries entriesread bufptr -- }
  0 ^ totalentries ^ entriesread 
  -1 ( MAX_PREFERRED_LENGTH) ^ bufptr
  0 ( filter ) 0 ( level) AuthServer >UNICODE DROP ( server)
  NetUserEnum 0= ( NERR_Success)
  IF bufptr entriesread 0 ?DO I CELLS OVER + @ xt EXECUTE LOOP DROP THEN
  bufptr NetApiBufferFree DROP
;
\ =============
USER CurrentUser
USER CurrentGroup

: ForEachGroupOfUser { usera useru xt \ totalentries entriesread bufptr -- }
  usera useru CurrentUser S!
  ^ totalentries ^ entriesread 
  -1 ( MAX_PREFERRED_LENGTH) ^ bufptr
  1 ( LG_INCLUDE_INDIRECT) 0 ( level) usera useru >UNICODE DROP
  AuthServer >UNICODE DROP ( server)
  NetUserGetLocalGroups 0= ( NERR_Success)
  IF bufptr entriesread 0 ?DO I CELLS OVER + @ xt EXECUTE LOOP DROP THEN
  bufptr NetApiBufferFree DROP

  0 -> totalentries 0 -> entriesread 0 -> bufptr
  ^ totalentries ^ entriesread 
  -1 ( MAX_PREFERRED_LENGTH) ^ bufptr
  0 ( level) usera useru >UNICODE DROP
  AuthServer >UNICODE DROP ( server)
  NetUserGetGroups 0= ( NERR_Success)
  IF bufptr entriesread 0 ?DO I CELLS OVER + @ xt EXECUTE LOOP DROP THEN
  bufptr NetApiBufferFree DROP
;
: ForEachMemberOfGroup { groupa groupu xt \ totalentries entriesread bufptr -- }
  groupa groupu CurrentGroup S!
  0 ^ totalentries ^ entriesread 
  -1 ( MAX_PREFERRED_LENGTH) ^ bufptr
  3 ( level) groupa groupu >UNICODE DROP
  AuthServer >UNICODE DROP ( server)
  NetLocalGroupGetMembers 0= ( NERR_Success)
  IF bufptr entriesread 0 ?DO I CELLS OVER + @ xt EXECUTE LOOP DROP THEN
  bufptr NetApiBufferFree DROP
;
: LoginDomainUser
  ['] AUTH-PARAMS uAuthServer !
  2OVER 2OVER 2SWAP AuthServer " Login: {s} {s} {s}" STR@ TYPE SPACE
  LoginUserNT DUP . CR
;

USER Users
USER Groups
USER UserGroups

: UserGroupsList1 ( addr -- )
  UASCIIZ> UNICODE> 2DUP
  " <a href={''}{script_name}?action=list_group&group={s}&user={CurrentUser @ STR@}{''}>{s}</a>, "
  UserGroups @ S+
;
: UserGroupsList ( usera useru -- addr u )
  "" UserGroups !
  ['] UserGroupsList1 ForEachGroupOfUser
  UserGroups @ STR@
;
: UserTable ( addr -- )
  UASCIIZ> UNICODE> 
  2DUP UserGroupsList 2SWAP
  2DUP
  " <tr><td><input type=checkbox name={''}{s}{''}></td><td>{s}</td><td>{s}</td></tr>{CRLF}"
  Users @ S+
;
: GroupTable ( addr -- )
  UASCIIZ> UNICODE> 2DUP
  " <tr><td><input type=checkbox name={''}{s}{''}></td><td>{s}</td></tr>{CRLF}"
  Groups @ S+
;
: UserList ( addr -- )
  UASCIIZ> UNICODE> 2DUP
  " <option value={''}{s}{''}>{s}</option>{CRLF}"
  Users @ S+
;
: GroupList ( addr -- )
  UASCIIZ> UNICODE> 2DUP
  " <option value={''}{s}{''}>{s}</option>{CRLF}"
  Groups @ S+
;
: ShowUsers { -- addr u }
  "" Users !
  ['] UserTable  ForEachUser
  Users @ STR@
;
: ShowGroups { -- addr u }
  "" Groups !
  ['] GroupTable  ForEachGroup
  Groups @ STR@
;
: ListUsers { -- addr u }
  "" Users !
  ['] UserList  ForEachUser
  Users @ STR@
;
: ListGroups { -- addr u }
  "" Groups !
  ['] GroupList  ForEachGroup
  Groups @ STR@
;
: AddUserToGroup { usera useru groupa groupu \ buf -- }
  1
  usera useru >UNICODE DROP -> buf
  ^ buf 3 ( level)
  groupa groupu >UNICODE DROP
  AuthServer >UNICODE DROP
  NetLocalGroupAddMembers THROW
;
: RemoveUserFromGroup { usera useru groupa groupu \ buf -- }
  1
  usera useru >UNICODE DROP -> buf
  ^ buf 3 ( level)
  groupa groupu >UNICODE DROP
  AuthServer >UNICODE DROP
  NetLocalGroupDelMembers THROW
;
: CreateUser { usera useru passa passu \ userinfo -- }
  8 CELLS ALLOCATE THROW -> userinfo
  usera useru >UNICODE DROP userinfo !
  passa passu >UNICODE DROP userinfo CELL+ !
  1 ( USER_PRIV_USER) userinfo 3 CELLS + !
  0 userinfo 1
  AuthServer >UNICODE DROP
  NetUserAdd THROW
  userinfo FREE THROW
;
: RemoveUser ( usera useru -- )
  >UNICODE DROP
  AuthServer >UNICODE DROP
  NetUserDel THROW
;
: CreateGroup { groupa groupu \ groupinfo -- }
  groupa groupu >UNICODE DROP -> groupinfo
  0 ^ groupinfo 0
  AuthServer >UNICODE DROP
  NetLocalGroupAdd THROW
;
: RemoveGroup ( groupa groupu -- )
  >UNICODE DROP
  AuthServer >UNICODE DROP
  NetLocalGroupDel THROW
;
USER uIsMemberOf

: IsMemberOf1 ( group_z -- )
  UASCIIZ> UNICODE>
  CurrentGroup @ STR@ COMPARE 0= IF TRUE uIsMemberOf ! THEN
;
: IsMemberOf ( usera useru groupa groupu -- flag )
  FALSE uIsMemberOf !
  CurrentGroup S! ['] IsMemberOf1 ForEachGroupOfUser
  uIsMemberOf @
;
: IsMemberOf: ( usera useru "group" -- flag )
  ParseStr IsMemberOf
;
: ShowGroupUsers1
  UASCIIZ> UNICODE> 
  " <tr><td>{s}</td></tr>{CRLF}"
  Users @ S+
;
: ShowGroupUsers ( groupa groupu -- )
  " <table border=1>" Users !
  ['] ShowGroupUsers1 ForEachMemberOfGroup
  S" </table>" Users @ STR+
  Users @ STR@
;
