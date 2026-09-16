-- LU decomposition without pivoting.
-- For well-conditioned matrices; extend to partial pivoting for production.

def lu [n] (a: [n][n]f32) : ([n][n]f32, [n][n]f32) =
  let (l, u, _) =
    loop (l, u, a_work) = (replicate n (replicate n 0.0),
                           replicate n (replicate n 0.0),
                           a)
    for k < n do
      let piv = a_work[k, k]
      let u_k = map (\j -> a_work[k, j]) (iota n)
      let l_col = map (\i -> if i > k then a_work[i, k] / piv else 0.0) (iota n)
      let a' = map (\i ->
                 if i > k
                 then map (\j -> a_work[i, j] - l_col[i] * u_k[j]) (iota n)
                 else a_work[i])
               (iota n)
      let l' = map (\i -> if i == k then l[i] with [k] = 1.0
                          else if i > k then l[i] with [k] = l_col[i]
                          else l[i])
               (iota n)
      let u' = u with [k] = u_k
      in (l', u', a')
  in (l, u)

entry lu_f32 [n] (a: [n][n]f32) : ([n][n]f32, [n][n]f32) = lu a
