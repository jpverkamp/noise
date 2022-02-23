#lang setup/infotab

(define name "noise")
(define scribblings '(("manual-noise.scrbl" ())))

(define blurb '("Perlin/Simplex noise generators."))
(define primary-file "main.rkt")
(define homepage "https://github.com/jpverkamp/noise/")

(define deps
  '("base"
    "typed-racket-lib"))

(define build-deps
  '("images-doc"
    "images-lib"
    "racket-doc"
    "scribble-lib"))

(define version "1.0.1")
(define release-notes '("Initial release + documentation updates."))

(define required-core-version "5.3")
