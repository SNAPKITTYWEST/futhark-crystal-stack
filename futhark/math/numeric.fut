-- Numerical primitives: reductions, scans, stencils.

def sum [n] (xs: [n]f32) : f32 = reduce (+) 0.0 xs
def product [n] (xs: [n]f32) : f32 = reduce (*) 1.0 xs
def maximum [n] (xs: [n]f32) : f32 = reduce f32.max f32.lowest xs
def minimum [n] (xs: [n]f32) : f32 = reduce f32.min f32.highest xs

def prefix_sum [n] (xs: [n]f32) : [n]f32 = scan (+) 0.0 xs

def stencil3 [n] (xs: [n]f32) : [n]f32 =
  map (\i ->
    let l = if i == 0 then xs[0] else xs[i-1]
        r = if i == n-1 then xs[n-1] else xs[i+1]
    in (l + xs[i] + r) / 3.0)
  (iota n)

entry numeric_sum [n] (xs: [n]f32) : f32 = sum xs
entry numeric_prefix_sum [n] (xs: [n]f32) : [n]f32 = prefix_sum xs
entry numeric_stencil3 [n] (xs: [n]f32) : [n]f32 = stencil3 xs
