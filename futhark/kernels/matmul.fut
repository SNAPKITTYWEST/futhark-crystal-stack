-- Batched matrix multiplication.
-- CONTRACT:
-- INPUT : A [m][k] f32, B [k][n] f32
-- OUTPUT : C [m][n] f32 where C[i,j] = sum_k A[i,k]*B[k,j]
-- INVARIANTS : shapes compatible; no NaN/Inf introduced if inputs finite
-- ERRORS : shape mismatch → Futhark runtime abort

def matmul [m][k][n] (a: [m][k]f32) (b: [k][n]f32) : [m][n]f32 =
  map (\ar ->
    map (\bc -> reduce (+) 0.0 (map2 (*) ar bc))
        (transpose b))
  a

def bmatmul [b][m][k][n] (as: [b][m][k]f32) (bs: [b][k][n]f32) : [b][m][n]f32 =
  map2 matmul as bs

entry matmul_f32 [m][k][n] (a: [m][k]f32) (b: [k][n]f32) : [m][n]f32 =
  matmul a b

entry bmatmul_f32 [b][m][k][n] (as: [b][m][k]f32) (bs: [b][k][n]f32) : [b][m][n]f32 =
  bmatmul as bs
