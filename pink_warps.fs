~yz/lib/winctl.f
REQUIRE WINDOWS... ~yz/lib/winlib.f

0 VALUE win
0 VALUE times
0 VALUE hdc
0 VALUE myrect
0 VALUE mypen2
22 VALUE dots

CREATE *dots dots CELLS 3 * ALLOT

: rnd TIMER@ * 200 UMOD ;

: rndxy   dots 2* 0 DO rnd 2 * 25 +  I CELL * *dots + !   rnd 3 * 25 + I CELL * *dots + CELL+ ! LOOP  ;

: new_warp
       rndxy 
       5 0 0 winmain -hwnd@ RedrawWindow DROP

 ;
 
 rndxy
 
WINAPI: CreatePen GDI32.dll
WINAPI: PolyBezier GDI32.dll
WINAPI: RedrawWindow User32.dll



PROC: paint
  mypen2 windc SelectObject DROP
  dots *dots windc PolyBezier DROP
PROC;

MESSAGES: my

M: wm_lbuttondblclk
    rndxy 
    5 0 0 winmain -hwnd@ RedrawWindow DROP \ 5 = rdw_erase rdw_invalidate OR
  TRUE
M;

MESSAGES;

: run 
  WINDOWS...
0x00F00599 2 0 CreatePen TO mypen2

0 create-window TO win
 win TO winmain
 " Безьешки" win -text!
420 430 0 button  place 
this TO myrect
10 10 myrect ctlresize
  ['] new_warp myrect -command!

120 130 win winmove
500 500 win winresize
   paint win -painter!
  my win -wndproc!
win winshow

...WINDOWS


;

' run MAINX !
S" warpy.exe" SAVE
run

