-- Vulkan Rust Generator.
-- Created by Felipe Ferreira da Silva (@dasifefe).
-- Distributed under ZLIB license.

file_path_vulkan_core_h = "vulkan_core.h"
file_path_vulkan_core_rs = "core.rs"

array_enum = {}
list_enum = {}
array_function = {}
list_function = {}
array_struct = {}
list_struct = {}
vk_version = nil
type = nil

fn_replace_type = function (text)
    if text == "uint64_t" then
        text = "u64"
    elseif text == "uint32_t" then
        text = "u32"
    elseif text == "uint16_t" then
        text = "u16"
    elseif text == "uint8_t" then
        text = "u8"
    elseif text == "int64_t" then
        text = "i64"
    elseif text == "int32_t" then
        text = "i32"
    elseif text == "int16_t" then
        text = "i16"
    elseif text == "int8_t" then
        text = "i8"
    elseif text == "float" then
        text = "f32"
    elseif text == "double" then
        text = "f64"
    elseif text == "void*" then
        text = "*mut c_void"
    elseif text == "const void*" then
        text = "*const c_void"
    elseif string.match(text, "const struct (Vk%w+)%*") ~= nil then
        text = "*const " .. string.match(text, "const struct (Vk%w+)%*")
    elseif string.match(text, "struct (Vk%w+)%*") ~= nil then
        text = "*mut " .. string.match(text, "struct (Vk%w+)%*")
    end
    return text
end

file_input = io.open(file_path_vulkan_core_h, "r")
line = file_input:read("*line")
while line ~= nil do
    if vk_version == nil then
        vk_version = string.match(line, "#define (VK_VERSION_[%d_]+)")
    else
        if string.match(line, "#endif %/%* " .. vk_version .. " %*%/") then
            vk_version = nil
        elseif type == nil then
            enum_name = string.match(line, "^typedef enum (%w+) {$")
            struct_name = string.match(line, "^typedef struct (%w+) {$")
            if struct_name ~= nil then
                struct = {}
                struct.name = struct_name
                struct.array_member = {}
                array_struct[#array_struct + 1] = struct
                type = "struct"
            end
            if enum_name ~= nil then
                enum = {}
                enum.name = enum_name
                enum.array_member = {}
                array_enum[#array_enum + 1] = enum
                type = "enum"
            end
        else
            if type == "enum" then
                if line == "} " .. enum.name .. ";" then
                    type = nil
                else
                    enum_member_name, enum_member_value = string.match(line, "([%w_]+) = ([%w-_]+)")
                    if string.sub(enum_member_name, 1, 3) == "VK_" then
                        enum_member_name = string.sub(enum_member_name, 4, -1)
                    end
                    enum_member = {}
                    enum_member.name = enum_member_name
                    enum_member.value = enum_member_value
                    enum.array_member[#enum.array_member + 1] = enum_member
                end
            end
            if type == "struct" then
                if line == "} " .. struct.name .. ";" then
                    type = nil
                else
                    struct_member_name = nil
                    struct_member_array = nil
                    struct_member_array_2d_1, struct_member_array_2d_0, struct_member_name, struct_member_type = string.match(string.reverse(line),
                        ";%]([%w_]+)%[" .. "%]([%w_]+)%[" .. "([%w]+)" .. "([%w%s%*_]+)"
                    )
                    if struct_member_name ~= nil then
                        struct_member_type = string.reverse(struct_member_type)
                        struct_member_name = string.reverse(struct_member_name)
                        struct_member_array_2d_0 = string.reverse(struct_member_array_2d_0)
                        struct_member_array_2d_1 = string.reverse(struct_member_array_2d_1)
                    end
                    if struct_member_name == nil then
                        struct_member_array_2d_0, struct_member_name, struct_member_type = string.match(string.reverse(line),
                            "%]([%w_]+)%[" .. "([%w]+)" .. "([%w%s%*_]+)"
                        )
                        if struct_member_name ~= nil then
                            struct_member_type = string.reverse(struct_member_type)
                            struct_member_name = string.reverse(struct_member_name)
                            struct_member_array_2d_0 = string.reverse(struct_member_array_2d_0)
                        end
                    end
                    if struct_member_array == nil then
                        struct_member_name, struct_member_type = string.match(string.reverse(line),
                            "([%w]+)" .. "([%w%s%*_]+)"
                        )
                        if struct_member_name ~= nil then
                            struct_member_type = string.reverse(struct_member_type)
                            struct_member_name = string.reverse(struct_member_name)
                        end
                    end
                    if struct_member_name == nil then
                        abort[1] = true
                    else
                        while string.sub(struct_member_type, -1, -1) == " " do
                            struct_member_type = string.sub(struct_member_type, 1, -2)
                        end
                        while string.sub(struct_member_type, 1, 1) == " " do
                            struct_member_type = string.sub(struct_member_type, 2, -1)
                        end
                        struct_member_type = fn_replace_type(struct_member_type)
                        struct_member = {}
                        struct_member.name = struct_member_name
                        struct_member.type = struct_member_type
                        while string.sub(struct_member.type, 1, 1) == " " do
                            struct_member.type = string.sub(struct_member.type, 2)
                        end
                        struct_member.array = nil
                        struct.array_member[#struct.array_member + 1] = struct_member
                        if struct_member_array_reverse ~= nil then
                            struct_member.array = struct_member_array
                        end
                    end
                end
            end
        end
    end
    line = file_input:read("*line")
end

file_output = io.open(file_path_vulkan_core_rs, "w")
file_output:write("use core::ffi::{c_void};\n\n")
for enum_index, enum in ipairs(array_enum) do
    file_output:write("#[derive(Clone, Copy, Eq, PartialEq)]" .. "\n")
    file_output:write("pub enum " .. enum.name .. " {" .. "\n")
    for enum_member_index, enum_member in ipairs(enum.array_member) do
        file_output:write("    " .. enum_member.name .. " = " .. enum_member.value .. ",\n")
    end
    file_output:write("}" .. "\n")
end
for struct_index, struct in ipairs(array_struct) do
    file_output:write("#[repr(C)]" .. "\n")
    file_output:write("#[derive(Clone, Eq, PartialEq, Ord, PartialOrd, Hash, Debug, Default)]" .. "\n")
    file_output:write("pub struct " .. struct.name .. " {" .. "\n")
    for struct_member_index, struct_member in ipairs(struct.array_member) do
        file_output:write("    " .. struct_member.name .. ": " .. struct_member.type .. "," .. "\n")
    end
    file_output:write("}" .. "\n")
end
file_output:write("#[repr(C)]" .. "\n")
file_output:write("#[derive(Clone, Eq, PartialEq, Ord, PartialOrd, Hash, Debug, Default)]" .. "\n")
file_output:write("pub struct VkContext {\n")
file_output:write("}\n")

io.close(file_output)
