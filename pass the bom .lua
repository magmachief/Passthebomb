-- Roblox "Pass The Bomb" Script with Enhanced Features and Yonkai Menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

-- Configuration Variables
local bombPassDistance = 10
local passToClosest = true
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local ESPEnabled = false
local EnemyHitboxEnabled = false
local AntiHitboxEnabled = false

local ESPTransparency = 0.5
local ESPColor = Color3.fromRGB(255, 0, 0)
local EnemyHitboxSize = Vector3.new(10, 10, 10)
local AntiHitboxSize = Vector3.new(0.1, 0.1, 0.1)

-- Utility Functions
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
    if AutoPassEnabled then
        local closestPlayer = getClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (closestPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance <= bombPassDistance then
                local bomb = LocalPlayer.Character:FindFirstChild("Bomb")
                if bomb then
                    local bombEvent = bomb:FindFirstChild("RemoteEvent")
                    if bombEvent then
                        bombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                        print("Bomb passed to:", closestPlayer.Name)
                    end
                end
            end
        end
    end
end

-- Hitbox and ESP Management
local function createESP(player)
    if player == LocalPlayer then return end
    local character = player.Character or player.CharacterAdded:Wait()
    local collisionPart = character:FindFirstChild("CollisionPart")
    if collisionPart then
        local espBox = Instance.new("BoxHandleAdornment")
        espBox.Name = "ESPBox"
        espBox.Adornee = collisionPart
        espBox.Size = collisionPart.Size
        espBox.Transparency = ESPTransparency
        espBox.Color3 = ESPColor
        espBox.AlwaysOnTop = true
        espBox.ZIndex = 1
        espBox.Parent = collisionPart
    end
end

local function removeESP(player)
    if player.Character then
        local collisionPart = player.Character:FindFirstChild("CollisionPart")
        if collisionPart then
            local espBox = collisionPart:FindFirstChild("ESPBox")
            if espBox then
                espBox:Destroy()
            end
        end
    end
end

local function expandEnemyHitboxes()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local collisionPart = player.Character:FindFirstChild("CollisionPart")
            if collisionPart and EnemyHitboxEnabled then
                collisionPart.Size = EnemyHitboxSize
                collisionPart.Transparency = 0.5
                collisionPart.CanCollide = false
            end
        end
    end
end

local function applyAntiHitbox()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local collisionPart = character:FindFirstChild("CollisionPart")
    if collisionPart and AntiHitboxEnabled then
        collisionPart.Size = AntiHitboxSize
        collisionPart.Transparency = 1
        collisionPart.CanCollide = false
    else
        if collisionPart then
            collisionPart.Size = Vector3.new(2, 2, 2)
            collisionPart.Transparency = 0
            collisionPart.CanCollide = true
        end
    end
end

-- Enhanced Yonkai Menu
local function createYonkaiMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YonkaiMenu"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.1, 0)
    corner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
    titleLabel.Text = "Yonkai Menu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 32
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame

    -- Create a button template
    local function createToggleButton(name, position, defaultText, toggleFunction)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.8, 0, 0.1, 0)
        button.Position = position
        button.Text = defaultText
        button.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 20
        button.Font = Enum.Font.Gotham
        button.Parent = mainFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0.2, 0)
        buttonCorner.Parent = button

        button.MouseButton1Click:Connect(toggleFunction)
        return button
    end

    -- Add toggle buttons
    createToggleButton("AutoPass", UDim2.new(0.1, 0, 0.2, 0), "Auto Pass: OFF", function()
        AutoPassEnabled = not AutoPassEnabled
        passBomb()
    end)

    createToggleButton("EnemyHitbox", UDim2.new(0.1, 0, 0.35, 0), "Enemy Hitbox: OFF", function()
        EnemyHitboxEnabled = not EnemyHitboxEnabled
        expandEnemyHitboxes()
    end)

    createToggleButton("AntiHitbox", UDim2.new(0.1, 0, 0.5, 0), "Anti Hitbox: OFF", function()
        AntiHitboxEnabled = not AntiHitboxEnabled
        applyAntiHitbox()
    end)

    createToggleButton("ESP", UDim2.new(0.1, 0, 0.65, 0), "ESP: OFF", function()
        ESPEnabled = not ESPEnabled
        for _, player in pairs(Players:GetPlayers()) do
            if ESPEnabled then
                createESP(player)
            else
                removeESP(player)
            end
        end
    end)

    -- Menu Toggle Button
    local toggleButton = Instance.new("ImageButton")
    toggleButton.Size = UDim2.new(0, 60, 0, 60)
    toggleButton.Position = UDim2.new(0, 20, 0, 20)
    toggleButton.Image = "rbxassetid://6031075938"
    toggleButton.BackgroundTransparency = 1
    toggleButton.Parent = screenGui

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    toggleButton.MouseButton1Click:Connect(function()
        if mainFrame.Visible then
            local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -200, 0.5, -700)})
            tween:Play()
            tween.Completed:Connect(function()
                mainFrame.Visible = false
            end)
        else
            mainFrame.Position = UDim2.new(0.5, -200, 0.5, -700)
            mainFrame.Visible = true
            local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -200, 0.5, -300)})
            tween:Play()
        end
    end)

    print("Enhanced Yonkai Menu with all features loaded.")
end

-- Initialize the Yonkai Menu
createYonkaiMenu()

-- Dynamic Updates for Players
Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        player.CharacterAdded:Connect(function()
            createESP(player)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

LocalPlayer.CharacterAdded:Connect(applyAntiHitbox)
