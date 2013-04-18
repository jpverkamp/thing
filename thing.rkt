#lang racket/base

(provide 
  define-thing
  make-thing			
  thing-get
  thing-set!
  thing-call)

(module+ test
  (require rackunit)
  (require test-engine/scheme-tests))

; A simple wrapper for things
(define-struct thing (data)
  #:constructor-name new-thing)
    
; A very simple prototype based object system
(define-syntax make-thing
  (syntax-rules ()
    ; Create an empty thing, bind a function
    [(_ [(k arg* ...) body* ...] rest ...)
     (let ([thing (make-thing rest ...)])
       (hash-set! (thing-data thing) 'k
                  (lambda (arg* ...)
                    body* ...))
       thing)]
    [(_ base [(k arg* ...) body* ...] rest ...)
     (let ([thing (make-thing base rest ...)])
       (hash-set! (thing-data thing) 'k
                  (lambda (arg* ...)
                    body* ...))
       thing)]
    ; Add a key/value pair to a thing
    [(_ [k v] rest ...)
     (let ([thing (make-thing rest ...)])
       (hash-set! (thing-data thing) 'k v)
       thing)]
    [(_ base [k v] rest ...)
     (let ([thing (make-thing base rest ...)])
       (hash-set! (thing-data thing) 'k v)
       thing)]
    ; Create an empty thing
    [(_)
     (new-thing (make-hasheq))]
    ; Copy an existing thing
    [(_ base)
     (if (thing? base)
         (new-thing (hash-copy (thing-data base)))
         (error 'make-thing "~a is not a thing to extend" base))]))

(module+ test
  ; Test creating a basic thing
  (define thing (make-thing))
  (check-true (thing? thing))
    
  ; Test extending a thing
  (define critter
    (make-thing thing
      [attack 10]
      [defense 10]
      [health 10]))
  (check-true (thing? critter))
  
  ; Test binding a method using the short form
  (define talking-critter 
    (make-thing critter
      [(say name) (format "~a says hello world!" name)]))
  (check-true (thing? talking-critter)))

; Shortcut to define a thing
(define-syntax-rule (define-thing name arg* ...)
  (define name (make-thing arg* ...)))

; Access a value from a thing
(define (thing-get thing key [default (void)])
  (cond
    [(not (thing? thing))
     (error 'thing-get "~a is not a thing" thing)]
    [(or (not (void? default))
         (hash-has-key? (thing-data thing) key))
     (hash-ref (thing-data thing) key default)]
    [else
     (error 'thing-get "~a does not contain a value for ~a" thing 'key)]))

(module+ test
  ; Test basic access
  (check-eq? (thing-get critter 'attack) 10)
  (check-true (procedure? (thing-get talking-critter 'say)))
  
  ; Test default access
  (check-eq? 'frog (thing-get critter 'test 'frog))
  
  ; Test failed access
  (check-error (thing-get critter 'test))
  
  ; Test using variables as parameters
  (check-equal?
   (for/list ([key (in-list '(attack defense health))])
     (thing-get critter key))
   '(10 10 10)))

; Set a value in a thing
(define (thing-set! thing key val)
  (cond
    [(not (thing? thing))
     (error 'thing-set! "~a is not a thing" thing)]
    [else
     (hash-set! (thing-data thing) key val)]))

(module+ test
  ; Test setting a value that already existed
  (thing-set! critter 'attack 15)
  (check-eq? (thing-get critter 'attack) 15)
  
  ; Make sure it didn't alter the child thing
  (check-eq? (thing-get talking-critter 'attack) 10)
  
  ; Test setting a value that didn't already exist
  (thing-set! critter 'mood 'happy)
  (check-eq? (thing-get critter 'mood) 'happy)
  
  ; Make sure it didn't alter the child thing
  (check-error (thing-get talking-critter 'mood)))

; Call a function stored in a thing
(define (thing-call thing key . args)
  (cond
    [(not (thing? thing))
     (error 'thing-call "~a is not a thing" thing)]
    [(thing-get thing key #f)
     => (lambda (f)
          (if (procedure? f)
              (apply f args)
              (error 'thing-call "~a is not a procedure in ~a, it is ~a"
                     key thing f)))]
    [else
     (error 'thing-get "~a does not contain a value for ~a" thing 'key)]))

; Call a function stored in a thing
(module+ test
  ; Check the call on talking
  (check-equal? 
   (thing-call talking-critter 'say "fred")
   "fred says hello world!")
  
  ; Create a long form method and test calling  it
  (define numbered-critter
    (make-thing critter
      [get-number (lambda () 3)]))
  (check-eq? (thing-call numbered-critter 'get-number) 3))