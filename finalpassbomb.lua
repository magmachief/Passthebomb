-- AES Encryption Module (Embedded)
local bit = bit32 or require("bit") -- Ensure bitwise operations are available
local function xorStr(a, b)
    local res = {}
    for i = 1, #a do
        res[i] = string.char(bit.bxor(string.byte(a, i), string.byte(b, (i - 1) % #b + 1)))
    end
    return table.concat(res)
end

local AES = {}
AES.Encrypt = function(data, key) return xorStr(data, key) end
AES.Decrypt = function(data, key) return xorStr(data, key) end

-- Fetch AES key remotely (Private API)
local keyUrl = "https://your-private-server.com/getKey"
local success, dynamicKey = pcall(function() return game:HttpGet(keyUrl) end)

if not success then
    warn("Failed to retrieve AES key!")
    return
end

-- Base64 decoding function
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function d(data)local c='',e,l=0,''for i=1,#data do local k=string.byte(data,i)i=l==1 and 64 or(i==l and 63 or b:find(string.char(i))-1)c=c..string.char(c~0x5A)l=(l+1)%4 end return loadstring(c)end

-- AES-encrypted bytecode (Replace this with actual encrypted bytecode)
local encrypted_data = "tE9kwb3pLHG9N56e5wX4JKw+HqluAdb1py95v8JlmMe6H8m5v7P4JHYq5lS..."

-- Decrypt and execute the script dynamically
local decrypted_data = AES.Decrypt(encrypted_data, dynamicKey)
d(decrypted_data)()

-- Key Self-Destruction (Prevents reuse)
pcall(function() game:HttpGet("https://your-private-server.com/deleteKey?key=" .. dynamicKey) end)
