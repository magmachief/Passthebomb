-- Roblox "Pass The Bomb" Script with ESP Removed and All Other Features

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Configuration Variables
local bombPassDistance = 10
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local EnemyHitboxEnabled = false
local AntiHitboxEnabled = false
local RemoveHitboxEnabled = false
local BombHitboxSize = Vector3.new(5, 5, 5)
local OriginalBombHitboxSize = Vector3.new(2, 2, 2)
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

local function applyAntiSlippery()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if AntiSlipperyEnabled then
        spawn(function()
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
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
            end
        end
    end
end

local function handleRemoveHitbox()
    if RemoveHitboxEnabled then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        for i = 1, 100 do
            wait()
            pcall(function()
                character:WaitForChild("CollisionPart"):Destroy()
            end)
        end
        LocalPlayer.CharacterAdded:Connect(function(char)
            char:WaitForChild("CollisionPart"):Destroy()
        end)
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
            elseif collisionPart then
                collisionPart.Size = Vector3.new(2, 2, 2)
                collisionPart.Transparency = 0
                collisionPart.CanCollide = true
            end
        end
    end
end

local function applyAntiHitbox()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local collisionPart = character:FindFirstChild("CollisionPart")
    if collisionPart then
        if AntiHitboxEnabled then
            collisionPart.Size = AntiHitboxSize
            collisionPart.Transparency = 1
            collisionPart.CanCollide = false
        else
            collisionPart.Size = Vector3.new(2, 2, 2)
            collisionPart.Transparency = 0
            collisionPart.CanCollide = true
        end
    end
end

local function handleBombHitbox()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    character.ChildAdded:Connect(function(child)
        if child.Name == "Bomb" then
            child.Size = BombHitboxSize
            child.Transparency = 0.5 -- Optional: Visual feedback
        end
    end)

    character.ChildRemoved:Connect(function(child)
        if child.Name == "Bomb" then
            child.Size = OriginalBombHitboxSize
            child.Transparency = 0
        end
    end)
end

-- Scrollable Yonkai Menu
local function createYonkaiMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YonkaiMenu"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.1, 0)
    corner.Parent = mainFrame

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    scrollingFrame.ScrollBarThickness = 8
    scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = scrollingFrame

    local function createToggleButton(defaultText, toggleFunction)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.8, 0, 0, 40)
        button.Text = defaultText
        button.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 18
        button.Font = Enum.Font.Gotham
        button.Parent = scrollingFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0.2, 0)
        buttonCorner.Parent = button

        button.MouseButton1Click:Connect(function()
            toggleFunction(button)
        end)
    end

    -- Add toggle buttons
    createToggleButton("Auto Pass: OFF", function(button)
        AutoPassEnabled = not AutoPassEnabled
        button.Text = "Auto Pass: " .. (AutoPassEnabled and "ON" or "OFF")
    end)

    createToggleButton("Anti-Slippery: OFF", function(button)
        AntiSlipperyEnabled = not AntiSlipperyEnabled
        button.Text = "Anti-Slippery: " .. (AntiSlipperyEnabled and "ON" or "OFF")
        applyAntiSlippery()
    end)

    createToggleButton("Enemy Hitbox: OFF", function(button)
        EnemyHitboxEnabled = not EnemyHitboxEnabled
        button.Text = "Enemy Hitbox: " .. (EnemyHitboxEnabled and "ON" or "OFF")
        expandEnemyHitboxes()
    end)

    createToggleButton("Anti-Hitbox: OFF", function(button)
        AntiHitboxEnabled = not AntiHitboxEnabled
        button.Text = "Anti-Hitbox: " .. (AntiHitboxEnabled and "ON" or "OFF")
        applyAntiHitbox()
    end)

    createToggleButton("Remove Hitbox: OFF", function(button)
        RemoveHitboxEnabled = not RemoveHitboxEnabled
        button.Text = "Remove Hitbox: " .. (RemoveHitboxEnabled and "ON" or "OFF")
        handleRemoveHitbox()
    end)

    -- Toggle menu button
    local toggleButton = Instance.new("ImageButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(0, 20, 0, 20)
    toggleButton.Image = "rbxassetid://6031075938" -- Gojo icon
    toggleButton.BackgroundTransparency = 1
    toggleButton.Parent = screenGui

    toggleButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    print("Scrollable Yonkai Menu loaded successfully.")
end

-- Initialize Features
handleBombHitbox()
createYonkaiMenu()

-- Monitor Player Updates
Players.PlayerRemoving:Connect(function(player)
    expandEnemyHitboxes() -- Reset enemy hitboxes on player removal
end)

LocalPlayer.CharacterAdded:Connect(function()
    applyAntiSlippery()
    applyAntiHitbox()
end)
