local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local KEY = "Volleyball2007" -- The encryption key used for XOR encryption

-- Debug Console Function
local function createDebugConsole()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local debugGui = Instance.new("ScreenGui")
    debugGui.Name = "DebugConsole"
    debugGui.Parent = playerGui

    local debugFrame = Instance.new("Frame")
    debugFrame.Size = UDim2.new(0.8, 0, 0.3, 0)
    debugFrame.Position = UDim2.new(0.1, 0, 0.65, 0)
    debugFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    debugFrame.BorderSizePixel = 2
    debugFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    debugFrame.Parent = debugGui

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Parent = debugFrame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame

    local function log(message)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.SourceSans
        label.Text = message
        label.Parent = scrollFrame

        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end

    return log
end

-- Initialize Debug Console
local log = createDebugConsole()

-- Whitelist Data Structure
local WhitelistSystem = {
    authorized = {
        [7551573578] = {
            key = "Znpo~nZnn~ppo", -- Encrypted key for "Volleyball2007"
            expiry = "2030-02-17", -- YYYY-MM-DD format
            tier = "premium"
        },
    },
    
    state = {}, -- Tracks authenticated users

    -- XOR Encryption
    encrypt = function(self, data)
        local encrypted = ""
        for i = 1, #data do
            local byte = string.byte(data, i)
            local keyByte = string.byte(KEY, ((i - 1) % #KEY) + 1)
            encrypted = encrypted .. string.char(bit32.bxor(byte, keyByte))
        end
        return encrypted
    end,

    decrypt = function(self, data)
        return self:encrypt(data) -- XOR encryption is reversible
    end,

    validateTimestamp = function(self, timestamp)
        local currentTime = os.time()
        local userTime = 0
        local year, month, day = timestamp:match("(%d+)-(%d+)-(%d+)")
        if year and month and day then
            userTime = os.time({year = year, month = month, day = day})
        end
        return currentTime < userTime
    end,

    checkAuthorization = function(self, userId)
        local userData = self.authorized[userId]
        if not userData then
            return false, "User not whitelisted"
        end
        if not self:validateTimestamp(userData.expiry) then
            return false, "Whitelist expired"
        end
        return true, userData.tier
    end,

    verifyKey = function(self, userId, providedKey)
        local userData = self.authorized[userId]
        if not userData then
            return false, "User not found"
        end
        local decryptedKey = self:decrypt(userData.key)
        log("Decrypted Key: " .. decryptedKey)
        return decryptedKey == providedKey, "Key verification " .. (decryptedKey == providedKey and "successful" or "failed")
    end,
}

-- Function to create the user input GUI
local function createUserInputGui()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UserInputGui"
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 300)
    frame.Position = UDim2.new(0.5, -150, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = screenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
    titleLabel.Text = "Enter User ID and Key"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = frame

    local userIdInput = Instance.new("TextBox")
    userIdInput.Size = UDim2.new(0.8, 0, 0.2, 0)
    userIdInput.Position = UDim2.new(0.1, 0, 0.2, 0)
    userIdInput.PlaceholderText = "Enter your User ID here"
    userIdInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    userIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    userIdInput.TextSize = 18
    userIdInput.Font = Enum.Font.SourceSans
    userIdInput.Parent = frame

    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(0.8, 0, 0.2, 0)
    keyInput.Position = UDim2.new(0.1, 0, 0.45, 0)
    keyInput.PlaceholderText = "Enter your key here"
    keyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.TextSize = 18
    keyInput.Font = Enum.Font.SourceSans
    keyInput.Parent = frame

    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(0.8, 0, 0.15, 0)
    submitButton.Position = UDim2.new(0.1, 0, 0.7, 0)
    submitButton.Text = "Submit"
    submitButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.TextSize = 18
    submitButton.Font = Enum.Font.SourceSans
    submitButton.Parent = frame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0.15, 0)
    statusLabel.Position = UDim2.new(0, 0, 0.85, 0)
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red for error messages
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextSize = 16
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.Parent = frame

    return screenGui, userIdInput, keyInput, submitButton, statusLabel
end

-- Function to initialize the whitelist
local function initializeWhitelist()
    local player = Players.LocalPlayer
    local userId = player.UserId

    if WhitelistSystem.state[userId] then
        runMainScript()
        return
    end

    local screenGui, userIdInput, keyInput, submitButton, statusLabel = createUserInputGui()

    submitButton.MouseButton1Click:Connect(function()
        local inputUserId = userIdInput.Text
        local inputKey = keyInput.Text

        inputUserId = tonumber(inputUserId)
        if not inputUserId then
            statusLabel.Text = "Invalid User ID"
            log("Invalid User ID: " .. tostring(inputUserId))
            return
        end

        local userData = WhitelistSystem.authorized[inputUserId]
        if not userData then
            statusLabel.Text = "User not whitelisted"
            log("User not found in whitelist: " .. tostring(inputUserId))
            return
        end

        local decryptedKey = WhitelistSystem:decrypt(userData.key)
        log("Decrypted Key: " .. decryptedKey)
        if inputKey ~= decryptedKey then
            statusLabel.Text = "Invalid Key"
            log("Key mismatch: Entered - " .. inputKey .. ", Expected - " .. decryptedKey)
            return
        end

        statusLabel.Text = "Authorization successful!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
        WhitelistSystem.state[inputUserId] = true
        log("User authorized successfully: " .. tostring(inputUserId))
        task.wait(1)
        screenGui:Destroy()
        runMainScript()
    end)
end

-- Main script functionality
function runMainScript()
    log("Main script running...")
    -- Add your main script logic here
end

-- Start the whitelist system
initializeWhitelist()
