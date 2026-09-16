```
███████╗██╗   ██╗████████╗██╗  ██╗ █████╗ ██████╗ ██╗  ██╗
██╔════╝██║   ██║╚══██╔══╝██║  ██║██╔══██╗██╔══██╗██║ ██╔╝
█████╗  ██║   ██║   ██║   ███████║███████║██████╔╝█████╔╝ 
██╔══╝  ██║   ██║   ██║   ██╔══██║██╔══██║██╔══██╗██╔═██╗ 
██║     ╚██████╔╝   ██║   ██║  ██║██║  ██║██║  ██║██║  ██╗
╚═╝      ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝

         ██████╗██████╗ ██╗   ██╗███████╗████████╗ █████╗ ██╗     
        ██╔════╝██╔══██╗╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔══██╗██║     
        ██║     ██████╔╝ ╚████╔╝ ███████╗   ██║   ███████║██║     
        ██║     ██╔══██╗  ╚██╔╝  ╚════██║   ██║   ██╔══██║██║     
        ╚██████╗██║  ██║   ██║   ███████║   ██║   ██║  ██║███████╗
         ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝

         Python-free GPU compute stack — Futhark kernels + Crystal runtime
```

# futhark-crystal-stack

Python-free, high-performance declarative GPU mathematics engine with an asynchronous Crystal systems shell.

**Futhark** owns all mathematical specification and kernel generation (CUDA, multicore, or pure C). **Crystal** owns networking, event routing, scheduling, memory ownership, and process control.

---

## Repository layout

```
futhark-crystal-stack/
├── futhark/
│   ├── math/          vector.fut · numeric.fut · helpers.fut
│   ├── kernels/       matmul · softmax · conv2d · vector_ops
│   │                  reduce_scan · stencil · fft_placeholder
│   ├── tensor/        normalize.fut (layer norm)
│   ├── matrix/        lu.fut
│   └── Makefile
├── crystal/
│   ├── src/
│   │   ├── protocol/  opcodes · checksum (CRC-32C) · frame
│   │   ├── net/       framing (length-prefixed FrameIO)
│   │   ├── router/    EventRouter + backpressure
│   │   ├── scheduler/ Channel-based JobQueue + worker pool
│   │   ├── gpu/       futhark_bindings (LibFuthark C ABI) · dispatcher
│   │   └── runtime/   Server (TCPServer + fiber-per-connection)
│   └── shard.yml      (zero external deps)
├── examples/          client.cr
├── tests/             protocol_roundtrip.cr
├── benchmarks/        README.md
├── docs/              contracts.md
└── build.sh
```

---

## System architecture

```mermaid
flowchart TD
    CLIENT["TCP Client"] -->|binary frame| FIO["FrameIO\nlength-prefixed"]
    FIO --> ER["EventRouter\nopcode dispatch · backpressure"]
    ER -->|Compute/Batch| JQ["JobQueue\nChannel-based · bounded"]
    ER -->|Status| SR["Status reply"]
    ER -->|Shutdown| SH["Shutdown + close"]
    JQ --> W1["Worker fiber"]
    JQ --> W2["Worker fiber"]
    W1 --> DISP["GPU::Dispatcher\nFuthark C ABI"]
    W2 --> DISP
    DISP -->|result frame| FIO
    FIO -->|response| CLIENT

    style CLIENT fill:#0f2744,stroke:#3b82f6,color:#e2e8f0
    style FIO fill:#0f2744,stroke:#3b82f6,color:#e2e8f0
    style ER fill:#2a1f44,stroke:#a855f7,color:#e2e8f0
    style JQ fill:#2a1f44,stroke:#a855f7,color:#e2e8f0
    style DISP fill:#0d3320,stroke:#22c55e,color:#e2e8f0
    style W1 fill:#1a2e1a,stroke:#22c55e,color:#e2e8f0
    style W2 fill:#1a2e1a,stroke:#22c55e,color:#e2e8f0
```

---

## Futhark kernel pipeline

```mermaid
flowchart LR
    FUT["*.fut source\npure math spec"] --> FC{"futhark\ncompile"}
    FC -->|multicore| MC["libkernel.so\nCPU threads"]
    FC -->|cuda| CU["libkernel.so\nCUDA PTX"]
    FC -->|c| CC["libkernel.c\nportable C"]
    MC --> CABI["Futhark C ABI\nLibFuthark bindings"]
    CU --> CABI
    CC --> CABI
    CABI --> DISP["GPU::Dispatcher\nCrystal"]

    style FUT fill:#0f2744,stroke:#3b82f6,color:#e2e8f0
    style FC fill:#2a1f44,stroke:#a855f7,color:#e2e8f0
    style MC fill:#1a2e1a,stroke:#22c55e,color:#e2e8f0
    style CU fill:#1a2e1a,stroke:#22c55e,color:#e2e8f0
    style CC fill:#1a2e1a,stroke:#22c55e,color:#e2e8f0
    style CABI fill:#0f2744,stroke:#3b82f6,color:#e2e8f0
    style DISP fill:#0d3320,stroke:#22c55e,color:#e2e8f0
```

---

## Request lifecycle

```mermaid
sequenceDiagram
    participant CL as Client
    participant FI as FrameIO
    participant ER as EventRouter
    participant JQ as JobQueue
    participant WK as Worker
    participant GP as Dispatcher

    CL->>FI: write_frame(encoded request)
    FI->>ER: read_frame → decode header
    ER->>ER: check inflight ≤ max
    ER->>JQ: enqueue(Job)
    JQ->>WK: channel receive
    WK->>GP: dispatch(opcode, body)
    GP-->>WK: result bytes
    WK-->>FI: on_complete(result)
    FI-->>CL: write_frame(response)
```

---

## Build

```bash
# Multicore (no GPU required)
cd futhark && make multicore

# Crystal host
cd crystal && crystal build src/main.cr -o bin/fc-stack --release

# Or run the build script
./build.sh
```

CUDA target when NVIDIA toolchain present:

```bash
cd futhark && make cuda
```

---

## Binary protocol (v1)

Little-endian frames over TCP. No JSON on the hot path.

| Field | Size | Description |
|-------|------|-------------|
| MAGIC | 4 | `0x44535948` |
| VERSION | 2 | `1` |
| REQUEST_ID | 8 | client-chosen |
| OPCODE | 1 | `Compute=1 Batch=2 Memory=3 Device=4 Status=5 Shutdown=6` |
| FLAGS | 1 | `ZeroCopy · Pinned · BatchAsync` |
| INPUT_COUNT | 2 | number of input buffers |
| BODY_LEN | 4 | payload length |
| BODY | variable | packed tensor data |
| CHECKSUM | 4 | CRC-32C of BODY |

---

## Mathematical contracts

Every Futhark entry point is a pure function. Contracts are in `docs/contracts.md`.

| Kernel | Contract |
|--------|----------|
| `matmul_f32` | `C[i,j] = Σ_k A[i,k] * B[k,j]` — shape-safe, finite |
| `softmax_f32` | numerically stable; output sums to 1 |
| `conv2d_valid_f32` | valid padding, linear, no bias |
| `layer_norm_f32` | mean=0 std=1 along last axis |
| `lu_f32` | LU without pivoting (well-conditioned inputs) |
| `fft_real_placeholder` | identity — replace with real FFT |

---

## Design principles

- Futhark specifies *what* to compute; CUDA/multicore specifies *where*
- Crystal specifies *how* to route, schedule, and supervise
- Binary protocol only on hot path — no JSON serialization overhead
- Explicit memory ownership: host → pinned → device tracked in `MemoryTracker`
- Fail-closed: every error path named; no silent fallbacks
- Zero Python anywhere in the stack

---

## Running the tests

```bash
crystal run tests/protocol_roundtrip.cr
```

---

## License

Sovereign Leviathan Covenant. See `license`.
