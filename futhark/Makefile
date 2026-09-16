FUTHARK ?= futhark
BACKEND ?= multicore
OUTDIR ?= ../cuda/generated

KERNELS := kernels/matmul.fut \
           kernels/softmax.fut \
           kernels/conv2d.fut \
           kernels/vector_ops.fut \
           kernels/reduce_scan.fut \
           kernels/stencil.fut \
           kernels/fft_placeholder.fut

.PHONY: all clean inspect cuda multicore c

all: multicore

multicore:
	@mkdir -p $(OUTDIR)
	@for k in $(KERNELS); do \
	  base=$$(basename $$k .fut); \
	  echo "Compiling $$k → multicore"; \
	  $(FUTHARK) multicore $$k -o $(OUTDIR)/$$base || exit 1; \
	done
	@echo "Multicore libraries ready in $(OUTDIR)"

cuda:
	@mkdir -p $(OUTDIR) ../cuda/ptx
	@for k in $(KERNELS); do \
	  base=$$(basename $$k .fut); \
	  echo "Compiling $$k → CUDA"; \
	  $(FUTHARK) cuda $$k -o $(OUTDIR)/$$base || exit 1; \
	done
	@echo "CUDA artefacts ready"

c:
	@mkdir -p $(OUTDIR)
	@for k in $(KERNELS); do \
	  base=$$(basename $$k .fut); \
	  $(FUTHARK) c $$k -o $(OUTDIR)/$$base || exit 1; \
	done

inspect:
	@mkdir -p ../cuda/inspection
	@for k in $(KERNELS); do \
	  base=$$(basename $$k .fut); \
	  if [ -f $(OUTDIR)/$$base.c ]; then \
	    cp $(OUTDIR)/$$base.c ../cuda/inspection/; \
	  fi; \
	done
	@echo "Inspectable C/PTX sources copied to cuda/inspection"

clean:
	rm -rf $(OUTDIR)/* ../cuda/ptx/* ../cuda/inspection/*
