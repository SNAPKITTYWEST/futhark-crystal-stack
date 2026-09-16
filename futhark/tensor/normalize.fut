-- Layer normalization: normalize along the last axis.

def layer_norm [n] (xs: [n]f32) (eps: f32) : [n]f32 =
  let mean = reduce (+) 0.0 xs / f32.i64 n
      var = reduce (+) 0.0 (map (\x -> let d = x - mean in d * d) xs)
             / f32.i64 n
      std = f32.sqrt (var + eps)
  in map (\x -> (x - mean) / std) xs

def batch_layer_norm [b][n] (xss: [b][n]f32) (eps: f32) : [b][n]f32 =
  map (\xs -> layer_norm xs eps) xss

entry layer_norm_f32 [n] (xs: [n]f32) (eps: f32) : [n]f32 =
  layer_norm xs eps

entry batch_layer_norm_f32 [b][n] (xss: [b][n]f32) (eps: f32) : [b][n]f32 =
  batch_layer_norm xss eps
