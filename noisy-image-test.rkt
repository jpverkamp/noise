#lang typed/racket

(require
 images/flomap
 racket/flonum
 "noise.rkt")

(provide
 build-perlin-image
 build-simplex-image
 build-colored-simplex-image)

; Clamp a number in the given range to [0, 1]
(: clamp (Real Real Real -> Real))
(define (clamp min max n)
  (/ (- n min) (- max min)))

; Build an image using perlin noise
(: build-perlin-image (Integer Integer [#:scale Real] -> flomap))
(define (build-perlin-image w h #:scale [scale 1.0])
  (build-flomap* 
   3 w h
   (lambda (x y)
     (: g Real)
     (define g (clamp -1.0 1.0 (perlin (* scale (/ x w)) (* scale (/ y h)))))
     (vector g g g))))

; Build an image using simplex noise
(: build-simplex-image (Integer Integer [#:scale Real] -> flomap))
(define (build-simplex-image w h #:scale [scale 1.0])
  (build-flomap* 
   3 w h
   (lambda (x y)
     (: g Real)
     (define g (clamp -1.0 1.0 (simplex (* scale (/ x w) (* scale (/ y h))))))
     (vector g g g))))

; Build a more colorful image using simplex noise
(: build-colored-simplex-image (Integer Integer [#:scale Real] -> flomap))
(define (build-colored-simplex-image w h #:scale [scale 1.0])
  (build-flomap*
   3 w h
   (lambda (x y)
     (vector
      (clamp -1.0 1.0 (simplex (* scale (/ x w)) (* scale (/ y h)) -1.0))
      (clamp -1.0 1.0 (simplex (* scale (/ x w)) (* scale (/ y h))  0.0))
      (clamp -1.0 1.0 (simplex (* scale (/ x w)) (* scale (/ y h))  1.0))))))