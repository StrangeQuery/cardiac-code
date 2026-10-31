# sortem

Reads numbers, sorts them, and prints them sorted, then their mean, minimum, maximum and median.

- `sortem.cardiac`, `sortem.deck`: everything in one deck. The program takes 94 cells, which leaves room for only 2
  numbers (cells 97–98).
- `sortem-1.cardiac`, `sortem-1.deck`: tape 1 of 2. Reads 35 numbers into cells 64–98, sorts them in place, and halts
  with the bug on 02.
- `sortem-2.cardiac`, `sortem-2.deck`: tape 2 of 2. Loads over tape 1's program but not over cells 64–98, so the
  sorted numbers are still there. Prints them and the statistics.

To run the two-tape version: load tape 1 followed by 35 number cards and start at 00. When it halts with the bug
on 02, put tape 2 in the reader and start at 00 again. Same machine, 35 numbers instead of 2.

The mean keeps its total in one cell, so the numbers must add up to 999 or less.

The decks are laid out as Brian Stuart describes on his CARDIAC page: the bootstrap cards 002 and 800, an address
card and a data card for each cell, then the pair 002 8xx, which puts a jump to the program's first instruction
in cell 02 so that the loader hands over to the program by itself; any input cards follow. The manual's own
loading program (its Program No. 7) ends instead with a BLANK card, which stops the loading, and the operator
starts the program.
