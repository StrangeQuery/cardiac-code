# quine

A program that punches its own deck: the two loader cards, an address card and a value card for each of its 21
cells (03–23), and the card that jumps to its start. Load what it punches and run it, and it punches the same
45 cards again.

- `quine.txt`: the program, cell by cell, with notes.
- `quine.tape`: the deck, one card per line. No input cards.

Two cells change while it runs, and each starts out holding what it holds at the moment it is punched. Cell 03
holds the address being punched, so it starts as 03. Cell 10 is rewritten to "OUT address" before it runs, so
when the address reaches 10 it holds 510. There is no JMP in it, because JMP writes cell 99.
