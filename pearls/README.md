# CARDIAC pearls

Idioms for programming CARDIAC well: each one an instruction, the reason, and a small example. CARDIAC has one
test (TAC: jump if the accumulator is negative), ten instructions, a four-digit accumulator and 100 three-digit
cells, so its idioms are about comparisons, digits, instructions treated as numbers, and room.

## Comparisons: TAC is the only test

1. **Put the threshold at 0 and make the thing you test reach it.** TAC is the only test, so every other comparison
   is built from it: `x < k` is a SUB, a TAC and a cell holding k; `x == k` takes two TACs; `x < 0` is the TAC
   alone. A loop that counts up from -96 to 0 needs no comparison at all; one that counts up to 96 pays a SUB and a
   cell holding 96 every pass.

   ```
   cell  contents  notes
    10      130    CLA 30  cells 10-14: count up from -5; the TAC is the whole test
    11      200    ADD 00
    12      630    STO 30
    13      530    OUT 30
    14      310    TAC 10
    15      900    HRS 00
    30     -005    the counter
   ```

   It prints -4, -3, -2, -1 and 0, with no cell holding a limit.

2. **Let negative mean "none".** Make the state you test for the negative one: -1 for "no entry", "off the edge",
   "no more cards". Testing it is one TAC, and -1 is never a valid index or column, so it needs no other test.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-15: add up cards until a negative one
    11      140    CLA 40
    12      316    TAC 16  -1 means no more cards
    13      241    ADD 41
    14      641    STO 41
    15      810    JMP 10
    16      541    OUT 41
    17      900    HRS 00
    40      000    the card
    41      000    the sum
   ```
   <!-- input: 3 4 5 -1 -->

   With the cards 3, 4, 5 and -1 it prints 12.

3. **Keep a flag as 0 and -1, not 1 and 0.** A flag stored as 0/1 is tested with CLA, SUB 00, TAC; as -1/0 with
   CLA, TAC: a cell and a step less per test. The price is a cell holding -1. It pays from the second test on.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-12: the flag is 0 or -1, so reading it is CLA and TAC
    11      130    CLA 30
    12      315    TAC 15
    13      531    OUT 31
    14      900    HRS 00
    15      500    OUT 00
    16      900    HRS 00
    31      000
   ```
   <!-- input: -1 -->

   With the flag set (-1) it prints 1; with 0 it prints 0. Kept as 1 and 0, the test would need a SUB 00 before the TAC.

4. **Equality is the expensive test.** `x == k` is SUB, TAC, a reversed SUB, TAC (not below, and not above). Test
   with "below" where you can, and put the common case first.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-16: x == 7 is two tests, x - 7 and 7 - x
    11      130    CLA 30
    12      731    SUB 31
    13      319    TAC 19  below 7
    14      131    CLA 31
    15      730    SUB 30
    16      319    TAC 19  above 7
    17      500    OUT 00  equal: print 1
    18      900    HRS 00
    19      532    OUT 32
    20      900    HRS 00
    31      007
    32      000
   ```
   <!-- input: 7 -->

   With 7 it prints 1; with any other number it prints 0.

5. **Ask the cheap question first.** Order your tests so a later one is already implied by what you know: if a
   counter starts at 0, "is it at least 0" never needs asking.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-13: x counts cards, so it is never negative; one test is enough
    11      130    CLA 30
    12      731    SUB 31  x - 10
    13      316    TAC 16
    14      532    OUT 32
    15      900    HRS 00
    16      500    OUT 00  a single digit: print 1
    17      900    HRS 00
    31      010
    32      000
   ```
   <!-- input: 4 -->

   With 4 it prints 1; with 10 or more it prints 0.

6. **Store the sign, not the number.** A two-way choice kept as -1 or 0 is one TAC to read; kept as 0 or 1 it needs
   a SUB first.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-14: whose turn it is, 0 for A and -1 for B; -1 - turn swaps them
    11      131    CLA 31
    12      730    SUB 30
    13      630    STO 30
    14      317    TAC 17  one TAC reads it
    15      500    OUT 00  A's turn: print 1
    16      900    HRS 00
    17      532    OUT 32  B's turn: print 2
    18      900    HRS 00
    31     -001
    32      002
   ```
   <!-- input: 0 -->

   Starting from A's turn (0), it swaps to B and prints 2.

7. **Don't test what you just set.** Code that sets a value and then jumps to a test of that value can jump to the
   answer instead.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-13: read cards until one is 7 or more
    11      130    CLA 30
    12      731    SUB 31
    13      310    TAC 10
    14      530    OUT 30  found it: act here, instead of setting a flag and testing it again
    15      900    HRS 00
    31      007
   ```
   <!-- input: 2 5 9 1 -->

   With the cards 2, 5, 9 and 1 it prints 9.

8. **Park the number you subtract; keep the other in the accumulator.** CARDIAC subtracts only a cell. Comparing
   two computed values, store the one to subtract and SUB it, instead of storing both and reloading. For a < b, test
   b - a - 1 against 0; the 1 is SUB 00.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-15: a = x + y, parked in cell 33 because it is the one subtracted
    11      031    INP 31
    12      032    INP 32
    13      130    CLA 30
    14      231    ADD 31
    15      633    STO 33
    16      132    CLA 32  cells 16-20: b = 10z stays in the accumulator; test b - a - 1
    17      410    SFT 10
    18      733    SUB 33
    19      700    SUB 00
    20      323    TAC 23
    21      500    OUT 00  a < b: print 1
    22      900    HRS 00
    23      534    OUT 34
    24      900    HRS 00
    34      000
   ```
   <!-- input: 12 7 2 -->

   With x = 12, y = 7 and z = 2 it compares 19 with 20 and prints 1.

9. **Encode so one comparison decides.** Choose your numbers so "highest wins" is the rule you want: a value that
   must beat another gets 10 added, and one compare picks it.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-14: plain cards are 0-9 and trumps are stored with 10 added, so one compare picks the winner
    11      031    INP 31
    12      130    CLA 30
    13      731    SUB 31
    14      317    TAC 17
    15      530    OUT 30
    16      900    HRS 00
    17      531    OUT 31
    18      900    HRS 00
   ```
   <!-- input: 9 12 -->

   With a plain 9 against the trump 2 (stored as 12) it prints 12: the trump wins.

10. **Classify with comparisons, not division.** Division is a loop of subtractions; three compares that sort a
    value into four bands are cheaper than dividing it.

    ```
    cell  contents  notes
     10      030    INP 30  cells 10-17: three compares sort x into four bands
     11      130    CLA 30
     12      740    SUB 40  x - 100
     13      320    TAC 20
     14      741    SUB 41  x - 300
     15      322    TAC 22
     16      742    SUB 42  x - 600
     17      324    TAC 24
     18      544    OUT 44
     19      900    HRS 00
     20      543    OUT 43
     21      900    HRS 00
     22      500    OUT 00
     23      900    HRS 00
     24      545    OUT 45
     25      900    HRS 00
     40      100
     41      200
     42      300
     43      000    band 0
     44      003    band 3
     45      002    band 2
    ```
    <!-- input: 450 -->

    With 450 it prints 2: under 100 is band 0, under 300 band 1, under 600 band 2, the rest band 3.

## Digits: arithmetic in decimal

1. **Scale by ten.** ×10 is one SFT; ×8 is eight ADDs. Prefer powers of ten, and ten's friends (2, 5, 20, 25, 50,
   by doubling and a shift).

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-14: x times 10 is one shift
    11      130    CLA 30
    12      410    SFT 10
    13      631    STO 31
    14      531    OUT 31
    15      130    CLA 30  cells 15-19: x times 20 is a doubling and the same shift
    16      230    ADD 30
    17      410    SFT 10
    18      631    STO 31
    19      531    OUT 31
    20      900    HRS 00
   ```
   <!-- input: 7 -->

   With 7 it prints 70 and 140.

2. **Fold the multiply into the shift.** SFT xy shifts left x places, then right y, zero-filling, in the four-digit
   accumulator, so one shift can pick a digit and place it. From abc: `SFT 31` gives c00, `SFT 13` gives 00a,
   `SFT 23` then `SFT 10` gives 0b0. The manual's Program No. 6 reverses abc in 15 instructions this way, adding
   each piece to the running total as it goes.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-23: reverse abc into cba, one shift for each digit
    11      130    CLA 30
    12      431    SFT 31  c00
    13      631    STO 31
    14      130    CLA 30
    15      423    SFT 23  00b
    16      410    SFT 10  0b0
    17      231    ADD 31
    18      631    STO 31
    19      130    CLA 30
    20      413    SFT 13  00a
    21      231    ADD 31
    22      631    STO 31
    23      531    OUT 31
    24      900    HRS 00
   ```
   <!-- input: 123 -->

   With 123 it prints 321.

3. **Divide by walking, and stop when the answer stops mattering.** If you only need the answer up to some bound,
   walk toward it and stop at the bound, instead of dividing all the way.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-20: how many times d goes into x, but only up to 3
    11      031    INP 31
    12      130    CLA 30
    13      731    SUB 31
    14      321    TAC 21
    15      630    STO 30
    16      132    CLA 32
    17      200    ADD 00
    18      632    STO 32
    19      733    SUB 33
    20      312    TAC 12  under 3: keep walking
    21      532    OUT 32
    22      900    HRS 00
    32      000    the count
    33      003    the bound
   ```
   <!-- input: 100 7 -->

   With x = 100 and d = 7 it stops at 3 instead of walking to 14; with x = 10 it prints 1.

4. **Halve before you square; check the box first.** 60 squared is 3600, past a cell; 30 squared fits. And test
   |dx| against the radius before squaring at all.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-13: dx is kept at half scale, 0-30, so its square fits a cell; check it against r first
    11      130    CLA 30
    12      731    SUB 31
    13      316    TAC 16
    14      534    OUT 34  outside: no square needed
    15      900    HRS 00
    16      134    CLA 34  cells 16-25: inside, so square it: add dx to itself dx times
    17      730    SUB 30
    18      633    STO 33
    19      135    CLA 35
    20      230    ADD 30
    21      635    STO 35
    22      133    CLA 33
    23      200    ADD 00
    24      633    STO 33
    25      319    TAC 19
    26      535    OUT 35
    27      900    HRS 00
    31      020    r
    34      000
    35      000    the square
   ```
   <!-- input: 12 -->

   With dx = 12 it prints 144; with 20 or more it prints 0 without squaring.

5. **Fit the arithmetic to three digits.** Arrange a formula so no intermediate leaves a cell: (21 s + 17) mod 1000
   as 10 (2 s mod 100) + s + 17.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-17: (21s + 17) mod 1000 as 10 (2s mod 100) + s + 17
    11      130    CLA 30
    12      230    ADD 30  2s
    13      422    SFT 22  2s mod 100
    14      410    SFT 10
    15      230    ADD 30
    16      231    ADD 31
    17      632    STO 32  STO keeps three digits: the mod 1000
    18      532    OUT 32
    19      900    HRS 00
    31      017
   ```
   <!-- input: 999 -->

   With s = 999 it prints 996, and no sum along the way passes 1999.

6. **Spend every digit of a random number.** Take a second value from the digits the first doesn't use, instead of
   drawing again.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-16: one random number abc gives a digit c and a number ab
    11      130    CLA 30
    12      433    SFT 33  c
    13      631    STO 31
    14      130    CLA 30
    15      412    SFT 12  ab
    16      632    STO 32
    17      531    OUT 31
    18      532    OUT 32
    19      900    HRS 00
   ```
   <!-- input: 472 -->

   With 472 it prints 2 and 47.

## Instructions are numbers

1. **Lay a table out in decimal: the address is the digits.** Keep the entry for (P, R) in cell 10P + R: CLA P,
   SFT 10, ADD R, then add the CLA instruction and run it. A row stride of 10 is one shift, and the unused cells
   x4…x9 between rows hold your variables. The manual's Nim programs do this.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-17: the entry for row P, column R is in cell 10P + R
    11      031    INP 31
    12      130    CLA 30
    13      410    SFT 10
    14      231    ADD 31
    15      232    ADD 32  add CLA 00 to the address
    16      617    STO 17
    17      000    CLA 10P + R, written by cell 16
    18      633    STO 33
    19      533    OUT 33
    20      900    HRS 00
    32      100    CLA 00
    40      101    cells 40-52: rows 4 and 5
    41      102
    42      103
    50      201
    51      202
    52      203
   ```
   <!-- input: 5 1 -->

   With P = 5 and R = 1 it prints 202, from cell 51.

2. **Add 500 to turn an instruction into its partner.** The ten instructions pair up five apart: INP and OUT (0
   and 5), CLA and STO (1 and 6), ADD and SUB (2 and 7), TAC and JMP (3 and 8), SFT and HRS (4 and 9). A cell keeps
   only three digits, so adding 500 to an instruction and storing it turns it into its partner, and doing it again
   turns it back: 251 (ADD 51) becomes 751 (SUB 51), and 751 + 500 = 1251 is stored as 251. If cell 30 holds the
   instruction and cell 43 holds 500, then CLA 30, ADD 43, STO 30 flips it, with no test: a sum that alternates
   between adding and subtracting, a conditional jump that becomes unconditional, a reader that becomes a punch.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-19: add the cards with alternating signs until a negative one
    11      130    CLA 30
    12      320    TAC 20
    13      133    CLA 33
    14      230    ADD 30  becomes SUB 30, then ADD 30 again
    15      633    STO 33
    16      114    CLA 14
    17      234    ADD 34  add 500 to cell 14
    18      614    STO 14
    19      810    JMP 10
    20      533    OUT 33
    21      900    HRS 00
    33      000    the sum
    34      500
   ```
   <!-- input: 5 3 4 -1 -->

   With the cards 5, 3, 4 and -1 it prints 5 - 3 + 4 = 6.

3. **SFT 22 reads the address out of an instruction.** CARDIAC has no indirect addressing, so a loop that walks a
   table rewrites the address in one of its own instructions, and that instruction is the pointer. CLA it and
   SFT 22 drops the opcode: CLA 45 is 145, the accumulator holds 0145, two places left leaves 4500 and two right
   leaves 0045. Now the pointer is a number: SUB the table's end and TAC to keep walking, OUT it, or ADD 600 to
   make the STO to the same cell, so a loop can read a cell and write back where it read with no counter kept
   beside the instruction.

   ```
   cell  contents  notes
    10      540    OUT 40  cells 10-16: print cells 40-43; cell 10 is the pointer
    11      110    CLA 10
    12      200    ADD 00
    13      610    STO 10
    14      422    SFT 22  drop the opcode: just the address
    15      731    SUB 31
    16      310    TAC 10
    17      900    HRS 00
    31      044    one past the end
    40      007
    41      003
    42      009
    43      001
   ```

   It prints 7, 3, 9 and 1, with no counter beside the pointer.

## Room: 100 cells and a card reader

1. **Cell 00 is the constant 1.** It is wired to 001, so ADD 00 and SUB 00 add or take one without a constant cell
   of your own. Every other constant costs a cell, since an instruction names a cell, never a value.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-16: count cards until a negative one
    11      130    CLA 30
    12      317    TAC 17
    13      131    CLA 31
    14      200    ADD 00  count + 1, with no constant of our own
    15      631    STO 31
    16      810    JMP 10
    17      531    OUT 31
    18      900    HRS 00
    31      000    the count
   ```
   <!-- input: 8 8 8 -1 -->

   With the cards 8, 8, 8 and -1 it prints 3.

2. **Load tables with the program, not with INP.** A table on the program's deck is placed by the loader, with no
   fill loop in the program. A single value is cheaper read with INP.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-14: the days in month m are in cell 39 + m
    11      130    CLA 30
    12      232    ADD 32
    13      614    STO 14
    14      000    CLA 39 + m, written by cell 13
    15      633    STO 33
    16      533    OUT 33
    17      900    HRS 00
    32      139    CLA 39
    40      031    cells 40-51: the table, loaded with the program
    41      028
    42      031
    43      030
    44      031
    45      030
    46      031
    47      031
    48      030
    49      031
    50      030
    51      031
   ```
   <!-- input: 9 -->

   With m = 9 it prints 30. The table costs twelve cells and no instructions.

3. **Stream the table; don't store it.** If you need only a few entries, read the whole table as input cards and
   keep just those: no memory for the table, only time. It can't work for a sort, which needs every element at
   once.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-17: read the table's cards one by one and keep only entry k
    11      031    INP 31
    12      130    CLA 30
    13      700    SUB 00
    14      630    STO 30
    15      700    SUB 00
    16      318    TAC 18
    17      811    JMP 11
    18      531    OUT 31
    19      900    HRS 00
   ```
   <!-- input: 2 31 28 31 30 -->

   With k = 2 followed by the cards 31, 28, 31 and 30, it prints 28, using one cell for the table.

4. **When it doesn't fit, split it.** Two small programs passing cards often fit where one big one doesn't. When
   the code is too big but the data must stay, chain tapes: the first ends with HRS n, the operator loads tape n
   and starts at 00, and the cells the new tape doesn't load keep their values (see sortem).

   ```
   cell  contents  notes
    10      030    INP 30  tape 1, cells 10-11: read x, which stays in cell 30
    11      902    HRS 02  halt on 02: load tape 2
   ```

   ```
   cell  contents  notes
    10      130    CLA 30  tape 2, cells 10-14: its own code over tape 1's, and x still in cell 30
    11      230    ADD 30
    12      631    STO 31
    13      531    OUT 31
    14      900    HRS 00
   ```
   <!-- input: 21 -->

   With 21 it prints 42: tape 2 replaces the code and finds x where tape 1 left it.
