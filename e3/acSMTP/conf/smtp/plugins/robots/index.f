( ~pig)
\ дополнительные переменные потока

USER $RobotFileName				\ для хранения имени файла копии письма

\ работа с файлом индивидуальной копии письма
: RobotFileName ( -- str ) $RobotFileName @ ;
: ROBOTFILENAME ( -- addr u ) RobotFileName STR@ ;
: CreateRobotFile ( addr u -- )
  2DUP FixFilename				\ почистить имя файла от неправильных символов
  2DUP " {ModuleDirName}{s}" STR@ $RobotFileName S!	\ зафиксировать полный путь к файлу
  CopyCurrentFileTo				\ создать копию файла
;
: CreateRobotFile: ( "file" -- )
  ParseStr					\ выбрать имя файла
  CreateRobotFile				\ создать временную копию для робота
;
