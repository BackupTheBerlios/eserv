: LoginDomainUser ( usera useru passa passu -- uid )
  SetUser " UsersFileE2: {AUTH-PARAMS}" STR@
  EVALUATE UID @
;

REQUIRE ForEachUser conf/plugins/auth/auth_e2/lib.f