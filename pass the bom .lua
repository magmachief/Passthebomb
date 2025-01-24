--// Services
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

--// Variables
local bombPassDistance = 10
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local BombAlertEnabled = false
local autoPassConnection = nil
local pathfindingSpeed = 16 -- Default speed
local jumpHeight = 10 -- Default jump height

-- UI Elements
local bombDistanceLabel -- UI for showing bomb distance
local bombIndicator -- UI for directional arrow
local uiThemes = {
    ["Dark"] = { Background = Color3.new(0, 0, 0), Text = Color3.new(1, 1, 1) },
    ["Light"] = { Background = Color3.new(1, 1, 1), Text = Color3.new(0, 0, 0) },
    ["Red"] = { Background = Color3.new(1, 0, 0), Text = Color3.new(1, 1, 1) },
}

--========================--
--    UTILITY FUNCTIONS   --
--========================--

-- Function to get the closest player
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

-- Function to create UI elements for bomb alerts
local function createBombAlertUI()
    local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))

    -- Distance Label
    bombDistanceLabel = Instance.new("TextLabel", screenGui)
    bombDistanceLabel.Size = UDim2.new(0, 200, 0, 50)
    bombDistanceLabel.Position = UDim2.new(0.5, -100, 0.85, 0)
    bombDistanceLabel.BackgroundTransparency = 1
    bombDistanceLabel.TextScaled = true
    bombDistanceLabel.Text = "No bomb detected"
    bombDistanceLabel.TextColor3 = Color3.new(1, 1, 1)

    -- Directional Indicator
    bombIndicator = Instance.new("ImageLabel", screenGui)
    bombIndicator.Size = UDim2.new(0, 50, 0, 50)
    bombIndicator.Position = UDim2.new(0.5, -25, 0.4, 0)
    bombIndicator.BackgroundTransparency = 1
    bombIndicator.Image = "rbxassetid://11582659479"
    bombIndicator.Visible = false
end

-- Function to apply UI themes
local function applyUITheme(themeName)
    local theme = uiThemes[themeName]
    if theme then
        if bombDistanceLabel then
            bombDistanceLabel.BackgroundColor3 = theme.Background
            bombDistanceLabel.TextColor3 = theme.Text
        end
        if bombIndicator then
            bombIndicator.BackgroundColor3 = theme.Background
        end
    else
        warn("Theme not found:", themeName)
    end
end

-- Function to update bomb alerts
local function bombAlert()
    while BombAlertEnabled do
        task.wait(0.5) -- Check every 0.5 seconds
        local bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
        if bomb then
            local bombPart = bomb:FindFirstChildWhichIsA("BasePart")
            if bombPart then
                local playerPosition = LocalPlayer.Character.HumanoidRootPart.Position
                local bombPosition = bombPart.Position
                local distance = (playerPosition - bombPosition).magnitude

                -- Update distance label
                bombDistanceLabel.Text = string.format("Bomb Distance: %.2f", distance)
                bombDistanceLabel.TextColor3 = distance < 10 and Color3.new(1, 0, 0) or (distance < 20 and Color3.new(1, 1, 0) or Color3.new(0, 1, 0))

                -- Update directional indicator
                local screenCenter = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
                local bombScreenPosition, onScreen = workspace.CurrentCamera:WorldToViewportPoint(bombPosition)
                local direction = (Vector2.new(bombScreenPosition.X, bombScreenPosition.Y) - screenCenter).unit
                local angle = math.atan2(direction.Y, direction.X)
                bombIndicator.Rotation = math.deg(angle) + 90 -- Adjust the rotation to point correctly
                bombIndicator.Position = UDim2.new(0.5, direction.X * 100, 0.4, direction.Y * 100) -- Adjust the position based on direction
                bombIndicator.Visible = true
            else
                bombDistanceLabel.Text = "Bomb not found"
                bombIndicator.Visible = false
            end
        else
            bombDistanceLabel.Text = "No bomb detected"
            bombIndicator.Visible = false
        end
    end
end

--========================--
--     FEATURE LOGIC      --
--========================--

-- Anti-Slippery: Apply or reset physical properties
local function applyAntiSlippery(enabled)
    if enabled then
        spawn(function()
            while enabled and AntiSlipperyEnabled do
                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
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

-- Remove Hitbox: Destroy collision parts
local function applyRemoveHitbox(enabled)
    if not enabled then return end
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local function removeCollisionPart(character)
        for destructionIteration = 1, 100 do
            wait()
            pcall(function()
                local collisionPart = character:FindFirstChild("CollisionPart")
                if collisionPart then collisionPart:Destroy() end
            end)
        end
    end
    removeCollisionPart(character)
    LocalPlayer.CharacterAdded:Connect(removeCollisionPart)
end

-- Auto Pass Bomb Logic
local function autoPassBomb()
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
                    local waypoints = path:GetWaypoints()
                    for _, waypoint in ipairs(waypoints) do
                        humanoid:MoveTo(waypoint.Position)
                        humanoid.MoveToFinished:Wait()
                    end
                end
                BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
            end
        end
    end)
end

--========================--
--  APPLY FEATURES ON RESPAWN --
--========================--
LocalPlayer.CharacterAdded:Connect(function()
    if AntiSlipperyEnabled then applyAntiSlippery(true) end
    if RemoveHitboxEnabled then applyRemoveHitbox(true) end
end)

--========================--
--  ORIONLIB INTERFACE    --
--========================--

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()
local Window = OrionLib:MakeWindow({ Name = "Yon Menu - Advanced", HidePremium = false, SaveConfig = true, ConfigFolder = "YonMenu_Advanced" })

-- Automated Tab
local AutomatedTab = Window:MakeTab({
    Name = "Automated",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AutomatedTab:AddToggle({
    Name = "Anti Slippery",
    Default = AntiSlipperyEnabled,
    Callback = function(value)
        AntiSlipperyEnabled = value
        applyAntiSlippery(value)
    end
})

AutomatedTab:AddToggle({
    Name = "Remove Hitbox",
    Default = RemoveHitboxEnabled,
    Callback = function(value)
        RemoveHitboxEnabled = value
        applyRemoveHitbox(value)
    end
})

AutomatedTab:AddToggle({
    Name = "Auto Pass Bomb",
    Default = AutoPassEnabled,
    Callback = function(value)
        AutoPassEnabled = value
        if AutoPassEnabled then
            autoPassConnection = RunService.Stepped:Connect(autoPassBomb)
        else
            if autoPassConnection then
                autoPassConnection:Disconnect()
                autoPassConnection = nil
            end
        end
    end
})

AutomatedTab:AddSlider({
    Name = "Bomb Pass Distance",
    Min = 5,
    Max = 30,
    Default = bombPassDistance,
    Increment = 1,
    Callback = function(value)
        bombPassDistance = value
    end
})

AutomatedTab:AddDropdown({
    Name = "Pathfinding Speed",
    Default = "16",
    Options = {"12", "16", "20"},
    Callback = function(value)
        pathfindingSpeed = tonumber(value)
    end
})

AutomatedTab:AddToggle({
    Name = "Bomb Alert",
    Default = BombAlertEnabled,
    Callback = function(value)
        BombAlertEnabled = value
        if BombAlertEnabled then
            spawn(bombAlert)
        end
    end
})

AutomatedTab:AddDropdown({
    Name = "UI Theme",
    Default = "Dark",
    Options = { "Dark", "Light", "Red" },
    Callback = applyUITheme,
})

local AudioTab = Window:MakeTab({
    Name = "Audio",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AudioTab:AddSlider({
    Name = "Game Volume",
    Min = 0,
    Max = 100,
    Default = 100,
    Increment = 1,
    Callback = function(value)
        SoundService.AmbientVolume = value / 100
    end
})

OrionLib:Init()
createBombAlertUI()
applyUITheme("Dark")
print("Yon Menu Script Loaded with Enhanced Features")
