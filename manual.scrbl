#lang scribble/manual

@(require scribble/eval
          (for-label racket
                     images/flomap
                     racket/flonum))

@title{thing: Prototype-based object system for Racket}
@author{@author+email["John-Paul Verkamp" "me@jverkamp.com"]}

This package provides a prototype object-based system for Racket.

@bold{Development} Development of this library is hosted by @hyperlink["http://github.com"]{GitHub} at the following project page:

@url{https://github.com/jpverkamp/thing/}

@section{Installation}

@commandline{raco pkg install github://github.com/jpverkamp/thing/master}

@section{Functions}

@defproc[(make-thing 
           [base thing? void] 
           [kv (or/c (List symbol? any ...)
                     (Pairof symbol? any))] ...) 
         thing?]{
  Create a new thing, given an optional base to extend.
  
  Each key, value pair will be stored with the thing and will override
  the given base values (if any).
  
  If a kv pair is specified as @code{[(name arg ...) body ...]}, it will be 
  converted to  @code{[name (λ (arg ...) body ...)]} and will be available to
   @code{thing-call}.
}

@defproc[(define-thing 
           [name string?] 
           [base thing? void] 
           [kv (or/c (List symbol? any ...)
                     (Pairof symbol? any))] ...)
         thing?]{
  Create a new thing and bind it to a name.
  
  Equivalent to  @code{(define name (make-thing ...))}.
}
                 
@defproc[(thing-get [thing thing?] [key symbol?] [default any void]) any]{
  Access a property in a thing.
  
  If the key doesn't exist, return default (if set).
}

@defproc[(thing-set! [thing thing?] [key symbol?] [val any]) void]{
  Set a property in a thing.
  
  If the key doesn't previously exist, it will be created.
  
  Previous children of this thing will not be modified, future children will
  have the new attribute set.
}
                 
@defproc[(thing-call [thing thing?] [key symbol?] [args any] ...) any]{
  Call a property defined in a thing.
  
  Equivalent to  @code{((thing-get thing key) args ...)}.
}

@section{Examples}

@interaction[
(require "thing/main.rkt")

; Create a basic thing
(define-thing color
  [red 0]
  [green 0]
  [blue 0])

; Extend things
(define-thing red color
  [red 255])

; Get values, with optional default
(thing-get red 'red) 
(thing-get red 'orange) 
(thing-get red 'orange 9001) 

; Set value, existing or not
(thing-set! red 'red 1.0)
(thing-set! red 'purple 0.5)

; Setting values does not change parent
(thing-get red 'purple)

; Values can be functions
(define-thing chatterbox
  [(talk name) (format "~a says hello world!" name)])

; Call functional values directly
(thing-call chatterbox 'talk "steve")
]

@section{License}

This program is free software: you can redistribute it and/or modify it
under the terms of the 
@hyperlink["http://www.gnu.org/licenses/lgpl.html"]{GNU Lesser General
Public License} as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License and GNU Lesser General Public License for more
details.