[UNDEFINED] init-trafc [IF] \EOF [THEN]
init-trafc \ initialization

\ ClientTrafC \ Продолжить работу TrafC исключительно на отрезке  acTCP <--> client
 ServerTrafC \ Продолжить работу TrafC исключительно на отрезке  inet <--> acTCP
                ( в основном, актуально для прокси-серверов. )
\ StopTrafC   \ Приостановить работу TrafC

Include ext\index.f
\ Include DefBands.rules.txt
\ Include DefQuotas.rules.txt
