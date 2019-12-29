#! /usr/bin/env racket
#lang racket

(provide main)

; —————————————————————————————————-——-———————————————————————————————

(require racket/engine)
(require "util.rkt")
(require "test-cases.rkt")

(define max-time-ms 600)

(define (tester-one expr-compare test)
  (with-handlers ([(lambda (_) #t) (lambda (_) 're)])
    (let* ([lhs (test-case-lhs test)]
           [rhs (test-case-rhs test)]
           [ans (test-case-ans test)]
           [eng (engine (lambda (_) (expr-compare lhs rhs)))]
           [exec-result (engine-run max-time-ms eng)])
      (cond [(not exec-result) (engine-kill eng)
                               'tle]
            [(equal? (engine-result eng) ans) 'ac]
            [#t 'wa]))))

(define (tester-all expr-compare report-port all-tests)
  (define all-results
    (for/list ([test all-tests])
      (printf ".")
      (flush-output)
      (tester-one expr-compare test)))
  (define (count-symbol sym lst)
    (count (lambda (x) (equal? sym x)) lst))
  (define ac-cnt (count-symbol 'ac all-results))
  (define wa-cnt (count-symbol 'wa all-results))
  (define re-cnt (count-symbol 're all-results))
  (define tle-cnt (count-symbol 'tle all-results))
  (printf "~%")
  (for ([ret all-results]
        [i (in-naturals)])
      (fprintf report-port "#~a: ~a~%" (~a (+ i 1) #:min-width 2 #:align 'right) ret))
  (fprintf report-port "~% ac: ~a wa: ~a re: ~a tle: ~a~%" ac-cnt wa-cnt re-cnt tle-cnt)
  (fprintf report-port "SCORE: ~a / ~a~%" (* 2 ac-cnt) (* 2 (+ ac-cnt wa-cnt re-cnt tle-cnt))))

(define (for-all-submission test-dir test-main)
  (for ([sub-dir (directory-list test-dir)])
    (let* ([source-file (build-path test-dir sub-dir "expr-compare.ss")]
           [report-file (build-path test-dir sub-dir "report.txt")]
           [report-port (open-output-file report-file #:mode 'text #:exists 'replace)])
      (printf "Testing ~a ...~%" sub-dir)
      (with-handlers ([(lambda (_) #t)
                       (lambda (_)
                         (fprintf report-port "Unable to compile or require 'expr-compare.~%"))])
        (let ([expr-compare (dynamic-require source-file 'expr-compare (lambda () #f))])
          (test-main expr-compare report-port)))
      (close-output-port report-port))))

(define (test-main expr-compare report-port)
  (tester-all expr-compare report-port all-tests)
  (fprintf report-port "~% ===EXTRA=== ~%")
  (tester-all expr-compare report-port extra-tests))

(define main
  (command-line
   #:program "cs131-hw5-grader"
   #:args (dir-name)
   (for-all-submission dir-name test-main)))

