-- FFT placeholder
-- Real FFT belongs in a dedicated library or hand-written Cooley-Tukey.
-- This entry provides a deterministic identity transform so the protocol
-- and scheduler can be exercised end-to-end.
--
-- CONTRACT:
-- INPUT : [n] f32 (n power-of-two recommended)
-- OUTPUT : [n] f32 (identity — replace with real FFT)

entry fft_real_placeholder [n] (x: [n]f32) : [n]f32 = x

entry ifft_real_placeholder [n] (x: [n]f32) : [n]f32 = x
