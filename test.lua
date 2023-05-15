local intconvert = require('intconvert')

local custom_str = '12345'
local custom_table = {'^', '*', '@', '3', '~'}

local custom_decoder, custom_encoder = intconvert.makedecoder(custom_str), intconvert.makeencoder(custom_str)
local custom_decoder2, custom_encoder2 = intconvert.makedecoder(custom_table), intconvert.makeencoder(custom_table)

for i = 1, 1000 do
	for base = 2, 62 do
		local v = math.random(-2251799813685247, 2251799813685247)
		local e_v = intconvert.encode(v, base)
		local d_e_v = intconvert.decode(e_v, base)
		assert(v == d_e_v, ("Assertion failed:\n base: %d\n value: %d\n encoded: %s\n decoded: %d"):format(base, v, e_v, d_e_v))
	end
	for base = 2, 36 do
		local v = math.random(-2251799813685247, 2251799813685247)
		local e_v = intconvert.encode(v, base)
		local d_e_v = intconvert.decode(e_v, base)
		local dn_e_v = tonumber(e_v, base)
		assert(dn_e_v == d_e_v, ("Assertion failed:\n base: %d\n value: %d\n encoded: %s\n decoded: %d\n native decoded: %d"):format(base, v, e_v, d_e_v, dn_e_v))
		assert(v == d_e_v, ("Assertion failed:\n base: %d\n value: %d\n encoded: %s\n decoded: %d"):format(base, v, e_v, d_e_v))
	end
	for base = 2, #custom_str do
		local v = math.random(-2251799813685247, 2251799813685247)
		local e_v = intconvert.encode(v, base, custom_encoder)
		local d_e_v = intconvert.decode(v, base, custom_decoder)
		assert(v == d_e_v, ("Assertion failed:\n base: %d\n value: %d\n encoded: %s\n decoded: %d"):format(base, v, e_v, d_e_v))
	end
	for base = 2, #custom_table do
		local v = math.random(-2251799813685247, 2251799813685247)
		local e_v = intconvert.encode(v, base, custom_encoder2)
		local d_e_v = intconvert.decode(v, base, custom_decoder2)
		assert(v == d_e_v, ("Assertion failed:\n base: %d\n value: %d\n encoded: %s\n decoded: %d"):format(base, v, e_v, d_e_v))
	end
end
