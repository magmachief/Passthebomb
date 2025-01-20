--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// Settings
local Settings = {
    BombPassDistance = 10, -- Maximum distance to pass the bomb
    BombPassCooldown = 2,  -- Cooldown for passing the bomb (seconds)
    AgentRadius = 2,       -- Pathfinding agent radius
    AgentHeight = 5,       -- Pathfinding agent height
    AgentCanJump = true,   -- Whether the agent can jump
    AgentJumpHeight = 10,  -- Jump height of the agent
    AgentMaxSlope = 45     -- Max slope for pathfinding
}

--// Variables
local bombHolder = nil
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local passCooldown = false
local menuOpen = false
local menuTweening = false

--// Utility Functions
local function debounce(func, delay)
    local isDebounced = false
    return function(...)
        if not isDebounced then
            isDebounced = true
            func(...)
            task.delay(delay, function()
                isDebounced = false
            end)
        end
    end
end

local function createMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YonkaiMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
    titleLabel.Text = "Yonkai Menu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 28
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Anti Slippery Button
    local antiSlipperyButton = Instance.new("TextButton")
    antiSlipperyButton.Size = UDim2.new(1, 0, 0.1, 0)
    antiSlipperyButton.Position = UDim2.new(0, 0, 0.15, 0)
    antiSlipperyButton.Text = "Toggle Anti-Slippery"
    antiSlipperyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    antiSlipperyButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    antiSlipperyButton.Font = Enum.Font.SourceSans
    antiSlipperyButton.TextSize = 24
    antiSlipperyButton.Parent = mainFrame
    antiSlipperyButton.MouseButton1Click:Connect(function()
        AntiSlipperyEnabled = not AntiSlipperyEnabled
        applyAntiSlippery()
    end)

    -- Remove Hitbox Button
    local removeHitboxButton = Instance.new("TextButton")
    removeHitboxButton.Size = UDim2.new(1, 0, 0.1, 0)
    removeHitboxButton.Position = UDim2.new(0, 0, 0.25, 0)
    removeHitboxButton.Text = "Toggle Remove Hitbox"
    removeHitboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    removeHitboxButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    removeHitboxButton.Font = Enum.Font.SourceSans
    removeHitboxButton.TextSize = 24
    removeHitboxButton.Parent = mainFrame
    removeHitboxButton.MouseButton1Click:Connect(function()
        RemoveHitboxEnabled = not RemoveHitboxEnabled
        removeHitbox()
    end)

    -- Auto Pass Bomb Button
    local autoPassButton = Instance.new("TextButton")
    autoPassButton.Size = UDim2.new(1, 0, 0.1, 0)
    autoPassButton.Position = UDim2.new(0, 0, 0.35, 0)
    autoPassButton.Text = "Toggle Auto Pass Bomb"
    autoPassButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoPassButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    autoPassButton.Font = Enum.Font.SourceSans
    autoPassButton.TextSize = 24
    autoPassButton.Parent = mainFrame
    autoPassButton.MouseButton1Click:Connect(function()
        AutoPassEnabled = not AutoPassEnabled
        if AutoPassEnabled then
            passBomb()
        end
    end)

    -- Menu Toggle Icon
    local menuIcon = Instance.new("TextButton")
    menuIcon.Size = UDim2.new(0, 50, 0, 50)
    menuIcon.Position = UDim2.new(0.95, -50, 0.05, 0)
    menuIcon.Text = "☰"
    menuIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    menuIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    menuIcon.Font = Enum.Font.SourceSans
    menuIcon.TextSize = 30
    menuIcon.Parent = screenGui
    menuIcon.MouseButton1Click:Connect(function()
        toggleMenu(mainFrame)
    end)
end

local function toggleMenu(menuFrame)
    if menuTweening then return end
    menuTweening = true

    local goal = menuOpen and UDim2.new(0.5, -175, 0.5, -225) or UDim2.new(0.5, -175, 0.5, 1)
    local tween = TweenService:Create(menuFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goal})
    tween:Play()

    tween.Completed:Connect(function()
        menuOpen = not menuOpen
        menuTweening = false
    end)
end

--// Anti-Slippery Functionality
local function applyAntiSlippery()
    if AntiSlipperyEnabled then
        spawn(function()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
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
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
            end
        end
    end
end

--// Remove Hitbox Functionality
local function removeHitbox()
    if RemoveHitboxEnabled then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local function removeCollisionPart()
            for _, part in pairs(character:GetDescendants()) do
                if part.Name == "CollisionPart" then
                    part:Destroy()
                end
            end
        end
        removeCollisionPart()
        LocalPlayer.CharacterAdded:Connect(function(character)
            removeCollisionPart()
        end)
    end
end

--// Pass Bomb Functionality
local function passBomb()
    if passCooldown then return end
    passCooldown = true
    task.delay(Settings.BombPassCooldown, function()
        passCooldown = false
    end)

    if bombHolder == LocalPlayer then
        local closestPlayer = getClosestPlayer()
        if closestPlayer then
            local bomb = LocalPlayer.Character:FindFirstChild("Bomb")
            if bomb then
                createBombEffect(bomb, "pass")
                bomb.Parent = closestPlayer.Character
                bombHolder = closestPlayer
                print("Bomb passed to:", closestPlayer.Name)
            end
        else
            print("No valid players within range to pass the bomb.")
        end
    end
end

--// Get Closest Player
local function getClosestPlayer()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

--// Initialize Menu
createMenu()

-- Recreate the menu if the player respawns
LocalPlayer.CharacterAdded:Connect(createMenu)
