--[[

 intconvert -- v1.0.0 public domain Lua integer to string encoder/decoder
 no warranty implied; use at your own risk

 author: Ilya Kolbin (iskolbin@gmail.com)
 url: github.com/iskolbin/lintconvert

 COMPATIBILITY

 Lua 5.1+, LuaJIT

 LICENSE

 See end of file for license information.

--]]

local type, tostring, floor, sub = _G.type, _G.tostring, math.floor, string.sub

local intconvert = {}

local function iscorrectsymbols(symbols, func_name)
	local symbols_type, t = type(symbols), {}
	if symbols_type == "string" then
		for i = 1, string.len(symbols) do
			local ch = sub(symbols, i, i)
			if not t[ch] then
				t[ch] = true
			else
				return false, "bad argument #1 to '" .. func_name .. "' (duplicate symbol '" .. ch .. "')"
			end
		end
	elseif symbols_type == "table" then
		for i = 1, #symbols do
			local ch = tostring(symbols[i])
			if not type(ch) == "string" or #ch ~= 1 then
				return false, "bad argument #1 to '" .. func_name .. "' (symbol is not single char: " .. tostring(ch) .. ")"
			end
			if not t[ch] then
				t[ch] = true
			else
				return false, "bad argument #1 to '" .. func_name .. "' (duplicate symbol '" .. ch .. "')"
			end
		end
	else
		return false, "bad argument #1 to '" .. func_name .. "' (table expected got " .. symbols_type .. ")"
	end

	return true
end

function intconvert.makeencoder(symbols)
	local ok, err = iscorrectsymbols(symbols, "makeencoder")
	if not ok then
		return nil, err
	end

	local encoder = {}
	local symbols_type = type(symbols)
	if symbols_type == "string" then
		for i = 1, string.len(symbols) do
			encoder[i - 1] = sub(symbols, i, i)
		end
	elseif symbols_type == "table" then
		for i = 1, #symbols do
			encoder[i - 1] = symbols[i]
		end
	end

	return encoder
end

function intconvert.makedecoder(symbols)
	local ok, err = iscorrectsymbols(symbols, "makedecoder")
	if not ok then
		return nil, err
	end
	local decoder = {}
	local symbols_type = type(symbols)
	if symbols_type == "string" then
		for i = 1, string.len(symbols) do
			decoder[sub(symbols, i, i)] = i - 1
		end
	elseif symbols_type == "table" then
		for i = 1, #symbols do
			decoder[symbols[i]] = i - 1
		end
	end

	return decoder
end

local CONVERSION_STRING = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local DEFAULT_ENCODER = intconvert.makeencoder(CONVERSION_STRING)
local DEFAULT_DECODER = intconvert.makedecoder(CONVERSION_STRING)

function intconvert.encode(num, base, encoder)
	base = base or 10
	encoder = encoder or DEFAULT_ENCODER
	local num_type = type(num)
	if num_type ~= "number" then
		return nil, "bad argument #1 to 'encode' (number expected got " .. num_type .. ")"
	end
	local base_type = type(base)
	if base_type ~= "number" then
		return nil, "bad argument #2 to 'encode' (number expected got " .. base_type .. ")"
	end
	local encoder_type = type(encoder)
	if type(encoder) ~= "table" then
		return nil, "bad argument #3 to 'encode' (table expected got " .. encoder_type .. ")"
	end
	if base == 1 then
		return string.rep(encoder[1], num)
	end
	local is_negative =  num < 0
	if is_negative then
		num = -num
	end
	local acc, i = {}, 1
	while num >= base do
		local v = num % base
		local cv = encoder[v]
		if not cv then
			return nil, "bad arguments to 'encode' (cannot find " .. tostring(v) ..
			" in encode table with base " .. tostring(base) .. ")"
		end
		acc[i] = cv
		num = floor(num / base)
		i = i + 1
	end
	acc[i] = encoder[num]

	return (is_negative and "-" or "") .. string.reverse(table.concat(acc))
end

function intconvert.decode(str, base, decoder)
	base = base or 10
	decoder = decoder or DEFAULT_DECODER
	local str_type = type(str)
	if str_type == "number" then
		return str
	elseif str_type ~= "string" then
		return nil, "bad argument #1 to 'decode' (string expected got " .. str_type .. ")"
	end
	local base_type = type(base)
	if base_type ~= "number" then
		return nil, "bad argument #2 to 'decode' (number expected got " .. base_type .. ")"
	end
	local decoder_type = type(decoder)
	if type(decoder) ~= "table" then
		return nil, "bad argument #3 to 'decode' (table expected got " .. decoder_type .. ")"
	end
	if base <= 1 then
		return string.len(str)
	end
	local v, b = 0, 1
	str = string.gsub(string.gsub(str, "^%s+", ""), "%s+$", "")
	local is_negative = string.match(str, "^%-")
	if is_negative then
		str = string.gsub(str, "^%-", "")
		b = -1
	end
	for i = string.len(str), 1, -1 do
		local ch = sub(str, i, i)
		local cv = decoder[ch]
		if not cv then
			return nil, "bad arguments to 'decode' (cannot find '" .. ch ..
			"' in decode table with base " .. tostring(base) .. ")"
		end
		v = v + b * cv
		b = b * base
	end

	return v
end

return intconvert

--[[
------------------------------------------------------------------------------
This software is available under 2 licenses -- choose whichever you prefer.
------------------------------------------------------------------------------
ALTERNATIVE A - MIT License
Copyright (c) 2023 Ilya Kolbin
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
------------------------------------------------------------------------------
ALTERNATIVE B - Public Domain (www.unlicense.org)
This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
software, either in source code form or as a compiled binary, for any purpose,
commercial or non-commercial, and by any means.
In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
------------------------------------------------------------------------------
--]]
