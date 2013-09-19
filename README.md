To install:

    raco pkg install github://github.com/jpverkamp/thing/master

A prototype based object system for Racket

Examples:

    ; Create a basic thing
    (define-thing color
      [red 0]
      [green 0]
      [blue 0])
    
    ; Extend things
    (define-thing red color
      [red 255])
    
    ; Get values, with optional default
    (thing-get red 'red) => 255
    (thing-get red 'orange) => *error*
    (thing-get red 'orange 9001) => 9001
    
    ; Set value, existing or not
    (thing-set! red 'red 1.0)
    (thing-set! red 'purple 0.5)
    
    ; Setting values does not change parent
    (thing-get red 'purple) => *error*
    
    ; Values can be functions
    (define-thing chatterbox
      [(talk name) (format "~a says hello world!" name)])
    
    ; Call functional values directly
    (thing-call chatterbox 'talk "steve") => "steve says hello world!")

