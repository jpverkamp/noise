#lang racket

(require
 picturing-programs
 "noise.rkt")

(provide
 build-perlin-image
 build-simplex-image
 build-colored-simplex-image)

; Clamp a number in the given range to [0, 1]
(define (clamp min max n)
  (/ (- n min) (- max min)))

; Convert floating point rgb to a color
(define (float-color r g b)
  (color (inexact->exact (floor (* 255 r)))
         (inexact->exact (floor (* 255 g)))
         (inexact->exact (floor (* 255 b)))))

; Build an image using perlin noise
(define (build-perlin-image w h #:scale [scale 1.0])
  (build-image 
   w h
   (lambda (x y)
     (define g (clamp -1.0 1.0 (perlin (real->double-flonum (* scale (/ x w)))
                                       (real->double-flonum (* scale (/ y h))))))
     (float-color g g g))))

; Build an image using simplex noise
(define (build-simplex-image w h #:scale [scale 1.0])
  (build-image 
   w h
   (lambda (x y)
     (define g (clamp -1.0 1.0 (simplex (real->double-flonum (* scale (/ x w)))
                                        (real->double-flonum (* scale (/ y h))))))
     (float-color g g g))))

; Build a more colorful image using simplex noise
(define (build-colored-simplex-image w h #:scale [scale 1.0])
  (build-image
   w h
   (lambda (x y)
     (float-color
      (clamp -1.0 1.0 (simplex (real->double-flonum (* scale (/ x w))) 
                               (real->double-flonum (* scale (/ y h))) -1.0))
      (clamp -1.0 1.0 (simplex (real->double-flonum (* scale (/ x w))) 
                               (real->double-flonum (* scale (/ y h)))  0.0))
      (clamp -1.0 1.0 (simplex (real->double-flonum (* scale (/ x w))) 
                               (real->double-flonum (* scale (/ y h)))  1.0))))))
                  
                  
                  
                  