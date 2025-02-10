--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

--// Variables
local bombPassDistance = 10
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local autoPassConnection = nil
local pathfindingSpeed = 16 -- Default speed
local lastTargetPosition = nil -- Cached position for pathfinding

-- UI Themes
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

-- Function to rotate the character towards the target smoothly
local function rotateCharacterTowardsTarget(targetPosition)
    local character = LocalPlayer.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local direction = (targetPosition - humanoidRootPart.Position).unit
    local newCFrame = CFrame.fromMatrix(humanoidRootPart.Position, direction, Vector3.new(0, 1, 0))

    -- Smooth rotation using TweenService
    local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = newCFrame})
    tween:Play()
end

-- Auto Pass Bomb Logic with Bomb Pass Distance
local function autoPassBomb()
    if not AutoPassEnabled then return end
    pcall(function()
        local Bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
        if Bomb then
            local BombEvent = Bomb:FindFirstChild("RemoteEvent")
            local closestPlayer = getClosestPlayer()
            if closestPlayer and closestPlayer.Character then
                local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                local distance = (targetPosition - LocalPlayer.Character.HumanoidRootPart.Position).magnitude

                -- Only pass the bomb if the target is within the bomb pass distance
                if distance <= bombPassDistance then
                    rotateCharacterTowardsTarget(targetPosition)
                    -- Fire the remote event to pass the bomb
                    BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                end
            end
        end
    end)
end

-- Anti-Slippery: Apply or reset physical properties
local function applyAntiSlippery(enable)
    local character = LocalPlayer.Character
    if not character then return end

    -- If Anti Slippery is enabled
    if enable then
        -- Iterate over each part and change physical properties to prevent slipperiness
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Apply anti-slippery properties
                part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
            end
        end
    else
        -- If Anti Slippery is disabled, revert to default physical properties
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Revert to default properties
                part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
            end
        end
    end
end


-- Remove Hitbox: Destroy collision parts
local function applyRemoveHitbox(enable)
    local character = LocalPlayer.Character
    if not character then return end

    if enable then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Hitbox" then
                part.Transparency = 1
                part.CanCollide = false
            end
        end
    else
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Hitbox" then
                part.Transparency = 0
                part.CanCollide = true
            end
        end
    end
end

--========================--
--  APPLY FEATURES ON RESPAWN --
--========================--
LocalPlayer.CharacterAdded:Connect(function()
    if AntiSlipperyEnabled then 
        applyAntiSlippery(true) 
    end
    if RemoveHitboxEnabled then 
        applyRemoveHitbox(true) 
    end
end)

--========================--
--  ORIONLIB INTERFACE    --
--========================--
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()
local Window = OrionLib:MakeWindow({
    Name = "Yon Menu - Advanced",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "YonMenu_Advanced"
})

-- Automated Tab
local AutomatedTab = Window:MakeTab({
    Name = "Automated",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Add toggles, sliders, and dropdowns for the features
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

AutomatedTab:AddDropdown({
    Name = "UI Theme",
    Default = "Dark",
    Options = {"Dark", "Light", "Red"},
    Callback = function(themeName)
        local theme = uiThemes[themeName]
        if theme then
            -- Apply theme to UI elements here if needed
        else
            warn("Theme not found:", themeName)
        end
    end
})

OrionLib:Init()
print("Yon Menu Script Loaded with Adjustments")
