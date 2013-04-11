Perlin and simple noise generators for Racket.

    ; Generate 1D/2D/3D Perlin noise
    ; Always uses a 3D generator in the background
    (perlin x [y 0.0] [z 0.0])
    
    ; Generate 1D/2D/3D simplex noise
    ; Always uses a 3D generator in the background
    (simplex x [y 0.0] [z 0.0])