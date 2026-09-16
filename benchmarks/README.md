# Benchmarks

Measure the real stack — never claim speedups without numbers.

## What to measure

| Metric | How |
|--------|-----|
| TCP latency | client → server STATUS round-trip |
| Frame encode/decode | FrameCodec micro-bench |
| Event dispatch | router path until job enqueue |
| Host↔device transfer | (when CUDA present) cudaMemcpy timing |
| Kernel execution | Futhark entry timing (`futhark bench`) |
| End-to-end | full COMPUTE request latency |
| Throughput | concurrent clients × requests/s |
| Queue saturation | time-to-QueueFull under load |
| Recovery | reconnect after forced disconnect |

## Running Futhark micro-benchmarks

```bash
cd futhark
futhark bench kernels/matmul.fut --backend=multicore
# or --backend=cuda when available
```

## Crystal side

Build the example client and time many STATUS or COMPUTE round-trips:

```bash
crystal build examples/client.cr -o /tmp/fc-client --release
```

## Comparison points

When a CUDA machine is available, compare:

- Crystal → Futhark multicore → CPU
- Crystal → Futhark CUDA → GPU
- (optional) hand-written CUDA baseline for matmul/conv kernels

Document raw numbers; do not claim superiority without data.
