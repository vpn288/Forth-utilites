\ mock smtp server v1.5

~nn/lib/sock2.f 

: ?Err  ( 0 / errcode --- )  DUP  IF   CR . ." ior not null "                               WSAGetLastError . CR  ABORT THEN DROP ;

VARIABLE temp 
8196 CONSTANT buf_size
buf_size 4 - CONSTANT buf_limit

0 VALUE ?QUIT
0 VALUE sockt
0 VALUE sockt2
0 VALUE session_id
0 VALUE fid
0 VALUE timr

0 VALUE to_read 
buf_size ALLOCATE THROW CONSTANT buf_begin
buf_begin VALUE buf 
buf_size ALLOCATE THROW CONSTANT str_buf_begin
str_buf_begin VALUE strbuf 

: !timeout   600 TO timr 
;

: timer_tick
                      timr 1- TO timr
;

: ?timeout  timr 0= IF ." Timeout" CR  RDROP RDROP RDROP  THEN  
;

: rdsockt   recv  DUP 0= IF -1 ELSE 0 THEN 
;

:  +S  ( addr u --- ) >R strbuf R@ CMOVE R> strbuf + TO strbuf  strbuf 1+ 0!  ;

: +S>adr_u ( ---- adr u ) str_buf_begin strbuf str_buf_begin - ;

: reset_+S   str_buf_begin TO strbuf ;

: log  
        OVER OVER fid WRITE-FILE THROW ;

: logCR 
         OVER OVER fid WRITE-LINE THROW ;

: server_answerCR ( addr u -- )
                        logCR   sockt2 WriteSocketLine THROW 
;

: server_answer ( addr u -- )
                        log sockt2 WriteSocket THROW
;

: buf_adr_u     buf_begin buf buf_begin - 
;

: set_quit  TRUE TO ?QUIT ;

: wait_response ( sockt--) 
                 !timeout BEGIN sockt2 ToRead THROW ( ." to read:" DUP .  ) 300 PAUSE timer_tick  ?timeout   DUP  TO to_read  UNTIL  
;

: input_tread       buf_begin >IN @ + buf buf_begin - >IN @ - 
;

: read_from_socket_write_to_file 
                                  wait_response  buf_begin
                                  buf_begin  to_read  MIN  DUP TO  to_read  sockt2  ReadSocket  THROW  
                                (  buf_begin to_read DUMP )
                               buf_begin to_read  fid   WRITE-FILE  THROW DROP  
;

 : ?LF.CRLF    buf_begin to_read +
                    
                       5 - @ DUP HEX  .  DECIMAL 0x0D2E0A0D =  

;

\ ---define server's commands ---

VOCABULARY REPLYES
GET-CURRENT ALSO REPLYES DEFINITIONS ORDER


  : HELO    
                  S" 250 mock.md Greeting " server_answer  
                  input_tread server_answer
                  buf buf_begin - 2- >IN ! 
  ; 

: EHLO    
                  S" 250 mock.md Greeting " server_answer  
                  input_tread server_answer
                  buf buf_begin - 2- >IN ! 
  ; 

 : DATA      S" 354 Enter mail, end with . on a line by itself" server_answerCR 
                BEGIN    read_from_socket_write_to_file    ?LF.CRLF UNTIL
                S" 250 Message accepted" server_answerCR 
                0x000 buf_begin  !  0 buf_begin 4 + !  0 >IN !  
 ;

  : QUIT    S" 221 bye-bye!" server_answerCR  ( ." STACK0:" DEPTH .SN )
                 0x0A0D0A0D buf_begin  !    0 >IN !   
                set_quit ( ." stack:" DEPTH .SN )
  ;

 : RSET    S" 250 OK - Reset" server_answerCR
                buf buf_begin - 2- >IN ! 
 ;
\ -----------------------------------------------
  
  VOCABULARY RCPT
     GET-CURRENT ALSO RCPT  DEFINITIONS ORDER

        : TO:      S" 250 OK recepient accepted, mail to: " server_answer
                      input_tread server_answer
                      buf buf_begin - 2- >IN !        
;

        : NOTFOUND    S" -ERR 500 Invalid rcpt to"  server_answerCR    ;

  PREVIOUS  SET-CURRENT


\ ---------------------------------------------
   VOCABULARY MAIL
       GET-CURRENT ALSO MAIL DEFINITIONS ORDER

          : FROM:   
                       S" 250 OK - mail from " server_answer
                     input_tread server_answer
                    (   S" sender accepted" server_answerCR )
                       buf buf_begin - 2- >IN ! 
;
 
          : NOTFOUND    S"  500 -ERR  Invalid mail from "  server_answerCR    ;

   PREVIOUS  SET-CURRENT
\ -----------------------------------------------

  
  : NOTFOUND    S" 500 -ERR  Wrong command "  server_answerCR   ." notfound" CR  ;

PREVIOUS SET-CURRENT
\ --------------------------------------------


: type_answer   ( --)
                wait_response   0  to_read buf  sockt2  rdsockt THROW TO to_read  buf to_read TYPE
;

: ?CRLF (  --  )
           buf 2- @ 0xFFFF AND  DUP 0x0D0A = SWAP 0x0A0D  = OR 
;



: wait_comand_from_client ( -- addr u ) 
                          buf_begin TO buf

                          BEGIN
                          wait_response 
                          buf  to_read sockt2  ReadSocket  THROW DUP .  TO to_read 
                          buf to_read + TO buf 
                          ?CRLF 
                          UNTIL                        
;


: ?BS   ( scan for bs symbol code  08. if symbol found move right rest of string to left by one symbol )
         buf_adr_u  temp ! BEGIN  DUP C@ 8 <>  temp @ 0<> AND   WHILE  1+   temp @ 1-   temp ! REPEAT 1+ DUP 2-  temp @  CMOVE 
                        
;

: ?:< ( scan for :<, insert space between ) 
        ( version 1, insert space on < ) 

         buf_adr_u     BEGIN >R  DUP   W@  0x3C3A <>  IF  ELSE DUP 1+ BL SWAP C!  THEN   1+  R> 1- DUP 0= UNTIL DROP DROP
;

: line_editor ( addr u -- addr u ) 
              ( exit on CRLF or on depletion of input buffer, catch BS symbol )
                                         
               BEGIN  ?BS ?:< temp @ 0= UNTIL 

;                     

: make_filename 
                       session_id S>D (D.) +S S" .txt" +S 
;

: start_session 
                  make_filename  +S>adr_u  3 CREATE-FILE THROW TO fid reset_+S
                  S" 220 mock.md  Mock SMTP Server v1.5  " server_answer
                  S"   Starting session " server_answer
                  session_id S>D (D.) server_answer
                  session_id 1+ TO session_id
                  S"   Greetings user" server_answer
                ( sockt2 GetPeerName  THROW server_answer )
                  S" , connected from IP:Port " server_answer
                  sockt2 GetPeerIP&Port THROW
                  SWAP
                  NtoA  server_answer
                  S" :"   server_answer
                  S>D (D.) server_answerCR 

;             

: session 

            BEGIN        
                        wait_comand_from_client   
                          line_editor 
                        buf_adr_u TYPE CR
                       buf_adr_u  REPLYES EVALUATE ONLY            
            ?QUIT
       UNTIL 
; 


: qq
      BEGIN
           FALSE TO ?QUIT
           
           SocketsStartup ?Err ." Sockets started" CR
           CreateSocket ?Err TO sockt ." Socket created" CR
           1313 sockt BindSocket ?Err ." Socket binded" CR
           sockt ListenSocket ?Err ." Listen" CR

          sockt AcceptSocket ?Err TO sockt2 ." Accept" CR
          start_session
          session
         
       
      fid CLOSE-FILE THROW
      SocketsCleanup THROW  ." Socket cleaned" CR
      AGAIN
 ;

STARTLOG
qq
