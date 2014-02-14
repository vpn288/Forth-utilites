~yz/lib/winctl.f
REQUIRE WINDOWS... ~yz/lib/winlib.f

0 VALUE win
0 VALUE times
0 VALUE hdc
0 VALUE myrect
0 VALUE mypen2
22 VALUE dots
0 VALUE fid
CREATE 0d0a  0xD C, 0xA C, 

CREATE *dots dots CELLS 3 * ALLOT


: rnd TIMER@ * 200 UMOD ;

: rndxy   dots 2* 0 DO rnd 2 * 25 +  I CELL * *dots + !   rnd 3 * 25 + I CELL * *dots + CELL+ ! LOOP  ;

: tre rndxy 
S" X: "  fid WRITE-FILE THROW 
dots 2* 0 DO  I CELL * *dots + @ S>D (D.) fid WRITE-FILE THROW  S"  " fid WRITE-FILE THROW  LOOP
0d0a 2 fid WRITE-FILE THROW

S" Y: "  fid WRITE-FILE THROW
dots 2* 0 DO  I CELL * *dots + CELL+ @ S>D (D.) fid WRITE-FILE THROW S"  " fid WRITE-FILE THROW LOOP
0d0a 2 fid WRITE-FILE THROW
0d0a 2 fid WRITE-FILE THROW

 ;
 
 rndxy
 
WINAPI: CreatePen GDI32.dll
WINAPI: PolyBezier GDI32.dll
WINAPI: RedrawWindow User32.dll


PROC: paint
  mypen2 windc SelectObject DROP
  dots *dots windc PolyBezier DROP
  rndxy
PROC;

MESSAGES: my

M: wm_lbuttondblclk
    rndxy 
5 0 0 winmain -hwnd@ RedrawWindow DROP \ wrm_erase + wrm_invalidate
     
  TRUE
M;
MESSAGES;

: run 
  WINDOWS...
S" warps.txt" R/W CREATE-FILE THROW TO fid

0x00F00599 2 0 CreatePen TO mypen2

0 create-window TO win
 win TO winmain
 " Безьешки" win -text!
420 430 0 button  place 
this TO myrect
10 10 myrect ctlresize
  ['] tre myrect -command!

120 130 win winmove
500 500 win winresize
   paint win -painter!
  my win -wndproc!
win winshow

...WINDOWS
fid CLOSE-FILE THROW
BYE
;

TRUE TO ?GUI
' run MAINX !
S" warpy.exe" SAVE
run

