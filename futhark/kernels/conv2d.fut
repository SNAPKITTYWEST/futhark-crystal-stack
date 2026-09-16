-- 2D convolution, valid padding, single input/output channel.
-- CONTRACT:
-- INPUT : image [h][w] f32, kernel [kh][kw] f32
-- OUTPUT : [h-kh+1][w-kw+1] f32 (valid padding)
-- INVARIANT : linear filter; no bias term

def conv2d_valid [h][w][kh][kw]
    (img: [h][w]f32) (ker: [kh][kw]f32) : [h-kh+1][w-kw+1]f32 =
  let oh = h - kh + 1
      ow = w - kw + 1
  in map (\i ->
       map (\j ->
         reduce (+) 0.0
           (flatten (tabulate_2d kh kw (\ki kj -> img[i+ki, j+kj] * ker[ki, kj]))))
         (iota ow))
     (iota oh)

def clamp_idx (i: i64) (n: i64) : i64 =
  if i < 0 then 0 else if i >= n then n-1 else i

entry conv2d_valid_f32 [h][w][kh][kw]
    (img: [h][w]f32) (ker: [kh][kw]f32) : [h-kh+1][w-kw+1]f32 =
  conv2d_valid img ker

-- Same-size convolution with clamp borders
entry conv2d_same_f32 [h][w][kh][kw]
    (img: [h][w]f32) (ker: [kh][kw]f32) : [h][w]f32 =
  let ph = kh / 2
      pw = kw / 2
  in tabulate_2d h w (\i j ->
       reduce (+) 0f32
         (flatten (tabulate_2d kh kw (\ki kj ->
            let ii = clamp_idx (i + ki - ph) h
            let jj = clamp_idx (j + kj - pw) w
            in img[ii,jj] * ker[ki,kj]))))
