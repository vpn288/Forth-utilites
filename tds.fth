~nn\lib\sock2.f 
lib\include\facil.f

88 CONSTANT port
0   VALUE          sockt
0   VALUE          sockt_a

: send_value   S>D (D.) sockt_a WriteSocket THROW ;
: send_delimeter sockt_a WriteSocket THROW ;

: make_value CREATE DOES> DROP send_value ;
: make_values 0 DO make_value LOOP ;

7 make_values    Day  Month  Year  Hours  Minutes  Seconds  Milliseconds 

: make_delimeter CREATE , DOES>  1 send_delimeter ;
: make_delimeters 0 DO make_delimeter LOOP ;

: define: : ;

BL  CHAR -   CHAR  :    3 make_delimeters  : - _



define:  time&date_server 

                SocketsStartup THROW   ." Sockets started" CR 
                CreateSocket   THROW   TO sockt ." Socket created" CR

                port sockt BindSocket THROW ." Socket binded" CR
                sockt ListenSocket THROW  ." Listen" CR

                sockt AcceptSocket THROW TO sockt_a ." Accept connection from: " 
                sockt_a GetPeerIP&Port THROW     SWAP        NtoA TYPE ."  port:" . 

                S" Current time:" sockt_a WriteSocket THROW

                TIME&DATE 

                Day - Month - Year _ Hours : Minutes : Seconds : Milliseconds  

                sockt_a CloseSocket THROW 

1000 PAUSE

                SocketsCleanup THROW 
;

define:  tds  BEGIN time&date_server  AGAIN ;
 tds
