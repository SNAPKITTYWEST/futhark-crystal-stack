-- Pure mathematical helpers (no IO, no side effects)

module helpers = {
  def is_finite (x: f32) : bool =
    !(f32.isinf x) && !(f32.isnan x)

  def clamp (lo: f32) (hi: f32) (x: f32) : f32 =
    f32.max lo (f32.min hi x)

  def softmax [n] (x: [n]f32) : [n]f32 =
    let m = reduce f32.max (-f32.inf) x
    let e = map (\v -> f32.exp (v - m)) x
    let s = reduce (+) 0f32 e
    in map (/s) e

  def relu [n] (x: [n]f32) : [n]f32 =
    map (f32.max 0f32) x
}
