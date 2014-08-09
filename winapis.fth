lstack.fth

VOCABULARY winlibs
ALSO winlibs DEFINITIONS

: ;WINAPIS  s-free  PREVIOUS   ;

: LIB:   ( -- addr u id )  s-free   s-s  CR OVER LoadLibraryA  DUP 0= IF -2009 THROW THEN   ;

: NOTFOUND ( addr u id addr u -- addr u id ) \ 2DUP TYPE CR
          2>R 3DUP 2R>    
          2DUP SHEADER
          ['] _WINAPI-CODE COMPILE, 
          HERE >R  
          0 , \ address of winproc
          0 , \ address of library name 
          0 , \ address of function name
          -1 , \ # of parameters
          IS-TEMP-WL 0=
                     IF
                        HERE WINAPLINK @ , WINAPLINK ! ( связь )
                     THEN 
              HERE DUP R@ CELL+ CELL+ ! >R 
               CHARS HERE SWAP DUP ALLOT MOVE 0 C, R> \ имя функции
              HERE  R> CELL+ !  2>R  
                CHARS HERE SWAP DUP ALLOT MOVE 0 C, 2R>  \ имя библиотеки addr_of_lib
       SWAP       GetProcAddress 0= IF -2010 THROW THEN \ ABORT" Procedure not found"
;

 PREVIOUS DEFINITIONS

: WINAPIS:  sp-save 1 2 3 ALSO winlibs   ; 

(

WINAPIS:
    LIB: USER32.DLL 
             PostQuitMessage
             PostMessageA
             SetActiveWindow
    LIB: GDI32.DLL
             CreateFontA
             GetDeviceCaps
             DeleteDC
    LIB: COMCTL32.DLL
             InitCommonControlsEx
;WINAPIS 
)
