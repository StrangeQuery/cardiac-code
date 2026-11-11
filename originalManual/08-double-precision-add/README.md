# Program No. 8: Subroutine for "A" + "B" = SUM

Pages 36-37: double-precision addition. Each six-digit number is kept in two cells, the three most
significant digits in the first. The main program reads the numbers and calls the subroutine in cell 86 with
op code 8; the subroutine takes its return address from cell 99, adds the low halves, carries, adds the high
halves, and returns.

- `double-precision-add.cardiac`: the subroutine and the main program as printed.
- `double-precision-add.deck`: the deck. No input cards. Cell 94 ("8__") has no card: the subroutine writes
  it (cells 86-87) before it gets there.
- [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=double-precision-add&cqb=002%0A800%0A086%0A199%0A087%0A694%0A088%0A196%0A089%0A298%0A090%0A698%0A091%0A403%0A092%0A295%0A093%0A297%0A050%0A095%0A051%0A096%0A052%0A097%0A053%0A098%0A054%0A886%0A055%0A659%0A056%0A559%0A057%0A598%0A058%0A900%0A002%0A850%0A&in=163%20742%20258%20500), with 163, 742, 258 and 500 on the input cards.

Put the bug in cell 50. Input cards: 1, the three most significant digits of A; 2, the three least
significant digits of A; 3 and 4, the same for B. It prints the high half of the sum, then the low half. For
163,742 + 258,500 (cards 163, 742, 258, 500) it printed 422 and 242.
