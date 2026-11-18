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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=put-the-threshold-at-0-and-make-the-thing-you-test-reach-it-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20130%20%20%20%20CLA%2030%20%20cells%2010-13%3A%20still%20below%205%3F%20TAC%20into%20the%20body%2C%20else%20JMP%20out%0A%2011%20%20%20%20%20%20731%20%20%20%20SUB%2031%0A%2012%20%20%20%20%20%20314%20%20%20%20TAC%2014%0A%2013%20%20%20%20%20%20819%20%20%20%20JMP%2019%0A%2014%20%20%20%20%20%20532%20%20%20%20OUT%2032%20%20cells%2014-19%3A%20the%20body%2C%20then%20count%20one%20more%20and%20go%20back%20to%20the%20test%0A%2015%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2016%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2017%20%20%20%20%20%20630%20%20%20%20STO%2030%0A%2018%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2019%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20the%20count%0A%2031%20%20%20%20%20%20005%20%20%20%20the%20limit%0A%2032%20%20%20%20%20%20042%20%20%20%20what%20the%20body%20prints%0A)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=put-the-threshold-at-0-and-make-the-thing-you-test-reach-it-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20532%20%20%20%20OUT%2032%20%20cells%2010-15%3A%20the%20body%2C%20then%20count%20up%3B%20TAC%20goes%20round%20while%20the%20count%20is%20negative%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2013%20%20%20%20%20%20630%20%20%20%20STO%2030%0A%2014%20%20%20%20%20%20310%20%20%20%20TAC%2010%0A%2015%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20-005%20%20%20%20the%20count%2C%20from%20-5%0A%2032%20%20%20%20%20%20042%20%20%20%20what%20the%20body%20prints%0A)

   Both print 42 five times. The first takes 13 cells and runs 45 instructions; the second takes 8 cells and runs 26.
   Same loop, a lot less work, and you'll find this shape all over good CARDIAC code.

   Real machines settled on the same shape. The PDP-8, a few years older than CARDIAC, closed its loops with ISZ,
   which adds one to a cell and skips the next instruction when the result is zero, so a loop that ran five times
   started its counter at -5. Compilers do the other half for you. LLVM's loop-rotate pass turns a loop that tests at
   the top into one that tests at the bottom, with one check in front for the case where it shouldn't run at all.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=let-negative-mean-none-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-21%3A%20the%20first%20card%20says%20how%20many%20follow%3B%20count%20it%20down%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2013%20%20%20%20%20%20320%20%20%20%20TAC%2020%0A%2014%20%20%20%20%20%20630%20%20%20%20STO%2030%0A%2015%20%20%20%20%20%20031%20%20%20%20INP%2031%0A%2016%20%20%20%20%20%20132%20%20%20%20CLA%2032%0A%2017%20%20%20%20%20%20231%20%20%20%20ADD%2031%0A%2018%20%20%20%20%20%20632%20%20%20%20STO%2032%0A%2019%20%20%20%20%20%20811%20%20%20%20JMP%2011%0A%2020%20%20%20%20%20%20532%20%20%20%20OUT%2032%0A%2021%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20how%20many%20cards%20are%20left%0A%2031%20%20%20%20%20%20000%0A%2032%20%20%20%20%20%20000%0A&in=3%203%204%205)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=let-negative-mean-none-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-17%3A%20add%20up%20cards%20until%20a%20negative%20one%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20316%20%20%20%20TAC%2016%20%20-1%20means%20no%20more%20cards%0A%2013%20%20%20%20%20%20231%20%20%20%20ADD%2031%0A%2014%20%20%20%20%20%20631%20%20%20%20STO%2031%0A%2015%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2016%20%20%20%20%20%20531%20%20%20%20OUT%2031%0A%2017%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20000%0A&in=3%204%205%20-1)

   Both add up 3, 4 and 5 and print 12. The counted version takes 15 cells and runs 33 instructions; the -1 version
   takes 10 cells and runs 23.

   C uses the same convention. getchar returns an int rather than a char so that EOF, which the C standard only
   promises is negative, can never be mistaken for a real character. Unix system calls return -1 when they fail, and
   Java's indexOf returns -1 for "not found".

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=keep-a-flag-as-0-and-1-not-1-and-0-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-17%3A%20the%20flag%20is%201%20or%200%3B%20testing%20it%20needs%20a%20SUB%20first%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2013%20%20%20%20%20%20316%20%20%20%20TAC%2016%0A%2014%20%20%20%20%20%20531%20%20%20%20OUT%2031%20%20set%3A%20print%201%0A%2015%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2016%20%20%20%20%20%20532%20%20%20%20OUT%2032%20%20clear%3A%20print%200%0A%2017%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20the%20flag%0A%2031%20%20%20%20%20%20001%0A%2032%20%20%20%20%20%20000%0A&in=1)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=keep-a-flag-as-0-and-1-not-1-and-0-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-16%3A%20the%20flag%20is%200%20or%20-1%3B%20reading%20it%20is%20CLA%20and%20TAC%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20315%20%20%20%20TAC%2015%0A%2013%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20set%3A%20print%201%0A%2014%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2015%20%20%20%20%20%20531%20%20%20%20OUT%2031%20%20clear%3A%20print%200%0A%2016%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20the%20flag%0A%2031%20%20%20%20%20%20000%0A&in=0)

   Both print 1 for yes. The 1-and-0 version takes 11 cells and runs 6 instructions; the 0-and-minus-1 version takes
   9 cells and runs 5. That's one of each saved, every single time you test the flag.

   Some processors make the sign the cheapest thing to test, just as CARDIAC does. On the 6502, loading a value sets
   the negative flag from its top bit, so a flag kept in that bit is read with LDA and BMI, branch if minus, which is
   CLA and TAC under other names. Its BIT instruction goes one better and copies the top bit of a memory cell into
   the negative flag without touching the accumulator at all.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=equality-is-the-expensive-test-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20530%20%20%20%20OUT%2030%20%20cells%2010-19%3A%20print%20the%20count%2C%20count%20one%20more%2C%20go%20round%20while%20it%20isn%27t%207%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2013%20%20%20%20%20%20630%20%20%20%20STO%2030%0A%2014%20%20%20%20%20%20731%20%20%20%20SUB%2031%20%20i%20-%207%3A%20below%3F%0A%2015%20%20%20%20%20%20310%20%20%20%20TAC%2010%0A%2016%20%20%20%20%20%20131%20%20%20%20CLA%2031%20%207%20-%20i%3A%20above%3F%0A%2017%20%20%20%20%20%20730%20%20%20%20SUB%2030%0A%2018%20%20%20%20%20%20310%20%20%20%20TAC%2010%0A%2019%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20the%20count%0A%2031%20%20%20%20%20%20007%0A)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=equality-is-the-expensive-test-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20530%20%20%20%20OUT%2030%20%20cells%2010-16%3A%20the%20same%20loop%2C%20asking%20only%20whether%20the%20count%20is%20below%207%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2013%20%20%20%20%20%20630%20%20%20%20STO%2030%0A%2014%20%20%20%20%20%20731%20%20%20%20SUB%2031%0A%2015%20%20%20%20%20%20310%20%20%20%20TAC%2010%0A%2016%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20the%20count%0A%2031%20%20%20%20%20%20007%0A)

   Both print 0 through 6. The equality version takes 12 cells and runs 46 instructions; the below-7 version takes 9
   cells and runs 43. In a loop where both halves ran every time, you'd be saving three instructions a pass.

   Every comparison on CARDIAC is a subtraction and a look at the sign, and that's still how processors compare. On
   x86 and ARM, CMP is a subtraction that throws the difference away and keeps only the flags. What those machines
   add is a zero flag, set when the difference is 0, so equality is one branch, JE on x86 or BEQ on ARM. CARDIAC has
   only the sign, which is why equality costs two questions here.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=ask-the-cheap-question-first-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-18%3A%20a%20digit%20is%20at%20least%200%20and%20below%2010%3A%20two%20tests%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20315%20%20%20%20TAC%2015%0A%2013%20%20%20%20%20%20731%20%20%20%20SUB%2031%0A%2014%20%20%20%20%20%20317%20%20%20%20TAC%2017%0A%2015%20%20%20%20%20%20532%20%20%20%20OUT%2032%0A%2016%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2017%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20a%20single%20digit%3A%20print%201%0A%2018%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20a%20count%20of%20cards%0A%2031%20%20%20%20%20%20010%0A%2032%20%20%20%20%20%20000%0A&in=4)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=ask-the-cheap-question-first-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-17%3A%20x%20counts%20cards%2C%20so%20it%20is%20never%20negative%3B%20one%20test%20is%20enough%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20731%20%20%20%20SUB%2031%0A%2013%20%20%20%20%20%20316%20%20%20%20TAC%2016%0A%2014%20%20%20%20%20%20532%20%20%20%20OUT%2032%0A%2015%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2016%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20a%20single%20digit%3A%20print%201%0A%2017%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20a%20count%20of%20cards%0A%2031%20%20%20%20%20%20010%0A%2032%20%20%20%20%20%20000%0A&in=4)

   Both print 1 for 4. Asking both takes 12 cells and runs 7 instructions; asking one takes 11 cells and runs 6.

   Compilers drop a test in the same way when they can prove its answer, and they have one more trick that CARDIAC
   can't use, because it has no unsigned numbers. Read as unsigned, a negative x becomes a huge number, so 0 <= x and
   x < 10 together are the single unsigned comparison x < 10. Hacker's Delight covers it in its chapter on bounds,
   and optimizing compilers rewrite range checks with constant ends this way.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=store-the-sign-not-the-number-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-13%3A%20whose%20turn%2C%201%20for%20A%20and%202%20for%20B%3B%203%20-%20turn%20swaps%20them%0A%2011%20%20%20%20%20%20132%20%20%20%20CLA%2032%0A%2012%20%20%20%20%20%20730%20%20%20%20SUB%2030%0A%2013%20%20%20%20%20%20630%20%20%20%20STO%2030%0A%2014%20%20%20%20%20%20731%20%20%20%20SUB%2031%20%20cells%2014-19%3A%20which%20is%20it%3F%20a%20SUB%20first%2C%20then%20the%20TAC%0A%2015%20%20%20%20%20%20318%20%20%20%20TAC%2018%0A%2016%20%20%20%20%20%20531%20%20%20%20OUT%2031%20%20B%27s%20turn%3A%20print%202%0A%2017%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2018%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20A%27s%20turn%3A%20print%201%0A%2019%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20002%0A%2032%20%20%20%20%20%20003%0A&in=1)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=store-the-sign-not-the-number-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-18%3A%20whose%20turn%2C%200%20for%20A%20and%20-1%20for%20B%3B%20-1%20-%20turn%20swaps%20them%0A%2011%20%20%20%20%20%20131%20%20%20%20CLA%2031%0A%2012%20%20%20%20%20%20730%20%20%20%20SUB%2030%0A%2013%20%20%20%20%20%20630%20%20%20%20STO%2030%0A%2014%20%20%20%20%20%20317%20%20%20%20TAC%2017%20%20one%20TAC%20reads%20it%0A%2015%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20A%27s%20turn%3A%20print%201%0A%2016%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2017%20%20%20%20%20%20532%20%20%20%20OUT%2032%20%20B%27s%20turn%3A%20print%202%0A%2018%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20-001%0A%2032%20%20%20%20%20%20002%0A&in=0)

   Both swap A's turn to B's and print 2. Numbering 1 and 2 takes 13 cells and runs 8 instructions; 0 and -1 takes 12
   cells and runs 7.

   There's a small surprise in that swap. In two's complement, the way binary machines store negative numbers, -1
   minus x is exactly NOT x, every bit flipped. So a choice kept as 0 and -1 flips with a single NOT, which is ~ in
   C.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=dont-test-what-you-just-set-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-14%3A%20read%20cards%20until%20one%20is%207%20or%20more%2C%20or%20a%20negative%20one%20ends%20them%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20317%20%20%20%20TAC%2017%0A%2013%20%20%20%20%20%20731%20%20%20%20SUB%2031%0A%2014%20%20%20%20%20%20310%20%20%20%20TAC%2010%0A%2015%20%20%20%20%20%20133%20%20%20%20CLA%2033%20%20cells%2015-16%3A%20found%3A%20set%20the%20flag%20and%20leave%20the%20loop%0A%2016%20%20%20%20%20%20632%20%20%20%20STO%2032%0A%2017%20%20%20%20%20%20132%20%20%20%20CLA%2032%20%20cells%2017-20%3A%20after%20the%20loop%2C%20test%20the%20flag%0A%2018%20%20%20%20%20%20320%20%20%20%20TAC%2020%0A%2019%20%20%20%20%20%20530%20%20%20%20OUT%2030%0A%2020%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20007%0A%2032%20%20%20%20%20-001%20%20%20%20the%20flag%3A%20-1%20not%20found%2C%200%20found%0A%2033%20%20%20%20%20%20000%0A&in=2%205%209%201)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=dont-test-what-you-just-set-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-16%3A%20read%20cards%20until%20one%20is%207%20or%20more%2C%20or%20a%20negative%20one%20ends%20them%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20316%20%20%20%20TAC%2016%0A%2013%20%20%20%20%20%20731%20%20%20%20SUB%2031%0A%2014%20%20%20%20%20%20310%20%20%20%20TAC%2010%0A%2015%20%20%20%20%20%20530%20%20%20%20OUT%2030%20%20found%3A%20act%20on%20it%20here%2C%20where%20the%20loop%27s%20own%20test%20already%20said%20so%0A%2016%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20007%0A&in=2%205%209%201)

   Both print 9. The flag version takes 15 cells and runs 21 instructions; acting on the spot takes 9 cells and runs
   17.

   Optimizing compilers do this for you, and GCC calls it jump threading. Its manual describes -fthread-jumps as
   checking whether a jump lands on a comparison whose answer the first one already settled, and if so, sending the
   jump straight on to where that comparison would have gone.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=park-the-number-you-subtract-keep-the-other-in-the-accumulator-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-15%3A%20a%20%3D%20x%20%2B%20y%2C%20stored%0A%2011%20%20%20%20%20%20041%20%20%20%20INP%2041%0A%2012%20%20%20%20%20%20042%20%20%20%20INP%2042%0A%2013%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2014%20%20%20%20%20%20241%20%20%20%20ADD%2041%0A%2015%20%20%20%20%20%20643%20%20%20%20STO%2043%0A%2016%20%20%20%20%20%20142%20%20%20%20CLA%2042%20%20cells%2016-18%3A%20b%20%3D%2010z%2C%20stored%0A%2017%20%20%20%20%20%20410%20%20%20%20SFT%2010%0A%2018%20%20%20%20%20%20644%20%20%20%20STO%2044%0A%2019%20%20%20%20%20%20144%20%20%20%20CLA%2044%20%20cells%2019-26%3A%20load%20b%20again%20and%20test%20b%20-%20a%20-%201%0A%2020%20%20%20%20%20%20743%20%20%20%20SUB%2043%0A%2021%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2022%20%20%20%20%20%20325%20%20%20%20TAC%2025%0A%2023%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20a%20%3C%20b%3A%20print%201%0A%2024%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2025%20%20%20%20%20%20545%20%20%20%20OUT%2045%0A%2026%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A%2042%20%20%20%20%20%20000%0A%2043%20%20%20%20%20%20000%0A%2044%20%20%20%20%20%20000%0A%2045%20%20%20%20%20%20000%0A&in=12%207%202)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=park-the-number-you-subtract-keep-the-other-in-the-accumulator-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-15%3A%20a%20%3D%20x%20%2B%20y%2C%20stored%2C%20because%20it%20is%20the%20one%20subtracted%0A%2011%20%20%20%20%20%20041%20%20%20%20INP%2041%0A%2012%20%20%20%20%20%20042%20%20%20%20INP%2042%0A%2013%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2014%20%20%20%20%20%20241%20%20%20%20ADD%2041%0A%2015%20%20%20%20%20%20643%20%20%20%20STO%2043%0A%2016%20%20%20%20%20%20142%20%20%20%20CLA%2042%20%20cells%2016-24%3A%20b%20%3D%2010z%20stays%20in%20the%20accumulator%3B%20test%20b%20-%20a%20-%201%0A%2017%20%20%20%20%20%20410%20%20%20%20SFT%2010%0A%2018%20%20%20%20%20%20743%20%20%20%20SUB%2043%0A%2019%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2020%20%20%20%20%20%20323%20%20%20%20TAC%2023%0A%2021%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20a%20%3C%20b%3A%20print%201%0A%2022%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2023%20%20%20%20%20%20544%20%20%20%20OUT%2044%0A%2024%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A%2042%20%20%20%20%20%20000%0A%2043%20%20%20%20%20%20000%0A%2044%20%20%20%20%20%20000%0A&in=12%207%202)

   Both compare 19 with 20 and print 1. Storing both takes 23 cells and runs 15 instructions; parking only a takes 20
   cells and runs 13.

   A compiler makes this choice all the time, and calls it register allocation. It keeps the values it's still
   working with in registers and spills the rest to memory. The 6502 has one accumulator, like CARDIAC, and its SBC
   and CMP also take a cell away from the accumulator and never the other way round, so its programmers made this
   same choice by hand.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=encode-so-one-comparison-decides-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-13%3A%20each%20card%20as%20a%20value%2C%200-9%2C%20and%20a%20trump%20flag%2C%201%20or%200%0A%2011%20%20%20%20%20%20041%20%20%20%20INP%2041%0A%2012%20%20%20%20%20%20042%20%20%20%20INP%2042%0A%2013%20%20%20%20%20%20043%20%20%20%20INP%2043%0A%2014%20%20%20%20%20%20141%20%20%20%20CLA%2041%20%20cells%2014-16%3A%20b%20is%20a%20trump%20and%20a%20isn%27t%3A%20b%20wins%0A%2015%20%20%20%20%20%20743%20%20%20%20SUB%2043%0A%2016%20%20%20%20%20%20325%20%20%20%20TAC%2025%0A%2017%20%20%20%20%20%20143%20%20%20%20CLA%2043%20%20cells%2017-19%3A%20a%20is%20a%20trump%20and%20b%20isn%27t%3A%20a%20wins%0A%2018%20%20%20%20%20%20741%20%20%20%20SUB%2041%0A%2019%20%20%20%20%20%20323%20%20%20%20TAC%2023%0A%2020%20%20%20%20%20%20140%20%20%20%20CLA%2040%20%20cells%2020-26%3A%20both%20or%20neither%3A%20the%20higher%20value%20wins%0A%2021%20%20%20%20%20%20742%20%20%20%20SUB%2042%0A%2022%20%20%20%20%20%20325%20%20%20%20TAC%2025%0A%2023%20%20%20%20%20%20540%20%20%20%20OUT%2040%0A%2024%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2025%20%20%20%20%20%20542%20%20%20%20OUT%2042%0A%2026%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A%2042%20%20%20%20%20%20000%0A%2043%20%20%20%20%20%20000%0A&in=9%200%202%201)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=encode-so-one-comparison-decides-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-18%3A%20a%20plain%20card%20is%200-9%20and%20a%20trump%20is%20stored%20with%2010%20added%3B%20one%20compare%20decides%0A%2011%20%20%20%20%20%20041%20%20%20%20INP%2041%0A%2012%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2013%20%20%20%20%20%20741%20%20%20%20SUB%2041%0A%2014%20%20%20%20%20%20317%20%20%20%20TAC%2017%0A%2015%20%20%20%20%20%20540%20%20%20%20OUT%2040%0A%2016%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2017%20%20%20%20%20%20541%20%20%20%20OUT%2041%0A%2018%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A&in=9%2012)

   A plain 9 meets the trump 2, and the trump wins: the first version prints 2, and the second prints the trump the
   way it stores it, 12. The flags take 21 cells and run 9 instructions; the encoding takes 11 cells and runs 7.

   IEEE 754 floating point is laid out on the same idea. The sign comes first, then the exponent, then the fraction,
   so for floats that are neither negative nor NaN, the bit patterns compare in the same order as the numbers, and a
   plain integer comparison sorts them. Negative numbers need their bits flipped first, which is the price of keeping
   the sign on its own.

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

    [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=classify-with-comparisons-not-division-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-20%3A%20the%20band%20is%20x%20%2F%20250%2C%20by%20subtracting%20250%20until%20x%20goes%20negative%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20741%20%20%20%20SUB%2041%0A%2013%20%20%20%20%20%20319%20%20%20%20TAC%2019%0A%2014%20%20%20%20%20%20640%20%20%20%20STO%2040%0A%2015%20%20%20%20%20%20142%20%20%20%20CLA%2042%0A%2016%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2017%20%20%20%20%20%20642%20%20%20%20STO%2042%0A%2018%20%20%20%20%20%20811%20%20%20%20JMP%2011%0A%2019%20%20%20%20%20%20542%20%20%20%20OUT%2042%0A%2020%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20250%0A%2042%20%20%20%20%20%20000%0A&in=600)

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

    [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=classify-with-comparisons-not-division-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-25%3A%20three%20compares%20sort%20x%20into%20four%20bands%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20741%20%20%20%20SUB%2041%20%20x%20-%20250%0A%2013%20%20%20%20%20%20320%20%20%20%20TAC%2020%0A%2014%20%20%20%20%20%20741%20%20%20%20SUB%2041%20%20x%20-%20500%0A%2015%20%20%20%20%20%20322%20%20%20%20TAC%2022%0A%2016%20%20%20%20%20%20741%20%20%20%20SUB%2041%20%20x%20-%20750%0A%2017%20%20%20%20%20%20324%20%20%20%20TAC%2024%0A%2018%20%20%20%20%20%20544%20%20%20%20OUT%2044%0A%2019%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2020%20%20%20%20%20%20542%20%20%20%20OUT%2042%0A%2021%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2022%20%20%20%20%20%20500%20%20%20%20OUT%2000%0A%2023%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2024%20%20%20%20%20%20543%20%20%20%20OUT%2043%0A%2025%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20250%0A%2042%20%20%20%20%20%20000%0A%2043%20%20%20%20%20%20002%0A%2044%20%20%20%20%20%20003%0A&in=600)

    Both put 600 in band 2. This one's a trade: the comparisons take more cells, 21 against 14, because each band
    needs its own way out. But they run 10 instructions where the division ran 22, and they never get slower.

    Division is still the slow one. On current processors an integer divide takes many times longer than an add or a
    compare, and compilers go out of their way to avoid it. Since Granlund and Montgomery's 1994 paper, a division by
    a constant is normally compiled as a multiplication and a shift.

11. **Subtract until it goes negative, then add one back.** Say you want the remainder when x is divided by d, like
    100 mod 7.

    In most languages you'd write a loop: while x is at least d, take d away from x. Written that way on CARDIAC,
    each pass loads x, subtracts d, tests, stores x back and jumps round. That's five instructions to take away one
    d.

    ```
    cell  contents  notes
     10      040    INP 40  cells 10-18: take d away from x and store it, while what is left isn't negative
     11      041    INP 41
     12      140    CLA 40
     13      741    SUB 41
     14      317    TAC 17
     15      640    STO 40
     16      812    JMP 12
     17      540    OUT 40
     18      900    HRS 00
     40      000    x, and then the remainder
     41      000    d
    ```
    <!-- input: 100 7 -->

    [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=subtract-until-it-goes-negative-then-add-one-back-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-18%3A%20take%20d%20away%20from%20x%20and%20store%20it%2C%20while%20what%20is%20left%20isn%27t%20negative%0A%2011%20%20%20%20%20%20041%20%20%20%20INP%2041%0A%2012%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2013%20%20%20%20%20%20741%20%20%20%20SUB%2041%0A%2014%20%20%20%20%20%20317%20%20%20%20TAC%2017%0A%2015%20%20%20%20%20%20640%20%20%20%20STO%2040%0A%2016%20%20%20%20%20%20812%20%20%20%20JMP%2012%0A%2017%20%20%20%20%20%20540%20%20%20%20OUT%2040%0A%2018%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%20%20%20%20x%2C%20and%20then%20the%20remainder%0A%2041%20%20%20%20%20%20000%20%20%20%20d%0A&in=100%207)

    But there's no need to store x until you're done. Keep it in the accumulator and subtract d until it goes
    negative, which is one subtraction too many, then add one d back, and what's left is the remainder. That's three
    instructions a pass. The same loop answers "does d divide x?" and is the heart of the greatest common divisor. If
    you want the quotient too, you have to count the passes, and the count brings the stores back, as in "Divide by
    walking".

    ```
    cell  contents  notes
     10      040    INP 40  cells 10-19: subtract d in the accumulator until it goes negative, then add one d back
     11      041    INP 41
     12      140    CLA 40
     13      741    SUB 41
     14      316    TAC 16
     15      813    JMP 13
     16      241    ADD 41
     17      640    STO 40
     18      540    OUT 40
     19      900    HRS 00
     40      000    x, and then the remainder
     41      000    d
    ```
    <!-- input: 100 7 -->

    [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=subtract-until-it-goes-negative-then-add-one-back-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-19%3A%20subtract%20d%20in%20the%20accumulator%20until%20it%20goes%20negative%2C%20then%20add%20one%20d%20back%0A%2011%20%20%20%20%20%20041%20%20%20%20INP%2041%0A%2012%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2013%20%20%20%20%20%20741%20%20%20%20SUB%2041%0A%2014%20%20%20%20%20%20316%20%20%20%20TAC%2016%0A%2015%20%20%20%20%20%20813%20%20%20%20JMP%2013%0A%2016%20%20%20%20%20%20241%20%20%20%20ADD%2041%0A%2017%20%20%20%20%20%20640%20%20%20%20STO%2040%0A%2018%20%20%20%20%20%20540%20%20%20%20OUT%2040%0A%2019%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%20%20%20%20x%2C%20and%20then%20the%20remainder%0A%2041%20%20%20%20%20%20000%20%20%20%20d%0A&in=100%207)

    Both print 2. Storing as you go takes 11 cells and runs 77 instructions. Staying in the accumulator takes 12
    cells, one more for adding d back, and runs 51.

    Textbook hardware dividers work the same way, and the method is called restoring division. Each step subtracts
    the divisor, and when the result goes negative, the divider adds it back and writes a 0 into the quotient. Non-
    restoring division was worked out to skip the adding back.

12. **Test for zero with SUB 00.** Say you want to print 42 n times, where n comes on a card and can be 0.

    The loop has to stop when n reaches 0, and "is it 0?" sounds like an equality test, which on CARDIAC is two
    questions. A count is never negative, so the question left is "is n above 0?", and the way to ask that is to
    subtract n from 0. That needs a cell holding 0, and n still has to be counted down on its own afterwards.

    ```
    cell  contents  notes
     10      030    INP 30  cells 10-14: is n above 0? 0 - n is negative when it is
     11      131    CLA 31
     12      730    SUB 30
     13      315    TAC 15
     14      820    JMP 20
     15      532    OUT 32  cells 15-20: the body, then count n down and test again
     16      130    CLA 30
     17      700    SUB 00
     18      630    STO 30
     19      811    JMP 11
     20      900    HRS 00
     30      000    n
     31      000    0
     32      042    what the body prints
    ```
    <!-- input: 3 -->

    [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=test-for-zero-with-sub-00-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-14%3A%20is%20n%20above%200%3F%200%20-%20n%20is%20negative%20when%20it%20is%0A%2011%20%20%20%20%20%20131%20%20%20%20CLA%2031%0A%2012%20%20%20%20%20%20730%20%20%20%20SUB%2030%0A%2013%20%20%20%20%20%20315%20%20%20%20TAC%2015%0A%2014%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2015%20%20%20%20%20%20532%20%20%20%20OUT%2032%20%20cells%2015-20%3A%20the%20body%2C%20then%20count%20n%20down%20and%20test%20again%0A%2016%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2017%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2018%20%20%20%20%20%20630%20%20%20%20STO%2030%0A%2019%20%20%20%20%20%20811%20%20%20%20JMP%2011%0A%2020%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20n%0A%2031%20%20%20%20%20%20000%20%20%20%200%0A%2032%20%20%20%20%20%20042%20%20%20%20what%20the%20body%20prints%0A&in=3)

    Here's the trick: when x can't be negative, x is 0 exactly when x - 1 is negative. The 1 comes free from cell 00.
    Better still, when the answer is no, x - 1 is already sitting in the accumulator, and it's the count you were
    about to store. The test and the counting down are the same subtraction.

    ```
    cell  contents  notes
     10      030    INP 30  cells 10-13: n - 1 is negative only when n is 0, and otherwise it is the new count
     11      130    CLA 30
     12      700    SUB 00
     13      317    TAC 17
     14      630    STO 30  cells 14-17: keep the new count, the body, and test again
     15      532    OUT 32
     16      811    JMP 11
     17      900    HRS 00
     30      000    n
     32      042    what the body prints
    ```
    <!-- input: 3 -->

    [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=test-for-zero-with-sub-00-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-13%3A%20n%20-%201%20is%20negative%20only%20when%20n%20is%200%2C%20and%20otherwise%20it%20is%20the%20new%20count%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2013%20%20%20%20%20%20317%20%20%20%20TAC%2017%0A%2014%20%20%20%20%20%20630%20%20%20%20STO%2030%20%20cells%2014-17%3A%20keep%20the%20new%20count%2C%20the%20body%2C%20and%20test%20again%0A%2015%20%20%20%20%20%20532%20%20%20%20OUT%2032%0A%2016%20%20%20%20%20%20811%20%20%20%20JMP%2011%0A%2017%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20n%0A%2032%20%20%20%20%20%20042%20%20%20%20what%20the%20body%20prints%0A&in=3)

    Both print 42 three times. Subtracting from 0 takes 14 cells and runs 30 instructions; SUB 00 takes 10 cells and
    runs 23.

    Later processors merged the same two jobs into one instruction. The Z80's DJNZ takes one from register B and
    jumps unless it has reached zero, and x86's LOOP does the same with the CX register, so counting down and testing
    for zero are a single step.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=scale-by-ten-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-19%3A%20x%20times%208%2C%20doubled%20three%20times%20through%20a%20spare%20cell%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20230%20%20%20%20ADD%2030%0A%2013%20%20%20%20%20%20631%20%20%20%20STO%2031%0A%2014%20%20%20%20%20%20231%20%20%20%20ADD%2031%0A%2015%20%20%20%20%20%20631%20%20%20%20STO%2031%0A%2016%20%20%20%20%20%20231%20%20%20%20ADD%2031%0A%2017%20%20%20%20%20%20631%20%20%20%20STO%2031%0A%2018%20%20%20%20%20%20531%20%20%20%20OUT%2031%0A%2019%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20000%0A&in=7)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=scale-by-ten-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-15%3A%20x%20times%2010%20is%20one%20shift%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20410%20%20%20%20SFT%2010%0A%2013%20%20%20%20%20%20631%20%20%20%20STO%2031%0A%2014%20%20%20%20%20%20531%20%20%20%20OUT%2031%0A%2015%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20000%0A&in=7)

   Times 8 prints 56 and times 10 prints 70. Times 8 takes 12 cells and runs 10 instructions; times 10 takes 8 cells
   and runs 6.

   Binary machines follow the same rule with 2 in place of 10. Fixed-point formats like Q15 put the binary point a
   power of two away, so rescaling is a shift, and Java's HashMap keeps its table a power of two in size so that
   finding a bucket is an AND instead of a remainder.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=fold-the-multiply-into-the-shift-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-19%3A%20cut%20out%20each%20digit%3A%20c%2C%20then%20b%2C%20then%20a%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20433%20%20%20%20SFT%2033%0A%2013%20%20%20%20%20%20643%20%20%20%20STO%2043%0A%2014%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2015%20%20%20%20%20%20423%20%20%20%20SFT%2023%0A%2016%20%20%20%20%20%20642%20%20%20%20STO%2042%0A%2017%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2018%20%20%20%20%20%20413%20%20%20%20SFT%2013%0A%2019%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2020%20%20%20%20%20%20143%20%20%20%20CLA%2043%20%20cells%2020-29%3A%20then%20put%20each%20in%20its%20place%20and%20add%20them%20up%0A%2021%20%20%20%20%20%20420%20%20%20%20SFT%2020%0A%2022%20%20%20%20%20%20644%20%20%20%20STO%2044%0A%2023%20%20%20%20%20%20142%20%20%20%20CLA%2042%0A%2024%20%20%20%20%20%20410%20%20%20%20SFT%2010%0A%2025%20%20%20%20%20%20244%20%20%20%20ADD%2044%0A%2026%20%20%20%20%20%20241%20%20%20%20ADD%2041%0A%2027%20%20%20%20%20%20644%20%20%20%20STO%2044%0A%2028%20%20%20%20%20%20544%20%20%20%20OUT%2044%0A%2029%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A%2042%20%20%20%20%20%20000%0A%2043%20%20%20%20%20%20000%0A%2044%20%20%20%20%20%20000%0A&in=123)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=fold-the-multiply-into-the-shift-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-24%3A%20each%20shift%20cuts%20a%20digit%20out%20and%20puts%20it%20in%20its%20new%20place%20at%20once%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20431%20%20%20%20SFT%2031%20%20c00%0A%2013%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2014%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2015%20%20%20%20%20%20423%20%20%20%20SFT%2023%20%2000b%0A%2016%20%20%20%20%20%20410%20%20%20%20SFT%2010%20%200b0%0A%2017%20%20%20%20%20%20241%20%20%20%20ADD%2041%0A%2018%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2019%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2020%20%20%20%20%20%20413%20%20%20%20SFT%2013%20%2000a%0A%2021%20%20%20%20%20%20241%20%20%20%20ADD%2041%0A%2022%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2023%20%20%20%20%20%20541%20%20%20%20OUT%2041%0A%2024%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A&in=123)

   Both turn 123 into 321. Cutting and placing separately takes 25 cells and runs 20 instructions; folding them
   together takes 17 cells and runs 15.

   SFT's shift left and then right is what binary machines call a bitfield extract, and many have it as one
   instruction. PowerPC's rlwinm rotates a register and masks it in one go, and ARM's UBFX pulls out a run of bits
   and lands it at the bottom of the register. Compilers use them for C bitfields and for exactly this kind of
   cutting and placing.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=divide-by-walking-and-stop-when-the-answer-stops-mattering-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-19%3A%20divide%20all%20the%20way%3A%20how%20many%20times%20d%20goes%20into%20x%0A%2011%20%20%20%20%20%20041%20%20%20%20INP%2041%0A%2012%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2013%20%20%20%20%20%20741%20%20%20%20SUB%2041%0A%2014%20%20%20%20%20%20320%20%20%20%20TAC%2020%0A%2015%20%20%20%20%20%20640%20%20%20%20STO%2040%0A%2016%20%20%20%20%20%20142%20%20%20%20CLA%2042%0A%2017%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2018%20%20%20%20%20%20642%20%20%20%20STO%2042%0A%2019%20%20%20%20%20%20812%20%20%20%20JMP%2012%0A%2020%20%20%20%20%20%20142%20%20%20%20CLA%2042%20%20cells%2020-26%3A%20then%20cut%20the%20answer%20down%20to%203%0A%2021%20%20%20%20%20%20743%20%20%20%20SUB%2043%0A%2022%20%20%20%20%20%20325%20%20%20%20TAC%2025%0A%2023%20%20%20%20%20%20143%20%20%20%20CLA%2043%0A%2024%20%20%20%20%20%20642%20%20%20%20STO%2042%0A%2025%20%20%20%20%20%20542%20%20%20%20OUT%2042%0A%2026%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A%2042%20%20%20%20%20%20000%20%20%20%20the%20count%0A%2043%20%20%20%20%20%20003%0A&in=100%207)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=divide-by-walking-and-stop-when-the-answer-stops-mattering-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-22%3A%20walk%2C%20and%20stop%20as%20soon%20as%20the%20count%20reaches%203%0A%2011%20%20%20%20%20%20041%20%20%20%20INP%2041%0A%2012%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2013%20%20%20%20%20%20741%20%20%20%20SUB%2041%0A%2014%20%20%20%20%20%20321%20%20%20%20TAC%2021%0A%2015%20%20%20%20%20%20640%20%20%20%20STO%2040%0A%2016%20%20%20%20%20%20142%20%20%20%20CLA%2042%0A%2017%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2018%20%20%20%20%20%20642%20%20%20%20STO%2042%0A%2019%20%20%20%20%20%20743%20%20%20%20SUB%2043%0A%2020%20%20%20%20%20%20312%20%20%20%20TAC%2012%20%20under%203%3A%20keep%20walking%0A%2021%20%20%20%20%20%20542%20%20%20%20OUT%2042%0A%2022%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A%2042%20%20%20%20%20%20000%20%20%20%20the%20count%0A%2043%20%20%20%20%20%20003%0A&in=100%207)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=halve-before-you-square-check-the-box-first-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cell%2010%3A%20dx%2C%20up%20to%2060%20from%20the%20middle%0A%2011%20%20%20%20%20%20144%20%20%20%20CLA%2044%20%20cells%2011-27%3A%20dx%20squared%3A%20add%20dx%20to%20itself%20dx%20times%2C%20counting%20up%20from%20-dx%0A%2012%20%20%20%20%20%20740%20%20%20%20SUB%2040%0A%2013%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2014%20%20%20%20%20%20142%20%20%20%20CLA%2042%0A%2015%20%20%20%20%20%20240%20%20%20%20ADD%2040%0A%2016%20%20%20%20%20%20642%20%20%20%20STO%2042%0A%2017%20%20%20%20%20%20141%20%20%20%20CLA%2041%0A%2018%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2019%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2020%20%20%20%20%20%20314%20%20%20%20TAC%2014%0A%2021%20%20%20%20%20%20142%20%20%20%20CLA%2042%20%20inside%20when%20dx%20squared%20is%20below%20r%20squared%2C%20400%0A%2022%20%20%20%20%20%20743%20%20%20%20SUB%2043%0A%2023%20%20%20%20%20%20326%20%20%20%20TAC%2026%0A%2024%20%20%20%20%20%20544%20%20%20%20OUT%2044%0A%2025%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2026%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20inside%3A%20print%201%0A%2027%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A%2042%20%20%20%20%20%20000%20%20%20%20dx%20squared%2C%20kept%20in%20a%20cell%3A%20only%20its%20last%20three%20digits%0A%2043%20%20%20%20%20%20400%0A%2044%20%20%20%20%20%20000%0A&in=33)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=halve-before-you-square-check-the-box-first-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-15%3A%20first%20the%20box%3A%20dx%20not%20below%20r%20means%20outside%2C%20with%20no%20square%20at%20all%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20743%20%20%20%20SUB%2043%0A%2013%20%20%20%20%20%20316%20%20%20%20TAC%2016%0A%2014%20%20%20%20%20%20545%20%20%20%20OUT%2045%0A%2015%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2016%20%20%20%20%20%20145%20%20%20%20CLA%2045%20%20cells%2016-32%3A%20dx%20squared%3A%20add%20dx%20to%20itself%20dx%20times%2C%20counting%20up%20from%20-dx%0A%2017%20%20%20%20%20%20740%20%20%20%20SUB%2040%0A%2018%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2019%20%20%20%20%20%20142%20%20%20%20CLA%2042%0A%2020%20%20%20%20%20%20240%20%20%20%20ADD%2040%0A%2021%20%20%20%20%20%20642%20%20%20%20STO%2042%0A%2022%20%20%20%20%20%20141%20%20%20%20CLA%2041%0A%2023%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2024%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2025%20%20%20%20%20%20319%20%20%20%20TAC%2019%0A%2026%20%20%20%20%20%20142%20%20%20%20CLA%2042%20%20inside%20the%20box%2C%20dx%20is%20below%2020%2C%20and%20its%20square%20fits%0A%2027%20%20%20%20%20%20744%20%20%20%20SUB%2044%0A%2028%20%20%20%20%20%20331%20%20%20%20TAC%2031%0A%2029%20%20%20%20%20%20545%20%20%20%20OUT%2045%0A%2030%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2031%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20inside%3A%20print%201%0A%2032%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A%2042%20%20%20%20%20%20000%0A%2043%20%20%20%20%20%20020%0A%2044%20%20%20%20%20%20400%0A%2045%20%20%20%20%20%20000%0A&in=33)

   The first version prints 1, which is wrong, after 240 instructions. The second prints 0, which is right, after 6.
   It does take more cells, 29 against 23, because it has the box check as well as the square.

   Arithmetic that quietly wraps around still catches people. In 2006 Joshua Bloch reported that the binary search in
   Java's own library worked out its midpoint as (low + high) / 2, which overflows once an array has more than about
   a billion elements, and as his title put it, nearly all binary searches had the same bug. Checking the box first
   is a habit in graphics and games too, where a cheap bounding-box test throws out most candidates before anything
   gets squared.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=fit-the-arithmetic-to-three-digits-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-19%3A%2021s%20by%20adding%20s%2021%20times%3B%20STO%20keeps%20three%20digits%20each%20time%0A%2011%20%20%20%20%20%20141%20%20%20%20CLA%2041%0A%2012%20%20%20%20%20%20642%20%20%20%20STO%2042%0A%2013%20%20%20%20%20%20143%20%20%20%20CLA%2043%0A%2014%20%20%20%20%20%20240%20%20%20%20ADD%2040%0A%2015%20%20%20%20%20%20643%20%20%20%20STO%2043%0A%2016%20%20%20%20%20%20142%20%20%20%20CLA%2042%0A%2017%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2018%20%20%20%20%20%20642%20%20%20%20STO%2042%0A%2019%20%20%20%20%20%20313%20%20%20%20TAC%2013%0A%2020%20%20%20%20%20%20143%20%20%20%20CLA%2043%20%20cells%2020-24%3A%20then%20add%2017%0A%2021%20%20%20%20%20%20244%20%20%20%20ADD%2044%0A%2022%20%20%20%20%20%20643%20%20%20%20STO%2043%0A%2023%20%20%20%20%20%20543%20%20%20%20OUT%2043%0A%2024%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20-021%0A%2042%20%20%20%20%20%20000%0A%2043%20%20%20%20%20%20000%0A%2044%20%20%20%20%20%20017%0A&in=999)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=fit-the-arithmetic-to-three-digits-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-19%3A%2021s%20%2B%2017%20as%2010%20%282s%20mod%20100%29%20%2B%20s%20%2B%2017%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20240%20%20%20%20ADD%2040%20%202s%0A%2013%20%20%20%20%20%20422%20%20%20%20SFT%2022%20%202s%20mod%20100%0A%2014%20%20%20%20%20%20410%20%20%20%20SFT%2010%20%2010%20%282s%20mod%20100%29%2C%20never%20past%20990%0A%2015%20%20%20%20%20%20240%20%20%20%20ADD%2040%0A%2016%20%20%20%20%20%20241%20%20%20%20ADD%2041%0A%2017%20%20%20%20%20%20642%20%20%20%20STO%2042%20%20STO%20keeps%20three%20digits%3A%20the%20mod%201000%0A%2018%20%20%20%20%20%20542%20%20%20%20OUT%2042%0A%2019%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20017%0A%2042%20%20%20%20%20%20000%0A&in=999)

   Both turn 999 into 996. The loop takes 20 cells and runs 155 instructions; the rearranged version takes 13 cells
   and runs 10.

   Random number generators on binary machines get the same free modulus. Make the modulus 2 to the 32 and the
   register's own wraparound does the mod, which is why the quick generator in Numerical Recipes, 1664525s +
   1013904223 on 32-bit unsigned integers, has no mod in it at all.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=spend-every-digit-of-a-random-number-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20050%20%20%20%20INP%2050%20%20cells%2010-31%3A%20the%20seed%0A%2011%20%20%20%20%20%20150%20%20%20%20CLA%2050%20%20cells%2011-17%3A%20the%20next%20random%20number%2C%20s%20%3D%20%2821s%20%2B%2017%29%20mod%201000%0A%2012%20%20%20%20%20%20250%20%20%20%20ADD%2050%0A%2013%20%20%20%20%20%20422%20%20%20%20SFT%2022%0A%2014%20%20%20%20%20%20410%20%20%20%20SFT%2010%0A%2015%20%20%20%20%20%20250%20%20%20%20ADD%2050%0A%2016%20%20%20%20%20%20251%20%20%20%20ADD%2051%0A%2017%20%20%20%20%20%20650%20%20%20%20STO%2050%0A%2018%20%20%20%20%20%20433%20%20%20%20SFT%2033%20%20a%20digit%2C%200-9%2C%20from%20the%20first%20draw%0A%2019%20%20%20%20%20%20652%20%20%20%20STO%2052%0A%2020%20%20%20%20%20%20150%20%20%20%20CLA%2050%20%20cells%2020-26%3A%20the%20next%20random%20number%2C%20s%20%3D%20%2821s%20%2B%2017%29%20mod%201000%0A%2021%20%20%20%20%20%20250%20%20%20%20ADD%2050%0A%2022%20%20%20%20%20%20422%20%20%20%20SFT%2022%0A%2023%20%20%20%20%20%20410%20%20%20%20SFT%2010%0A%2024%20%20%20%20%20%20250%20%20%20%20ADD%2050%0A%2025%20%20%20%20%20%20251%20%20%20%20ADD%2051%0A%2026%20%20%20%20%20%20650%20%20%20%20STO%2050%0A%2027%20%20%20%20%20%20422%20%20%20%20SFT%2022%20%20a%20number%2C%200-99%2C%20from%20a%20second%20draw%0A%2028%20%20%20%20%20%20653%20%20%20%20STO%2053%0A%2029%20%20%20%20%20%20552%20%20%20%20OUT%2052%0A%2030%20%20%20%20%20%20553%20%20%20%20OUT%2053%0A%2031%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2050%20%20%20%20%20%20000%0A%2051%20%20%20%20%20%20017%0A%2052%20%20%20%20%20%20000%0A%2053%20%20%20%20%20%20000%0A&in=472)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=spend-every-digit-of-a-random-number-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20050%20%20%20%20INP%2050%20%20cells%2010-25%3A%20the%20seed%0A%2011%20%20%20%20%20%20150%20%20%20%20CLA%2050%20%20cells%2011-17%3A%20the%20next%20random%20number%2C%20s%20%3D%20%2821s%20%2B%2017%29%20mod%201000%0A%2012%20%20%20%20%20%20250%20%20%20%20ADD%2050%0A%2013%20%20%20%20%20%20422%20%20%20%20SFT%2022%0A%2014%20%20%20%20%20%20410%20%20%20%20SFT%2010%0A%2015%20%20%20%20%20%20250%20%20%20%20ADD%2050%0A%2016%20%20%20%20%20%20251%20%20%20%20ADD%2051%0A%2017%20%20%20%20%20%20650%20%20%20%20STO%2050%0A%2018%20%20%20%20%20%20433%20%20%20%20SFT%2033%20%20a%20digit%2C%200-9%3A%20the%20last%20digit%0A%2019%20%20%20%20%20%20652%20%20%20%20STO%2052%0A%2020%20%20%20%20%20%20150%20%20%20%20CLA%2050%0A%2021%20%20%20%20%20%20412%20%20%20%20SFT%2012%20%20a%20number%2C%200-99%3A%20the%20first%20two%20digits%2C%20from%20the%20same%20draw%0A%2022%20%20%20%20%20%20653%20%20%20%20STO%2053%0A%2023%20%20%20%20%20%20552%20%20%20%20OUT%2052%0A%2024%20%20%20%20%20%20553%20%20%20%20OUT%2053%0A%2025%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2050%20%20%20%20%20%20000%0A%2051%20%20%20%20%20%20017%0A%2052%20%20%20%20%20%20000%0A%2053%20%20%20%20%20%20000%0A&in=472)

   From the seed 472, drawing twice prints 9 and 26, and drawing once prints 9 and 92. Two draws take 26 cells and
   run 22 instructions; one draw takes 20 cells and runs 16.

   One thing to know before you spend them. In a generator of this kind, the low digits repeat far sooner than the
   whole number does. With (21s + 17) mod 1000, the last digit just goes up by 7 on every draw, so it runs through
   all ten digits in a fixed order. Binary generators have the same weakness in their low bits, and the documentation
   for Java's Random says so, which is why its nextInt hands out high bits when the range is a power of two. The
   front of the number is the better part to lean on.

7. **Pack three counts into one cell.** Say you're keeping score over a season: how many wins, draws and losses, each
   fewer than ten.

   The obvious way gives each count its own cell. Then every result needs questions to find out which count it
   belongs to, and printing the counts takes three OUTs.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-12: read results until a negative card: 2 a win, 1 a draw, 0 a loss
    11      140    CLA 40
    12      329    TAC 29
    13      700    SUB 00  cells 13-16: which one?
    14      325    TAC 25
    15      700    SUB 00
    16      321    TAC 21
    17      141    CLA 41  cells 17-28: count it in its own cell
    18      200    ADD 00
    19      641    STO 41
    20      810    JMP 10
    21      142    CLA 42
    22      200    ADD 00
    23      642    STO 42
    24      810    JMP 10
    25      143    CLA 43
    26      200    ADD 00
    27      643    STO 43
    28      810    JMP 10
    29      541    OUT 41  cells 29-32: print wins, draws and losses
    30      542    OUT 42
    31      543    OUT 43
    32      900    HRS 00
    40      000    the card
    41      000    wins
    42      000    draws
    43      000    losses
   ```
   <!-- input: 2 0 0 1 2 0 -1 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=pack-three-counts-into-one-cell-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-12%3A%20read%20results%20until%20a%20negative%20card%3A%202%20a%20win%2C%201%20a%20draw%2C%200%20a%20loss%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20329%20%20%20%20TAC%2029%0A%2013%20%20%20%20%20%20700%20%20%20%20SUB%2000%20%20cells%2013-16%3A%20which%20one%3F%0A%2014%20%20%20%20%20%20325%20%20%20%20TAC%2025%0A%2015%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2016%20%20%20%20%20%20321%20%20%20%20TAC%2021%0A%2017%20%20%20%20%20%20141%20%20%20%20CLA%2041%20%20cells%2017-28%3A%20count%20it%20in%20its%20own%20cell%0A%2018%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2019%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2020%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2021%20%20%20%20%20%20142%20%20%20%20CLA%2042%0A%2022%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2023%20%20%20%20%20%20642%20%20%20%20STO%2042%0A%2024%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2025%20%20%20%20%20%20143%20%20%20%20CLA%2043%0A%2026%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2027%20%20%20%20%20%20643%20%20%20%20STO%2043%0A%2028%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2029%20%20%20%20%20%20541%20%20%20%20OUT%2041%20%20cells%2029-32%3A%20print%20wins%2C%20draws%20and%20losses%0A%2030%20%20%20%20%20%20542%20%20%20%20OUT%2042%0A%2031%20%20%20%20%20%20543%20%20%20%20OUT%2043%0A%2032%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%20%20%20%20the%20card%0A%2041%20%20%20%20%20%20000%20%20%20%20wins%0A%2042%20%20%20%20%20%20000%20%20%20%20draws%0A%2043%20%20%20%20%20%20000%20%20%20%20losses%0A&in=2%200%200%201%202%200%20-1)

   But a cell has three decimal digits, and each count fits in one. Let the hundreds count the wins, the tens the
   draws and the units the losses, and put each result on its card as the amount it adds: 100 for a win, 10 for a
   draw and 1 for a loss. Now there's nothing to sort out, because adding up the cards keeps all three counts, and
   213 means two wins, one draw and three losses. You can still pull out any one count when you need it: SFT 13
   leaves the hundreds, SFT 23 the tens and SFT 33 the units. Just don't let a count pass 9, or it spills into the
   next one.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-17: a win is 100, a draw 10 and a loss 1, so the sum keeps all three counts
    11      140    CLA 40
    12      316    TAC 16
    13      241    ADD 41
    14      641    STO 41
    15      810    JMP 10
    16      541    OUT 41
    17      900    HRS 00
    40      000    the card
    41      000    wins, draws and losses, one digit each
   ```
   <!-- input: 100 1 1 10 100 1 -1 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=pack-three-counts-into-one-cell-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-17%3A%20a%20win%20is%20100%2C%20a%20draw%2010%20and%20a%20loss%201%2C%20so%20the%20sum%20keeps%20all%20three%20counts%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20316%20%20%20%20TAC%2016%0A%2013%20%20%20%20%20%20241%20%20%20%20ADD%2041%0A%2014%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2015%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2016%20%20%20%20%20%20541%20%20%20%20OUT%2041%0A%2017%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%20%20%20%20the%20card%0A%2041%20%20%20%20%20%20000%20%20%20%20wins%2C%20draws%20and%20losses%2C%20one%20digit%20each%0A&in=100%201%201%2010%20100%201%20-1)

   <!-- maps -->

   Both find two wins, one draw and three losses, and the second prints them as 213. Counting in three cells takes 27
   cells and runs 67 instructions; counting in one takes 10 cells and runs 41. The same packing puts three yes-or-no
   flags, or three small numbers, in every cell, which is how a program fits data three times bigger than it would
   otherwise have room for.

   Unix file permissions pack the same way, in octal. The digits in chmod 754 are for the owner, the group and
   everyone else, and each one is the sum of 4 for read, 2 for write and 1 for execute. C's bitfields and the x86
   flags register do the same with bits.

8. **Keep a number too big for a cell in two.** Say you're adding up cards, and the total can go past 999.

   The usual loop keeps the total in one cell. That's fine until the total passes 999. The accumulator holds four
   digits, but STO keeps only the last three, so 500, 600 and 700 add up to 800.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-17: add up cards until a negative one, in one cell
    11      130    CLA 30
    12      316    TAC 16
    13      231    ADD 31
    14      631    STO 31  STO keeps only the last three digits
    15      810    JMP 10
    16      531    OUT 31
    17      900    HRS 00
    30      000
    31      000    the total
   ```
   <!-- input: 500 600 700 -1 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=keep-a-number-too-big-for-a-cell-in-two-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-17%3A%20add%20up%20cards%20until%20a%20negative%20one%2C%20in%20one%20cell%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20316%20%20%20%20TAC%2016%0A%2013%20%20%20%20%20%20231%20%20%20%20ADD%2031%0A%2014%20%20%20%20%20%20631%20%20%20%20STO%2031%20%20STO%20keeps%20only%20the%20last%20three%20digits%0A%2015%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2016%20%20%20%20%20%20531%20%20%20%20OUT%2031%0A%2017%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20000%20%20%20%20the%20total%0A&in=500%20600%20700%20-1)

   So keep the total in two cells, one for the last three digits and one for the thousands. The accumulator can hold
   the last three digits plus a card, which is at most 1998, and two instructions split it. STO keeps the last three
   digits, and SFT 03 drops them and leaves the thousands, 0 or 1, to carry into the other cell. Print the thousands
   and then the rest, so 1 and 800 means 1,800, and 2 and 50 means 2,050. Two cells go up to 999,999.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-20: add up cards until a negative one, in two cells
    11      130    CLA 30
    12      319    TAC 19
    13      231    ADD 31  up to 1998, which the accumulator can hold
    14      631    STO 31  STO keeps the last three digits
    15      403    SFT 03  and SFT 03 leaves the thousands: the carry
    16      232    ADD 32
    17      632    STO 32
    18      810    JMP 10
    19      532    OUT 32  cells 19-21: print the thousands, then the rest
    20      531    OUT 31
    21      900    HRS 00
    30      000
    31      000    the total's last three digits
    32      000    the total's thousands
   ```
   <!-- input: 500 600 700 -1 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=keep-a-number-too-big-for-a-cell-in-two-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-20%3A%20add%20up%20cards%20until%20a%20negative%20one%2C%20in%20two%20cells%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20319%20%20%20%20TAC%2019%0A%2013%20%20%20%20%20%20231%20%20%20%20ADD%2031%20%20up%20to%201998%2C%20which%20the%20accumulator%20can%20hold%0A%2014%20%20%20%20%20%20631%20%20%20%20STO%2031%20%20STO%20keeps%20the%20last%20three%20digits%0A%2015%20%20%20%20%20%20403%20%20%20%20SFT%2003%20%20and%20SFT%2003%20leaves%20the%20thousands%3A%20the%20carry%0A%2016%20%20%20%20%20%20232%20%20%20%20ADD%2032%0A%2017%20%20%20%20%20%20632%20%20%20%20STO%2032%0A%2018%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2019%20%20%20%20%20%20532%20%20%20%20OUT%2032%20%20cells%2019-21%3A%20print%20the%20thousands%2C%20then%20the%20rest%0A%2020%20%20%20%20%20%20531%20%20%20%20OUT%2031%0A%2021%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20000%20%20%20%20the%20total%27s%20last%20three%20digits%0A%2032%20%20%20%20%20%20000%20%20%20%20the%20total%27s%20thousands%0A&in=500%20600%20700%20-1)

   <!-- maps -->

   The one-cell version prints 800, which is wrong, in 10 cells and 23 instructions. The two-cell version prints 1
   and 800, which is right, in 15 cells and 33 instructions.

   Binary machines do this with a carry flag, and it's called multi-precision arithmetic. On the 8-bit 6502, adding
   two 16-bit numbers is one ADC on the low bytes and another on the high bytes, and the second ADC adds in the carry
   the first one left behind. Libraries like GMP do the same on 64-bit words to work with numbers thousands of digits
   long.

9. **Tell odd from even with 5n.** Say you want to know whether n is odd.

   CARDIAC can't divide, so the remainder after dividing by 2 means walking: take 2 away until n goes negative, and
   look at what's left. Even walking in the accumulator, as in "Subtract until it goes negative, then add one back",
   that's three instructions for every 2 in n, and 123 takes 62 subtractions.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-14: take 2 away from n until it goes negative
    11      140    CLA 40
    12      741    SUB 41
    13      315    TAC 15
    14      812    JMP 12
    15      200    ADD 00  cells 15-20: -1 is left when n is odd, -2 when it is even
    16      319    TAC 19
    17      500    OUT 00  odd: print 1
    18      900    HRS 00
    19      542    OUT 42  even: print 0
    20      900    HRS 00
    40      000    n
    41      002
    42      000
   ```
   <!-- input: 123 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=tell-odd-from-even-with-5n-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-14%3A%20take%202%20away%20from%20n%20until%20it%20goes%20negative%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20741%20%20%20%20SUB%2041%0A%2013%20%20%20%20%20%20315%20%20%20%20TAC%2015%0A%2014%20%20%20%20%20%20812%20%20%20%20JMP%2012%0A%2015%20%20%20%20%20%20200%20%20%20%20ADD%2000%20%20cells%2015-20%3A%20-1%20is%20left%20when%20n%20is%20odd%2C%20-2%20when%20it%20is%20even%0A%2016%20%20%20%20%20%20319%20%20%20%20TAC%2019%0A%2017%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20odd%3A%20print%201%0A%2018%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2019%20%20%20%20%20%20542%20%20%20%20OUT%2042%20%20even%3A%20print%200%0A%2020%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%20%20%20%20n%0A%2041%20%20%20%20%20%20002%0A%2042%20%20%20%20%20%20000%0A&in=123)

   Multiply by 5 instead. 5n ends in 0 when n is even and in 5 when n is odd, so every even number looks the same,
   and so does every odd one. Times 5 is four additions, and SFT 33 keeps only the last digit. Take away the 1 in
   cell 00, and 0 goes negative while 5 doesn't. The accumulator holds four digits, so 5n fits for any n up to 999.
   There's a bonus, too: the same 5n with SFT 01 is half of n, rounded down, so a program that halves n and tests it
   for odd does both with one multiply.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-16: 5n ends in 5 when n is odd and in 0 when it is even; SFT 33 keeps that digit
    11      140    CLA 40
    12      240    ADD 40
    13      240    ADD 40
    14      240    ADD 40
    15      240    ADD 40
    16      433    SFT 33
    17      700    SUB 00  cells 17-22: 0 - 1 is negative, 5 - 1 isn't
    18      321    TAC 21
    19      500    OUT 00  odd: print 1
    20      900    HRS 00
    21      541    OUT 41  even: print 0
    22      900    HRS 00
    40      000    n
    41      000
   ```
   <!-- input: 123 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=tell-odd-from-even-with-5n-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-16%3A%205n%20ends%20in%205%20when%20n%20is%20odd%20and%20in%200%20when%20it%20is%20even%3B%20SFT%2033%20keeps%20that%20digit%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20240%20%20%20%20ADD%2040%0A%2013%20%20%20%20%20%20240%20%20%20%20ADD%2040%0A%2014%20%20%20%20%20%20240%20%20%20%20ADD%2040%0A%2015%20%20%20%20%20%20240%20%20%20%20ADD%2040%0A%2016%20%20%20%20%20%20433%20%20%20%20SFT%2033%0A%2017%20%20%20%20%20%20700%20%20%20%20SUB%2000%20%20cells%2017-22%3A%200%20-%201%20is%20negative%2C%205%20-%201%20isn%27t%0A%2018%20%20%20%20%20%20321%20%20%20%20TAC%2021%0A%2019%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20odd%3A%20print%201%0A%2020%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2021%20%20%20%20%20%20541%20%20%20%20OUT%2041%20%20even%3A%20print%200%0A%2022%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%20%20%20%20n%0A%2041%20%20%20%20%20%20000%0A&in=123)

   Both say 123 is odd. Walking takes 14 cells and runs 191 instructions; 5n takes 15 cells and runs 11, the same 11
   for every n.

   On a binary machine the odd test is cheaper still, because evenness lives in the lowest bit. Testing n & 1 tells
   you, a shift right by one halves n, and compilers turn n % 2 and n / 2 into those for you, with a small correction
   when n might be negative. Swapping an expensive operation for a cheap one like this is called strength reduction.
   5n is the decimal version of the same idea. Since 10 is 2 times 5, multiplying by 5 moves the halving and the
   oddness into whole digits, where SFT can reach them.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=lay-a-table-out-in-decimal-the-address-is-the-digits-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20046%20%20%20%20INP%2046%20%20cells%2010-21%3A%20the%20entry%20for%20row%20P%2C%20column%20R%20is%20in%20cell%2040%20%2B%203P%20%2B%20R%0A%2011%20%20%20%20%20%20047%20%20%20%20INP%2047%0A%2012%20%20%20%20%20%20146%20%20%20%20CLA%2046%0A%2013%20%20%20%20%20%20246%20%20%20%20ADD%2046%20%203P%3A%20two%20adds%2C%20and%20one%20more%20for%20every%20column%20a%20row%20has%0A%2014%20%20%20%20%20%20246%20%20%20%20ADD%2046%0A%2015%20%20%20%20%20%20247%20%20%20%20ADD%2047%0A%2016%20%20%20%20%20%20249%20%20%20%20ADD%2049%20%20add%20CLA%2040%0A%2017%20%20%20%20%20%20618%20%20%20%20STO%2018%0A%2018%20%20%20%20%20%20100%20%20%20%20CLA%2000%20%20CLA%2040%20%2B%203P%20%2B%20R%2C%20written%20by%20the%20cell%20before%0A%2019%20%20%20%20%20%20648%20%20%20%20STO%2048%0A%2020%20%20%20%20%20%20548%20%20%20%20OUT%2048%0A%2021%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20101%20%20%20%20cells%2040-45%3A%20rows%200%20and%201%2C%20packed%20tight%0A%2041%20%20%20%20%20%20102%0A%2042%20%20%20%20%20%20103%0A%2043%20%20%20%20%20%20201%0A%2044%20%20%20%20%20%20202%0A%2045%20%20%20%20%20%20203%0A%2046%20%20%20%20%20%20000%0A%2047%20%20%20%20%20%20000%0A%2048%20%20%20%20%20%20000%0A%2049%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A&in=1%201)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=lay-a-table-out-in-decimal-the-address-is-the-digits-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20043%20%20%20%20INP%2043%20%20cells%2010-20%3A%20the%20entry%20for%20row%20P%2C%20column%20R%20is%20in%20cell%2040%20%2B%2010P%20%2B%20R%0A%2011%20%20%20%20%20%20044%20%20%20%20INP%2044%0A%2012%20%20%20%20%20%20143%20%20%20%20CLA%2043%0A%2013%20%20%20%20%20%20410%20%20%20%20SFT%2010%20%2010P%3A%20one%20shift%2C%20however%20wide%20the%20rows%0A%2014%20%20%20%20%20%20244%20%20%20%20ADD%2044%0A%2015%20%20%20%20%20%20246%20%20%20%20ADD%2046%20%20add%20CLA%2040%0A%2016%20%20%20%20%20%20617%20%20%20%20STO%2017%0A%2017%20%20%20%20%20%20100%20%20%20%20CLA%2000%20%20CLA%2040%20%2B%2010P%20%2B%20R%2C%20written%20by%20the%20cell%20before%0A%2018%20%20%20%20%20%20645%20%20%20%20STO%2045%0A%2019%20%20%20%20%20%20545%20%20%20%20OUT%2045%0A%2020%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20101%20%20%20%20cells%2040-52%3A%20rows%200%20and%201%2C%20ten%20cells%20apart%0A%2041%20%20%20%20%20%20102%0A%2042%20%20%20%20%20%20103%0A%2043%20%20%20%20%20%20000%20%20%20%20cells%2043-49%20between%20the%20rows%20hold%20the%20variables%3A%20P%0A%2044%20%20%20%20%20%20000%20%20%20%20R%0A%2045%20%20%20%20%20%20000%20%20%20%20the%20entry%0A%2046%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2050%20%20%20%20%20%20201%0A%2051%20%20%20%20%20%20202%0A%2052%20%20%20%20%20%20203%0A&in=1%201)

   <!-- maps -->

   Both look up row 1, column 1 and print 202. The packed table takes 22 cells and runs 12 instructions; the decimal
   one takes 21 cells and runs 11, and the gap grows with every column you add.

   Binary machines pad tables the same way, to powers of two. A C array whose rows are 8 or 16 elements wide is
   indexed with a shift, and x86 goes a step further, since an address can include an index register scaled by 1, 2,
   4 or 8, so the scaling costs nothing at all.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=add-500-to-turn-an-instruction-into-its-partner-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-12%3A%20add%20the%20cards%20with%20alternating%20signs%20until%20a%20negative%20one%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20326%20%20%20%20TAC%2026%0A%2013%20%20%20%20%20%20142%20%20%20%20CLA%2042%20%20cells%2013-21%3A%20which%20way%20this%20time%3F%20test%20a%20flag%0A%2014%20%20%20%20%20%20319%20%20%20%20TAC%2019%0A%2015%20%20%20%20%20%20141%20%20%20%20CLA%2041%0A%2016%20%20%20%20%20%20240%20%20%20%20ADD%2040%0A%2017%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2018%20%20%20%20%20%20822%20%20%20%20JMP%2022%0A%2019%20%20%20%20%20%20141%20%20%20%20CLA%2041%0A%2020%20%20%20%20%20%20740%20%20%20%20SUB%2040%0A%2021%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2022%20%20%20%20%20%20143%20%20%20%20CLA%2043%20%20cells%2022-27%3A%20swap%20the%20flag%2C%20-1%20-%20sign%0A%2023%20%20%20%20%20%20742%20%20%20%20SUB%2042%0A%2024%20%20%20%20%20%20642%20%20%20%20STO%2042%0A%2025%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2026%20%20%20%20%20%20541%20%20%20%20OUT%2041%0A%2027%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A%2042%20%20%20%20%20%20000%20%20%20%200%3A%20add%2C%20-1%3A%20subtract%0A%2043%20%20%20%20%20-001%0A&in=5%203%204%20-1)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=add-500-to-turn-an-instruction-into-its-partner-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-21%3A%20add%20the%20cards%20with%20alternating%20signs%20until%20a%20negative%20one%0A%2011%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2012%20%20%20%20%20%20320%20%20%20%20TAC%2020%0A%2013%20%20%20%20%20%20141%20%20%20%20CLA%2041%0A%2014%20%20%20%20%20%20240%20%20%20%20ADD%2040%20%20becomes%20SUB%2C%20then%20ADD%20again%0A%2015%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2016%20%20%20%20%20%20114%20%20%20%20CLA%2014%0A%2017%20%20%20%20%20%20242%20%20%20%20ADD%2042%20%20add%20500%20to%20cell%2014%0A%2018%20%20%20%20%20%20614%20%20%20%20STO%2014%0A%2019%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2020%20%20%20%20%20%20541%20%20%20%20OUT%2041%0A%2021%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2040%20%20%20%20%20%20000%0A%2041%20%20%20%20%20%20000%0A%2042%20%20%20%20%20%20500%0A&in=5%203%204%20-1)

   Both work out 5 - 3 + 4 and print 6. The flag takes 22 cells and runs 43 instructions; adding 500 takes 15 cells
   and runs 35.

   Real instruction sets put partners side by side on purpose. On x86 each conditional jump sits next to its
   opposite, JE at 74 and JNE at 75 in hex, because Intel's manual defines the lowest bit of the condition as "use
   the negation". Flipping a branch is a one-bit change.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=sft-22-reads-the-address-out-of-an-instruction-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20130%20%20%20%20CLA%2030%20%20cells%2010-13%3A%20build%20OUT%2040%20%2B%20i%20from%20the%20counter%0A%2011%20%20%20%20%20%20232%20%20%20%20ADD%2032%0A%2012%20%20%20%20%20%20613%20%20%20%20STO%2013%0A%2013%20%20%20%20%20%20500%20%20%20%20OUT%2000%20%20OUT%2040%20%2B%20i%2C%20written%20by%20the%20cell%20before%0A%2014%20%20%20%20%20%20130%20%20%20%20CLA%2030%20%20cells%2014-19%3A%20count%2C%20and%20stop%20at%204%0A%2015%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2016%20%20%20%20%20%20630%20%20%20%20STO%2030%0A%2017%20%20%20%20%20%20731%20%20%20%20SUB%2031%0A%2018%20%20%20%20%20%20310%20%20%20%20TAC%2010%0A%2019%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20the%20counter%2C%20kept%20in%20step%20with%20the%20instruction%0A%2031%20%20%20%20%20%20004%0A%2032%20%20%20%20%20%20540%20%20%20%20OUT%2040%0A%2040%20%20%20%20%20%20007%0A%2041%20%20%20%20%20%20003%0A%2042%20%20%20%20%20%20009%0A%2043%20%20%20%20%20%20001%0A)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=sft-22-reads-the-address-out-of-an-instruction-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20540%20%20%20%20OUT%2040%20%20cells%2010-17%3A%20print%20cells%2040-43%3B%20cell%2010%20is%20the%20pointer%0A%2011%20%20%20%20%20%20110%20%20%20%20CLA%2010%0A%2012%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2013%20%20%20%20%20%20610%20%20%20%20STO%2010%0A%2014%20%20%20%20%20%20422%20%20%20%20SFT%2022%20%20drop%20the%20opcode%3A%20just%20the%20address%0A%2015%20%20%20%20%20%20730%20%20%20%20SUB%2030%0A%2016%20%20%20%20%20%20310%20%20%20%20TAC%2010%0A%2017%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20044%20%20%20%20one%20past%20the%20end%0A%2040%20%20%20%20%20%20007%0A%2041%20%20%20%20%20%20003%0A%2042%20%20%20%20%20%20009%0A%2043%20%20%20%20%20%20001%0A)

   Both print 7, 3, 9 and 1. Keeping a counter takes 17 cells and runs 37 instructions; using the instruction as the
   pointer takes 13 cells and runs 29.

   Early stored-program computers walked tables by rewriting their own addresses too. The Manchester Mark 1 added
   what it called B-lines in 1949, registers whose contents were added to an instruction's address as it ran, and
   they're known today as index registers. They and the addressing modes built on them, like the PDP-11's
   autoincrement, which steps a pointer each time it's used, do in hardware what this tip does by hand.

4. **Add the case number to a JMP.** Say you're writing a little calculator. Each card is a command from 0 to 4: add
   1, take 1 away, double, times ten, or print the total.

   You'd probably find out which command it is one question at a time: take 1 away and test, take 1 away and test.
   The commands at the front are cheap, but each one further down pays for all the questions before it.

   ```
   cell  contents  notes
    10      050    INP 50  cells 10-12: read commands until a negative one
    11      150    CLA 50
    12      339    TAC 39
    13      700    SUB 00  cells 13-20: which command? one SUB and one TAC for each
    14      323    TAC 23
    15      700    SUB 00
    16      327    TAC 27
    17      700    SUB 00
    18      331    TAC 31
    19      700    SUB 00
    20      335    TAC 35
    21      551    OUT 51  cells 21-22: command 4: print the total
    22      810    JMP 10
    23      151    CLA 51  cells 23-26: command 0: add 1
    24      200    ADD 00
    25      651    STO 51
    26      810    JMP 10
    27      151    CLA 51  cells 27-30: command 1: take 1 away
    28      700    SUB 00
    29      651    STO 51
    30      810    JMP 10
    31      151    CLA 51  cells 31-34: command 2: double
    32      251    ADD 51
    33      651    STO 51
    34      810    JMP 10
    35      151    CLA 51  cells 35-38: command 3: times ten
    36      410    SFT 10
    37      651    STO 51
    38      810    JMP 10
    39      900    HRS 00
    50      000    the command
    51      000    the total
   ```
   <!-- input: 0 0 2 3 1 4 -1 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=add-the-case-number-to-a-jmp-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20050%20%20%20%20INP%2050%20%20cells%2010-12%3A%20read%20commands%20until%20a%20negative%20one%0A%2011%20%20%20%20%20%20150%20%20%20%20CLA%2050%0A%2012%20%20%20%20%20%20339%20%20%20%20TAC%2039%0A%2013%20%20%20%20%20%20700%20%20%20%20SUB%2000%20%20cells%2013-20%3A%20which%20command%3F%20one%20SUB%20and%20one%20TAC%20for%20each%0A%2014%20%20%20%20%20%20323%20%20%20%20TAC%2023%0A%2015%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2016%20%20%20%20%20%20327%20%20%20%20TAC%2027%0A%2017%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2018%20%20%20%20%20%20331%20%20%20%20TAC%2031%0A%2019%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2020%20%20%20%20%20%20335%20%20%20%20TAC%2035%0A%2021%20%20%20%20%20%20551%20%20%20%20OUT%2051%20%20cells%2021-22%3A%20command%204%3A%20print%20the%20total%0A%2022%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2023%20%20%20%20%20%20151%20%20%20%20CLA%2051%20%20cells%2023-26%3A%20command%200%3A%20add%201%0A%2024%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2025%20%20%20%20%20%20651%20%20%20%20STO%2051%0A%2026%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2027%20%20%20%20%20%20151%20%20%20%20CLA%2051%20%20cells%2027-30%3A%20command%201%3A%20take%201%20away%0A%2028%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2029%20%20%20%20%20%20651%20%20%20%20STO%2051%0A%2030%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2031%20%20%20%20%20%20151%20%20%20%20CLA%2051%20%20cells%2031-34%3A%20command%202%3A%20double%0A%2032%20%20%20%20%20%20251%20%20%20%20ADD%2051%0A%2033%20%20%20%20%20%20651%20%20%20%20STO%2051%0A%2034%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2035%20%20%20%20%20%20151%20%20%20%20CLA%2051%20%20cells%2035-38%3A%20command%203%3A%20times%20ten%0A%2036%20%20%20%20%20%20410%20%20%20%20SFT%2010%0A%2037%20%20%20%20%20%20651%20%20%20%20STO%2051%0A%2038%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2039%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2050%20%20%20%20%20%20000%20%20%20%20the%20command%0A%2051%20%20%20%20%20%20000%20%20%20%20the%20total%0A&in=0%200%202%203%201%204%20-1)

   Instead, jump straight to the command's code. Lay the commands out ten cells apart, so command k starts at cell 20
   + 10k. SFT 10 makes 10k, adding JMP 20 makes the jump, and storing it in the next cell runs it. It's the same
   addition that reads an entry in "Lay a table out in decimal", aimed at code instead of data, and the gaps between
   the commands hold the variables, just as they do there. When the cases don't fit ten cells apart, add k to a JMP
   aimed at a table of JMPs, one for each case. Brian L. Stuart's
   [CARDIAC page](https://www.cs.drexel.edu/~bls96/museum/cardiac.html) shows the same addition for reaching element
   i of an array, with CLA and STO.

   ```
   cell  contents  notes
    10      025    INP 25  cells 10-12: read commands until a negative one
    11      125    CLA 25
    12      317    TAC 17
    13      410    SFT 10  cells 13-16: command k starts at cell 20 + 10k, so add 10k to JMP 20 and run it
    14      227    ADD 27
    15      616    STO 16
    16      800    JMP 00  JMP 20 + 10k, written by the cell before
    17      900    HRS 00
    20      126    CLA 26  cells 20-23: command 0: add 1
    21      200    ADD 00
    22      626    STO 26
    23      810    JMP 10
    25      000    cells 25-27, in the gap: the command, the total, and JMP 20
    26      000
    27      820    JMP 20
    30      126    CLA 26  cells 30-33: command 1: take 1 away
    31      700    SUB 00
    32      626    STO 26
    33      810    JMP 10
    40      126    CLA 26  cells 40-43: command 2: double
    41      226    ADD 26
    42      626    STO 26
    43      810    JMP 10
    50      126    CLA 26  cells 50-53: command 3: times ten
    51      410    SFT 10
    52      626    STO 26
    53      810    JMP 10
    60      526    OUT 26  cells 60-61: command 4: print the total
    61      810    JMP 10
   ```
   <!-- input: 0 0 2 3 1 4 -1 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=add-the-case-number-to-a-jmp-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20025%20%20%20%20INP%2025%20%20cells%2010-12%3A%20read%20commands%20until%20a%20negative%20one%0A%2011%20%20%20%20%20%20125%20%20%20%20CLA%2025%0A%2012%20%20%20%20%20%20317%20%20%20%20TAC%2017%0A%2013%20%20%20%20%20%20410%20%20%20%20SFT%2010%20%20cells%2013-16%3A%20command%20k%20starts%20at%20cell%2020%20%2B%2010k%2C%20so%20add%2010k%20to%20JMP%2020%20and%20run%20it%0A%2014%20%20%20%20%20%20227%20%20%20%20ADD%2027%0A%2015%20%20%20%20%20%20616%20%20%20%20STO%2016%0A%2016%20%20%20%20%20%20800%20%20%20%20JMP%2000%20%20JMP%2020%20%2B%2010k%2C%20written%20by%20the%20cell%20before%0A%2017%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2020%20%20%20%20%20%20126%20%20%20%20CLA%2026%20%20cells%2020-23%3A%20command%200%3A%20add%201%0A%2021%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2022%20%20%20%20%20%20626%20%20%20%20STO%2026%0A%2023%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2025%20%20%20%20%20%20000%20%20%20%20cells%2025-27%2C%20in%20the%20gap%3A%20the%20command%2C%20the%20total%2C%20and%20JMP%2020%0A%2026%20%20%20%20%20%20000%0A%2027%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2030%20%20%20%20%20%20126%20%20%20%20CLA%2026%20%20cells%2030-33%3A%20command%201%3A%20take%201%20away%0A%2031%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2032%20%20%20%20%20%20626%20%20%20%20STO%2026%0A%2033%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2040%20%20%20%20%20%20126%20%20%20%20CLA%2026%20%20cells%2040-43%3A%20command%202%3A%20double%0A%2041%20%20%20%20%20%20226%20%20%20%20ADD%2026%0A%2042%20%20%20%20%20%20626%20%20%20%20STO%2026%0A%2043%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2050%20%20%20%20%20%20126%20%20%20%20CLA%2026%20%20cells%2050-53%3A%20command%203%3A%20times%20ten%0A%2051%20%20%20%20%20%20410%20%20%20%20SFT%2010%0A%2052%20%20%20%20%20%20626%20%20%20%20STO%2026%0A%2053%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2060%20%20%20%20%20%20526%20%20%20%20OUT%2026%20%20cells%2060-61%3A%20command%204%3A%20print%20the%20total%0A%2061%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A&in=0%200%202%203%201%204%20-1)

   Both print 39. Asking takes 32 cells and runs 74 instructions; jumping takes 29 cells and runs 68. With the jump,
   every command costs 11 instructions, or 9 for print, wherever it is in the list. With the questions it's anywhere
   from 9 to 15, and each command you add makes the ones after it dearer. One caution: the jump trusts the card. A
   command of 5 would land on cell 70, where there's nothing, so if the cards might be wrong, check the range first.

   This is how compilers lower a dense switch statement. GCC and LLVM build a table of addresses and index it with
   the case value, after a range check that sends anything outside the cases to the default, which is the caution
   above. When the cases are spread out, they use a tree of comparisons instead, much like the first version.

## Subroutines: JMP leaves the way back

CARDIAC has no call and no return. What it has is JMP, which writes a jump back to the cell after it into cell 99
before it jumps, and that turns out to be all a subroutine needs.

1. **Subroutines and recursion.** Say you need the same small job, doubling a number and printing it, in two places
   in your program.

   CARDIAC has no call instruction, but JMP does half the work. It writes 8 and the address of the cell after it into
   cell 99, so JMP 20 in cell 11 leaves 812 there, which is JMP 12, the way back. The trouble is keeping it, because
   the next JMP overwrites cell 99, and you can't simply JMP 99 to return, because that JMP would write its own way
   back into cell 99 before it got there.

   ARM and MIPS still call this way. ARM's BL leaves the return address in a register called the link register, LR,
   and MIPS's jal leaves it in $ra, with no stack involved. A leaf function, one that calls nothing else, returns
   straight through it, and a function that makes calls of its own saves it first, which is the choice this tip is
   about.

   #### The stack is expensive

   Ask most programmers where a way back belongs, and they'll say on a stack. So the routine pushes cell 99 as soon
   as it starts, and pops it into its last cell just before it runs into it. The stack is Brian L. Stuart's, from his
   [CARDIAC page](https://www.cs.drexel.edu/~bls96/museum/cardiac.html): he keeps the top of the stack as an address,
   and adds it to STO 00 to push or to CLA 00 to pop. Here cell 50 keeps the STO itself, so a push only has to copy
   it and add 1, and subtracting 500 turns it into the CLA that reads the top back.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-14: two calls; each JMP leaves its way back in cell 99
    11      820    JMP 20
    12      040    INP 40
    13      820    JMP 20
    14      900    HRS 00
    20      150    CLA 50  cells 20-25: push cell 99; cell 50 is the STO to the stack's top
    21      625    STO 25
    22      200    ADD 00
    23      650    STO 50
    24      199    CLA 99
    25      600    STO 00  STO to the top, written by cell 21
    26      140    CLA 40  cells 26-29: double x and print it
    27      240    ADD 40
    28      641    STO 41
    29      541    OUT 41
    30      150    CLA 50  cells 30-37: pop the way back into cell 37 and run it; CLA is STO minus 500
    31      700    SUB 00
    32      650    STO 50
    33      751    SUB 51
    34      635    STO 35
    35      100    CLA 00  the way back, read from the stack
    36      637    STO 37
    37      000    the way back, popped into place
    40      000    x
    41      000
    50      652    STO 52
    51      500
    52      000    the stack
   ```
   <!-- input: 3 4 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=subroutines-and-recursion-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-14%3A%20two%20calls%3B%20each%20JMP%20leaves%20its%20way%20back%20in%20cell%2099%0A%2011%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2012%20%20%20%20%20%20040%20%20%20%20INP%2040%0A%2013%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2014%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2020%20%20%20%20%20%20150%20%20%20%20CLA%2050%20%20cells%2020-25%3A%20push%20cell%2099%3B%20cell%2050%20is%20the%20STO%20to%20the%20stack%27s%20top%0A%2021%20%20%20%20%20%20625%20%20%20%20STO%2025%0A%2022%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2023%20%20%20%20%20%20650%20%20%20%20STO%2050%0A%2024%20%20%20%20%20%20199%20%20%20%20CLA%2099%0A%2025%20%20%20%20%20%20600%20%20%20%20STO%2000%20%20STO%20to%20the%20top%2C%20written%20by%20cell%2021%0A%2026%20%20%20%20%20%20140%20%20%20%20CLA%2040%20%20cells%2026-29%3A%20double%20x%20and%20print%20it%0A%2027%20%20%20%20%20%20240%20%20%20%20ADD%2040%0A%2028%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2029%20%20%20%20%20%20541%20%20%20%20OUT%2041%0A%2030%20%20%20%20%20%20150%20%20%20%20CLA%2050%20%20cells%2030-37%3A%20pop%20the%20way%20back%20into%20cell%2037%20and%20run%20it%3B%20CLA%20is%20STO%20minus%20500%0A%2031%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2032%20%20%20%20%20%20650%20%20%20%20STO%2050%0A%2033%20%20%20%20%20%20751%20%20%20%20SUB%2051%0A%2034%20%20%20%20%20%20635%20%20%20%20STO%2035%0A%2035%20%20%20%20%20%20100%20%20%20%20CLA%2000%20%20the%20way%20back%2C%20read%20from%20the%20stack%0A%2036%20%20%20%20%20%20637%20%20%20%20STO%2037%0A%2037%20%20%20%20%20%20000%20%20%20%20the%20way%20back%2C%20popped%20into%20place%0A%2040%20%20%20%20%20%20000%20%20%20%20x%0A%2041%20%20%20%20%20%20000%0A%2050%20%20%20%20%20%20652%20%20%20%20STO%2052%0A%2051%20%20%20%20%20%20500%0A%2052%20%20%20%20%20%20000%20%20%20%20the%20stack%0A&in=3%204)

   It works, but look at the price on a machine with a hundred cells. Pushing runs 6 instructions and popping 7, so
   every call costs 13 instructions before the routine does anything. The routine spends 14 cells on pushing, popping
   and its way back, and the pointer, the 500 and the stack take 3 more, one stack cell for every call that can be
   under way at once.

   #### A more economical way

   A routine that never calls itself only ever has one way back to keep, and it doesn't need a stack for that. The
   stackless way is to copy cell 99 into the routine's own last cell as soon as it starts, and let the routine run
   into it at the end. The copy comes first because any JMP inside the routine, in a loop or a call to another
   routine, overwrites cell 99, and by then the copy is safe. Routines can call each other this way, since each one
   keeps its own way back in its own cell. It still costs something: three cells in every routine, two for CLA 99 and
   STO and one to hold the way back, and two instructions every call. If the routine's argument arrives in the
   accumulator, it has to be stored before CLA 99, which can cost one more. Brian Stuart's page builds its routines
   this way too, before it gets to the stack.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-14: two calls; each JMP leaves its way back in cell 99
    11      820    JMP 20
    12      040    INP 40
    13      820    JMP 20
    14      900    HRS 00
    20      199    CLA 99  cells 20-26: copy cell 99 into the routine's last cell, then double x and print it
    21      626    STO 26
    22      140    CLA 40
    23      240    ADD 40
    24      641    STO 41
    25      541    OUT 41
    26      000    the way back, copied from cell 99
    40      000    x
    41      000
   ```
   <!-- input: 3 4 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=subroutines-and-recursion-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-14%3A%20two%20calls%3B%20each%20JMP%20leaves%20its%20way%20back%20in%20cell%2099%0A%2011%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2012%20%20%20%20%20%20040%20%20%20%20INP%2040%0A%2013%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2014%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2020%20%20%20%20%20%20199%20%20%20%20CLA%2099%20%20cells%2020-26%3A%20copy%20cell%2099%20into%20the%20routine%27s%20last%20cell%2C%20then%20double%20x%20and%20print%20it%0A%2021%20%20%20%20%20%20626%20%20%20%20STO%2026%0A%2022%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2023%20%20%20%20%20%20240%20%20%20%20ADD%2040%0A%2024%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2025%20%20%20%20%20%20541%20%20%20%20OUT%2041%0A%2026%20%20%20%20%20%20000%20%20%20%20the%20way%20back%2C%20copied%20from%20cell%2099%0A%2040%20%20%20%20%20%20000%20%20%20%20x%0A%2041%20%20%20%20%20%20000%0A&in=3%204)

   <!-- maps -->

   Both print 6 and 8. The stack takes 28 cells and runs 41 instructions; stackless takes 14 cells and runs 19.
   That's 17 cells of linkage against 3, and 13 instructions a call against 2.

   The PDP-8 built the stackless way into its call instruction. JMS stores the way back in the first word of the
   routine and starts it at the second, and the routine returns with an indirect jump through that word, so its
   routines couldn't call themselves without help either.

   What stackless gives up is recursion. A routine that calls itself overwrites its own copy, and the outer call
   loses its way back, and two routines that call each other do the same to each other. The exception is a call
   that's the last thing the routine does. There's nothing left to come back for, so the call can be a jump back to
   the routine's start, and the way back it copied first is still in its cell. Compilers call this tail-call
   elimination, and Scheme's standard requires it, so a loop can be written as a function that calls itself last
   without ever running out of stack.

   So the question to ask of every routine is whether it can be called again before it has returned, other than as
   the last thing it does. If it can't, stackless does the job in a fraction of the cells and instructions. If it
   can, nothing short of a stack will do.

   | If | Reach for |
   | --- | --- |
   | A routine calls itself anywhere but at the end | A stack |
   | Two routines call each other anywhere but at their ends | A stack |
   | A routine calls itself as the last thing it does | No stack: jump back to its start |
   | Two routines call each other only at their ends | No stack: merge them into one routine, and jump |
   | Routines call other routines, but never back up the chain | Stackless: copy cell 99 |
   | A routine runs inside a loop and every instruction counts | Stackless: 2 instructions a call, not 13 |
   | Cells are tight | Stackless: 3 cells a routine, not 14 plus the stack |
   | A routine only returns when the accumulator is negative | Stackless with no copy at all: return with TAC 99, the next tip |

2. **Return with TAC 99 when the accumulator is negative.** Say a routine adds a reading to a running total, but a
   negative reading means there was nothing to read, and it should be skipped.

   Done as in the last tip, the routine copies cell 99 first thing and returns through the copy, and a skipped
   reading jumps straight to the copy.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-18: four readings, each handed to the routine; then print the total
    11      820    JMP 20
    12      040    INP 40
    13      820    JMP 20
    14      040    INP 40
    15      820    JMP 20
    16      040    INP 40
    17      820    JMP 20
    18      541    OUT 41
    19      900    HRS 00
    20      199    CLA 99  cells 20-26: copy the way back first, then add the reading unless it is negative
    21      626    STO 26
    22      140    CLA 40
    23      326    TAC 26  negative: skip it and go back
    24      241    ADD 41
    25      641    STO 41
    26      000    the way back, copied from cell 99
    40      000    the reading
    41      000    the total
   ```
   <!-- input: 5 -1 7 -3 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=return-with-tac-99-when-the-accumulator-is-negative-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-18%3A%20four%20readings%2C%20each%20handed%20to%20the%20routine%3B%20then%20print%20the%20total%0A%2011%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2012%20%20%20%20%20%20040%20%20%20%20INP%2040%0A%2013%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2014%20%20%20%20%20%20040%20%20%20%20INP%2040%0A%2015%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2016%20%20%20%20%20%20040%20%20%20%20INP%2040%0A%2017%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2018%20%20%20%20%20%20541%20%20%20%20OUT%2041%0A%2019%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2020%20%20%20%20%20%20199%20%20%20%20CLA%2099%20%20cells%2020-26%3A%20copy%20the%20way%20back%20first%2C%20then%20add%20the%20reading%20unless%20it%20is%20negative%0A%2021%20%20%20%20%20%20626%20%20%20%20STO%2026%0A%2022%20%20%20%20%20%20140%20%20%20%20CLA%2040%0A%2023%20%20%20%20%20%20326%20%20%20%20TAC%2026%20%20negative%3A%20skip%20it%20and%20go%20back%0A%2024%20%20%20%20%20%20241%20%20%20%20ADD%2041%0A%2025%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2026%20%20%20%20%20%20000%20%20%20%20the%20way%20back%2C%20copied%20from%20cell%2099%0A%2040%20%20%20%20%20%20000%20%20%20%20the%20reading%0A%2041%20%20%20%20%20%20000%20%20%20%20the%20total%0A&in=5%20-1%207%20-3)

   TAC doesn't write cell 99; only JMP does. So when the accumulator is negative, TAC 99 goes straight back to the
   caller, and here the accumulator is negative exactly when the reading should be skipped. The test that skips it is
   the return. The copy moves down to the one path that still needs it, and a skipped reading never pays for it.

   ```
   cell  contents  notes
    10      040    INP 40  cells 10-18: four readings, each handed to the routine; then print the total
    11      820    JMP 20
    12      040    INP 40
    13      820    JMP 20
    14      040    INP 40
    15      820    JMP 20
    16      040    INP 40
    17      820    JMP 20
    18      541    OUT 41
    19      900    HRS 00
    20      140    CLA 40  cells 20-21: a negative reading returns at once; TAC leaves cell 99 alone
    21      399    TAC 99
    22      241    ADD 41  cells 22-26: otherwise add it, and only now copy the way back
    23      641    STO 41
    24      199    CLA 99
    25      626    STO 26
    26      000    the way back, copied from cell 99
    40      000    the reading
    41      000    the total
   ```
   <!-- input: 5 -1 7 -3 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=return-with-tac-99-when-the-accumulator-is-negative-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2010-18%3A%20four%20readings%2C%20each%20handed%20to%20the%20routine%3B%20then%20print%20the%20total%0A%2011%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2012%20%20%20%20%20%20040%20%20%20%20INP%2040%0A%2013%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2014%20%20%20%20%20%20040%20%20%20%20INP%2040%0A%2015%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2016%20%20%20%20%20%20040%20%20%20%20INP%2040%0A%2017%20%20%20%20%20%20820%20%20%20%20JMP%2020%0A%2018%20%20%20%20%20%20541%20%20%20%20OUT%2041%0A%2019%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2020%20%20%20%20%20%20140%20%20%20%20CLA%2040%20%20cells%2020-21%3A%20a%20negative%20reading%20returns%20at%20once%3B%20TAC%20leaves%20cell%2099%20alone%0A%2021%20%20%20%20%20%20399%20%20%20%20TAC%2099%0A%2022%20%20%20%20%20%20241%20%20%20%20ADD%2041%20%20cells%2022-26%3A%20otherwise%20add%20it%2C%20and%20only%20now%20copy%20the%20way%20back%0A%2023%20%20%20%20%20%20641%20%20%20%20STO%2041%0A%2024%20%20%20%20%20%20199%20%20%20%20CLA%2099%0A%2025%20%20%20%20%20%20626%20%20%20%20STO%2026%0A%2026%20%20%20%20%20%20000%20%20%20%20the%20way%20back%2C%20copied%20from%20cell%2099%0A%2040%20%20%20%20%20%20000%20%20%20%20the%20reading%0A%2041%20%20%20%20%20%20000%20%20%20%20the%20total%0A&in=5%20-1%207%20-3)

   Both add up 5 and 7 and print 12, and both take 19 cells. Copying first runs 34 instructions, and returning with
   TAC runs 30, two fewer for every reading skipped. A routine that ends negative on every path never has to copy
   cell 99 at all, which is why some programs go as far as storing their data as negative numbers. Cell 99 as the way
   back is the subroutine technique Brian L. Stuart's
   [CARDIAC page](https://www.cs.drexel.edu/~bls96/museum/cardiac.html) shows, and TAC 99 is a small variation on it.

   The Intel 8080 has this as one instruction. RM, return if minus, returns when the sign flag is set and otherwise
   carries on, and the Z80 kept it as RET M.

3. **Call a routine through its address.** Say you want to apply a function to each card in a stack, and the first
   card says which function: double, or times ten.

   The usual way is to pass a number saying which function you want, and test it before every call. That's a test for
   every card, and another for every function you add.

   ```
   cell  contents  notes
    10      030    INP 30  cell 10: which function: 0 for double, -1 for times ten
    11      031    INP 31  cells 11-13: each card until a negative one
    12      131    CLA 31
    13      322    TAC 22
    14      130    CLA 30  cells 14-18: test the choice, then call one function or the other
    15      318    TAC 18
    16      840    JMP 40
    17      819    JMP 19
    18      845    JMP 45
    19      632    STO 32  cells 19-22: print what came back
    20      532    OUT 32
    21      811    JMP 11
    22      900    HRS 00
    30      000    the choice
    31      000    the card
    32      000
    40      199    CLA 99  cells 40-44: double the card
    41      644    STO 44
    42      131    CLA 31
    43      231    ADD 31
    44      000    the way back
    45      199    CLA 99  cells 45-49: ten times the card
    46      649    STO 49
    47      131    CLA 31
    48      410    SFT 10
    49      000    the way back
   ```
   <!-- input: 0 3 5 -1 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=call-a-routine-through-its-address-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cell%2010%3A%20which%20function%3A%200%20for%20double%2C%20-1%20for%20times%20ten%0A%2011%20%20%20%20%20%20031%20%20%20%20INP%2031%20%20cells%2011-13%3A%20each%20card%20until%20a%20negative%20one%0A%2012%20%20%20%20%20%20131%20%20%20%20CLA%2031%0A%2013%20%20%20%20%20%20322%20%20%20%20TAC%2022%0A%2014%20%20%20%20%20%20130%20%20%20%20CLA%2030%20%20cells%2014-18%3A%20test%20the%20choice%2C%20then%20call%20one%20function%20or%20the%20other%0A%2015%20%20%20%20%20%20318%20%20%20%20TAC%2018%0A%2016%20%20%20%20%20%20840%20%20%20%20JMP%2040%0A%2017%20%20%20%20%20%20819%20%20%20%20JMP%2019%0A%2018%20%20%20%20%20%20845%20%20%20%20JMP%2045%0A%2019%20%20%20%20%20%20632%20%20%20%20STO%2032%20%20cells%2019-22%3A%20print%20what%20came%20back%0A%2020%20%20%20%20%20%20532%20%20%20%20OUT%2032%0A%2021%20%20%20%20%20%20811%20%20%20%20JMP%2011%0A%2022%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20the%20choice%0A%2031%20%20%20%20%20%20000%20%20%20%20the%20card%0A%2032%20%20%20%20%20%20000%0A%2040%20%20%20%20%20%20199%20%20%20%20CLA%2099%20%20cells%2040-44%3A%20double%20the%20card%0A%2041%20%20%20%20%20%20644%20%20%20%20STO%2044%0A%2042%20%20%20%20%20%20131%20%20%20%20CLA%2031%0A%2043%20%20%20%20%20%20231%20%20%20%20ADD%2031%0A%2044%20%20%20%20%20%20000%20%20%20%20the%20way%20back%0A%2045%20%20%20%20%20%20199%20%20%20%20CLA%2099%20%20cells%2045-49%3A%20ten%20times%20the%20card%0A%2046%20%20%20%20%20%20649%20%20%20%20STO%2049%0A%2047%20%20%20%20%20%20131%20%20%20%20CLA%2031%0A%2048%20%20%20%20%20%20410%20%20%20%20SFT%2010%0A%2049%20%20%20%20%20%20000%20%20%20%20the%20way%20back%0A&in=0%203%205%20-1)

   On CARDIAC a routine is just the address of its first cell, so pass the address itself. JMP 00 is 800, and adding
   the address to it makes the call, JMP 40 or JMP 45. Store it once, before the loop, and every card after that goes
   straight to the right function. The loop doesn't know or care how many functions there are, and a function written
   later works without changing it.

   ```
   cell  contents  notes
    10      030    INP 30  cells 10-13: the function is its address; JMP 00 plus the address is the call
    11      130    CLA 30
    12      233    ADD 33
    13      617    STO 17
    14      031    INP 31  cells 14-21: each card until a negative one: call the function, print what came back
    15      131    CLA 31
    16      321    TAC 21
    17      800    JMP 00  JMP f, written by cell 13
    18      632    STO 32
    19      532    OUT 32
    20      814    JMP 14
    21      900    HRS 00
    30      000    the function's address
    31      000    the card
    32      000
    33      800    JMP 00
    40      199    CLA 99  cells 40-44: double the card
    41      644    STO 44
    42      131    CLA 31
    43      231    ADD 31
    44      000    the way back
    45      199    CLA 99  cells 45-49: ten times the card
    46      649    STO 49
    47      131    CLA 31
    48      410    SFT 10
    49      000    the way back
   ```
   <!-- input: 40 3 5 -1 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=call-a-routine-through-its-address-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-13%3A%20the%20function%20is%20its%20address%3B%20JMP%2000%20plus%20the%20address%20is%20the%20call%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20233%20%20%20%20ADD%2033%0A%2013%20%20%20%20%20%20617%20%20%20%20STO%2017%0A%2014%20%20%20%20%20%20031%20%20%20%20INP%2031%20%20cells%2014-21%3A%20each%20card%20until%20a%20negative%20one%3A%20call%20the%20function%2C%20print%20what%20came%20back%0A%2015%20%20%20%20%20%20131%20%20%20%20CLA%2031%0A%2016%20%20%20%20%20%20321%20%20%20%20TAC%2021%0A%2017%20%20%20%20%20%20800%20%20%20%20JMP%2000%20%20JMP%20f%2C%20written%20by%20cell%2013%0A%2018%20%20%20%20%20%20632%20%20%20%20STO%2032%0A%2019%20%20%20%20%20%20532%20%20%20%20OUT%2032%0A%2020%20%20%20%20%20%20814%20%20%20%20JMP%2014%0A%2021%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%20%20%20%20the%20function%27s%20address%0A%2031%20%20%20%20%20%20000%20%20%20%20the%20card%0A%2032%20%20%20%20%20%20000%0A%2033%20%20%20%20%20%20800%20%20%20%20JMP%2000%0A%2040%20%20%20%20%20%20199%20%20%20%20CLA%2099%20%20cells%2040-44%3A%20double%20the%20card%0A%2041%20%20%20%20%20%20644%20%20%20%20STO%2044%0A%2042%20%20%20%20%20%20131%20%20%20%20CLA%2031%0A%2043%20%20%20%20%20%20231%20%20%20%20ADD%2031%0A%2044%20%20%20%20%20%20000%20%20%20%20the%20way%20back%0A%2045%20%20%20%20%20%20199%20%20%20%20CLA%2099%20%20cells%2045-49%3A%20ten%20times%20the%20card%0A%2046%20%20%20%20%20%20649%20%20%20%20STO%2049%0A%2047%20%20%20%20%20%20131%20%20%20%20CLA%2031%0A%2048%20%20%20%20%20%20410%20%20%20%20SFT%2010%0A%2049%20%20%20%20%20%20000%20%20%20%20the%20way%20back%0A&in=40%203%205%20-1)

   Doubling 3 and 5 prints 6 and 10 both ways. Testing takes 26 cells and runs 35 instructions; calling through the
   address takes 26 cells and runs 32. Each card costs 12 instructions instead of 14 or 15, and making the call costs
   3, once. The functions return through cell 99 as Brian L. Stuart's
   [CARDIAC page](https://www.cs.drexel.edu/~bls96/museum/cardiac.html) shows, and the call is built the way that
   page builds its indirect loads and stores, by adding an address to an instruction and running it.

   On any other machine you'd call this a function pointer. C's qsort takes its comparison this way, and a C++
   virtual call does the same with one more step, fetching the address from the object's table of functions, its
   vtable, and calling through it.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=cell-00-is-the-constant-1-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-18%3A%20count%20cards%20until%20a%20negative%20one%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20317%20%20%20%20TAC%2017%0A%2013%20%20%20%20%20%20131%20%20%20%20CLA%2031%0A%2014%20%20%20%20%20%20232%20%20%20%20ADD%2032%20%20count%20%2B%201%2C%20from%20a%20cell%20holding%201%0A%2015%20%20%20%20%20%20631%20%20%20%20STO%2031%0A%2016%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2017%20%20%20%20%20%20531%20%20%20%20OUT%2031%0A%2018%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20000%20%20%20%20the%20count%0A%2032%20%20%20%20%20%20001%0A&in=8%208%208%20-1)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=cell-00-is-the-constant-1-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-18%3A%20count%20cards%20until%20a%20negative%20one%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20317%20%20%20%20TAC%2017%0A%2013%20%20%20%20%20%20131%20%20%20%20CLA%2031%0A%2014%20%20%20%20%20%20200%20%20%20%20ADD%2000%20%20count%20%2B%201%2C%20from%20cell%2000%0A%2015%20%20%20%20%20%20631%20%20%20%20STO%2031%0A%2016%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2017%20%20%20%20%20%20531%20%20%20%20OUT%2031%0A%2018%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20000%20%20%20%20the%20count%0A&in=8%208%208%20-1)

   <!-- maps -->

   Both count three cards. Bringing your own 1 takes 12 cells, and using cell 00 takes 11. They both run 26
   instructions, so the saving here is the cell, which on a hundred-cell machine is worth having.

   Several later instruction sets wire in a constant the same way, usually zero. MIPS's $zero and RISC-V's x0 always
   read as 0, which gives every instruction a free zero to work with. The MSP430 goes further, with two registers
   that generate the constants 0, 1, 2, 4, 8 and -1, so the most common constants cost no extra word in the program.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=load-tables-with-the-program-not-with-inp-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cell%2010%3A%20the%20month%0A%2011%20%20%20%20%20%20040%20%20%20%20INP%2040%20%20cells%2011-16%3A%20then%20read%20the%20table%27s%2012%20cards%20into%20cells%2040-51%0A%2012%20%20%20%20%20%20111%20%20%20%20CLA%2011%0A%2013%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2014%20%20%20%20%20%20611%20%20%20%20STO%2011%0A%2015%20%20%20%20%20%20731%20%20%20%20SUB%2031%0A%2016%20%20%20%20%20%20311%20%20%20%20TAC%2011%0A%2017%20%20%20%20%20%20130%20%20%20%20CLA%2030%20%20cells%2017-23%3A%20the%20days%20in%20month%20m%20are%20in%20cell%2039%20%2B%20m%0A%2018%20%20%20%20%20%20232%20%20%20%20ADD%2032%0A%2019%20%20%20%20%20%20620%20%20%20%20STO%2020%0A%2020%20%20%20%20%20%20100%20%20%20%20CLA%2000%20%20CLA%2039%20%2B%20m%2C%20written%20by%20the%20cell%20before%0A%2021%20%20%20%20%20%20633%20%20%20%20STO%2033%0A%2022%20%20%20%20%20%20533%20%20%20%20OUT%2033%0A%2023%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20052%20%20%20%20INP%2052%0A%2032%20%20%20%20%20%20139%20%20%20%20CLA%2039%0A%2033%20%20%20%20%20%20000%0A&in=9%2031%2028%2031%2030%2031%2030%2031%2031%2030%2031%2030%2031)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=load-tables-with-the-program-not-with-inp-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-17%3A%20the%20days%20in%20month%20m%20are%20in%20cell%2039%20%2B%20m%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20231%20%20%20%20ADD%2031%0A%2013%20%20%20%20%20%20614%20%20%20%20STO%2014%0A%2014%20%20%20%20%20%20100%20%20%20%20CLA%2000%20%20CLA%2039%20%2B%20m%2C%20written%20by%20the%20cell%20before%0A%2015%20%20%20%20%20%20632%20%20%20%20STO%2032%0A%2016%20%20%20%20%20%20532%20%20%20%20OUT%2032%0A%2017%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20139%20%20%20%20CLA%2039%0A%2032%20%20%20%20%20%20000%0A%2040%20%20%20%20%20%20031%20%20%20%20cells%2040-51%3A%20the%20table%2C%20on%20the%20program%27s%20own%20deck%0A%2041%20%20%20%20%20%20028%0A%2042%20%20%20%20%20%20031%0A%2043%20%20%20%20%20%20030%0A%2044%20%20%20%20%20%20031%0A%2045%20%20%20%20%20%20030%0A%2046%20%20%20%20%20%20031%0A%2047%20%20%20%20%20%20031%0A%2048%20%20%20%20%20%20030%0A%2049%20%20%20%20%20%20031%0A%2050%20%20%20%20%20%20030%0A%2051%20%20%20%20%20%20031%0A&in=9)

   Both print 30 for September. Counting the loading, reading the table in takes 18 cells and runs 140 instructions,
   and loading it with the program takes 23 cells and runs 83.

   Compiled programs do the same thing. A C array with an initializer goes into the program file's data section, and
   the loader puts it in memory along with the code, so no instructions run to fill it.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=stream-the-table-dont-store-it-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-17%3A%20entry%20k%20of%20the%20table%20is%20in%20cell%2039%20%2B%20k%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20231%20%20%20%20ADD%2031%0A%2013%20%20%20%20%20%20614%20%20%20%20STO%2014%0A%2014%20%20%20%20%20%20100%20%20%20%20CLA%2000%20%20CLA%2039%20%2B%20k%2C%20written%20by%20the%20cell%20before%0A%2015%20%20%20%20%20%20632%20%20%20%20STO%2032%0A%2016%20%20%20%20%20%20532%20%20%20%20OUT%2032%0A%2017%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20139%20%20%20%20CLA%2039%0A%2032%20%20%20%20%20%20000%0A%2040%20%20%20%20%20%20031%20%20%20%20cells%2040-51%3A%20the%20whole%20table%2C%20in%20memory%0A%2041%20%20%20%20%20%20028%0A%2042%20%20%20%20%20%20031%0A%2043%20%20%20%20%20%20030%0A%2044%20%20%20%20%20%20031%0A%2045%20%20%20%20%20%20030%0A%2046%20%20%20%20%20%20031%0A%2047%20%20%20%20%20%20031%0A%2048%20%20%20%20%20%20030%0A%2049%20%20%20%20%20%20031%0A%2050%20%20%20%20%20%20030%0A%2051%20%20%20%20%20%20031%0A&in=2)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=stream-the-table-dont-store-it-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-19%3A%20read%20the%20table%27s%20cards%20one%20by%20one%20and%20keep%20only%20entry%20k%0A%2011%20%20%20%20%20%20031%20%20%20%20INP%2031%0A%2012%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2013%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2014%20%20%20%20%20%20630%20%20%20%20STO%2030%0A%2015%20%20%20%20%20%20700%20%20%20%20SUB%2000%0A%2016%20%20%20%20%20%20318%20%20%20%20TAC%2018%0A%2017%20%20%20%20%20%20811%20%20%20%20JMP%2011%0A%2018%20%20%20%20%20%20531%20%20%20%20OUT%2031%0A%2019%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20000%20%20%20%20the%20one%20card%20kept%0A&in=2%2031%2028%2031%2030%2031%2030%2031%2031%2030%2031%2030%2031)

   <!-- maps -->

   Both print 28 for entry 2. Keeping the table takes 23 cells and runs 8 instructions; streaming it takes 12 cells
   and runs 16, plus the time to read the cards.

   Unix tools are built this way. grep reads its input a line at a time and keeps only the line in hand, so it can
   search a file far bigger than memory, and the same goes for most programs written to sit in a pipeline.

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=when-it-doesnt-fit-split-it-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20030%20%20%20%20INP%2030%20%20cells%2010-18%3A%20both%20parts%20in%20one%20deck%3A%20all%20of%20it%20in%20memory%20at%20once%0A%2011%20%20%20%20%20%20130%20%20%20%20CLA%2030%0A%2012%20%20%20%20%20%20230%20%20%20%20ADD%2030%0A%2013%20%20%20%20%20%20631%20%20%20%20STO%2031%0A%2014%20%20%20%20%20%20131%20%20%20%20CLA%2031%0A%2015%20%20%20%20%20%20231%20%20%20%20ADD%2031%0A%2016%20%20%20%20%20%20632%20%20%20%20STO%2032%0A%2017%20%20%20%20%20%20532%20%20%20%20OUT%2032%0A%2018%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2030%20%20%20%20%20%20000%0A%2031%20%20%20%20%20%20000%0A%2032%20%20%20%20%20%20000%0A&in=21)

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

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=when-it-doesnt-fit-split-it-2&cqb=002%0A800%0A010%0A030%0A011%0A130%0A012%0A230%0A013%0A631%0A014%0A902%0A030%0A000%0A031%0A000%0A002%0A810%0A&cqb=002%0A800%0A010%0A131%0A011%0A231%0A012%0A632%0A013%0A532%0A014%0A900%0A032%0A000%0A002%0A810%0A&in=21)

   <!-- maps -->

   Both print 84 for 21. In one deck the program needs 12 cells at once; split, the bigger tape needs 7.

   Before virtual memory, this was how big programs fit, and it was called an overlay. The program was cut into
   pieces that took turns in the same memory, and whatever the next piece needed was left where it was. Microsoft's
   BASIC interpreters had a statement for it, CHAIN, which loads and runs the next program, and with COMMON it keeps
   the variables you name for the program it loads.

5. **Owe the bonus; don't look ahead.** Say you want to score a game of bowling. Each card is one roll, the number of
   pins it knocked down, and the program outputs the running total after each frame, the way a scoresheet shows it.

   A strike scores 10 plus the next two rolls, and a spare scores 10 plus the next one, so a frame's score depends on
   rolls that haven't happened yet. The usual answer is to keep every roll in an array, up to 21 of them, and look
   ahead. If roll i is a strike, add 10 and rolls i + 1 and i + 2, and move on one roll; otherwise move on two. On
   CARDIAC the array costs 21 cells, and each look into it is a CLA built by adding i to CLA 78. There's a catch,
   too. No card says where the game ends, so reading the rolls in means working out the frames once already, just to
   know when to stop.

   ```
   cell  contents  notes
    10      860    JMP 60  cells 10-18: read frames 1-9, one roll for a strike and two otherwise
    11      776    SUB 76
    12      314    TAC 14
    13      815    JMP 15
    14      860    JMP 60
    15      170    CLA 70
    16      200    ADD 00
    17      670    STO 70
    18      310    TAC 10
    19      860    JMP 60  cells 19-25: the tenth frame: two rolls, and a third after a strike or a spare
    20      673    STO 73
    21      860    JMP 60
    22      273    ADD 73
    23      776    SUB 76
    24      326    TAC 26
    25      860    JMP 60
    26      178    CLA 78  cells 26-37: copy rolls i, i+1 and i+2 into cells 73-75; cell 26 is CLA 78 + i
    27      673    STO 73
    28      126    CLA 26
    29      200    ADD 00
    30      626    STO 26
    31      634    STO 34
    32      200    ADD 00
    33      636    STO 36
    34      100    CLA 00
    35      674    STO 74
    36      100    CLA 00
    37      675    STO 75
    38      173    CLA 73  cells 38-43: a strike scores 10 + the next two rolls, and the frame is one roll
    39      776    SUB 76
    40      344    TAC 44
    41      174    CLA 74
    42      275    ADD 75
    43      851    JMP 51
    44      136    CLA 36  cells 44-50: otherwise the frame is two rolls; a spare scores 10 + the next roll, an open frame its two rolls
    45      626    STO 26
    46      173    CLA 73
    47      274    ADD 74
    48      776    SUB 76
    49      351    TAC 51
    50      275    ADD 75
    51      276    ADD 76  cells 51-59: add the 10, add the frame to the score and output it, ten times
    52      272    ADD 72
    53      672    STO 72
    54      572    OUT 72
    55      171    CLA 71
    56      200    ADD 00
    57      671    STO 71
    58      326    TAC 26
    59      900    HRS 00
    60      199    CLA 99  cells 60-68: read a roll into the array: copy the way back, step the STO in cell 67, and leave the roll in the accumulator
    61      668    STO 68
    62      069    INP 69
    63      167    CLA 67
    64      200    ADD 00
    65      667    STO 67
    66      169    CLA 69
    67      677    STO 77
    68      800    JMP 00
    69      000    the roll
    70     -009    frames 1-9 still to read
    71     -010    frames still to score
    72      000    the score
    73      000    rolls i, i+1 and i+2
    74      000
    75      000
    76      010
    78      000    cells 78-98: the rolls, up to 21
    79      000
    80      000
    81      000
    82      000
    83      000
    84      000
    85      000
    86      000
    87      000
    88      000
    89      000
    90      000
    91      000
    92      000
    93      000
    94      000
    95      000
    96      000
    97      000
    98      000
   ```
   <!-- input: 10 7 3 9 0 10 0 8 8 2 0 6 10 10 10 8 1 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=owe-the-bonus-dont-look-ahead-1&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20860%20%20%20%20JMP%2060%20%20cells%2010-18%3A%20read%20frames%201-9%2C%20one%20roll%20for%20a%20strike%20and%20two%20otherwise%0A%2011%20%20%20%20%20%20776%20%20%20%20SUB%2076%0A%2012%20%20%20%20%20%20314%20%20%20%20TAC%2014%0A%2013%20%20%20%20%20%20815%20%20%20%20JMP%2015%0A%2014%20%20%20%20%20%20860%20%20%20%20JMP%2060%0A%2015%20%20%20%20%20%20170%20%20%20%20CLA%2070%0A%2016%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2017%20%20%20%20%20%20670%20%20%20%20STO%2070%0A%2018%20%20%20%20%20%20310%20%20%20%20TAC%2010%0A%2019%20%20%20%20%20%20860%20%20%20%20JMP%2060%20%20cells%2019-25%3A%20the%20tenth%20frame%3A%20two%20rolls%2C%20and%20a%20third%20after%20a%20strike%20or%20a%20spare%0A%2020%20%20%20%20%20%20673%20%20%20%20STO%2073%0A%2021%20%20%20%20%20%20860%20%20%20%20JMP%2060%0A%2022%20%20%20%20%20%20273%20%20%20%20ADD%2073%0A%2023%20%20%20%20%20%20776%20%20%20%20SUB%2076%0A%2024%20%20%20%20%20%20326%20%20%20%20TAC%2026%0A%2025%20%20%20%20%20%20860%20%20%20%20JMP%2060%0A%2026%20%20%20%20%20%20178%20%20%20%20CLA%2078%20%20cells%2026-37%3A%20copy%20rolls%20i%2C%20i%2B1%20and%20i%2B2%20into%20cells%2073-75%3B%20cell%2026%20is%20CLA%2078%20%2B%20i%0A%2027%20%20%20%20%20%20673%20%20%20%20STO%2073%0A%2028%20%20%20%20%20%20126%20%20%20%20CLA%2026%0A%2029%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2030%20%20%20%20%20%20626%20%20%20%20STO%2026%0A%2031%20%20%20%20%20%20634%20%20%20%20STO%2034%0A%2032%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2033%20%20%20%20%20%20636%20%20%20%20STO%2036%0A%2034%20%20%20%20%20%20100%20%20%20%20CLA%2000%0A%2035%20%20%20%20%20%20674%20%20%20%20STO%2074%0A%2036%20%20%20%20%20%20100%20%20%20%20CLA%2000%0A%2037%20%20%20%20%20%20675%20%20%20%20STO%2075%0A%2038%20%20%20%20%20%20173%20%20%20%20CLA%2073%20%20cells%2038-43%3A%20a%20strike%20scores%2010%20%2B%20the%20next%20two%20rolls%2C%20and%20the%20frame%20is%20one%20roll%0A%2039%20%20%20%20%20%20776%20%20%20%20SUB%2076%0A%2040%20%20%20%20%20%20344%20%20%20%20TAC%2044%0A%2041%20%20%20%20%20%20174%20%20%20%20CLA%2074%0A%2042%20%20%20%20%20%20275%20%20%20%20ADD%2075%0A%2043%20%20%20%20%20%20851%20%20%20%20JMP%2051%0A%2044%20%20%20%20%20%20136%20%20%20%20CLA%2036%20%20cells%2044-50%3A%20otherwise%20the%20frame%20is%20two%20rolls%3B%20a%20spare%20scores%2010%20%2B%20the%20next%20roll%2C%20an%20open%20frame%20its%20two%20rolls%0A%2045%20%20%20%20%20%20626%20%20%20%20STO%2026%0A%2046%20%20%20%20%20%20173%20%20%20%20CLA%2073%0A%2047%20%20%20%20%20%20274%20%20%20%20ADD%2074%0A%2048%20%20%20%20%20%20776%20%20%20%20SUB%2076%0A%2049%20%20%20%20%20%20351%20%20%20%20TAC%2051%0A%2050%20%20%20%20%20%20275%20%20%20%20ADD%2075%0A%2051%20%20%20%20%20%20276%20%20%20%20ADD%2076%20%20cells%2051-59%3A%20add%20the%2010%2C%20add%20the%20frame%20to%20the%20score%20and%20output%20it%2C%20ten%20times%0A%2052%20%20%20%20%20%20272%20%20%20%20ADD%2072%0A%2053%20%20%20%20%20%20672%20%20%20%20STO%2072%0A%2054%20%20%20%20%20%20572%20%20%20%20OUT%2072%0A%2055%20%20%20%20%20%20171%20%20%20%20CLA%2071%0A%2056%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2057%20%20%20%20%20%20671%20%20%20%20STO%2071%0A%2058%20%20%20%20%20%20326%20%20%20%20TAC%2026%0A%2059%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2060%20%20%20%20%20%20199%20%20%20%20CLA%2099%20%20cells%2060-68%3A%20read%20a%20roll%20into%20the%20array%3A%20copy%20the%20way%20back%2C%20step%20the%20STO%20in%20cell%2067%2C%20and%20leave%20the%20roll%20in%20the%20accumulator%0A%2061%20%20%20%20%20%20668%20%20%20%20STO%2068%0A%2062%20%20%20%20%20%20069%20%20%20%20INP%2069%0A%2063%20%20%20%20%20%20167%20%20%20%20CLA%2067%0A%2064%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2065%20%20%20%20%20%20667%20%20%20%20STO%2067%0A%2066%20%20%20%20%20%20169%20%20%20%20CLA%2069%0A%2067%20%20%20%20%20%20677%20%20%20%20STO%2077%0A%2068%20%20%20%20%20%20800%20%20%20%20JMP%2000%0A%2069%20%20%20%20%20%20000%20%20%20%20the%20roll%0A%2070%20%20%20%20%20-009%20%20%20%20frames%201-9%20still%20to%20read%0A%2071%20%20%20%20%20-010%20%20%20%20frames%20still%20to%20score%0A%2072%20%20%20%20%20%20000%20%20%20%20the%20score%0A%2073%20%20%20%20%20%20000%20%20%20%20rolls%20i%2C%20i%2B1%20and%20i%2B2%0A%2074%20%20%20%20%20%20000%0A%2075%20%20%20%20%20%20000%0A%2076%20%20%20%20%20%20010%0A%2078%20%20%20%20%20%20000%20%20%20%20cells%2078-98%3A%20the%20rolls%2C%20up%20to%2021%0A%2079%20%20%20%20%20%20000%0A%2080%20%20%20%20%20%20000%0A%2081%20%20%20%20%20%20000%0A%2082%20%20%20%20%20%20000%0A%2083%20%20%20%20%20%20000%0A%2084%20%20%20%20%20%20000%0A%2085%20%20%20%20%20%20000%0A%2086%20%20%20%20%20%20000%0A%2087%20%20%20%20%20%20000%0A%2088%20%20%20%20%20%20000%0A%2089%20%20%20%20%20%20000%0A%2090%20%20%20%20%20%20000%0A%2091%20%20%20%20%20%20000%0A%2092%20%20%20%20%20%20000%0A%2093%20%20%20%20%20%20000%0A%2094%20%20%20%20%20%20000%0A%2095%20%20%20%20%20%20000%0A%2096%20%20%20%20%20%20000%0A%2097%20%20%20%20%20%20000%0A%2098%20%20%20%20%20%20000%0A&in=10%207%203%209%200%2010%200%208%208%202%200%206%2010%2010%2010%208%201)

   But a frame never waits on more than the next two rolls, so what it needs isn't the rolls. It needs to know what
   it's still owed. Read the rolls one at a time, and let a strike or a spare wait until its bonus rolls have come
   in. The moment its last roll arrives, the frame is done and its score goes on the sheet.

   Two cells carry everything from one roll to the next. Cell 46 holds the frame that's waiting on this very roll, as
   its score so far less 10, and it's negative when no frame is waiting. A roll that finds it not negative adds
   itself and closes that frame. Cell 47 holds the frame's first ball less 10, and that one number does three jobs.
   After a strike it's 0, which means the strike is still owed two rolls, so the next roll moves it into cell 46 as
   10 plus that roll. Added to a second ball, it gives the two balls less 10, which is 0 for a spare, left in cell 46
   to wait, and negative for an open frame, which closes on the spot. And storing the roll less 10 is the strike
   test, because TAC sends anything negative on to the second ball.

   The tenth frame needs no code of its own. Its bonus rolls go round the same loop, as if they were starting an
   eleventh frame, but the routine that closes frames counts them, and after the tenth it halts before it reads
   another card. It returns with TAC 99 while the count is still negative, as in "Return with TAC 99 when the
   accumulator is negative".

   ```
   cell  contents  notes
    10      045    INP 45  cells 10-14: a first ball; a frame waiting on this roll (cell 46 not negative) closes with cell 46 + 10 + the roll
    11      146    CLA 46
    12      315    TAC 15
    13      245    ADD 45
    14      836    JMP 36
    15      147    CLA 47  cells 15-18: after a strike (cell 47 is 0) the strike waits, with 10 + this roll, kept less 10; else nothing waits
    16      318    TAC 18
    17      245    ADD 45
    18      646    STO 46
    19      145    CLA 45  cells 19-23: cell 47 = the roll - 10, which is 0 for a strike, so a strike's next roll is a first ball too
    20      750    SUB 50
    21      647    STO 47
    22      324    TAC 24
    23      810    JMP 10
    24      045    INP 45  cells 24-28: a second ball, closing the same way
    25      146    CLA 46
    26      329    TAC 29
    27      245    ADD 45
    28      836    JMP 36
    29      147    CLA 47  cells 29-35: the two balls - 10: 0 for a spare, which waits on the next roll; negative for an open frame, which closes now
    30      245    ADD 45
    31      646    STO 46
    32      334    TAC 34
    33      810    JMP 10
    34      836    JMP 36
    35      810    JMP 10
    36      250    ADD 50  cells 36-44: close a frame: add the accumulator + 10 to the score and output it; return with TAC 99 until the tenth
    37      248    ADD 48
    38      648    STO 48
    39      548    OUT 48
    40      149    CLA 49
    41      200    ADD 00
    42      649    STO 49
    43      399    TAC 99
    44      900    HRS 00
    45      000    the roll
    46     -001    the waiting frame's score - 10, or negative when no frame waits
    47     -001    the frame's first ball - 10; 0 after a strike
    48      000    the score
    49     -010    frames to go, counting up from -10
    50      010
   ```
   <!-- input: 10 7 3 9 0 10 0 8 8 2 0 6 10 10 10 8 1 -->

   [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=owe-the-bonus-dont-look-ahead-2&cq=cell%20%20contents%20%20notes%0A%2010%20%20%20%20%20%20045%20%20%20%20INP%2045%20%20cells%2010-14%3A%20a%20first%20ball%3B%20a%20frame%20waiting%20on%20this%20roll%20%28cell%2046%20not%20negative%29%20closes%20with%20cell%2046%20%2B%2010%20%2B%20the%20roll%0A%2011%20%20%20%20%20%20146%20%20%20%20CLA%2046%0A%2012%20%20%20%20%20%20315%20%20%20%20TAC%2015%0A%2013%20%20%20%20%20%20245%20%20%20%20ADD%2045%0A%2014%20%20%20%20%20%20836%20%20%20%20JMP%2036%0A%2015%20%20%20%20%20%20147%20%20%20%20CLA%2047%20%20cells%2015-18%3A%20after%20a%20strike%20%28cell%2047%20is%200%29%20the%20strike%20waits%2C%20with%2010%20%2B%20this%20roll%2C%20kept%20less%2010%3B%20else%20nothing%20waits%0A%2016%20%20%20%20%20%20318%20%20%20%20TAC%2018%0A%2017%20%20%20%20%20%20245%20%20%20%20ADD%2045%0A%2018%20%20%20%20%20%20646%20%20%20%20STO%2046%0A%2019%20%20%20%20%20%20145%20%20%20%20CLA%2045%20%20cells%2019-23%3A%20cell%2047%20%3D%20the%20roll%20-%2010%2C%20which%20is%200%20for%20a%20strike%2C%20so%20a%20strike%27s%20next%20roll%20is%20a%20first%20ball%20too%0A%2020%20%20%20%20%20%20750%20%20%20%20SUB%2050%0A%2021%20%20%20%20%20%20647%20%20%20%20STO%2047%0A%2022%20%20%20%20%20%20324%20%20%20%20TAC%2024%0A%2023%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2024%20%20%20%20%20%20045%20%20%20%20INP%2045%20%20cells%2024-28%3A%20a%20second%20ball%2C%20closing%20the%20same%20way%0A%2025%20%20%20%20%20%20146%20%20%20%20CLA%2046%0A%2026%20%20%20%20%20%20329%20%20%20%20TAC%2029%0A%2027%20%20%20%20%20%20245%20%20%20%20ADD%2045%0A%2028%20%20%20%20%20%20836%20%20%20%20JMP%2036%0A%2029%20%20%20%20%20%20147%20%20%20%20CLA%2047%20%20cells%2029-35%3A%20the%20two%20balls%20-%2010%3A%200%20for%20a%20spare%2C%20which%20waits%20on%20the%20next%20roll%3B%20negative%20for%20an%20open%20frame%2C%20which%20closes%20now%0A%2030%20%20%20%20%20%20245%20%20%20%20ADD%2045%0A%2031%20%20%20%20%20%20646%20%20%20%20STO%2046%0A%2032%20%20%20%20%20%20334%20%20%20%20TAC%2034%0A%2033%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2034%20%20%20%20%20%20836%20%20%20%20JMP%2036%0A%2035%20%20%20%20%20%20810%20%20%20%20JMP%2010%0A%2036%20%20%20%20%20%20250%20%20%20%20ADD%2050%20%20cells%2036-44%3A%20close%20a%20frame%3A%20add%20the%20accumulator%20%2B%2010%20to%20the%20score%20and%20output%20it%3B%20return%20with%20TAC%2099%20until%20the%20tenth%0A%2037%20%20%20%20%20%20248%20%20%20%20ADD%2048%0A%2038%20%20%20%20%20%20648%20%20%20%20STO%2048%0A%2039%20%20%20%20%20%20548%20%20%20%20OUT%2048%0A%2040%20%20%20%20%20%20149%20%20%20%20CLA%2049%0A%2041%20%20%20%20%20%20200%20%20%20%20ADD%2000%0A%2042%20%20%20%20%20%20649%20%20%20%20STO%2049%0A%2043%20%20%20%20%20%20399%20%20%20%20TAC%2099%0A%2044%20%20%20%20%20%20900%20%20%20%20HRS%2000%0A%2045%20%20%20%20%20%20000%20%20%20%20the%20roll%0A%2046%20%20%20%20%20-001%20%20%20%20the%20waiting%20frame%27s%20score%20-%2010%2C%20or%20negative%20when%20no%20frame%20waits%0A%2047%20%20%20%20%20-001%20%20%20%20the%20frame%27s%20first%20ball%20-%2010%3B%200%20after%20a%20strike%0A%2048%20%20%20%20%20%20000%20%20%20%20the%20score%0A%2049%20%20%20%20%20-010%20%20%20%20frames%20to%20go%2C%20counting%20up%20from%20-10%0A%2050%20%20%20%20%20%20010%0A&in=10%207%203%209%200%2010%200%208%208%202%200%206%2010%2010%2010%208%201)

   <!-- maps -->

   Both output 20, 39, 48, 66, 74, 84, 90, 120, 148 and 167. The array way takes 88 cells and runs 510 instructions;
   the streaming way takes 41 cells and runs 270. A perfect game is 448 instructions against 244, and twenty gutter
   balls 549 against 279. The array way leaves just one cell free between 10 and 98, so there's no room for anything
   else.

   This is the problem in Robert C. Martin's Bowling Game kata, a classic exercise in test-driven development. Its
   Game class keeps the rolls in an array of 21 and scores them with the same lookahead as the first program, which
   is the clear way to write it when memory is plentiful. The second program is an online algorithm. It handles each
   input as it arrives, keeps a small fixed state, and never needs an input again. Welford's 1962 method for the mean
   and variance of a stream works the same way. It keeps a count, the running mean and one running sum, however much
   data goes past, which is why it suits data too big to keep.
