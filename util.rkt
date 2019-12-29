#lang racket

(provide to-func)

; —————————————————————————————————-——-———————————————————————————————

(require racket/random)

(define (cvt-var var)
  (let* ([str (symbol->string var)]
         [syms (string-split str "!")])
    (if (= (length syms) 2)
        `(if %
             (quote ,(string->symbol (car syms)))
             (quote ,(string->symbol (cadr syms))))
        `(quote ,(string->symbol (car syms))))))

(define (cvt-expr expr)
  (cond [(equal? expr '%) '%]
        [(symbol? expr) (cvt-var expr)]
        [(not (list? expr)) expr]
        [(equal? expr '(not %)) '(not %)]
        [(and (equal? (car expr) 'if)
              (equal? (cadr expr) '%))
         `(if % ,(cvt-expr (caddr expr)) ,(cvt-expr (cadddr expr)))]
        [#t `(list ,@(map cvt-expr expr))]))

(define ns (make-base-namespace))

(define (to-func expr)
  (eval `(lambda (%) ,(cvt-expr expr))) ns)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (random-symbol)
  (let ([type (random 2)])
    (if (= type 0)
        (car (random-sample '(+ - * / = ? @) 1))
        (merge-symbol (car (random-sample '(+ - * / = ? @) 1))
                      (car (random-sample '(+ - * / = ? @) 1))))))

(define (merge-symbol x y)
  (let* ([str-x (symbol->string x)]
         [str-y (symbol->string y)]
         [str-all (string-append str-x "!" str-y)])
    (string->symbol str-all)))

(define (random-atom)
  (let ([type (random 4)])
    (cond [(= type 0) (car (random-sample '(#t #f) 1))]
          [(= type 1) (random -9 10)]
          [(= type 2) (car (random-sample '("+" "-" "*" "/" "=" "?" "@" "_") 1))]
          [(= type 3) (car (random-sample '(+ - * / = ? @) 1))])))

(define (random-list)
  (let ([len (random 4)])
    (for/list ([i (in-range len)])
      (random-datum))))

(define (random-datum)
  (let ([type (random 4)])
    (cond [(= type 0) (random-atom)]
          [(= type 1) (random-list)]
          [(= type 2) `(quote ,(random-datum))]
          [(= type 3) (list 'if (random-datum) (random-datum) (random-datum))]
          [(= type 4) `(lambda (,(random-atom)) (random-datum))])))




