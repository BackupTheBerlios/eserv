\ API антивирусов, к сожалению, закрытый.
\ Ётот Plugin будет работать, если поддержка антивирусов
\ скомпилирована внутрь EXE. ≈сли нет, то plugin не загрузитс€.

USER uInfectedMailFile		\ дл€ хранени€ имени файла письма с вирусом

\ проверка письма на вирусы
: ScanMailFile ( filea fileu -- true | false )
  AvScanFile
  IF VirusName S! TRUE
  ELSE VirusName 0! 2DROP FALSE THEN
;

\ перемещение зараженного письма и фиксаци€ имени файла (~pig)
: MoveInfectedFileTo:
  ParseStr			\ выбрать им€ файла
  2DUP uInfectedMailFile S!	\ запомнить дл€ извещений
  MoveCurrentFileTo		\ переместить файл письма
;

\ выборка имени файла зараженного письма
: INFECTEDMAILFILE ( -- addr u )
  uInfectedMailFile @ STR@
;
