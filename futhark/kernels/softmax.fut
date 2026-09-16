-- Numerically stable softmax along the last axis.
-- CONTRACT:
-- INPUT : [n] f32
-- OUTPUT : [n] f32, sum = 1.0, all values in (0,1)

def softmax [n] (xs: [n]f32) : [n]f32 =
  let m = reduce f32.max f32.lowest xs
      exps = map (\x -> f32.exp (x - m)) xs
      s = reduce (+) 0.0 exps
  in map (/ s) exps

def batch_softmax [b][n] (xss: [b][n]f32) : [b][n]f32 =
  map softmax xss

entry softmax_f32 [n] (xs: [n]f32) : [n]f32 = softmax xs
entry batch_softmax_f32 [b][n] (xss: [b][n]f32) : [b][n]f32 = batch_softmax xss
