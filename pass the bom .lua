local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local ENCRYPTION_KEY = "Volleyball2007" -- The encryption key used for XOR encryption
local DATASTORE_NAME = "WhitelistDataStore"
local datastore = DataStoreService:GetDataStore(DATASTORE_NAME)

-- Whitelist Data Structure
local WhitelistSystem = {
    authorized = {
        [7551573578] = {
            key = "Znpo~nZnn~ppo", -- Encrypted key for "Volleyball2007"
            expiry = "2030-01-17", -- Expiry date (YYYY-MM-DD format)
        },
    },
    state = {}, -- Tracks authenticated users

    -- XOR Encryption
    encrypt = function(self, data)
        local encrypted = ""
        for i = 1, #data do
            local byte = string.byte(data, i)
            local keyByte = string.byte(ENCRYPTION_KEY, ((i - 1) % #ENCRYPTION_KEY) + 1)
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
        return true, "User is authorized"
    end,

    verifyKey = function(self, userId, providedKey)
        local userData = self.authorized[userId]
        if not userData then
            return false, "User not found"
        end
        local decryptedKey = self:decrypt(userData.key)
        return decryptedKey == providedKey, "Key verification " .. (decryptedKey == providedKey and "successful" or "failed")
    end,

    saveAuthorizedUser = function(self, userId)
        self.state[userId] = true
        local success, errorMessage = pcall(function()
            datastore:SetAsync(tostring(userId), true)
        end)
        if not success then
            warn("Failed to save authorized user: " .. errorMessage)
        end
    end,

    loadAuthorizedUser = function(self, userId)
        local success, result = pcall(function()
            return datastore:GetAsync(tostring(userId))
        end)
        if success and result then
            self.state[userId] = true
            return true
        else
            return false
        end
    end
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

    -- Make the frame draggable
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    return screenGui, userIdInput, keyInput, submitButton, statusLabel
end

-- Function to initialize the whitelist
local function initializeWhitelist()
    local player = Players.LocalPlayer
    local userId = player.UserId

    if WhitelistSystem.state[userId] or WhitelistSystem:loadAuthorizedUser(userId) then
        runMainScript()
        return
    end

    local screenGui, userIdInput, keyInput, submitButton, statusLabel = createUserInputGui()

    submitButton.MouseButton1Click:Connect(function()
        local inputUserId = tonumber(userIdInput.Text)
        local inputKey = keyInput.Text

        if not inputUserId then
            statusLabel.Text = "Invalid User ID"
            print("Invalid User ID: " .. tostring(inputUserId))
            return
        end

        local userData = WhitelistSystem.authorized[inputUserId]
        if not userData then
            statusLabel.Text = "User not whitelisted"
            print("User not found in whitelist: " .. tostring(inputUserId))
            return
        end

        local decryptedKey = WhitelistSystem:decrypt(userData.key)
        if inputKey ~= decryptedKey then
            statusLabel.Text = "Invalid Key"
            print("Key mismatch: Entered - " .. inputKey .. ", Expected - " .. decryptedKey)
            return
        end

        statusLabel.Text = "Authorization successful!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
        WhitelistSystem:saveAuthorizedUser(inputUserId)
        print("User authorized successfully: " .. tostring(inputUserId))
        task.wait(1)
        screenGui:Destroy()
        runMainScript()
    end)
end

-- Main script functionality
function runMainScript()
    print("Main script running...")
    -- Add your main script logic here
end

-- Start the whitelist system
initializeWhitelist()
