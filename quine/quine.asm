; a CARDIAC quine: punches the deck that loads it
a:     DAT 3          ; cell 03: the address being punched; starts as its own address
start: OUT two        ; the loader: 002
       OUT e800       ;             800
loop:  OUT a          ; an address card
       CLA a
       ADD op         ; build OUT a
       STO doit
doit:  OUT doit       ; runs as OUT a: the value card (and when a is doit, this is what doit holds)
       CLA a
       ADD one
       STO a
       SUB fin
       TAC loop
       OUT go         ; the last card: JMP start
       HRS 0
two:   DAT 2
e800:  DAT 800
op:    OUT 0
one:   DAT 1
go:    JMP start
fin:   DAT fin+1      ; one past the last cell
