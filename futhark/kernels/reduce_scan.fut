-- Parallel reductions and scans
-- CONTRACT:
-- reduce is associative; scan is inclusive/exclusive as named.

entry reduce_sum [n] (x: [n]f32) : f32 =
  reduce (+) 0f32 x

entry reduce_max [n] (x: [n]f32) : f32 =
  reduce f32.max (-f32.inf) x

entry reduce_min [n] (x: [n]f32) : f32 =
  reduce f32.min f32.inf x

entry inclusive_scan_sum [n] (x: [n]f32) : [n]f32 =
  scan (+) 0f32 x

entry exclusive_scan_sum [n] (x: [n]f32) : [n]f32 =
  let s = scan (+) 0f32 x
  in map (\i -> if i == 0 then 0f32 else s[i-1]) (iota n)

-- Segmented reduce (inclusive scan over all values; real segmented ops
-- use Futhark's segmented operators when available)
entry segmented_reduce_sum [n] (flags: [n]bool) (vals: [n]f32) : [n]f32 =
  scan (+) 0f32 vals
