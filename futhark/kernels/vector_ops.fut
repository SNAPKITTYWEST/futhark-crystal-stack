-- Vector / element-wise operations
-- CONTRACT:
-- All ops are pure, shape-preserving unless noted.

entry map_add_scalar [n] (x: [n]f32) (s: f32) : [n]f32 =
  map (+s) x

entry map_mul [n] (a: [n]f32) (b: [n]f32) : [n]f32 =
  map2 (*) a b

entry map_fma [n] (a: [n]f32) (b: [n]f32) (c: [n]f32) : [n]f32 =
  map3 (\x y z -> x * y + z) a b c

entry l2_norm [n] (x: [n]f32) : f32 =
  f32.sqrt (reduce (+) 0f32 (map (\v -> v*v) x))

entry normalize [n] (x: [n]f32) : [n]f32 =
  let nrm = l2_norm x
  in if nrm == 0f32 then x else map (/nrm) x

entry dot [n] (a: [n]f32) (b: [n]f32) : f32 =
  reduce (+) 0f32 (map2 (*) a b)

entry axpy [n] (alpha: f32) (x: [n]f32) (y: [n]f32) : [n]f32 =
  map2 (\xi yi -> alpha * xi + yi) x y
