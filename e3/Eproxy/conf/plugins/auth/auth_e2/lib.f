: ForEachGroup { xt  -- }
;
: ForEachUser { xt  -- }
;
: ForEachGroupOfUser { usera useru xt -- }
;
: ForEachMemberOfGroup { groupa groupu xt -- }
;
: UserGroupsList ( usera useru -- addr u )
;
: UserTable ( addr -- )
;
: GroupTable ( addr -- )
;
: UserList ( addr -- )
;
: GroupList ( addr -- )
;
: ShowUsers { -- addr u }
;
: ShowGroups { -- addr u }
;
: ListUsers { -- addr u }
;
: ListGroups { -- addr u }
;
: AddUserToGroup { usera useru groupa groupu -- }
;
: RemoveUserFromGroup { usera useru groupa groupu -- }
;
: CreateUser { usera useru passa passu -- }
;
: RemoveUser ( usera useru -- )
;
: CreateGroup { groupa groupu \ groupinfo -- }
;
: RemoveGroup ( groupa groupu -- )
;
: IsMemberOf ( usera useru groupa groupu -- flag )
;
: IsMemberOf: ( usera useru "group" -- flag )
;
: ShowGroupUsers ( groupa groupu -- )
;
