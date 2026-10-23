# quine

A CARDIAC program that punches its own deck: the two-card loader, an address and a value card for each of its 21
cells, and the card that jumps to its start. Feed what it punches back in as a tape and you get the same 45 cards
again, forever.

    heartburn asm quine.asm
    heartburn run quine.tape

The catch is self-modifying code: a cell the program changes while it runs would be punched with its changed value.
So each such cell starts out holding what it holds at the moment it is punched. The loop counter `a` lives in cell 03
and starts at 3, its own address; `doit`, where the loop builds `OUT a`, starts as `OUT doit`, which is what it holds
when the loop reaches it. No JMP, because JMP writes cell 99.
