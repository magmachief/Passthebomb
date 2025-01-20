
local HttpService = game:GetService("HttpService")

-- GitHub raw URLs
local whitelistURL = "https://raw.githubusercontent.com/your-username/your-repo/main/whitelist.json"
local scriptURL = "https://raw.githubusercontent.com/your-username/your-repo/main/robloxScript.lua"

-- Credentials
local username = "user1"  -- Replace with input from your UI
local password = "password123"  -- Replace with input from your UI

-- Function to fetch data from GitHub
local function fetchGitHubFile(url)
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if success then
        return response
    else
        warn("Failed to fetch file:", response)
        return nil
    end
end

-- Validate user credentials
local function validateUser(username, password, whitelist)
    for _, user in pairs(whitelist) do
        if user.username == username and user.password == password then
            return true
        end
    end
    return false
end

-- Main function
local function loadScript()
    -- Fetch the whitelist
    local whitelistData = fetchGitHubFile(whitelistURL)
    if not whitelistData then
        warn("Could not fetch whitelist.")
        return
    end

    -- Decode the whitelist JSON
    local success, whitelist = pcall(function()
        return HttpService:JSONDecode(whitelistData)
    end)
    if not success then
        warn("Failed to decode whitelist.")
        return
    end

    -- Validate credentials
    if validateUser(username, password, whitelist) then
        print("Access granted. Fetching script...")

        -- Fetch the script
        local scriptData = fetchGitHubFile(scriptURL)
        if scriptData then
            local newScript = Instance.new("Script")
            newScript.Source = scriptData
            newScript.Parent = workspace
            print("Script loaded successfully!")
        else
            warn("Failed to fetch the script.")
        end
    else
        warn("Access denied. Invalid credentials.")
    end
end

-- Run the script loader
loadScript()
