REQUIRE AllocConsole conf/plugins/console/alloc_console.f

: INIT-CONSOLE ( -- )
  ?GUI IF AllocConsole DROP THEN
  " {PROG-NAME} console" STR@ DROP
  SetConsoleTitleA DROP
;
: RUN-CONSOLE
  INIT-CONSOLE
( SPF4.008: ) CONSOLE-HANDLES
  ['] QUIT CATCH .
;
