\ Random number server. Listening on port 80.


~nn/lib/sock2.f 

: ?Err  ( 0 / errcode --- )  DUP  IF   CR . ." ior not null "  WSAGetLastError . CR  QUIT  THEN DROP ;
: tick ( печать количества тиков ) TIMER@ (D.) ;

VARIABLE RNDN 0 ,
0 VALUE sockt
0 VALUE sockt2
0 VALUE xx
0 VALUE to_read 
1024 ALLOCATE . VALUE buf

 : wait_response ( sockt--)  BEGIN sockt2 ToRead THROW  300 PAUSE  DUP  TO to_read UNTIL   ;
: rdsockt  recv  DUP -1 = IF ." hhhy" ABORT  ELSE 0 THEN ;
 : type_answer   ( --) wait_response   0  to_read buf  sockt2  rdsockt THROW TO to_read  buf to_read TYPE ;
: rnd RNDN 2@ * TIMER@ * RNDN 2! ;


: qq
SocketsStartup THROW ." Sockets started" CR
CreateSocket THROW TO sockt ." Socket created" CR
80 sockt BindSocket THROW ." Socket binded" CR
sockt ListenSocket THROW  ." Listen" CR

BEGIN
rnd

sockt AcceptSocket THROW TO sockt2 ." Accept connection from: " 
 
sockt2 GetPeerIP&Port THROW     SWAP        NtoA TYPE CR

 type_answer

S" Twenty four 64-bit random numbers:" sockt2 WriteSocketLine THROW
 RNDN 2@ (D.) sockt2 WriteSocketLine  THROW   
 rnd
 400 PAUSE

 24 0 DO
 rnd  ( RNDN 2@ D. CR )
 RNDN 2@ (D.) sockt2 WriteSocketLine  THROW 

  LOOP

/ 13000 PAUSE 
 sockt2 CloseSocket THROW
  ." Socket closed" CR

AGAIN
SocketsCleanup  THROW  ." Socket cleaned" CR
 ;

STARTLOG
qq
qq
