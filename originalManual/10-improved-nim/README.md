# Program No. 10: Improved Nim Game

Pages 42-48: Nim with any pile up to 999. CARDIAC keeps the pile N, finds the residue R (the pile less as many
fours as it holds), builds the instruction "CLA PR" from your move P and R, and runs it to look up its reply
C in a sixteen-entry table. Each turn it prints N after your move, its move C, and N after its move, then
halts with the bug on 52 for your next card.

- `improved-nim.cardiac`: the program, the table of CARDIAC's moves, the table of constants and variables, and
  the directions, as printed.
- `improved-nim-player-first.deck`: the deck with N = 13 in cells 14 and 17, started at 52. No input cards.
- `improved-nim-cardiac-first.deck`: the deck with N = 15, started at 53. No input cards.

The starting pile is the card after 014 and the card after 017 (the manual's N(start)); change both for
another pile. Cells 01 and 02 of the table (001 and 002) are not in the decks: the loader runs in those cells.
CARDIAC looks there only for its first move when it goes first with a pile of 4k+1 or 4k+2; for such a pile,
write 001 in cell 01 and 002 in cell 02 before starting at 53.

You first: the deck starts at 52. Input cards: the number of pebbles you take, 001, 002 or 003, one card a
turn; after each reply it halts with the bug on 52, so put your next card in and start again. CARDIAC first:
start at 53, then as above.

What it printed: pile 13, you take 1: 12, 3, 9. CARDIAC first with 15: 15, 3, 12.
