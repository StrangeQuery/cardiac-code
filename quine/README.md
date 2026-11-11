# quine

A program that punches its own deck: the two loader cards, an address card and a data card for each of its 22
cells (03–24), and the pair that starts it. Load what it punches and run it, and it punches the same 48
cards again.

- `quine.cardiac`: the program, cell by cell, with notes.
- `quine.deck`: the deck, one card per line. No input cards.
- [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=quine&cq=A%20CARDIAC%20quine%3A%20it%20punches%20the%20deck%20that%20loads%20it.%0A%0Acell%20%20contents%20%20%20notes%0A%2003%20%20%20%20%20003%20%20%20%20%20%20the%20address%20to%20punch%20next%3B%20it%20starts%20as%20its%20own%20address%2C%2003%0A%2004%20%20%20%20%20519%20%20%20%20%20%20OUT%2019%20%20%20punch%20002%2C%20the%20first%20bootstrap%20card%20%20%20%20%20%20%3C-%20starts%20here%0A%2005%20%20%20%20%20520%20%20%20%20%20%20OUT%2020%20%20%20punch%20800%2C%20the%20second%20bootstrap%20card%0A%2006%20%20%20%20%20503%20%20%20%20%20%20OUT%2003%20%20%20punch%20the%20address%20card%0A%2007%20%20%20%20%20103%20%20%20%20%20%20CLA%2003%20%20%20take%20the%20address%0A%2008%20%20%20%20%20221%20%20%20%20%20%20ADD%2021%20%20%20add%20500%2C%20making%20%22OUT%20address%22%0A%2009%20%20%20%20%20610%20%20%20%20%20%20STO%2010%20%20%20put%20that%20instruction%20in%20cell%2010%0A%2010%20%20%20%20%20510%20%20%20%20%20%20OUT%2010%20%20%20%28rewritten%20every%20time%3A%20OUT%20address%29%20punch%20the%20data%20card%0A%2011%20%20%20%20%20103%20%20%20%20%20%20CLA%2003%0A%2012%20%20%20%20%20222%20%20%20%20%20%20ADD%2022%20%20%20next%20address%0A%2013%20%20%20%20%20603%20%20%20%20%20%20STO%2003%0A%2014%20%20%20%20%20724%20%20%20%20%20%20SUB%2024%20%20%20past%20the%20last%20cell%20yet%3F%0A%2015%20%20%20%20%20306%20%20%20%20%20%20TAC%2006%20%20%20no%3A%20punch%20the%20next%20pair%0A%2016%20%20%20%20%20519%20%20%20%20%20%20OUT%2019%20%20%20punch%20002%20...%0A%2017%20%20%20%20%20523%20%20%20%20%20%20OUT%2023%20%20%20...%20and%20804%3A%20the%20pair%20that%20puts%20JMP%2004%20in%20cell%2002%0A%2018%20%20%20%20%20900%20%20%20%20%20%20HRS%2000%20%20%20halt%0A%2019%20%20%20%20%20002%20%20%20%20%20%20data%3A%20002%0A%2020%20%20%20%20%20800%20%20%20%20%20%20data%3A%20800%0A%2021%20%20%20%20%20500%20%20%20%20%20%20data%3A%20500%2C%20the%20OUT%20instruction%20with%20address%2000%0A%2022%20%20%20%20%20001%20%20%20%20%20%20data%3A%201%0A%2023%20%20%20%20%20804%20%20%20%20%20%20data%3A%20804%2C%20JMP%2004%0A%2024%20%20%20%20%20025%20%20%20%20%20%20data%3A%2025%2C%20one%20past%20the%20last%20cell%0A).

Two cells change while it runs, and each starts out holding what it holds at the moment it is punched. Cell 03
holds the address being punched, so it starts as 03. Cell 10 is rewritten to "OUT address" before it runs, so
when the address reaches 10 it holds 510. There is no JMP in it, because JMP writes cell 99.

The decks are laid out as Brian Stuart describes on his CARDIAC page: the bootstrap cards 002 and 800, an address
card and a data card for each cell, then the pair 002 8xx, which puts a jump to the program's first instruction
in cell 02 so that the loader hands over to the program by itself; any input cards follow. The manual's own
loading program (its Program No. 7) ends instead with a BLANK card, which stops the loading, and the operator
starts the program.
