# CARDIAC pearls

These are the tricks that make CARDIAC programs small and fast. Each one starts with an everyday job, shows the way
you'd probably write it, and then shows the way that plays to how CARDIAC works, with what each costs. "Cells" is how
much memory a program takes, and "instructions" is how many it runs, not counting the loader unless the tip is about
loading. Every program here has been run with the input it says, and prints what it says.

## Comparisons: TAC is the only test

CARDIAC can ask exactly one question: is the accumulator negative? Every comparison you write is built out of that,
so it pays to make it the question you need.

1. **Put the threshold at 0 and make the thing you test reach it.** Say you want to do something five times.

   You'd probably count from 0 up to 5 and check at the top of each pass whether you're still under 5. That's how it
   looks in most languages, and it works here, but it costs more than it looks. The check is a SUB and a cell to hold
   the 5, and because TAC only jumps when the answer is negative, you need a JMP to get out of the loop and another
   at the bottom to get back in.

   ```
   cell  contents  notes
    10      130    CLA 30  cells 10-13: still below 5? TAC into the body, else JMP out
    11      731    SUB 31
    12      314    TAC 14
    13      819    JMP 19
    14      532    OUT 32  cells 14-19: the body, then count one more and go back to the test
    15      130    CLA 30
    16      200    ADD 00
    17      630    STO 30
    18      810    JMP 10
    19      900    HRS 00
    30      000    the count
    31      005    the limit
    32      042    what the body prints
   ```

   Here's the trick: count from -5 up to 0 instead, and test at the bottom. TAC only ever asks "is this below zero?",
   and while your count is still negative the answer is yes, so TAC's jump is what takes you round again. There's no
   limit to subtract, and both JMPs disappear.

   ```
   cell  contents  notes
    10      532    OUT 32  cells 10-15: the body, then count up; TAC goes round while the count is negative
    11      130    CLA 30
    12      200    ADD 00
    13      630    STO 30
    14      310    TAC 10
    15      900    HRS 00
    30     -005    the count, from -5
    32      042    what the body prints
   ```

   Both print 42 five times. The first takes 13 cells and runs 45 instructions; the second takes 8 cells and runs 26.
   Same loop, a lot less work, and you'll find this shape all over good CARDIAC code.

2. **Let negative mean "none".** Say you want to add up a stack of cards, and you don't know how many there are.

   The usual answer is to put a count on the first card and count it down as you go. That works, but it costs you a
   cell for the count and four instructions every pass just to take one off it and test it.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-21: the first card says how many follow; count it down
    11      130    CLA 30
    12      700    SUB 00
    13      320    TAC 20
    14      630    STO 30
    15      031    INP 31
    16      132    CLA 32
    17      231    ADD 31
    18      632    STO 32
    19      811    JMP 11
    20      532    OUT 32
    21      900    HRS 00
    30      000    how many cards are left
    31      000
    32      000
   ```
   <!-- input: 3 3 4 5 -->

   Instead, end the stack with a -1. You're already loading each card into the accumulator to add it, so spotting the
   end costs you nothing but the TAC, and -1 can never be mistaken for a real card. Once you start doing this you'll
   see uses everywhere: -1 for "not found", "off the edge", "no more". Whatever you're testing for, make it the
   negative case.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-17: add up cards until a negative one
    11      130    CLA 30
    12      316    TAC 16  -1 means no more cards
    13      231    ADD 31
    14      631    STO 31
    15      810    JMP 10
    16      531    OUT 31
    17      900    HRS 00
    30      000
    31      000
   ```
   <!-- input: 3 4 5 -1 -->

   Both add up 3, 4 and 5 and print 12. The counted version takes 15 cells and runs 33 instructions; the -1 version
   takes 10 cells and runs 23.

3. **Keep a flag as 0 and -1, not 1 and 0.** Say you want a yes-or-no flag that you set in one place and test in
   another.

   Everyone reaches for 1 and 0. The catch is that TAC can't tell them apart, since neither one is negative, so every
   test needs a SUB 00 first to turn them into 0 and -1.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-17: the flag is 1 or 0; testing it needs a SUB first
    11      130    CLA 30
    12      700    SUB 00
    13      316    TAC 16
    14      531    OUT 31  set: print 1
    15      900    HRS 00
    16      532    OUT 32  clear: print 0
    17      900    HRS 00
    30      000    the flag
    31      001
    32      000
   ```
   <!-- input: 1 -->

   So store them that way to begin with: 0 for yes, -1 for no. Now each test is just CLA and TAC. It isn't quite
   free, because you need a cell holding -1 somewhere to set the flag to no, but that pays for itself from the second
   test on.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-16: the flag is 0 or -1; reading it is CLA and TAC
    11      130    CLA 30
    12      315    TAC 15
    13      500    OUT 00  set: print 1
    14      900    HRS 00
    15      531    OUT 31  clear: print 0
    16      900    HRS 00
    30      000    the flag
    31      000
   ```
   <!-- input: 0 -->

   Both print 1 for yes. The 1-and-0 version takes 11 cells and runs 6 instructions; the 0-and-minus-1 version takes
   9 cells and runs 5. That's one of each saved, every single time you test the flag.

4. **Equality is the expensive test.** Say you're counting up and want to stop at 7.

   The obvious loop keeps going while the count isn't 7. But on CARDIAC "isn't 7" is really two questions: is it
   below 7, and is it above? Each one is a subtraction and a TAC.

   ```
   cell  contents  notes
    10      530    OUT 30  cells 10-19: print the count, count one more, go round while it isn't 7
    11      130    CLA 30
    12      200    ADD 00
    13      630    STO 30
    14      731    SUB 31  i - 7: below?
    15      310    TAC 10
    16      131    CLA 31  7 - i: above?
    17      730    SUB 30
    18      310    TAC 10
    19      900    HRS 00
    30      000    the count
    31      007
   ```

   Think about what you actually know. A count that goes up one at a time can't skip past 7, so the moment it stops
   being below 7, it is 7. Ask only "below 7?" and you're done. When you really do need equality, ask the likely half
   first. Here the count is below 7 on every pass but the last, which is why the first version's second question only
   ever runs once.

   ```
   cell  contents  notes
    10      530    OUT 30  cells 10-16: the same loop, asking only whether the count is below 7
    11      130    CLA 30
    12      200    ADD 00
    13      630    STO 30
    14      731    SUB 31
    15      310    TAC 10
    16      900    HRS 00
    30      000    the count
    31      007
   ```

   Both print 0 through 6. The equality version takes 12 cells and runs 46 instructions; the below-7 version takes 9
   cells and runs 43. In a loop where both halves ran every time, you'd be saving three instructions a pass.

5. **Ask the cheap question first.** Say you want to check that a value is a single digit, 0 to 9.

   The careful way is to check both ends: is it at least 0, and is it below 10?

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-18: a digit is at least 0 and below 10: two tests
    11      130    CLA 30
    12      315    TAC 15
    13      731    SUB 31
    14      317    TAC 17
    15      532    OUT 32
    16      900    HRS 00
    17      500    OUT 00  a single digit: print 1
    18      900    HRS 00
    30      000    a count of cards
    31      010
    32      000
   ```
   <!-- input: 4 -->

   But look at where the value came from. If it's counting cards, it can't be negative, so the first question has
   already been answered for you and only "below 10?" is left. It's worth getting into the habit of ordering your
   tests so that what you already know answers the later ones.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-17: x counts cards, so it is never negative; one test is enough
    11      130    CLA 30
    12      731    SUB 31
    13      316    TAC 16
    14      532    OUT 32
    15      900    HRS 00
    16      500    OUT 00  a single digit: print 1
    17      900    HRS 00
    30      000    a count of cards
    31      010
    32      000
   ```
   <!-- input: 4 -->

   Both print 1 for 4. Asking both takes 12 cells and runs 7 instructions; asking one takes 11 cells and runs 6.

6. **Store the sign, not the number.** Say two players take turns, A and B, and you need to track whose turn it is.

   Most people number them 1 and 2. Swapping is 3 minus the turn, which is fine, but finding out whose turn it is
   means subtracting 2 before you can TAC.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-13: whose turn, 1 for A and 2 for B; 3 - turn swaps them
    11      132    CLA 32
    12      730    SUB 30
    13      630    STO 30
    14      731    SUB 31  cells 14-19: which is it? a SUB first, then the TAC
    15      318    TAC 18
    16      531    OUT 31  B's turn: print 2
    17      900    HRS 00
    18      500    OUT 00  A's turn: print 1
    19      900    HRS 00
    30      000
    31      002
    32      003
   ```
   <!-- input: 1 -->

   Number them 0 and -1 instead. Swapping becomes -1 minus the turn, and finding out whose turn it is is the TAC on
   its own. Any time you're choosing between two things, you can store the choice as a sign.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-18: whose turn, 0 for A and -1 for B; -1 - turn swaps them
    11      131    CLA 31
    12      730    SUB 30
    13      630    STO 30
    14      317    TAC 17  one TAC reads it
    15      500    OUT 00  A's turn: print 1
    16      900    HRS 00
    17      532    OUT 32  B's turn: print 2
    18      900    HRS 00
    30      000
    31     -001
    32      002
   ```
   <!-- input: 0 -->

   Both swap A's turn to B's and print 2. Numbering 1 and 2 takes 13 cells and runs 8 instructions; 0 and -1 takes 12
   cells and runs 7.

7. **Don't test what you just set.** Say you're looking for the first card that's 7 or more, and want to print it if
   it's there.

   A common way to write this sets a "found" flag when you find the card, leaves the loop, and then tests the flag
   afterwards to work out how the loop ended.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-14: read cards until one is 7 or more, or a negative one ends them
    11      130    CLA 30
    12      317    TAC 17
    13      731    SUB 31
    14      310    TAC 10
    15      133    CLA 33  cells 15-16: found: set the flag and leave the loop
    16      632    STO 32
    17      132    CLA 32  cells 17-20: after the loop, test the flag
    18      320    TAC 20
    19      530    OUT 30
    20      900    HRS 00
    30      000
    31      007
    32     -001    the flag: -1 not found, 0 found
    33      000
   ```
   <!-- input: 2 5 9 1 -->

   But at the moment you find the card, you already know you found it: the loop's own test just told you. So do the
   work right there and skip the flag entirely. Whenever you're about to set something and then jump to a test of it,
   jump straight to the answer instead.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-16: read cards until one is 7 or more, or a negative one ends them
    11      130    CLA 30
    12      316    TAC 16
    13      731    SUB 31
    14      310    TAC 10
    15      530    OUT 30  found: act on it here, where the loop's own test already said so
    16      900    HRS 00
    30      000
    31      007
   ```
   <!-- input: 2 5 9 1 -->

   Both print 9. The flag version takes 15 cells and runs 21 instructions; acting on the spot takes 9 cells and runs
   17.

8. **Park the number you subtract; keep the other in the accumulator.** Say you've worked out two values, a = x + y
   and b = 10z, and want to know whether a is below b.

   The tidy way is to work out both, store both, then load b back and subtract a.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-15: a = x + y, stored
    11      041    INP 41
    12      042    INP 42
    13      140    CLA 40
    14      241    ADD 41
    15      643    STO 43
    16      142    CLA 42  cells 16-18: b = 10z, stored
    17      410    SFT 10
    18      644    STO 44
    19      144    CLA 44  cells 19-26: load b again and test b - a - 1
    20      743    SUB 43
    21      700    SUB 00
    22      325    TAC 25
    23      500    OUT 00  a < b: print 1
    24      900    HRS 00
    25      545    OUT 45
    26      900    HRS 00
    40      000
    41      000
    42      000
    43      000
    44      000
    45      000
   ```
   <!-- input: 12 7 2 -->

   Here's the thing: CARDIAC can only subtract a cell, so only the number you subtract has to be stored. Store a,
   work out b, and while b is still sitting in the accumulator, subtract a straight away. For "a < b" you test b - a
   - 1 against zero, and the 1 comes free from cell 00.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-15: a = x + y, stored, because it is the one subtracted
    11      041    INP 41
    12      042    INP 42
    13      140    CLA 40
    14      241    ADD 41
    15      643    STO 43
    16      142    CLA 42  cells 16-24: b = 10z stays in the accumulator; test b - a - 1
    17      410    SFT 10
    18      743    SUB 43
    19      700    SUB 00
    20      323    TAC 23
    21      500    OUT 00  a < b: print 1
    22      900    HRS 00
    23      544    OUT 44
    24      900    HRS 00
    40      000
    41      000
    42      000
    43      000
    44      000
   ```
   <!-- input: 12 7 2 -->

   Both compare 19 with 20 and print 1. Storing both takes 23 cells and runs 15 instructions; parking only a takes 20
   cells and runs 13.

9. **Encode so one comparison decides.** Say two cards meet, and the winner is the trump if exactly one of them is a
   trump, and otherwise the higher card.

   You'd probably keep each card as a value plus a trump flag, and then ask three questions: is only b a trump, is
   only a a trump, and which value is higher?

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-13: each card as a value, 0-9, and a trump flag, 1 or 0
    11      041    INP 41
    12      042    INP 42
    13      043    INP 43
    14      141    CLA 41  cells 14-16: b is a trump and a isn't: b wins
    15      743    SUB 43
    16      325    TAC 25
    17      143    CLA 43  cells 17-19: a is a trump and b isn't: a wins
    18      741    SUB 41
    19      323    TAC 23
    20      140    CLA 40  cells 20-26: both or neither: the higher value wins
    21      742    SUB 42
    22      325    TAC 25
    23      540    OUT 40
    24      900    HRS 00
    25      542    OUT 42
    26      900    HRS 00
    40      000
    41      000
    42      000
    43      000
   ```
   <!-- input: 9 0 2 1 -->

   Instead, store a trump with 10 added. Now every trump is higher than every plain card, "higher wins" is the whole
   rule, and one compare settles it. It's a nice example of choosing your numbers so the comparison you'd make anyway
   gives the answer you want.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-18: a plain card is 0-9 and a trump is stored with 10 added; one compare decides
    11      041    INP 41
    12      140    CLA 40
    13      741    SUB 41
    14      317    TAC 17
    15      540    OUT 40
    16      900    HRS 00
    17      541    OUT 41
    18      900    HRS 00
    40      000
    41      000
   ```
   <!-- input: 9 12 -->

   A plain 9 meets the trump 2, and the trump wins: the first version prints 2, and the second prints the trump the
   way it stores it, 12. The flags take 21 cells and run 9 instructions; the encoding takes 11 cells and runs 7.

10. **Classify with comparisons, not division.** Say you want to sort a number from 0 to 999 into one of four bands
    of 250.

    The obvious move is to divide by 250. CARDIAC has no divide, though, so that turns into a loop of subtractions
    with a counter, and the bigger the number, the longer it runs.

    ```
    cell  contents  notes
     10      040    INP 40  cells 10-20: the band is x / 250, by subtracting 250 until x goes negative
     11      140    CLA 40
     12      741    SUB 41
     13      319    TAC 19
     14      640    STO 40
     15      142    CLA 42
     16      200    ADD 00
     17      642    STO 42
     18      811    JMP 11
     19      542    OUT 42
     20      900    HRS 00
     40      000
     41      250
     42      000
    ```
    <!-- input: 600 -->

    Just ask three questions in a row instead: below 250? below 500? below 750? Each is a SUB and a TAC on whatever
    the last one left in the accumulator.

    ```
    cell  contents  notes
     10      040    INP 40  cells 10-25: three compares sort x into four bands
     11      140    CLA 40
     12      741    SUB 41  x - 250
     13      320    TAC 20
     14      741    SUB 41  x - 500
     15      322    TAC 22
     16      741    SUB 41  x - 750
     17      324    TAC 24
     18      544    OUT 44
     19      900    HRS 00
     20      542    OUT 42
     21      900    HRS 00
     22      500    OUT 00
     23      900    HRS 00
     24      543    OUT 43
     25      900    HRS 00
     40      000
     41      250
     42      000
     43      002
     44      003
    ```
    <!-- input: 600 -->

    Both put 600 in band 2. This one's a trade: the comparisons take more cells, 21 against 14, because each band
    needs its own way out. But they run 10 instructions where the division ran 22, and they never get slower.

## Digits: arithmetic in decimal

CARDIAC thinks in decimal: three digits in a cell, four in the accumulator, and SFT moves whole digits around. Lean
on that and a lot of arithmetic gets cheap.

1. **Scale by ten.** Say you need to scale a value up, and you get to pick the scale.

   If you grew up on binary, you'd pick 8. On CARDIAC, times 8 means doubling three times through a spare cell.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-19: x times 8, doubled three times through a spare cell
    11      130    CLA 30
    12      230    ADD 30
    13      631    STO 31
    14      231    ADD 31
    15      631    STO 31
    16      231    ADD 31
    17      631    STO 31
    18      531    OUT 31
    19      900    HRS 00
    30      000
    31      000
   ```
   <!-- input: 7 -->

   Pick 10 instead. SFT moves whole decimal digits, so times 10 is a single shift. Ten's friends are cheap too: times
   20 is one doubling and a shift, and times 100 is just a bigger shift.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-15: x times 10 is one shift
    11      130    CLA 30
    12      410    SFT 10
    13      631    STO 31
    14      531    OUT 31
    15      900    HRS 00
    30      000
    31      000
   ```
   <!-- input: 7 -->

   Times 8 prints 56 and times 10 prints 70. Times 8 takes 12 cells and runs 10 instructions; times 10 takes 8 cells
   and runs 6.

2. **Fold the multiply into the shift.** Say you want to reverse a three-digit number, so 123 becomes 321.

   You'd probably cut out the three digits one at a time, then use another shift on each to put it in its new place,
   and add them up.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-19: cut out each digit: c, then b, then a
    11      140    CLA 40
    12      433    SFT 33
    13      643    STO 43
    14      140    CLA 40
    15      423    SFT 23
    16      642    STO 42
    17      140    CLA 40
    18      413    SFT 13
    19      641    STO 41
    20      143    CLA 43  cells 20-29: then put each in its place and add them up
    21      420    SFT 20
    22      644    STO 44
    23      142    CLA 42
    24      410    SFT 10
    25      244    ADD 44
    26      241    ADD 41
    27      644    STO 44
    28      544    OUT 44
    29      900    HRS 00
    40      000
    41      000
    42      000
    43      000
    44      000
   ```
   <!-- input: 123 -->

   Here's what makes SFT so handy: SFT xy shifts left x places and then right y, and whatever falls off either end is
   gone. That means one shift can cut a digit out and drop it where it belongs, all at once. From abc, SFT 31 gives
   you c00, and SFT 13 gives you 00a. Add each piece to a running total as you go. This is how the manual's own
   Program No. 6 does it.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-24: each shift cuts a digit out and puts it in its new place at once
    11      140    CLA 40
    12      431    SFT 31  c00
    13      641    STO 41
    14      140    CLA 40
    15      423    SFT 23  00b
    16      410    SFT 10  0b0
    17      241    ADD 41
    18      641    STO 41
    19      140    CLA 40
    20      413    SFT 13  00a
    21      241    ADD 41
    22      641    STO 41
    23      541    OUT 41
    24      900    HRS 00
    40      000
    41      000
   ```
   <!-- input: 123 -->

   Both turn 123 into 321. Cutting and placing separately takes 25 cells and runs 20 instructions; folding them
   together takes 17 cells and runs 15.

3. **Divide by walking, and stop when the answer stops mattering.** Say you want to know how many times 7 goes into
   100, but anything over 3 just counts as 3, like a meter with three bars.

   The straightforward way divides all the way, 14 rounds of subtracting, and then cuts the answer down to 3.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-19: divide all the way: how many times d goes into x
    11      041    INP 41
    12      140    CLA 40
    13      741    SUB 41
    14      320    TAC 20
    15      640    STO 40
    16      142    CLA 42
    17      200    ADD 00
    18      642    STO 42
    19      812    JMP 12
    20      142    CLA 42  cells 20-26: then cut the answer down to 3
    21      743    SUB 43
    22      325    TAC 25
    23      143    CLA 43
    24      642    STO 42
    25      542    OUT 42
    26      900    HRS 00
    40      000
    41      000
    42      000    the count
    43      003
   ```
   <!-- input: 100 7 -->

   Since CARDIAC divides by walking, one subtraction at a time anyway, you can simply stop walking the moment the
   answer reaches 3. Everything after that would be work you throw away.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-22: walk, and stop as soon as the count reaches 3
    11      041    INP 41
    12      140    CLA 40
    13      741    SUB 41
    14      321    TAC 21
    15      640    STO 40
    16      142    CLA 42
    17      200    ADD 00
    18      642    STO 42
    19      743    SUB 43
    20      312    TAC 12  under 3: keep walking
    21      542    OUT 42
    22      900    HRS 00
    40      000
    41      000
    42      000    the count
    43      003
   ```
   <!-- input: 100 7 -->

   Both print 3. Dividing all the way takes 21 cells and runs 124 instructions; stopping at 3 takes 17 cells and runs
   31.

4. **Halve before you square; check the box first.** Say you're drawing a picture 120 wide and want to know whether a
   point is within 20 of the middle. Its distance dx can be anything up to 60.

   The textbook way squares dx and compares it with 20 squared. But here's the problem: a cell only keeps three
   digits, and 60 squared is 3600. Try dx = 33. Its square is 1089, the cell keeps 089, and the program cheerfully
   tells you the point is inside.

   ```
   cell  contents  notes
    10      040    INP 40  cell 10: dx, up to 60 from the middle
    11      144    CLA 44  cells 11-27: dx squared: add dx to itself dx times, counting up from -dx
    12      740    SUB 40
    13      641    STO 41
    14      142    CLA 42
    15      240    ADD 40
    16      642    STO 42
    17      141    CLA 41
    18      200    ADD 00
    19      641    STO 41
    20      314    TAC 14
    21      142    CLA 42  inside when dx squared is below r squared, 400
    22      743    SUB 43
    23      326    TAC 26
    24      544    OUT 44
    25      900    HRS 00
    26      500    OUT 00  inside: print 1
    27      900    HRS 00
    40      000
    41      000
    42      000    dx squared, kept in a cell: only its last three digits
    43      400
    44      000
   ```
   <!-- input: 33 -->

   So check the box first. If dx isn't below 20, the point is outside and there's nothing to square at all. Inside
   the box, dx is under 20, and its square fits in a cell just fine. If you really do need squares across the whole
   range, halve first: 30 squared is 900, which fits.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-15: first the box: dx not below r means outside, with no square at all
    11      140    CLA 40
    12      743    SUB 43
    13      316    TAC 16
    14      545    OUT 45
    15      900    HRS 00
    16      145    CLA 45  cells 16-32: dx squared: add dx to itself dx times, counting up from -dx
    17      740    SUB 40
    18      641    STO 41
    19      142    CLA 42
    20      240    ADD 40
    21      642    STO 42
    22      141    CLA 41
    23      200    ADD 00
    24      641    STO 41
    25      319    TAC 19
    26      142    CLA 42  inside the box, dx is below 20, and its square fits
    27      744    SUB 44
    28      331    TAC 31
    29      545    OUT 45
    30      900    HRS 00
    31      500    OUT 00  inside: print 1
    32      900    HRS 00
    40      000
    41      000
    42      000
    43      020
    44      400
    45      000
   ```
   <!-- input: 33 -->

   The first version prints 1, which is wrong, after 240 instructions. The second prints 0, which is right, after 6.
   It does take more cells, 29 against 23, because it has the box check as well as the square.

5. **Fit the arithmetic to three digits.** Say you want the next number in a random sequence: (21s + 17) mod 1000.

   The direct way works out 21s by adding s to itself 21 times. Every STO keeps only three digits, so the mod 1000
   takes care of itself, but you're looping 21 times for one number.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-19: 21s by adding s 21 times; STO keeps three digits each time
    11      141    CLA 41
    12      642    STO 42
    13      143    CLA 43
    14      240    ADD 40
    15      643    STO 43
    16      142    CLA 42
    17      200    ADD 00
    18      642    STO 42
    19      313    TAC 13
    20      143    CLA 43  cells 20-24: then add 17
    21      244    ADD 44
    22      643    STO 43
    23      543    OUT 43
    24      900    HRS 00
    40      000
    41     -021
    42      000
    43      000
    44      017
   ```
   <!-- input: 999 -->

   With a little rearranging, nothing in the formula needs more than four digits. 21s is 20s + s, and 20s mod 1000 is
   10 times (2s mod 100). SFT 22 keeps the last two digits, which is your mod 100. SFT 10 multiplies by ten. And the
   final STO does the mod 1000 for you.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-19: 21s + 17 as 10 (2s mod 100) + s + 17
    11      140    CLA 40
    12      240    ADD 40  2s
    13      422    SFT 22  2s mod 100
    14      410    SFT 10  10 (2s mod 100), never past 990
    15      240    ADD 40
    16      241    ADD 41
    17      642    STO 42  STO keeps three digits: the mod 1000
    18      542    OUT 42
    19      900    HRS 00
    40      000
    41      017
    42      000
   ```
   <!-- input: 999 -->

   Both turn 999 into 996. The loop takes 20 cells and runs 155 instructions; the rearranged version takes 13 cells
   and runs 10.

6. **Spend every digit of a random number.** Say you need two random choices: a digit from 0 to 9, and a number from
   0 to 99.

   The natural thing is to draw twice from your generator and take what you need from each draw.

   ```
   cell  contents  notes
    10      050    INP 50  cells 10-31: the seed
    11      150    CLA 50  cells 11-17: the next random number, s = (21s + 17) mod 1000
    12      250    ADD 50
    13      422    SFT 22
    14      410    SFT 10
    15      250    ADD 50
    16      251    ADD 51
    17      650    STO 50
    18      433    SFT 33  a digit, 0-9, from the first draw
    19      652    STO 52
    20      150    CLA 50  cells 20-26: the next random number, s = (21s + 17) mod 1000
    21      250    ADD 50
    22      422    SFT 22
    23      410    SFT 10
    24      250    ADD 50
    25      251    ADD 51
    26      650    STO 50
    27      422    SFT 22  a number, 0-99, from a second draw
    28      653    STO 53
    29      552    OUT 52
    30      553    OUT 53
    31      900    HRS 00
    50      000
    51      017
    52      000
    53      000
   ```
   <!-- input: 472 -->

   But a three-digit random number has three digits in it, and you only need three. Draw once, take the digit from
   the end and the 0 to 99 from the front.

   ```
   cell  contents  notes
    10      050    INP 50  cells 10-25: the seed
    11      150    CLA 50  cells 11-17: the next random number, s = (21s + 17) mod 1000
    12      250    ADD 50
    13      422    SFT 22
    14      410    SFT 10
    15      250    ADD 50
    16      251    ADD 51
    17      650    STO 50
    18      433    SFT 33  a digit, 0-9: the last digit
    19      652    STO 52
    20      150    CLA 50
    21      412    SFT 12  a number, 0-99: the first two digits, from the same draw
    22      653    STO 53
    23      552    OUT 52
    24      553    OUT 53
    25      900    HRS 00
    50      000
    51      017
    52      000
    53      000
   ```
   <!-- input: 472 -->

   From the seed 472, drawing twice prints 9 and 26, and drawing once prints 9 and 92. Two draws take 26 cells and
   run 22 instructions; one draw takes 20 cells and runs 16.

## Instructions are numbers

An instruction is just a three-digit number, so your program can do arithmetic on its own code. On CARDIAC that isn't
a hack, it's how you get things done.

1. **Lay a table out in decimal: the address is the digits.** Say you've got a table with three columns, and you want
   the entry at row P, column R.

   You'd probably pack the rows tight, so the entry is at 3P + R. Times 3 is two additions, and a wider table needs
   more.

   ```
   cell  contents  notes
    10      046    INP 46  cells 10-21: the entry for row P, column R is in cell 40 + 3P + R
    11      047    INP 47
    12      146    CLA 46
    13      246    ADD 46  3P: two adds, and one more for every column a row has
    14      246    ADD 46
    15      247    ADD 47
    16      249    ADD 49  add CLA 40
    17      618    STO 18
    18      100    CLA 00  CLA 40 + 3P + R, written by the cell before
    19      648    STO 48
    20      548    OUT 48
    21      900    HRS 00
    40      101    cells 40-45: rows 0 and 1, packed tight
    41      102
    42      103
    43      201
    44      202
    45      203
    46      000
    47      000
    48      000
    49      140    CLA 40
   ```
   <!-- input: 1 1 -->

   Instead, start every row ten cells apart, so the entry is at 10P + R. Times 10 is one shift, however wide your
   rows are. And the cells left over between rows aren't wasted: that's where your variables go. Add the CLA
   instruction to the address, run it, and you've done the lookup. The manual's Nim programs keep their tables
   exactly this way.

   ```
   cell  contents  notes
    10      043    INP 43  cells 10-20: the entry for row P, column R is in cell 40 + 10P + R
    11      044    INP 44
    12      143    CLA 43
    13      410    SFT 10  10P: one shift, however wide the rows
    14      244    ADD 44
    15      246    ADD 46  add CLA 40
    16      617    STO 17
    17      100    CLA 00  CLA 40 + 10P + R, written by the cell before
    18      645    STO 45
    19      545    OUT 45
    20      900    HRS 00
    40      101    cells 40-52: rows 0 and 1, ten cells apart
    41      102
    42      103
    43      000    cells 43-49 between the rows hold the variables: P
    44      000    R
    45      000    the entry
    46      140    CLA 40
    50      201
    51      202
    52      203
   ```
   <!-- input: 1 1 -->

   Both look up row 1, column 1 and print 202. The packed table takes 22 cells and runs 12 instructions; the decimal
   one takes 21 cells and runs 11, and the gap grows with every column you add.

2. **Add 500 to turn an instruction into its partner.** Say you want to add up cards with alternating signs: plus,
   minus, plus, and so on.

   You'd probably keep a flag for which way to go next, test it for every card, and flip it each time.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-12: add the cards with alternating signs until a negative one
    11      140    CLA 40
    12      326    TAC 26
    13      142    CLA 42  cells 13-21: which way this time? test a flag
    14      319    TAC 19
    15      141    CLA 41
    16      240    ADD 40
    17      641    STO 41
    18      822    JMP 22
    19      141    CLA 41
    20      740    SUB 40
    21      641    STO 41
    22      143    CLA 43  cells 22-27: swap the flag, -1 - sign
    23      742    SUB 42
    24      642    STO 42
    25      810    JMP 10
    26      541    OUT 41
    27      900    HRS 00
    40      000
    41      000
    42      000    0: add, -1: subtract
    43     -001
   ```
   <!-- input: 5 3 4 -1 -->

   This one is my favorite. CARDIAC's instructions pair up five apart: INP and OUT, CLA and STO, ADD and SUB, TAC and
   JMP, SFT and HRS. And a cell only keeps three digits, so adding 500 to an instruction turns it into its partner,
   and adding 500 again turns it back. ADD 51 is 251; add 500 and you get 751, which is SUB 51; add 500 again and you
   get 1251, which the cell keeps as 251. So the program just adds 500 to its own ADD after every card, and there's
   nothing to test. The same move turns a conditional jump into an unconditional one, or an INP that reads a card
   into an OUT that outputs one.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-21: add the cards with alternating signs until a negative one
    11      140    CLA 40
    12      320    TAC 20
    13      141    CLA 41
    14      240    ADD 40  becomes SUB, then ADD again
    15      641    STO 41
    16      114    CLA 14
    17      242    ADD 42  add 500 to cell 14
    18      614    STO 14
    19      810    JMP 10
    20      541    OUT 41
    21      900    HRS 00
    40      000
    41      000
    42      500
   ```
   <!-- input: 5 3 4 -1 -->

   Both work out 5 - 3 + 4 and print 6. The flag takes 22 cells and runs 43 instructions; adding 500 takes 15 cells
   and runs 35.

3. **SFT 22 reads the address out of an instruction.** Say you want to walk through a table in cells 40 to 43 and
   print each entry.

   CARDIAC has no indirect addressing, so walking a table means rewriting the address in one of your own
   instructions. The usual way also keeps a counter, builds the instruction from it each time round, and checks the
   counter against the end.

   ```
   cell  contents  notes
    10      130    CLA 30  cells 10-13: build OUT 40 + i from the counter
    11      232    ADD 32
    12      613    STO 13
    13      500    OUT 00  OUT 40 + i, written by the cell before
    14      130    CLA 30  cells 14-19: count, and stop at 4
    15      200    ADD 00
    16      630    STO 30
    17      731    SUB 31
    18      310    TAC 10
    19      900    HRS 00
    30      000    the counter, kept in step with the instruction
    31      004
    32      540    OUT 40
    40      007
    41      003
    42      009
    43      001
   ```

   But the instruction already knows where it's pointing, so let it be the pointer. Add 1 to the instruction itself,
   and when you want to know where it's got to, load it and do SFT 22, which drops the opcode and leaves the address.
   OUT 41 is 541; shift 0541 two places left and two right and you've got 0041. There's no counter to keep in step.

   ```
   cell  contents  notes
    10      540    OUT 40  cells 10-17: print cells 40-43; cell 10 is the pointer
    11      110    CLA 10
    12      200    ADD 00
    13      610    STO 10
    14      422    SFT 22  drop the opcode: just the address
    15      730    SUB 30
    16      310    TAC 10
    17      900    HRS 00
    30      044    one past the end
    40      007
    41      003
    42      009
    43      001
   ```

   Both print 7, 3, 9 and 1. Keeping a counter takes 17 cells and runs 37 instructions; using the instruction as the
   pointer takes 13 cells and runs 29.

## Room: 100 cells and a card reader

Your program and its data share a hundred cells, and everything else arrives on cards. A lot of good CARDIAC code is
about where things live.

1. **Cell 00 is the constant 1.** Say you're counting cards until you hit a negative one.

   You'd keep a cell holding 1 and add it to the count each time. An instruction names a cell, never a value, so on
   CARDIAC every constant costs you a cell.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-18: count cards until a negative one
    11      130    CLA 30
    12      317    TAC 17
    13      131    CLA 31
    14      232    ADD 32  count + 1, from a cell holding 1
    15      631    STO 31
    16      810    JMP 10
    17      531    OUT 31
    18      900    HRS 00
    30      000
    31      000    the count
    32      001
   ```
   <!-- input: 8 8 8 -1 -->

   Except one. Cell 00 is wired to hold 001, so there's a 1 sitting there that you never have to supply. ADD 00 and
   SUB 00 add and take away one for free.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-18: count cards until a negative one
    11      130    CLA 30
    12      317    TAC 17
    13      131    CLA 31
    14      200    ADD 00  count + 1, from cell 00
    15      631    STO 31
    16      810    JMP 10
    17      531    OUT 31
    18      900    HRS 00
    30      000
    31      000    the count
   ```
   <!-- input: 8 8 8 -1 -->

   Both count three cards. Bringing your own 1 takes 12 cells, and using cell 00 takes 11. They both run 26
   instructions, so the saving here is the cell, which on a hundred-cell machine is worth having.

2. **Load tables with the program, not with INP.** Say you want to look up the number of days in a month from a table
   of twelve.

   You'd probably read the table in with INP when the program starts, using a little loop that rewrites its own INP
   to fill cells 40 to 51.

   ```
   cell  contents  notes
    10      030    INP 30  cell 10: the month
    11      040    INP 40  cells 11-16: then read the table's 12 cards into cells 40-51
    12      111    CLA 11
    13      200    ADD 00
    14      611    STO 11
    15      731    SUB 31
    16      311    TAC 11
    17      130    CLA 30  cells 17-23: the days in month m are in cell 39 + m
    18      232    ADD 32
    19      620    STO 20
    20      100    CLA 00  CLA 39 + m, written by the cell before
    21      633    STO 33
    22      533    OUT 33
    23      900    HRS 00
    30      000
    31      052    INP 52
    32      139    CLA 39
    33      000
   ```
   <!-- input: 9 31 28 31 30 31 30 31 31 30 31 30 31 -->

   Instead, put the table on the program's own deck. The loader drops each entry into its cell on the way in, so your
   program doesn't need a fill loop at all. Loading isn't free, it costs three instructions a cell, but a fill loop
   pays that and more. One caveat: for a single value, a plain INP is still cheaper.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-17: the days in month m are in cell 39 + m
    11      130    CLA 30
    12      231    ADD 31
    13      614    STO 14
    14      100    CLA 00  CLA 39 + m, written by the cell before
    15      632    STO 32
    16      532    OUT 32
    17      900    HRS 00
    30      000
    31      139    CLA 39
    32      000
    40      031    cells 40-51: the table, on the program's own deck
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

   Both print 30 for September. Counting the loading, reading the table in takes 18 cells and runs 140 instructions,
   and loading it with the program takes 23 cells and runs 83.

3. **Stream the table; don't store it.** Say you need just one entry from a table of twelve.

   The obvious way keeps the whole table in memory, twelve cells of it, and looks the entry up.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-17: entry k of the table is in cell 39 + k
    11      130    CLA 30
    12      231    ADD 31
    13      614    STO 14
    14      100    CLA 00  CLA 39 + k, written by the cell before
    15      632    STO 32
    16      532    OUT 32
    17      900    HRS 00
    30      000
    31      139    CLA 39
    32      000
    40      031    cells 40-51: the whole table, in memory
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
   <!-- input: 2 -->

   But if you only need one entry, why keep all twelve? Read the table as input cards, one at a time, and hold on to
   just the entry you want. The table takes no memory at all, only the time to read it. It works whenever you need a
   handful of entries. It won't work for a sort, which needs every entry at once.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-19: read the table's cards one by one and keep only entry k
    11      031    INP 31
    12      130    CLA 30
    13      700    SUB 00
    14      630    STO 30
    15      700    SUB 00
    16      318    TAC 18
    17      811    JMP 11
    18      531    OUT 31
    19      900    HRS 00
    30      000
    31      000    the one card kept
   ```
   <!-- input: 2 31 28 31 30 31 30 31 31 30 31 30 31 -->

   Both print 28 for entry 2. Keeping the table takes 23 cells and runs 8 instructions; streaming it takes 12 cells
   and runs 16, plus the time to read the cards.

4. **When it doesn't fit, split it.** Say your program has two parts, and the second part needs what the first one
   worked out.

   Normally you'd write one deck with both parts in memory at once.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-18: both parts in one deck: all of it in memory at once
    11      130    CLA 30
    12      230    ADD 30
    13      631    STO 31
    14      131    CLA 31
    15      231    ADD 31
    16      632    STO 32
    17      532    OUT 32
    18      900    HRS 00
    30      000
    31      000
    32      000
   ```
   <!-- input: 21 -->

   When that doesn't fit, split it into two tapes. The first ends with HRS 02, the operator loads tape 2 and starts
   at 00, and the loader lays tape 2's code over tape 1's. Here's the nice part: every cell tape 2 doesn't load keeps
   its value, so tape 1's answer is still sitting there waiting. Only the bigger tape has to fit, and the room the
   code no longer needs goes to your data.

   ```
   cell  contents  notes
    10      030    INP 30  tape 1, cells 10-14: the first part: y = 2x, left in cell 31
    11      130    CLA 30
    12      230    ADD 30
    13      631    STO 31
    14      902    HRS 02  halt on 02: load tape 2
    30      000
    31      000
   ```
   ```
   cell  contents  notes
    10      131    CLA 31  tape 2, cells 10-14: its own code over tape 1's; y is still in cell 31, on no card of this tape
    11      231    ADD 31
    12      632    STO 32
    13      532    OUT 32
    14      900    HRS 00
    32      000
   ```
   <!-- input: 21 -->

   Both print 84 for 21. In one deck the program needs 12 cells at once; split, the bigger tape needs 7.
