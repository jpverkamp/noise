#lang racket

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

(printf " perlin: ")
(time 
 (for ([x (in-range 256)])
   (for ([y (in-range 256)])
     (perlin (/ x 256.0) (/ y 256.0))))
 (void))

(printf "simplex: ")
(time 
 (for ([x (in-range 256)])
   (for ([y (in-range 256)])
     (simplex (/ x 256.0) (/ y 256.0))))
 (void))

(printf " colors: ")
(time 
 (for ([x (in-range 256)])
   (for ([y (in-range 256)])
     (simplex (/ x 256.0) (/ y 256.0) -1.0)
     (simplex (/ x 256.0) (/ y 256.0)  0.0)
     (simplex (/ x 256.0) (/ y 256.0)  1.0)))
 (void))