REQUIRE WINDOWS... ~yz/lib/winlib.f
~yz/lib/winctl.f

~yz/lib/wincc.f

STARTLOG

values.txt
winapis.txt
dots.txt

GROUP gg

VALUES: 
	 win 1stdotctl dot_m
;VALUES


Dots: dots1
	100 , 100 ,
	115 , 120 ,
	125 , 107 ,
	149 , 111 ,
	103 , 137 ,
	117 , 298 ,
	163 , 186 ,
;Dots

dots1 copy_to dots2
.( dots1: )
dots1 dotstype CR
.( dots2: )
dots2 dotstype CR

CREATE ctls dots1 @ CELLS ALLOT  

PROC: quit
  winmain W: wm_close ?send TRUE
PROC;


WINAPIS:
	LIB: GDI32.dll
		 CreatePen  
 		 PolyBezier
		 Polyline   
		 MoveToEx   
		 LineTo   

	LIB: User32.dll  
		 RedrawWindow 
		 SetTimer     
		 KillTimer   
;WINAPIS

0x00F00599 2 0 CreatePen CONSTANT mypen2
0x00000599 1 0 CreatePen CONSTANT mypen3
0x00F0FF6F 3 0 CreatePen CONSTANT mypen4


PROC: paint
 
  mypen2 windc SelectObject DROP
  dots2 @    dots2 CELL+  windc Polyline DROP
	\ mypen3 windc SelectObject DROP
	\ dots1 @  dots1 CELL+  windc PolyBezier .
 
  
PROC;

: do_dot	
		
		gg @ .
		red 	1stdotctl  	-bgcolor! 
		1stdotctl -userdata@ DUP CR ." 1st ctl:" . 
		2* CELLS   dots2 CELL+ + 2@

		blue 	thisctl 	-bgcolor! 
		thisctl -userdata@ DUP ."  presd ctl:"  . 
		2* CELLS dots2 CELL+ + 2@
		1stdotctl -userdata@
		2* CELLS dots2 CELL+ + 2!
		thisctl -userdata@
		2* CELLS dots2 CELL+ + 2!
		1stdotctl	-userdata@
		thisctl 	-userdata@
		1stdotctl	-userdata!
		thisctl		-userdata!
		thisctl TO 1stdotctl 
	CR ." dotstype:"
		dots2 dotstype 
		winmain force-redraw 
;
: do_dot_main 	gg @ EXECUTE ;

: do_dot_m	CR ."  dotted " 
		dot_m 1+ TO dot_m
		blue thisctl -bgcolor!

		dot_m DUP . CR DUP dots2 @ 1- 
<> IF 
	
		2* CELLS dots2 CELL+ + 2@ 
		thisctl 	-userdata@
		2* CELLS dots2 CELL+ + 2@
		dot_m 
		2* CELLS dots2 CELL+ + 2!
		thisctl 	-userdata@
		2* CELLS dots2 CELL+ + 2! 
( индекс нажатой точки ставится дотм, индекс нажатой точки присваивается точке ктл которой получается по дотм )
		thisctl		-userdata@ DUP ."   pressed dot:" .

		dot_m	
		thisctl		-userdata!
		
		dot_m CELLS ctls + @ -userdata!

ELSE 
		."  last dot" .
THEN
		winmain force-redraw 
		
		dots2 dotstype 
; 


: set_tooltip ( I  -- I )  
				  DUP 2* CELLS dots1 CELL+ +  2@  >R
                                 <# 
                                  
                                  S>D #S   	S" , Y:"     HOLDS R>  
                                  S>D #S        S" X:"       HOLDS 
                                      
                                      #> DROP  this  -tooltip!   ;

: set_color ( color  --  )  this -bgcolor! ;
: set_size  (  --  )  5 5 this ctlresize ;
: set_place ( I --  ) 2* CELLS dots1 CELL+ + 2@ 1- DUP . SWAP 1- DUP . rectangle place ;
: set_command ( -- ) ['] do_dot_main this -command! ;


: place_dot ( I -- ) 
		DUP set_place 
		set_size 
		red set_color     
		set_command  
		DUP this -userdata! 
		DUP set_tooltip 2DROP 
		CELLS ctls + this SWAP ! ;

: place_1st_dot
	0 set_place 
	this TO 1stdotctl 
	set_size 
	blue set_color 
	set_command 
	0 this -userdata! 0 set_tooltip this ctls ! ;

: place_dots   
                place_1st_dot dots1 @  1 DO I place_dot   LOOP   ;



: run 
  WINDOWS...
 
	0 create-window TO win
	win TO winmain
	" Соединяем точки" win -text!
	0 create-tooltip

 250 200 " Choose" groupbox  place 90 60 this ctlresize
 gg start-group
250 220 ['] do_dot " 1st dot" radio  place 	TRUE  this -state!
250 240 ['] do_dot_m " next dot" radio place

 
  place_dots 
           paint win -painter!

    win winshow

...WINDOWS

;
\ маршрут вручную 
\ по нажатию на точку надо получить индекс этой точки и поставить координаты точки  
run
