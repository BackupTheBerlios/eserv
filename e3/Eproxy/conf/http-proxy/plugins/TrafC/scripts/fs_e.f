REQUIRE [IF]                lib/include/tools.f
WARNING @ WARNING 0!
REQUIRE STR@                ~ac/lib/str2.f
WARNING !
REQUIRE ForEachIP           ~ac/lib/win/winsock/foreach_ip.f
REQUIRE InVoc{              ~ac/lib/transl/vocab.f
REQUIRE StartApp            ~ac/lib/win/process/process.f
REQUIRE WinNT?              ~ac/lib/win/winver.f


: IsSet  ( a u -- f ) 
  2DROP FALSE
;
