[![Build Status](https://travis-ci.com/iskolbin/lintconvert.svg?branch=master)](https://travis-ci.org/iskolbin/lintconvert)
[![license](https://img.shields.io/badge/license-public%20domain-blue.svg)]()
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)

Lua integer encoder/decoder
===========================

Pure Lua integer encoder/decoder for arbitrary bases. Works with Lua 5.1+ and LuaJIT.

```lua
local intconvert = require'intconvert'
local v = 28489299
local encoded = intconvert.encode(v, 47) -- 5DiHe, default encoder supports base up to 62
local decoded = intconvert.decode(converted, 47)
assert(encoded == decoded)
```

intconvert.encode(num, base = 10, encoder = DEFAULT)
----------------------------------------------------
Encodes `num` number using `encoder` table with `base`. By default uses table which
supports base up to 62.

intconvert.decode(str, base = 10, decoder = DEFAULT)
----------------------------------------------------
Decodes `str` number using `decoder` table with `base`. By default uses table which
supports base up to 62.

intconvert.makeencoder(symbols)
-------------------------------
Make encoding table from `symbols` which is string or array.

intconvert.makedecoder(symbols)
-------------------------------
Make decoding table from `symbols` which is string or array.

Install
-------
```bash
luarocks install intconvert
```
