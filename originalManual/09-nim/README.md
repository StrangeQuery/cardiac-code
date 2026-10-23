# Program No. 9: Single-Pile Nim (Ten Pebbles)

Page 41 (directions on page 42): "what may be the shortest game program ever written". Ten pebbles; each
player takes one, two or three, but not the number the other just took. A move is written as three digits:
the player (0 for CARDIAC, 5 for you), the pebbles taken, the pebbles left. Your move card is read into cell
01 and run as an instruction: 5xy is "print cell xy", and cell xy of the look-up table holds CARDIAC's reply.
Cell 02 halts and resets the bug to 00, ready for your next card.

- `nim.txt`: the program and the look-up table as printed.
- `nim.tape`: the deck. No input cards. The program lives in the loader's own cells 01 and 02, so the deck
  loads the table first, then 002 900 (cell 02; the halt runs at once and stops the machine with the bug on
  00), then 001 529 (cell 01; it stops again with the bug on 00). Start again after the first stop.

You first: with the bug on 00, put your move card in and start; after each reply it halts with the bug on 00
for your next card. CARDIAC first: put the bug in cell 01 and start (cell 01 must be 529 at the start of each
game). Each move card is one of 519, 528, 537 at the start, and so on.

What it printed: CARDIAC first, 019. In the manual's example moves (page 41), 517 got 034 and 513 got 030.
