#lang racket

(require "noisy-image-test.rkt")

(time (begin (build-perlin-image 256 256) (void)))
(time (begin (build-simplex-image 256 256) (void)))
(time (begin (build-colored-simplex-image 256 256) (void)))
