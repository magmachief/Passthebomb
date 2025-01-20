local bcrypt = require(script.Bcrypt) -- Include bcrypt.lua module

-- Validate user credentials with hashed passwords
local function validateUser(username, password, whitelist)
    for _, user in pairs(whitelist) do
        if user.username == username and bcrypt.verify(password, user.password) then
            return true
        end
    end
    return false
end
