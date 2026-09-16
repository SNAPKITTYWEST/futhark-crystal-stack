# Mathematical Contracts

Every Futhark entry point is a pure function with an explicit contract.

## matmul_f32 / bmatmul_f32

| | |
|---|---|
| **Inputs** | `A : [m][k]f32`, `B : [k][n]f32` |
| **Output** | `C : [m][n]f32` |
| **Semantics** | `C[i,j] = Σ_k A[i,k] * B[k,j]` |
| **Invariants** | Finite inputs → finite outputs |
| **Errors** | Shape mismatch → runtime abort |

## softmax_f32 / batch_softmax_f32

- Numerically stable (subtract max before exp)
- Output sums to 1.0; all values in (0,1)

## conv2d_valid_f32 / conv2d_same_f32

- `valid`: output shape `[h-kh+1][w-kw+1]`
- `same`: output shape `[h][w]` with clamp border
- Linear filter; no bias term

## layer_norm_f32 / batch_layer_norm_f32

- Normalizes mean=0, std=1 along last axis
- `eps` prevents division by zero

## vector_ops

- `map_add_scalar`, `map_mul`, `map_fma`, `axpy` — element-wise, shape-preserving
- `l2_norm`, `dot` — reductions to scalar
- `normalize` — unit L2 (zero vector is identity)

## reduce_scan

- `reduce_sum/max/min` — associative reductions
- `inclusive_scan_sum` / `exclusive_scan_sum`

## stencil_1d_3pt / stencil_2d_5pt

Clamp border condition. Weights supplied as input.

## lu_f32

LU decomposition without pivoting. Well-conditioned matrices only; extend to partial pivoting for production use.

## fft_real_placeholder

Identity (placeholder). Replace with real Cooley-Tukey or library FFT for production.

---

All contracts are enforced by Futhark's type/shape system; the Crystal host never re-implements the mathematics.
