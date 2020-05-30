# Rust Vulkan Generator

Generate the Vulkan API in Rust.

The generator is writen in Lua, and requires the Vulkan C header. Yes, the parser will use the C header, instead of the XML. The C header is much simpler to parse than the XML.

The generated Vulkan Rust is still untested.

## Usage

Place `vulkan_core.h` in the same folder as `rust_vk_generator.lua`. Execute in the Lua script:

```
lua ./rust_vk_generator.lua
```

The script will generate `core.rs`.

## Goals

- Context inside a structure, maybe.
- Mostly a raw 1:1 translation.
- Avoid `std`. Currently only using `core::ffi::{c_void}`.

## License

This work is distributed under ZLIB license.
