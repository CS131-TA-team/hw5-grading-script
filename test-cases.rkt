#lang racket

(provide (struct-out test-case)
         all-tests
         extra-tests)

; —————————————————————————————————-——-———————————————————————————————

(struct test-case (lhs rhs ans) #:transparent)

;; Test cases
(define all-tests
  (list (test-case 12 12 12) ; # 1
        (test-case 12 20 '(if % 12 20)) ; # 2
        (test-case #t #t #t) ; # 3
        ))

;; Extra test cases, which are not counted into the grades
(define extra-tests
  (list (test-case '(λ a a) '(λ b b) '(λ a!b a!b))
        (test-case '(λ a a) '(λ (a) a) '(if % (λ a a) (λ (a) a)))
        ))
