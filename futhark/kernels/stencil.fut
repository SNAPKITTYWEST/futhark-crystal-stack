-- Stencil operations (1-D and 2-D)
-- CONTRACT:
-- Boundary condition: clamp (edge values repeated)

def clamp_idx (i: i64) (n: i64) : i64 =
  if i < 0 then 0 else if i >= n then n-1 else i

entry stencil_1d_3pt [n] (x: [n]f32) (w: [3]f32) : [n]f32 =
  map (\i ->
         let a = x[clamp_idx (i-1) n]
         let b = x[i]
         let c = x[clamp_idx (i+1) n]
         in a*w[0] + b*w[1] + c*w[2]
      ) (iota n)

entry stencil_2d_5pt [h][w] (img: [h][w]f32) (k: [5]f32) : [h][w]f32 =
  -- k = [center, up, down, left, right]
  tabulate_2d h w (\i j ->
    let c = img[i,j]
    let u = img[clamp_idx (i-1) h, j]
    let d = img[clamp_idx (i+1) h, j]
    let l = img[i, clamp_idx (j-1) w]
    let r = img[i, clamp_idx (j+1) w]
    in c*k[0] + u*k[1] + d*k[2] + l*k[3] + r*k[4]
  )
