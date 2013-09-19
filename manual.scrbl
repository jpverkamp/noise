#lang scribble/manual

@(require scribble/eval
          (for-label racket
                     images/flomap
                     racket/flonum))

@title{noise: Perlin/Simplex noise generators}
@author{@author+email["John-Paul Verkamp" "me@jverkamp.com"]}

This package provides Racket versions of the 
@hyperlink["https://en.wikipedia.org/wiki/Perlin_noise"]{Perlin} and 
@hyperlink["https://en.wikipedia.org/wiki/Simplex_noise"]{Simplex} noise generators.

@bold{Development} Development of this library is hosted by @hyperlink["http://github.com"]{GitHub} at the following project page:

@url{https://github.com/jpverkamp/noise/}

@section{Installation}

@commandline{raco pkg install github://github.com/jpverkamp/noise/master}

@section{Functions}

@defproc[(perlin [x real?] [y real? 0.0] [z real? 0.0]) real?]{
  Calculates the 1D, 2D, or 3D Perlin noise value at the given point.
}
               
@defproc[(simplex? [x real?] [y real? 0.0] [z real? 0.0]) real?]{
  Calculates the 1D, 2D, or 3D Simplex noise value at the given point.
}

@section{Examples}

@interaction[
(require images/flomap racket/flonum noise)
(define (clamp min max n)
  (/ (- n min) (- max min)))

(define (build-perlin-image w h #:scale [scale 1.0])
  (flomap->bitmap
   (build-flomap* 
    3 w h
    (lambda (x y)
      (define g (clamp -1.0 1.0 (perlin (* scale (/ x w)) (* scale (/ y h)))))
      (vector g g g)))))
(build-perlin-image 256 256 #:scale 10.0)

(define (build-simplex-image w h #:scale [scale 1.0])
  (flomap->bitmap
   (build-flomap* 
    3 w h
    (lambda (x y)
      (define g (clamp -1.0 1.0 (simplex (* scale (/ x w)) (* scale (/ y h)))))
      (vector g g g)))))
(build-simplex-image 256 256 #:scale 10.0)

(define (build-colored-simplex-image w h #:scale [scale 1.0])
  (flomap->bitmap
   (build-flomap* 
    3 w h
    (lambda (x y)
      (vector
       (clamp -1.0 1.0 (simplex (* scale (/ x w)) (* scale (/ y h)) -1.0))
       (clamp -1.0 1.0 (simplex (* scale (/ x w)) (* scale (/ y h))  0.0))
       (clamp -1.0 1.0 (simplex (* scale (/ x w)) (* scale (/ y h))  1.0)))))))
(build-colored-simplex-image 256 256 #:scale 10.0)
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