# CS131 HW5 Sample Grading Script
* This is a real grading script used in 2019 Fall, but all test cases are omitted.

## Usage
* Create a folder for each submission in the `submissions` folder
* Put `expr-compare.ss` in the corresponding folder. Make sure there are `#lang racket` and `(provide (all-defined-out))` lines in that file.
* Please make sure that in your `expr-compare.ss`, there are only definitions. Top-level function calls such as `(test-expr-compare test-expr-x test-expr-y)` may cause compiling error and thus not allowed.
* Execute the script via
  ```shell
  ./main.rkt ./submissions
  ```
* Go to each subfolder in the `submissions` folder and check the `report.txt`.
* To add new test cases, modify `test-cases.rkt`.
