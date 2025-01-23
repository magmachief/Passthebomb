-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/refs/heads/main/Orion%20Lib.lua"))()

-- Variables and Default Settings
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

local bombHolder = nil
local bombPassDistance = 10
local passToClosest = true

local preferences = {
    AntiSlipperyEnabled = false,
    RemoveHitboxEnabled = false,
    AutoPassEnabled = false,
}

-- Theme Presets
local themes = {
    Dark = {Background = Color3.fromRGB(30, 30, 30), TextColor = Color3.fromRGB(255, 255, 255)},
    Light = {Background = Color3.fromRGB(230, 230, 230), TextColor = Color3.fromRGB(0, 0, 0)},
    Ocean = {Background = Color3.fromRGB(0, 128, 255), TextColor = Color3.fromRGB(255, 255, 255)},
    Sunset = {Background = Color3.fromRGB(255, 128, 0), TextColor = Color3.fromRGB(0, 0, 0)},
}

-- Functions
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
            end
        end
    end
end

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
    Name = "Advanced Menu",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AdvancedMenuConfig"
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
            RunService.Stepped:Connect(passBomb)
        end
    end
})

-- Settings
SettingsTab:AddDropdown({
    Name = "Theme",
    Default = "Dark",
    Options = {"Dark", "Light", "Ocean", "Sunset"},
    Callback = function(theme)
        OrionLib:MakeNotification({
            Name = "Theme Changed",
            Content = "Switched to " .. theme .. " theme.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

-- Finalize Orion Menu
OrionLib:Init()
