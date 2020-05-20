# CS131 HW5 Sample Grading Script
* This is a real grading script used in 2019 Fall, but all test cases are omitted.

## Usage
* Create a folder for each submission in the `submissions` folder
* Put `expr-compare.ss` in the corresponding folder. Make sure there are `#lang racket` and `(provide (all-defined-out))` lines in that file.
* Please make sure that in your `expr-compare.ss`, there are only definitions. Top-level function calls such as `(test-expr-compare test-expr-x test-expr-y)` may cause compiling error and thus not allowed.
* Execute the script via
  ```shell
  racket ./main.rkt ./submissions
  ```
* Go to each subfolder in the `submissions` folder and check the `report.txt`.
* For each test case, there are 4 kinds of results:
  * AC (Accepted): Correct
  * WA (Wrong Answer): The answer is wrong.
  * RE (Runtime Error): An exception is thrown during this test case.
  * TLE (Time Limit Exceed): Your program stuck on this test case for >600ms.
* There are about 50 test cases. Among them, about 30 are included in `test-case.rkt`.
  * So you can expect to get approximately 60% if you passed all of the test cases.
  * I reserve the right to change all cases if I see someone tries to enumerate test cases instead of implementing the program.
* To add new test cases, modify `test-cases.rkt`.

