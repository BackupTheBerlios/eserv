VARIABLE AuthParams
VARIABLE AuthSource
VARIABLE AuthType

: AUTH-PARAMS AuthParams @ STR@ ;
: AUTH-SOURCE AuthSource @ STR@ ;
: AUTH-TYPE   AuthType   @ STR@ ;

: AuthSource:
  ParseStr AuthSource S! NextWord 2DUP AuthType S!
  1 PARSE AuthParams S!
  " ..\{s}\lib.f" STR@ ['] INCLUDED CATCH
  ?DUP IF " {CRLF}Unable to open lib.f, error: {n}{CRLF}" STYPE THEN
;
S" ..\AuthSources.rules.txt" INCLUDED


: AddToGroup
  S" on" COMPARE 0=
  IF S" group" EVALUATE AddUserToGroup
  ELSE 2DROP THEN
;
: RemoveFromGroup
  S" on" COMPARE 0=
  IF S" group" EVALUATE RemoveUserFromGroup
  ELSE 2DROP THEN
;
: RemoveUsers
  S" on" COMPARE 0=
  IF RemoveUser
  ELSE 2DROP THEN
;

InVoc{ ACTIONS2
: add_to_group
  ['] AddToGroup ForEachParam
  " Add OK" STR@
;
: remove_from_group
  ['] RemoveFromGroup ForEachParam
  " Remove OK" STR@
;
: add_user
  S" username" EVALUATE S" password" EVALUATE CreateUser
  " Create OK" STR@
;
: del_users
  ['] RemoveUsers ForEachParam
  " Remove OK" STR@
;
: add_group
  S" groupname" EVALUATE CreateGroup
  " Create OK" STR@
;
: del_group
  S" group" EVALUATE RemoveGroup
  " Remove OK" STR@
;
}PrevVoc

InVoc{ ACTIONS
: update
  S" action2" EVALUATE
  ALSO ACTIONS2 EVALUATE PREVIOUS
;
: list_group
  S" group" EVALUATE ShowGroupUsers
;
}PrevVoc
