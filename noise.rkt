#lang typed/racket

; Direct translation of:
; http://webstaff.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf

(provide
 perlin
 simplex)

(require
 racket/flonum)

(: grad3 (Vectorof (Vector Flonum Flonum Flonum)))
(define grad3
  '#(#( 1.0  1.0  0.0) #(-1.0  1.0  0.0) #( 1.0 -1.0  0.0) #(-1.0 -1.0  0.0)
     #( 1.0  0.0  1.0) #(-1.0  0.0  1.0) #( 1.0  0.0 -1.0) #(-1.0  0.0 -1.0) 
     #( 0.0  1.0  1.0) #( 0.0 -1.0  1.0) #( 0.0  1.0 -1.0) #( 0.0 -1.0 -1.0)))

(: p (Vectorof Byte))
(define p 
  '#(151 160 137 91 90 15 131 13 201 95 96 53 194 233 7 
     225 140 36 103 30 69 142 8 99 37 240 21 10 23 190 6 
     148 247 120 234 75 0 26 197 62 94 252 219 203 117 35 
     11 32 57 177 33 88 237 149 56 87 174 20 125 136 171 
     168 68 175 74 165 71 134 139 48 27 166 77 146 158 
     231 83 111 229 122 60 211 133 230 220 105 92 41 55 
     46 245 40 244 102 143 54 65 25 63 161 1 216 80 73 
     209 76 132 187 208 89 18 169 200 196 135 130 116 188 
     159 86 164 100 109 198 173 186 3 64 52 217 226 250 
     124 123 5 202 38 147 118 126 255 82 85 212 207 206 
     59 227 47 16 58 17 182 189 28 42 223 183 170 213 119 
     248 152 2 44 154 163 70 221 153 101 155 167 43 172 9 
     129 22 39 253 19 98 108 110 79 113 224 232 178 185 
     112 104 218 246 97 228 251 34 242 193 238 210 144 12 
     191 179 162 241 81 51 145 235 249 14 239 107 49 192 
     214 31 181 199 106 157 184 84 204 176 115 121 50 45 
     127 4 150 254 138 236 205 93 222 114 67 29 24 72 243 
     141 128 195 78 66 215 61 156 180))

; To remove the need for index wrapping, double the permutation table length
(: perm (Vectorof Byte))
(define perm (vector-append p p))

; This method is a *lot* faster than using (int)Math.floor(x)
; TODO: Not sure if this is actually true in Racket
(: fast-floor (Flonum -> Integer))
(define (fast-floor x)
  (fl->exact-integer (floor x)))

(: dot ((Vector Flonum Flonum Flonum) Flonum Flonum Flonum -> Flonum))
(define (dot g x y z)
   (+ (* (vector-ref g 0) x)
      (* (vector-ref g 1) y)
      (* (vector-ref g 2) z)))

(: mix (Flonum Flonum Flonum -> Flonum))
(define (mix a b t)
  (+ (* (- 1.0 t) a) (* t b)))

(: fade (Flonum -> Flonum))
(define (fade t)
  (* t t t (+ (* t (- (* t 6.0) 15.0)) 10.0)))

; Classic Perlin noise, 3D version
(: perlin
   (case-> (Flonum -> Flonum)
           (Flonum Flonum -> Flonum)
           (Flonum Flonum Flonum -> Flonum)))
(define (perlin x [y 0.0] [z 0.0])
  ; Find unit grid cell containing point
  (: X Integer) (: Y Integer) (: Z Integer)
  (define X (fast-floor x))
  (define Y (fast-floor y))
  (define Z (fast-floor z))
  
  ; Get relative xyz coordinates of point within that cell
  (set! x (- x X))
  (set! y (- y Y))
  (set! z (- z Z))

  ; Wrap the integer cells at 255 (smaller integer period can be introduced here)
  (set! X (bitwise-and X 255))
  (set! Y (bitwise-and Y 255))
  (set! Z (bitwise-and Z 255))
  
  ; Calculate a set of eight hashed gradient indices
  (: gi000 Integer) (: gi001 Integer) (: gi010 Integer) (: gi011 Integer)
  (: gi100 Integer) (: gi101 Integer) (: gi110 Integer) (: gi111 Integer)
  (define gi000 (remainder (vector-ref perm (+ X   (vector-ref perm (+ Y   (vector-ref perm Z))))) 12))
  (define gi001 (remainder (vector-ref perm (+ X   (vector-ref perm (+ Y   (vector-ref perm (+ Z 1)))))) 12))
  (define gi010 (remainder (vector-ref perm (+ X   (vector-ref perm (+ Y 1 (vector-ref perm Z))))) 12))
  (define gi011 (remainder (vector-ref perm (+ X   (vector-ref perm (+ Y 1 (vector-ref perm (+ Z 1)))))) 12))
  (define gi100 (remainder (vector-ref perm (+ X 1 (vector-ref perm (+ Y   (vector-ref perm Z))))) 12))
  (define gi101 (remainder (vector-ref perm (+ X 1 (vector-ref perm (+ Y   (vector-ref perm (+ Z 1)))))) 12))
  (define gi110 (remainder (vector-ref perm (+ X 1 (vector-ref perm (+ Y 1 (vector-ref perm Z))))) 12))
  (define gi111 (remainder (vector-ref perm (+ X 1 (vector-ref perm (+ Y 1 (vector-ref perm (+ Z 1)))))) 12))
  
  ; Calculate noise contributions from each of the eight corners
  (: n000 Flonum) (: n001 Flonum) (: n010 Flonum) (: n011 Flonum)
  (: n100 Flonum) (: n101 Flonum) (: n110 Flonum) (: n111 Flonum)
  (define n000 (dot (vector-ref grad3 gi000) x       y       z))
  (define n100 (dot (vector-ref grad3 gi100) (- x 1) y       z))
  (define n010 (dot (vector-ref grad3 gi010) x       (- y 1) z))
  (define n110 (dot (vector-ref grad3 gi110) (- x 1) (- y 1) z))
  (define n001 (dot (vector-ref grad3 gi001) x       y       (- z 1)))
  (define n101 (dot (vector-ref grad3 gi101) (- x 1) y       (- z 1)))
  (define n011 (dot (vector-ref grad3 gi011) x       (- y 1) (- z 1)))
  (define n111 (dot (vector-ref grad3 gi111) (- x 1) (- y 1) (- z 1)))
  
  ; Compute the fade curve value for each of x, y, z
  (: u Flonum) (: v Flonum) (: w Flonum)
  (define u (fade x))
  (define v (fade y))
  (define w (fade z))
  
  ; Interpolate along x the contributions from each of the corners
  (: nx00 Flonum) (: nx01 Flonum) (: nx10 Flonum) (: nx11 Flonum)
  (define nx00 (mix n000 n100 u))
  (define nx01 (mix n001 n101 u))
  (define nx10 (mix n010 n110 u))
  (define nx11 (mix n011 n111 u))
  
  ; Interpolate the four results along y
  (: nxy0 Flonum) (: nxy1 Flonum)
  (define nxy0 (mix nx00 nx10 v))
  (define nxy1 (mix nx01 nx11 v))
  
  ; Interpolate the two last results along z
  (mix nxy0 nxy1 w))

; 3D simplex noise
(: F3 Flonum) (: G3 Flonum)
(define F3 (/ 1.0 3.0)) ; Very nice and simple skew factor for 3D
(define G3 (/ 1.0 6.0)) ; Very nice and simple unskew factor, too
(: simplex 
   (case-> (Flonum -> Flonum)
           (Flonum Flonum -> Flonum)
           (Flonum Flonum Flonum -> Flonum)))
(define (simplex xin [yin 0.0] [zin 0.0])
  ; Skew the input space to determine which simplex cell we're in
  (: s Flonum)
  (define s (* (+ xin yin zin) F3)) 
  
  (: i Integer) (: j Integer) (: k Integer)
  (define i (fast-floor (+ xin s)))
  (define j (fast-floor (+ yin s)))
  (define k (fast-floor (+ zin s)))
  
  (: t Flonum)
  (define t (real->double-flonum (* (+ i j k) G3)))
  
  (: X0 Flonum) (: Y0 Flonum) (: Z0 Flonum)
  (: x0 Flonum) (: y0 Flonum) (: z0 Flonum)
  (define X0 (- i t)) ; Unskew the cell origin back to (x,y,z) space
  (define Y0 (- j t))
  (define Z0 (- k t))
  (define x0 (- xin X0)) ; The x,y,z distances from the cell origin
  (define y0 (- yin Y0))
  (define z0 (- zin Z0))
  
  ; For the 3D case, the simplex shape is a slightly irregular tetrahedron.
  ; Determine which simplex we are in.
  (: i1 Integer) (: j1 Integer) (: k1 Integer) 
  (: i2 Integer) (: j2 Integer) (: k2 Integer) 
  (define-values (i1 j1 k1 i2 j2 k2)
    (cond 
      [(and (>= x0 y0) (>= y0 z0)) (values 1 0 0 1 1 0)]   ; X Y Z order
      [(and (>= x0 y0) (>= x0 z0)) (values 1 0 0 1 0 1)]   ; X Z Y order
      [(>= x0 y0)                  (values 0 0 1 1 0 1)]   ; Z X Y order
      [(< y0 z0)                   (values 0 0 1 0 1 1)]   ; Z Y X order
      [(< x0 z0)                   (values 0 1 0 0 1 1)]   ; Y Z X order
      [else                        (values 0 1 0 1 1 0)])) ; Y X Z order
  
  ; A step of (1,0,0) in (i,j,k) means a step of (1-c,-c,-c) in (x,y,z),
  ; a step of (0,1,0) in (i,j,k) means a step of (-c,1-c,-c) in (x,y,z), and
  ; a step of (0,0,1) in (i,j,k) means a step of (-c,-c,1-c) in (x,y,z), where
  ; c = 1/6.
  (: x1 Flonum) (: y1 Flonum) (: z1 Flonum) 
  (: x2 Flonum) (: y2 Flonum) (: z2 Flonum) 
  (: x3 Flonum) (: y3 Flonum) (: z3 Flonum) 
  (define x1 (+ (- x0 i1) G3)) ; Offsets for second corner in (x,y,z) coords
  (define y1 (+ (- y0 j1) G3))
  (define z1 (+ (- z0 k1) G3))
  (define x2 (+ (- x0 i2) (* 2.0 G3))) ; Offsets for third corner in (x,y,z) coords
  (define y2 (+ (- y0 j2) (* 2.0 G3))) 
  (define z2 (+ (- z0 k2) (* 2.0 G3)))
  (define x3 (+ (- x0 1.0) (* 3.0 G3))) ;  Offsets for last corner in (x,y,z) coords
  (define y3 (+ (- y0 1.0) (* 3.0 G3)))
  (define z3 (+ (- z0 1.0) (* 3.0 G3)))
  
  ; Work out the hashed gradient indices of the four simplex corners
  (: ii Integer) (: jj Integer) (: kk Integer) 
  (define ii (bitwise-and i 255))
  (define jj (bitwise-and j 255))
  (define kk (bitwise-and k 255))
  
  (: gi0 Integer) (: gi1 Integer) (: gi2 Integer) (: gi3 Integer) 
  (define gi0 (remainder (vector-ref perm (+ ii    (vector-ref perm (+ jj    (vector-ref perm kk))))) 12))
  (define gi1 (remainder (vector-ref perm (+ ii i1 (vector-ref perm (+ jj j1 (vector-ref perm (+ kk k1)))))) 12))
  (define gi2 (remainder (vector-ref perm (+ ii i2 (vector-ref perm (+ jj j2 (vector-ref perm (+ kk k2)))))) 12))
  (define gi3 (remainder (vector-ref perm (+ ii 1  (vector-ref perm (+ jj 1  (vector-ref perm (+ kk 1)))))) 12))
  
  ; Calculate the contribution from the four corners
  (: t0 Flonum) (: n0 Flonum)
  (define t0 (- 0.5 (* x0 x0) (* y0 y0) (* z0 z0)))
  (define n0
    (if (< t0 0)
        0.0
        (begin
          (set! t0 (* t0 t0))
          (* t0 t0 (dot (vector-ref grad3 gi0) x0 y0 z0)))))
  
  (: t1 Flonum) (: n1 Flonum)
  (define t1 (- 0.5 (* x1 x1) (* y1 y1) (* z1 z1)))
  (define n1
    (if (< t1 0)
        0.0
        (begin
          (set! t1 (* t1 t1))
          (* t1 t1 (dot (vector-ref grad3 gi1) x1 y1 z1)))))
  
  (: t2 Flonum) (: n2 Flonum)
  (define t2 (- 0.5 (* x2 x2) (* y2 y2) (* z2 z2)))
  (define n2
    (if (< t2 0)
        0.0
        (begin
          (set! t2 (* t2 t2))
          (* t2 t2 (dot (vector-ref grad3 gi2) x2 y2 z2)))))
  
  (: t3 Flonum) (: n3 Flonum)
  (define t3 (- 0.5 (* x3 x3) (* y3 y3) (* z3 z3)))
  (define n3
    (if (< t3 0)
        0.0
        (begin
          (set! t3 (* t3 t3))
          (* t3 t3 (dot (vector-ref grad3 gi3) x3 y3 z3)))))
  
  ; Add contributions from each corner to get the final noise value.
  ; The result is scaled to stay just inside [-1,1]
  ; NOTE: This scaling factor seems to work better than the given one
  ;       I'm not sure why
  (* 76.5 (+ n0 n1 n2 n3)))