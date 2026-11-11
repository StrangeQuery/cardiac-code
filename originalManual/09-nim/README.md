# Program No. 9: Single-Pile Nim (Ten Pebbles)

Page 41 (directions on page 42): "what may be the shortest game program ever written". Ten pebbles; each
player takes one, two or three, but not the number the other just took. A move is written as three digits:
the player (0 for CARDIAC, 5 for you), the pebbles taken, the pebbles left. Your move card is read into cell
01 and run as an instruction: 5xy is "print cell xy", and cell xy of the look-up table holds CARDIAC's reply.
Cell 02 halts and resets the bug to 00, ready for your next card.

- `nim.cardiac`: the program and the look-up table as printed.
- `nim.deck`: the deck. No input cards. The program lives in the loader's own cells 01 and 02, so the deck
  loads the table first, then 002 900 (cell 02; the halt runs at once and stops the machine with the bug on
  00), then 001 529 (cell 01; it stops again with the bug on 00). Start again after the first stop.
- [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=nim&cq=Program%20No.%209%3A%20Single-Pile%20Nim%20%28Ten%20Pebbles%29%20%28manual%20page%2041%29%0A%0AADDRESS%20%20CONTENTS%20%20COMMENT%0A%20%2000%20%20%20%20%20%20%20001%20%20%20%20%20Read%20an%20input%20card%20%28this%20instruction%20is%20wired%20in%29.%0A%20%2001%20%20%20%20%20%20%20529%20%20%20%20%20This%20is%20used%20only%20when%20CARDIAC%20plays%20first.%20Cell%2001%20must%20be%20reset%20to%20529%20for%20each%20new%20game.%0A%20%2002%20%20%20%20%20%20%20900%20%20%20%20%20Halt%20and%20reset.%0A%0AThe%20following%20look-up%20table%20must%20be%20entered%20in%20CARDIAC%27s%20memory.%0A%0AADDRESS%20%20CONTENTS%20%20ADDRESS%20%20CONTENTS%0A%20%2010%20%20%20%20%20%20%20000%20%20%20%20%20%20%2024%20%20%20%20%20%20%20013%0A%20%2011%20%20%20%20%20%20%20001%20%20%20%20%20%20%2025%20%20%20%20%20%20%20014%0A%20%2012%20%20%20%20%20%20%20020%20%20%20%20%20%20%2026%20%20%20%20%20%20%20015%0A%20%2013%20%20%20%20%20%20%20030%20%20%20%20%20%20%2027%20%20%20%20%20%20%20034%0A%20%2014%20%20%20%20%20%20%20022%20%20%20%20%20%20%2028%20%20%20%20%20%20%20017%0A%20%2015%20%20%20%20%20%20%20023%20%20%20%20%20%20%2029%20%20%20%20%20%20%20019%0A%20%2016%20%20%20%20%20%20%20033%20%20%20%20%20%20%2030%20%20%20%20%20%20%20000%0A%20%2017%20%20%20%20%20%20%20034%20%20%20%20%20%20%2031%20%20%20%20%20%20%20010%0A%20%2018%20%20%20%20%20%20%20026%20%20%20%20%20%20%2032%20%20%20%20%20%20%20020%0A%20%2019%20%20%20%20%20%20%20027%20%20%20%20%20%20%2033%20%20%20%20%20%20%20012%0A%20%2020%20%20%20%20%20%20%20000%20%20%20%20%20%20%2034%20%20%20%20%20%20%20013%0A%20%2021%20%20%20%20%20%20%20010%20%20%20%20%20%20%2035%20%20%20%20%20%20%20014%0A%20%2022%20%20%20%20%20%20%20011%20%20%20%20%20%20%2036%20%20%20%20%20%20%20024%0A%20%2023%20%20%20%20%20%20%20030%20%20%20%20%20%20%2037%20%20%20%20%20%20%20025%0A&in=517), with your move 517 on the input card.

You first: with the bug on 00, put your move card in and start; after each reply it halts with the bug on 00
for your next card. CARDIAC first: put the bug in cell 01 and start (cell 01 must be 529 at the start of each
game). Each move card is one of 519, 528, 537 at the start, and so on.

What it printed: CARDIAC first, 019. In the manual's example moves (page 41), 517 got 034 and 513 got 030.
