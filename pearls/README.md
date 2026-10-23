# CARDIAC pearls

Idioms for programming CARDIAC well: each one an instruction, the reason, and a small example. CARDIAC has one
test (TAC: jump if the accumulator is negative), ten instructions, a four-digit accumulator and 100 three-digit
cells, so its idioms are about comparisons, digits and room.

1. **Put the threshold at 0 and make the thing you test reach it.** TAC is the only test, so every other comparison
   is built from it: `x < k` is a SUB, a TAC and a cell holding k; `x == k` takes two TACs; `x < 0` is the TAC
   alone. A loop that counts up from -96 to 0 needs no comparison at all; one that counts up to 96 pays a SUB and a
   cell holding 96 every pass.
2. **Let negative mean "none".** Make the state you test for the negative one: -1 for "no entry", "off the edge",
   "no more cards". Testing it is one TAC, and -1 is never a valid index or column, so it needs no other test.
3. **Keep a flag as 0 and -1, not 1 and 0.** A flag stored as 0/1 is tested with CLA, SUB 00, TAC; as -1/0 with
   CLA, TAC: a cell and a step less per test. The price is a cell holding -1. It pays from the second test on.
4. **Cell 00 is the constant 1.** It is wired to 001, so ADD 00 and SUB 00 add or take one without a constant cell
   of your own. Every other constant costs a cell, since an instruction names a cell, never a value.
5. **Equality is the expensive test.** `x == k` is SUB, TAC, a reversed SUB, TAC (not below, and not above). Test
   with "below" where you can, and put the common case first.
6. **Ask the cheap question first.** Order your tests so a later one is already implied by what you know: if a
   counter starts at 0, "is it at least 0" never needs asking.
7. **Store the sign, not the number.** A two-way choice kept as -1 or 0 is one TAC to read; kept as 0 or 1 it needs
   a SUB first.
8. **Don't test what you just set.** Code that sets a value and then jumps to a test of that value can jump to the
   answer instead.
9. **Park the number you subtract; keep the other in the accumulator.** CARDIAC subtracts only a cell. Comparing
   two computed values, store the one to subtract and SUB it, instead of storing both and reloading. For a < b, test
   b - a - 1 against 0; the 1 is SUB 00.
10. **Encode so one comparison decides.** Choose your numbers so "highest wins" is the rule you want: a value that
    must beat another gets 10 added, and one compare picks it.
11. **Scale by ten.** ×10 is one SFT; ×8 is eight ADDs. Prefer powers of ten, and ten's friends (2, 5, 20, 25, 50,
    by doubling and a shift).
12. **Fold the multiply into the shift.** SFT xy shifts left x places, then right y, zero-filling, in the four-digit
    accumulator, so one shift can pick a digit and place it. From abc: `SFT 31` gives c00, `SFT 13` gives 00a,
    `SFT 23` then `SFT 10` gives 0b0. The manual's Program No. 6 reverses abc in 15 instructions this way, adding
    each piece to the running total as it goes.
13. **Lay a table out in decimal: the address is the digits.** Keep the entry for (P, R) in cell 10P + R: CLA P,
    SFT 10, ADD R, then add the CLA instruction and run it. A row stride of 10 is one shift, and the unused cells
    x4…x9 between rows hold your variables. The manual's Nim programs do this.
14. **Classify with comparisons, not division.** Division is a loop of subtractions; three compares that sort a
    value into four bands are cheaper than dividing it.
15. **Divide by walking, and stop when the answer stops mattering.** If you only need the answer up to some bound,
    walk toward it and stop at the bound, instead of dividing all the way.
16. **Halve before you square; check the box first.** 60 squared is 3600, past a cell; 30 squared fits. And test
    |dx| against the radius before squaring at all.
17. **Fit the arithmetic to three digits.** Arrange a formula so no intermediate leaves a cell: (21 s + 17) mod 1000
    as 10 (2 s mod 100) + s + 17.
18. **Spend every digit of a random number.** Take a second value from the digits the first doesn't use, instead of
    drawing again.
19. **Load tables with the program, not with INP.** A table on the program's deck is placed by the loader, with no
    fill loop in the program. A single value is cheaper read with INP.
20. **Stream the table; don't store it.** If you need only a few entries, read the whole table as input cards and
    keep just those: no memory for the table, only time. It can't work for a sort, which needs every element at
    once.
21. **When it doesn't fit, split it.** Two small programs passing cards often fit where one big one doesn't. When
    the code is too big but the data must stay, chain tapes: the first ends with HRS n, the operator loads tape n
    and starts at 00, and the cells the new tape doesn't load keep their values (see sortem).
