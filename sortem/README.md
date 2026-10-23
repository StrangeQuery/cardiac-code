# sortem

Reads numbers, sorts them, and prints them sorted, then their mean, minimum, maximum and median.

- `sortem.txt`, `sortem.tape`: everything in one deck. The program takes 94 cells, which leaves room for only 2
  numbers (cells 97–98).
- `sortem-1.txt`, `sortem-1.tape`: tape 1 of 2. Reads 35 numbers into cells 64–98, sorts them in place, and halts
  with the bug on 02.
- `sortem-2.txt`, `sortem-2.tape`: tape 2 of 2. Loads over tape 1's program but not over cells 64–98, so the
  sorted numbers are still there. Prints them and the statistics.

To run the two-tape version: load tape 1 followed by 35 number cards and start at 00. When it halts with the bug
on 02, put tape 2 in the reader and start at 00 again. Same machine, 35 numbers instead of 2.

The mean keeps its total in one cell, so the numbers must add up to 999 or less.
