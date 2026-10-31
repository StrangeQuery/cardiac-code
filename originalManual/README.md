# The manual's programs

Every program in *CARDIAC: A Cardboard Illustrative Aid to Computation*, the 1968 Bell Telephone Laboratories
manual by David Hagelbarger and Saul Fingerman, transcribed from the page images of the Internet Archive item
`CardiacCardboardIllustrativeAidToComputation`. Each is exactly as printed, its cells and comments in the
manual's own columns, with the page it is on.

- `01-add`: Program No. 1, Adding Number "A" to Number "B" (page 20). Start at 17.
- `02-counting`: Program No. 2, Counting, written out in full (pages 22-23). Start at 20.
- `03-counting-loop`: Program No. 3, Counting Program with Loop (page 24). Start at 21.
- `04-countdown`: Program No. 4, Rocket-Launching Countdown (page 27). Start at 20.
- `05-multiply`: Program No. 5, Multiplication by a Single-Digit Multiplier (page 30). Start at 07.
- `06-reverse`: Program No. 6, Reversing the Order of a Number "abc" (page 32). Start at 15.
- `07-bootstrap-addition`: Program No. 7, Bootstrap and Loading Program for Addition (page 34). Start at 00.
- `08-double-precision-add`: Program No. 8, Subroutine for "A" + "B" = SUM, double precision (page 37). Start
  at 50.
- `09-nim`: Program No. 9, Single-Pile Nim (Ten Pebbles) (page 41). Start at 00, or at 01 for CARDIAC first.
- `10-improved-nim`: Program No. 10, Improved Nim Game (pages 47-48). Start at 52, or at 53 for CARDIAC first.

Each folder has the program as printed (`.cardiac`), its deck (`.deck`), and a README: what it does, where to start
it, what goes on the input cards, and what it printed.

The decks are laid out as Brian Stuart describes on his CARDIAC page: the bootstrap cards 002 and 800, an
address card and a data card for each cell, then the pair 002 8xx, which puts a jump to the program's first
instruction in cell 02 so that the loader hands over to the program by itself; any input cards follow. The
manual's own loading program (Program No. 7) ends instead with a BLANK card, which stops the loading, and the
operator starts the program. Programs Nos. 9 and 10 use cells 01 and 02 themselves, so their READMEs say how
their decks deal with that.
