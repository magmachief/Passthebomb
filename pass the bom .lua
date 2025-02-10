-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- Premium System
local function GrantPremiumToAll()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        player:SetAttribute("Premium", true)  -- Match existing "Premium"
    end
end

game:GetService("Players").PlayerAdded:Connect(function(player)
    player:SetAttribute("Premium", true)  -- Match existing "Premium"
end)

function IsPremium(player)
    return player:GetAttribute("Premium") == true  -- Match existing "Premium"
end

-- Ensure premium status is granted upon script start
GrantPremiumToAll()

-- Shift Lock System (removed based on your request)
-- Removing shift lock feature since this script is separate and the user doesn't want it.

-- Utility Functions
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
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

local function rotateCharacterTowardsTarget(targetPosition)
    local character = LocalPlayer.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local direction = (targetPosition - humanoidRootPart.Position).unit
    local newCFrame = CFrame.fromMatrix(humanoidRootPart.Position, direction, Vector3.new(0, 1, 0))

    local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = newCFrame})
    tween:Play()
end

-- Features
local bombDistance = 10
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local autoPassConnection = nil

local function autoPassBomb()
    if not AutoPassEnabled then return end
    pcall(function()
        local Bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
        if Bomb then
            local BombEvent = Bomb:FindFirstChild("RemoteEvent")
            local closestPlayer = getClosestPlayer()
            if closestPlayer and closestPlayer.Character then
                local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                rotateCharacterTowardsTarget(targetPosition)
                BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
            end
        end
    end)
end

-- Anti Slippery Implementation
local function applyAntiSlippery(enable)
    if enable then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
            end
        end
    else
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0, 0) -- Default properties
            end
        end
    end
end

-- Remove Hitbox Implementation
local function applyRemoveHitbox(enable)
    if enable then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Hitbox" then
                part.Transparency = 1
                part.CanCollide = false
            end
        end
    else
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Hitbox" then
                part.Transparency = 0
                part.CanCollide = true
            end
        end
    end
end

-- UI Elements
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()
local Window = OrionLib:MakeWindow({ Name = "Advanced Menu", HidePremium = false, SaveConfig = true, ConfigFolder = "Advanced_Config" })

-- Debug print to see if the player is recognized as premium
print("Is LocalPlayer premium? " .. tostring(IsPremium(LocalPlayer)))

if IsPremium(LocalPlayer) then
    local AutomatedTab = Window:MakeTab({
        Name = "Automated",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = true
    })

    AutomatedTab:AddToggle({
        Name = "Anti Slippery",
        Default = false,
        Callback = function(value)
            AntiSlipperyEnabled = value
            applyAntiSlippery(value)
        end
    })

    AutomatedTab:AddToggle({
        Name = "Remove Hitbox",
        Default = false,
        Callback = function(value)
            RemoveHitboxEnabled = value
            applyRemoveHitbox(value)
        end
    })

    AutomatedTab:AddToggle({
        Name = "Auto Pass Bomb",
        Default = false,
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

    -- Bomb Distance Slider
    AutomatedTab:AddSlider({
        Name = "Bomb Distance",
        Min = 5,
        Max = 20,
        Default = 10,
        Callback = function(value)
            bombDistance = value
            print("Bomb Distance set to: " .. bombDistance)
        end
    })
else
    Window:MakeTab({
        Name = "Premium Locked",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    }):AddLabel("⚠️ This feature requires Premium.")
end

OrionLib:Init()
print("Yon Menu Script Loaded with Premium Features 🚀")
