[DEFINED] AVdrweb [IF]
AVdrweb UsedAntivirus !
AntivirusDrWEB[Data] AntivirusDrWEB[Bin] AvLoad

AvGetVersion AvGetDatabasesInfo 437 LOG

:NONAME
 BEGIN
   S" AntivirusDrWEB[UpdateInterval]" EVALUATE >NUM DUP
 WHILE
   60 * 1000 * PAUSE
   S" AntivirusDrWEB[Updater]" EVALUATE StartAppWait DROP
   AvReload GetTime
   AvGetVersion AvGetDatabasesInfo 438 LOG
 REPEAT
; TASK: AV-

0 AV- START CLOSE-FILE THROW
[THEN]