# Program No. 1: Adding Number "A" to Number "B"

The manual's first program, page 20: it reads two numbers and prints their sum.

- `add.cardiac`: the program as printed.
- `add.deck`: the deck. No input cards.
- [Open in Cardigan](https://lab.strangequery.com/cardigan/ide/#name=add&cq=Program%20No.%201%3A%20Adding%20Number%20%22A%22%20to%20Number%20%22B%22%20to%20Produce%20Sum%20%22S%22%20%28manual%20page%2020%29%0A%0AADDRESS%20%20CONTENTS%20%20COMMENTS%0A%20%2017%20%20%20%20%20%20%20034%20%20%20%20%20Read%20%22A%22.%0A%20%2018%20%20%20%20%20%20%20035%20%20%20%20%20Read%20%22B%22.%0A%20%2019%20%20%20%20%20%20%20134%20%20%20%20%20Clear%20accumulator%20and%20add%20%22A%22.%0A%20%2020%20%20%20%20%20%20%20235%20%20%20%20%20Add%20%22B%22%20%28%22S%22%20is%20now%20in%20accumulator%29.%0A%20%2021%20%20%20%20%20%20%20636%20%20%20%20%20Store%20%22S%22.%0A%20%2022%20%20%20%20%20%20%20536%20%20%20%20%20Print%20%22S%22.%0A%20%2023%20%20%20%20%20%20%20900%20%20%20%20%20Halt%20and%20reset.%0A&in=123%20456), with 123 and 456 on the input cards.

Put the bug in cell 17. Input cards: A, then B (any two numbers whose sum doesn't exceed 999). It prints the
sum and halts. With 123 and 456 it printed 579.
