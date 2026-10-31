# Program No. 7: Bootstrap and Loading Program for Addition

Page 34: Program No. 1 loaded from cards instead of written into memory. The bootstrap (001 in cell 00,
then the cards 002 and 800) makes a loop that reads an addressing instruction into cell 01 and then a program
word into the cell it names. Here the addition program sits in cells 10-16.

- `bootstrap-addition.cardiac`: the input cards as printed, ending with the BLANK card that stops the loading and
  the two data cards.
- `bootstrap-addition.deck`: the same deck with the pair 002 810 where the manual has BLANK, so that the
  loader hands over to the program in cell 10 by itself.

With the manual's cards: put the bug in cell 00 and start; the BLANK card stops the loading; then put the bug
in cell 10 and start, with the two numbers on the cards after it. With 123 and 456 it printed 579.
