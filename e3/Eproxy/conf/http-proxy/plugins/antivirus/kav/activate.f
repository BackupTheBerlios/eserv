AVkav UsedAntivirus !
AntivirusKAV[Data] AntivirusKAV[Bin] AvLoad
AvGetVersion AvGetDatabasesInfo 437 LOG

Antivirus[ProxyPerformsUpdate] >NUM
[IF]
:NONAME
 BEGIN
   S" AntivirusKAV[UpdateInterval]" EVALUATE >NUM DUP
 WHILE
   60 * 1000 * PAUSE
   S" AntivirusKAV[Updater]" EVALUATE StartAppWait DROP
   AvReload
   AvGetVersion AvGetDatabasesInfo 438 LOG
 REPEAT DROP
; TASK: AV-

0 AV- START CLOSE-FILE THROW
[THEN]

