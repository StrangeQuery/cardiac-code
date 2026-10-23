# quine

A program that punches its own deck: the two loader cards, an address card and a data card for each of its 22
cells (03–24), and the pair that starts it. Load what it punches and run it, and it punches the same 48
cards again.

- `quine.txt`: the program, cell by cell, with notes.
- `quine.tape`: the deck, one card per line. No input cards.

Two cells change while it runs, and each starts out holding what it holds at the moment it is punched. Cell 03
holds the address being punched, so it starts as 03. Cell 10 is rewritten to "OUT address" before it runs, so
when the address reaches 10 it holds 510. There is no JMP in it, because JMP writes cell 99.

The decks are laid out as Brian Stuart describes on his CARDIAC page: the bootstrap cards 002 and 800, an address
card and a data card for each cell, then the pair 002 8xx, which puts a jump to the program's first instruction
in cell 02 so that the loader hands over to the program by itself; any input cards follow. The manual's own
loading program (its Program No. 7) ends instead with a BLANK card, which stops the loading, and the operator
starts the program.
