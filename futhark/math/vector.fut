-- Pure mathematical vector operations.
-- No hidden orchestration; every transformation is explicit.

def dotprod [n] (xs: [n]f32) (ys: [n]f32) : f32 =
  reduce (+) 0.0 (map2 (*) xs ys)

def norm [n] (xs: [n]f32) : f32 =
  f32.sqrt (dotprod xs xs)

def normalize [n] (xs: [n]f32) : [n]f32 =
  let n = norm xs
  in if n == 0.0 then xs else map (/ n) xs

def cosine_similarity [n] (xs: [n]f32) (ys: [n]f32) : f32 =
  let d = dotprod xs ys
      nx = norm xs
      ny = norm ys
  in if nx == 0.0 || ny == 0.0 then 0.0 else d / (nx * ny)

entry vector_dotprod [n] (xs: [n]f32) (ys: [n]f32) : f32 =
  dotprod xs ys

entry vector_normalize [n] (xs: [n]f32) : [n]f32 =
  normalize xs
