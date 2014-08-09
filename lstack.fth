SP@ VALUE spstore 
: sp-save   SP@  TO spstore ;
: sp-restore spstore  SP!  ;
: s-allot  ( n bytes -- addr )   sp-save  spstore SWAP - ALIGNED DUP >R  CELL- CELL- SP!   R> ;
: s-s      ( -- addr u )    NextWord 2>R R@  s-allot DUP DUP R@ + 0!  2R> >R SWAP R@ CMOVE R>  ;
: s-free   spstore CELL+ SP! ;
: 3DUP    2 PICK 2 PICK 2 PICK ;
: 3DROP  DROP DROP DROP ; 

\ 14 s-allot
\ sp-restore 
