local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local KEY = "Volleyball2007"

-- Whitelist Data Structure
local WhitelistSystem = {
    authorized = {
        [7551573578] = {
            key = "Znpo~nZnn~ppo", -- Encrypted key for "Volleyball2007"
            expiry = "2030-02-17", -- YYYY-MM-DD format
            tier = "premium"
        },
        -- Add more users as needed
    },
    
    state = {}, -- Tracks authenticated users

    encrypt = function(self, data)
        local encrypted = ""
        for i = 1, #data do
            local byte = string.byte(data, i)
            encrypted = encrypted .. string.char(bit32.bxor(byte, string.byte(KEY, (i % #KEY) + 1)))
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
        return decryptedKey == providedKey, "Key verification " .. (decryptedKey == providedKey and "successful" or "failed")
    end,
}

-- Function to create the user input GUI with status feedback
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

        inputUserId = tonumber(inputUserId) -- Convert to number for validation
        if not inputUserId then
            statusLabel.Text = "Invalid User ID"
            return
        end

        local success, tierOrError = WhitelistSystem:checkAuthorization(inputUserId)
        if not success then
            statusLabel.Text = "Authorization failed: " .. tierOrError
            return
        end

        local validKey, message = WhitelistSystem:verifyKey(inputUserId, inputKey)
        if not validKey then
            statusLabel.Text = "Invalid Key: " .. message
            return
        end

        -- Success
        WhitelistSystem.state[userId] = true
        statusLabel.Text = "Authorization successful!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green for success

        task.wait(1) -- Pause briefly to show success message
        screenGui:Destroy()
        runMainScript()
    end)
end

-- Main script functionality
function runMainScript()
    print("Main script running...")
    
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local bombHolder = nil

local bombPassDistance = 10
local passToClosest = true
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not player.Character:FindFirstChild("Bomb") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

local function passBomb()
    if bombHolder == LocalPlayer and passToClosest then
        local closestPlayer = getClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (closestPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance <= bombPassDistance then
                local bomb = LocalPlayer.Character:FindFirstChild("Bomb")
                if bomb then
                    local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    local tween = TweenService:Create(bomb, tweenInfo, {Position = targetPosition})
                    tween:Play()
                    tween.Completed:Connect(function()
                        bomb.Parent = closestPlayer.Character
                        print("Bomb passed to:", closestPlayer.Name)
                    end)
                end
            else
                print("No players within bomb pass distance.")
            end
        else
            print("No valid closest player found.")
        end
    end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YonkaiMenu"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.1, 0)
corner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
titleLabel.Text = "Yonkai Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.TextSize = 28
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

local antiSlipperyButton = Instance.new("TextButton")
antiSlipperyButton.Size = UDim2.new(0.8, 0, 0.15, 0)
antiSlipperyButton.Position = UDim2.new(0.1, 0, 0.2, 0)
antiSlipperyButton.Text = "Anti-Slippery: OFF"
antiSlipperyButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
antiSlipperyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
antiSlipperyButton.TextSize = 20
antiSlipperyButton.Font = Enum.Font.SourceSans
antiSlipperyButton.Parent = mainFrame
local antiSlipperyCorner = Instance.new("UICorner")
antiSlipperyCorner.CornerRadius = UDim.new(0.1, 0)
antiSlipperyCorner.Parent = antiSlipperyButton

local removeHitboxButton = Instance.new("TextButton")
removeHitboxButton.Size = UDim2.new(0.8, 0, 0.15, 0)
removeHitboxButton.Position = UDim2.new(0.1, 0, 0.4, 0)
removeHitboxButton.Text = "Remove Hitbox: OFF"
removeHitboxButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
removeHitboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
removeHitboxButton.TextSize = 20
removeHitboxButton.Font = Enum.Font.SourceSans
removeHitboxButton.Parent = mainFrame
local removeHitboxCorner = Instance.new("UICorner")
removeHitboxCorner.CornerRadius = UDim.new(0.1, 0)
removeHitboxCorner.Parent = removeHitboxButton

local autoPassBombButton = Instance.new("TextButton")
autoPassBombButton.Size = UDim2.new(0.8, 0, 0.15, 0)
autoPassBombButton.Position = UDim2.new(0.1, 0, 0.6, 0)
autoPassBombButton.Text = "Auto Pass Bomb: OFF"
autoPassBombButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
autoPassBombButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoPassBombButton.TextSize = 20
autoPassBombButton.Font = Enum.Font.SourceSans
autoPassBombButton.Parent = mainFrame
local autoPassBombCorner = Instance.new("UICorner")
autoPassBombCorner.CornerRadius = UDim.new(0.1, 0)
autoPassBombCorner.Parent = autoPassBombButton

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 50, 0, 50)
icon.Position = UDim2.new(0, 10, 0, 10)
icon.Image = "rbxassetid://6031075938" -- Gojo icon asset ID
icon.BackgroundTransparency = 1
icon.Parent = screenGui

local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.Image = "rbxassetid://6031075938" -- Gojo icon asset ID
toggleButton.BackgroundTransparency = 1
toggleButton.Parent = screenGui

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

toggleButton.MouseButton1Click:Connect(function()
    if mainFrame.Visible then
        local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -175, 0.5, -700)})
        tween:Play()
        tween.Completed:Connect(function()
            mainFrame.Visible = false
        end)
    else
        mainFrame.Position = UDim2.new(0.5, -175, 0.5, -700)
        mainFrame.Visible = true
        local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -175, 0.5, -225)})
        tween:Play()
    end
end)

antiSlipperyButton.MouseButton1Click:Connect(function()
    AntiSlipperyEnabled = not AntiSlipperyEnabled
    antiSlipperyButton.Text = "Anti-Slippery: " .. (AntiSlipperyEnabled and "ON" or "OFF")
    if AntiSlipperyEnabled then
        spawn(function()
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            while AntiSlipperyEnabled do
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                    end
                end
                wait(0.1)
            end
        end)
    else
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
            end
        end
    end
end)

removeHitboxButton.MouseButton1Click:Connect(function()
    RemoveHitboxEnabled = not RemoveHitboxEnabled
    removeHitboxButton.Text = "Remove Hitbox: " .. (RemoveHitboxEnabled and "ON" or "OFF")
    if RemoveHitboxEnabled then
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local function removeCollisionPart(character)
            for destructionIteration = 1, 100 do
                wait()
                pcall(function()
                    character:WaitForChild("CollisionPart"):Destroy()
                end)
            end
        end
        removeCollisionPart(Character)
        LocalPlayer.CharacterAdded:Connect(function(character)
            removeCollisionPart(character)
        end)
    end
end)

autoPassBombButton.MouseButton1Click:Connect(function()
    AutoPassEnabled = not AutoPassEnabled
    autoPassBombButton.Text = "Auto Pass Bomb: " .. (AutoPassEnabled and "ON" or "OFF")
    if AutoPassEnabled then
        game:GetService("RunService").Stepped:Connect(function()
            if not AutoPassEnabled then return end
            pcall(function()
                if LocalPlayer.Backpack:FindFirstChild("Bomb") then
                    LocalPlayer.Backpack:FindFirstChild("Bomb").Parent = LocalPlayer.Character
                end

                local Bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
                if Bomb then
                    local BombEvent = Bomb:FindFirstChild("RemoteEvent")
                    local closestPlayer = getClosestPlayer()
                    if closestPlayer and closestPlayer.Character then
                        local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                        if humanoid then
  local path = PathfindingService:CreatePath({
                                AgentRadius = 2,
                                AgentHeight = 5,
                                AgentCanJump = true,
                                AgentJumpHeight = 10,
                                AgentMaxSlope = 45,
                            })
                            path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, targetPosition)
                            for _, waypoint in ipairs(path:GetWaypoints()) do
                                humanoid:MoveTo(waypoint.Position)
                                humanoid.MoveToFinished:Wait()
                            end
                        end
                        BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                    end
                end
            end)
        end)
    end
end)

print("Pass The Bomb Script Loaded with Enhanced Yonkai Menu and Gojo Icon")
end

-- Start the whitelist system
initializeWhitelist()
