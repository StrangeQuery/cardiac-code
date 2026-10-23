# Program No. 8: Subroutine for "A" + "B" = SUM

Pages 36-37: double-precision addition. Each six-digit number is kept in two cells, the three most
significant digits in the first. The main program reads the numbers and calls the subroutine in cell 86 with
op code 8; the subroutine takes its return address from cell 99, adds the low halves, carries, adds the high
halves, and returns.

- `double-precision-add.txt`: the subroutine and the main program as printed.
- `double-precision-add.tape`: the deck. No input cards. Cell 94 ("8__") has no card: the subroutine writes
  it (cells 86-87) before it gets there.

Put the bug in cell 50. Input cards: 1, the three most significant digits of A; 2, the three least
significant digits of A; 3 and 4, the same for B. It prints the high half of the sum, then the low half. For
163,742 + 258,500 (cards 163, 742, 258, 500) it printed 422 and 242.
