\ FilterAdd ( srchost srcmask srcport targethost targetmask targetport -- )
\ запретить пакеты с srchost srcmask srcport на targethost targetmask targetport

\ FilterDenyPacketsTo { host port -- }
\ запретить исходящие соединения к хосту:порту

\ FilterDenyPacketsFrom { host port -- }
\ запретить любые соединения с указанного хоста
