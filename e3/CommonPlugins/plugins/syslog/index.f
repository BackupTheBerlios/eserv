: CreateLogSocket
  CreateUdpSocket THROW LogSocket !
  8000 LogSocket @ SetSocketTimeout THROW
  S" 127.0.0.1" GetHostIP THROW LogToIP !
  514 LogToPort !
;
