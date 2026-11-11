# Program No. 3: Counting Program with Loop

Page 24: the same counting in five words, with a jump back to cell 22. It counts on indefinitely.

- `counting-loop.cardiac`: the program as printed.
- `counting-loop.deck`: the deck. No input cards.
- [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=counting-loop&cq=Program%20No.%203%3A%20Counting%20Program%20with%20Loop%20%28manual%20page%2024%29%0A%0AADDRESS%20%20CONTENTS%20%20COMMENTS%0A%20%2021%20%20%20%20%20%20%20100%20%20%20%20%20Clear%20and%20add%20contents%20of%20cell%2000.%0A%20%2022%20%20%20%20%20%20%20603%20%20%20%20%20Store%20contents%20of%20acc.%20in%20cell%2003.%0A%20%2023%20%20%20%20%20%20%20503%20%20%20%20%20Print%20contents%20of%20cell%2003.%0A%20%2024%20%20%20%20%20%20%20200%20%20%20%20%20Add%20contents%20of%20cell%2000.%0A%20%2025%20%20%20%20%20%20%20822%20%20%20%20%20Jump%20to%20instruction%20in%20cell%2022.%0A).

Put the bug in cell 21. No input. It printed 1, 2, 3, 4, 5, 6, ... and keeps going until you stop it.
