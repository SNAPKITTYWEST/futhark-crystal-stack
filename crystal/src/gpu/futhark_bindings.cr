# Bindings to the C API produced by `futhark cuda --library`.
# The shared object is named after the .fut file (e.g. `matmul.so`).
#
# We bind the opaque pointer types and the generic context/array
# functions. Entry-point-specific array constructors are emitted by
# Futhark in the generated header and accessed through the dispatcher.

lib LibFuthark
  # Opaque handles.
  type ContextConfig = Void*
  type Context = Void*
  type FutharkArray = Void*

  # Configuration.
  fun futhark_context_config_new : ContextConfig
  fun futhark_context_config_free(cfg : ContextConfig) : Void
  fun futhark_context_config_set_default_device(cfg : ContextConfig, device : Int32) : Void
  fun futhark_context_config_set_default_num_threads(cfg : ContextConfig, n : Int32) : Void

  # Context.
  fun futhark_context_new(cfg : ContextConfig) : Context
  fun futhark_context_free(ctx : Context) : Void
  fun futhark_context_get_error(ctx : Context) : LibC::Char*
  fun futhark_context_sync(ctx : Context) : Int32

  # Generic 1-D f32 array lifecycle (multicore backend naming).
  fun futhark_new_f32_1d(ctx : Context, data : Float32*, n : Int64) : FutharkArray
  fun futhark_free_f32_1d(ctx : Context, arr : FutharkArray) : Int32
  fun futhark_values_f32_1d(ctx : Context, arr : FutharkArray, out : Float32*) : Int32
  fun futhark_shape_f32_1d(ctx : Context, arr : FutharkArray) : Int64*
end
