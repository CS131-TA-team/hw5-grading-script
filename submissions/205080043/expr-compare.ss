#lang racket
(provide (all-defined-out))

(define (expr-compare x y)
  x)

(define test-expr-x '(+ 3 ((lambda (a b) (list a b)) 1 2)))
(define test-expr-y '(+ 2 ((lambda (a c) (list a c)) 1 2)))
