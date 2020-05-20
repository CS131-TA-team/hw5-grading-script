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
        (test-case #f #f #f) ; # 4
        (test-case #t #f '%) ; # 5
        (test-case #f #t '(not %)) ; # 6
        (test-case 'a '(cons a b) '(if % a (cons a b))) ; # 7
        (test-case '(cons a b) '(cons a b) '(cons a b)) ; # 8
        (test-case '(cons a lambda) '(cons a λ) '(cons a (if % lambda λ))) ; # 9
        (test-case '(cons (cons a b) (cons b c))
                   '(cons (cons a c) (cons a c))
                   '(cons (cons a (if % b c)) (cons (if % b a) c))) ; # 10
        (test-case '(cons a b) '(list a b) '((if % cons list) a b)) ; # 11
        (test-case '(list) '(list a) '(if % (list) (list a))) ; # 12
        (test-case ''(a b) ''(a c) '(if % '(a b) '(a c))) ; # 13
        (test-case '(quoth (a b)) '(quoth (a c)) '(quoth (a (if % b c)))) ; # 14
        (test-case '(if x y z) '(if x z z) '(if x (if % y z) z)) ; # 15
        (test-case '(if x y z) '(g x y z) '(if % (if x y z) (g x y z))) ; # 16
        (test-case '((lambda (a) (f a)) 1)
                   '((lambda (a) (g a)) 2)
                   '((lambda (a) ((if % f g) a)) (if % 1 2))) ; # 17
        (test-case '((lambda (a) (f a)) 1)
                   '((λ (a) (g a)) 2)
                   '((λ (a) ((if % f g) a)) (if % 1 2))) ; # 18
        (test-case '((lambda (a) a) c)
                   '((lambda (b) b) d)
                   '((lambda (a!b) a!b) (if % c d))) ; # 19
        (test-case ''((λ (a) a) c)
                   ''((lambda (b) b) d)
                   '(if % '((λ (a) a) c) '((lambda (b) b) d))) ; # 20
        (test-case '(+ #f ((λ (a b) (f a b)) 1 2))
                   '(+ #t ((lambda (a c) (f a c)) 1 2))
                   '(+ (not %) ((λ (a b!c) (f a b!c)) 1 2))) ; # 21
        (test-case '((λ (a b) (f a b)) 1 2)
                   '((λ (a b) (f b a)) 1 2)
                   '((λ (a b) (f (if % a b) (if % b a))) 1 2)) ; # 22
        (test-case '((lambda (lambda) (+ lambda if (f lambda))) 3)
                   '((lambda (if) (+ if if (f λ))) 3)
                   '((lambda (lambda!if) (+ lambda!if (if % if lambda!if)
                                            (f (if % lambda!if λ)))) 3)) ; # 23
        (test-case '((lambda (a) (eq? a ((λ (a b) ((λ (a b) (a b)) b a))
                                         a (lambda (a) a))))
                     (lambda (b a) (b a)))
                   '((λ (a) (eqv? a ((lambda (b a) ((lambda (a b) (a b)) b a))
                                     a (λ (b) a))))
                     (lambda (a b) (a b)))
                   '((λ (a) ((if % eq? eqv?) a ((λ (a!b b!a) ((λ (a b) (a b)) (if % b!a a!b) (if % a!b b!a)))
                                                a (λ (a!b) (if % a!b a)))))
                     (lambda (b!a a!b) (b!a a!b)))) ; # 24
        ; ----------
        (test-case '(cons a lambda) '(cons a λ) '(cons a (if % lambda λ))) ; # 25
        (test-case '(lambda (a) a) '(lambda (b) b) '(lambda (a!b) a!b)) ; # 26
        (test-case '(lambda (a) a) '(lambda (b) b) '(lambda (a!b) a!b)) ; # 27
        (test-case '(lambda (a) b) '(cons (c) b) '(if % (lambda (a) b) (cons (c) b))) ; # 28
        (test-case '((λ (if) (+ if 1)) 3) '((lambda (fi) (+ fi 1)) 3) '((λ (if!fi) (+ if!fi 1)) 3)) ; # 29
        (test-case '(lambda (lambda) lambda) '(λ (λ) λ) '(λ (lambda!λ) lambda!λ)) ; # 30
        (test-case ''lambda '(quote λ) '(if % 'lambda 'λ)) ; # 31
        (test-case '(lambda (a b) a) '(λ (a) a) '(if % (lambda (a b) a) (λ (a) a))) ; # 32
        (test-case '(λ (let) (let ((x 1)) x))
                   '(lambda (let) (let ((y 1)) y))
                   '(λ (let) (let (((if % x y) 1)) (if % x y)))) ; # 33
        (test-case '(λ (x) ((λ (x) x) x))
                   '(λ (y) ((λ (x) y) x))
                   '(λ (x!y) ((λ (x) (if % x x!y)) (if % x!y x)))) ; # 34
        (test-case '(lambda (x y) (+ (x y) '(y x)))
                   '(lambda (y x) (+ (y x) '(x y)))
                   '(lambda (x!y y!x) (+ (x!y y!x) (if % '(y x) '(x y))))) ; # 35
        (test-case '(((λ (g)
                        ((λ (x) (g (λ () (x x))))     ; This is the way we define a recursive function
                         (λ (x) (g (λ () (x x))))))   ; when we don't have 'letrec'
                      (λ (r)                               ; Here (r) will be the function itself
                        (λ (n) (if (= n 0)
                                   1
                                   (* n ((r) (- n 1))))))) ; Therefore this thing calculates factorial of n
                     10)
                   '(((λ (x)
                        ((λ (n) (x (λ () (n n))))
                         (λ (r) (x (λ () (r r))))))
                      (λ (g)
                        (λ (x) (if (= x 0)
                                   1
                                   (* x ((g) (- x 1)))))))
                     9)
                   '(((λ (g!x)
                        ((λ (x!n) (g!x (λ () (x!n x!n))))
                         (λ (x!r) (g!x (λ () (x!r x!r))))))
                      (λ (r!g)
                        (λ (n!x) (if (= n!x 0)
                                     1
                                     (* n!x ((r!g) (- n!x 1)))))))
                     (if % 10 9))) ; # 36
        ))

;; Extra test cases, which are not counted into the grades
(define extra-tests
  (list (test-case '(λ (a) a) '(λ (b) b) '(λ (a!b) a!b))
        ))
