Perlin and simple noise generators for Racket.

    ; Generate 1D/2D/3D Perlin noise with an optional scaling factor
    ; Always uses a 3D generator in the background
    (perlin x [y 0.0] [z 0.0] #:scale [scale 1.0])
    
    ; Generate 1D/2D/3D simplex noise with an optional scaling factor
    ; Always uses a 3D generator in the background
    (simplex x [y 0.0] [z 0.0] #:scale [scale 1.0])