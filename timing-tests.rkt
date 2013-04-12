#lang typed/racket

(require 
 "noise.rkt"
 "noisy-image-test.rkt")

(printf "--- images ---\n")

(printf " perlin: ")
(time (begin (build-perlin-image 256 256) (void)))

(printf "simplex: ")
(time (begin (build-simplex-image 256 256) (void)))

(printf " colors: ")
(time (begin (build-colored-simplex-image 256 256) (void)))

(printf "\n--- no images ---\n")

(: for-test ((Real Real -> Real) -> Void))
(define (for-test f)
  (printf "~a: " f)
  (time 
   (for ([x (in-range 256)])
     (for ([y (in-range 256)])
       (f (/ x 256.0) (/ y 256.0))))
   (void)))
 
(for-test perlin)
(for-test simplex)

(printf "\n--- no images or loops ---\n")

(: let-loop-test ((Real Real -> Real) -> Void))
(define (let-loop-test f)
  (printf "~a: " f)
  (time
   (let: loop : Void ([x : Integer 0] [y : Integer 0])
     (cond
       [(= x 256) (void)]
       [(= y 256) (loop (+ x 1) 0)]
       [else
        (f (/ x 256.0) (/ y 256.0))
        (loop x (+ y 1))]))))

(let-loop-test perlin)
(let-loop-test simplex)
