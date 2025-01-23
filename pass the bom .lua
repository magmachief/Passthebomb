--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/refs/heads/main/Orion%20Lib.lua"))()

-- Default Settings and Preferences
local bombHolder = nil
local bombPassDistance = 10
local passToClosest = true

local preferences = {
    AntiSlipperyEnabled = false,
    RemoveHitboxEnabled = false,
    AutoPassEnabled = false,
}

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

-- Function to pass the bomb to the closest player
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
                print("No players within bomb pass distance. Searching for a new target...")
            end
        else
            print("No valid closest player found.")
        end
    end
end

-- Anti-Slippery functionality
local function applyAntiSlippery(enabled)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if enabled then
        while preferences.AntiSlipperyEnabled do
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                end
            end
            RunService.Heartbeat:Wait()
        end
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
            end
        end
    end
end

-- Remove Hitbox functionality
local function removeHitbox(enabled)
    local function cleanHitbox(character)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "CollisionPart" then
                part:Destroy()
            end
        end
    end

    if enabled then
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        cleanHitbox(character)
        LocalPlayer.CharacterAdded:Connect(cleanHitbox)
    end
end

-- Orion Menu
local Window = OrionLib:MakeWindow({
    Name = "Yonkai Menu",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "YonkaiMenuConfig"
})

-- Tabs
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Main Features
MainTab:AddToggle({
    Name = "Anti-Slippery",
    Default = preferences.AntiSlipperyEnabled,
    Callback = function(value)
        preferences.AntiSlipperyEnabled = value
        applyAntiSlippery(value)
    end
})

MainTab:AddToggle({
    Name = "Remove Hitbox",
    Default = preferences.RemoveHitboxEnabled,
    Callback = function(value)
        preferences.RemoveHitboxEnabled = value
        removeHitbox(value)
    end
})

MainTab:AddToggle({
    Name = "Auto Pass Bomb",
    Default = preferences.AutoPassEnabled,
    Callback = function(value)
        preferences.AutoPassEnabled = value
        if value then
            print("Auto Pass Bomb: Enabled")
            RunService.Stepped:Connect(passBomb)
        else
            print("Auto Pass Bomb: Disabled")
        end
    end
})

-- Settings
SettingsTab:AddDropdown({
    Name = "Theme",
    Default = "Dark",
    Options = {"Dark", "Light", "Ocean", "Sunset"},
    Callback = function(theme)
        print("Theme changed to:", theme)
    end
})

-- Toggle Button for Menu Visibility (Mobile-Friendly)
local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 70, 0, 70)
toggleButton.Position = UDim2.new(0.9, -80, 0.8, -80) -- Bottom-right corner
toggleButton.Image = "rbxassetid://6031075938" -- Replace with your desired icon asset ID
toggleButton.BackgroundTransparency = 1
toggleButton.Parent = game.CoreGui

local menuVisible = true

toggleButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    Window:Toggle(menuVisible)
end)

-- Finalize Orion Menu
OrionLib:Init()
