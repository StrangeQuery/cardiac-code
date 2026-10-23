# sortem

Reads numbers, sorts them, and prints them sorted, then their mean, minimum, maximum and median.

`sortem.asm` does it all in one tape: 94 cells of code and variables leave room for only 2 numbers.

`sortem-1.asm` and `sortem-2.asm` split it in two. Phase 1 reads 35 numbers into cells 64–98, bubble-sorts them in
place, and stops with `HRS 2`: the bug on 2 asks for tape 2. Tape 2 loads over phase 1's code but never touches cells
64–98, so the sorted numbers are still there; it prints them and the statistics. Same machine, 35 numbers instead
of 2.

    heartburn asm sortem-1.asm
    heartburn asm sortem-2.asm
    heartburn run sortem-2phase.tape -- 9 18 27 8 17 26 7 16 25 6 15 24 5 14 23 4 13 22 3 12 21 2 11 20 1 10 19 0 9 18 27 8 17 26 7

`sortem-2phase.tape` is the two tapes stacked in one file with a `# phase 2` line between them. On a paper CARDIAC
you do the same by hand: when it halts with the bug on 2, load tape 2 and start again at 00.

The mean keeps its total in one card, so the numbers must add up to 999 or less.
