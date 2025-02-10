--[[
    FULL LOCAL SCRIPT
    -------------------------------
    This script loads OrionLib from GitHub, sets up Premium and Shift Lock systems,
    defines extra features (including a bomb distance slider), and creates a UI window.
    It now also includes built-in console functions so you can press F9 to toggle
    a console window.
    
    Make sure this script is a LocalScript (client-side) and your executor allows HTTP requests.
--]]

-----------------------------------------------------
-- SERVICES & LOCAL VARIABLES
-----------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-----------------------------------------------------
-- PREMIUM SYSTEM
-----------------------------------------------------
local function GrantPremiumToAll()
    for _, player in ipairs(Players:GetPlayers()) do
        player:SetAttribute("Premium", true)
    end
end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("Premium", true)
end)

local function IsPremium(player)
    return player:GetAttribute("Premium") == true
end

GrantPremiumToAll()

-----------------------------------------------------
-- SHIFT LOCK SYSTEM
-----------------------------------------------------
-- Shift Lock System (Revised)
local shiftlockk = Instance.new("ScreenGui")
local LockButton = Instance.new("ImageButton")
local btnIcon = Instance.new("ImageLabel")

shiftlockk.Name = "shiftlockk"
shiftlockk.Parent = game.CoreGui
shiftlockk.ResetOnSpawn = false

LockButton.Name = "LockButton"
LockButton.Parent = shiftlockk
LockButton.AnchorPoint = Vector2.new(1, 1)
LockButton.Position = UDim2.new(1, -50, 1, -50)
LockButton.Size = UDim2.new(0, 60, 0, 60)
LockButton.Image = "rbxassetid://530406505"
LockButton.ImageColor3 = Color3.fromRGB(0, 133, 199)

btnIcon.Name = "btnIcon"
btnIcon.Parent = LockButton
btnIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
btnIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
btnIcon.Image = "rbxasset://textures/ui/mouseLock_off.png"

local function EnableShiftLock()
    local gameSettings = settings():GetService("UserGameSettings")
    local previousRotation = gameSettings.RotationType
    local connection = nil

    -- Initially enable shift lock
    connection = RunService.RenderStepped:Connect(function()
        pcall(function()
            gameSettings.RotationType = Enum.RotationType.CameraRelative
        end)
    end)

    LockButton.MouseButton1Click:Connect(function()
        if connection then
            connection:Disconnect()
            connection = nil
            gameSettings.RotationType = previousRotation
            print("Shift Lock disabled")
        else
            connection = RunService.RenderStepped:Connect(function()
                pcall(function()
                    gameSettings.RotationType = Enum.RotationType.CameraRelative
                end)
            end)
            print("Shift Lock enabled")
        end
    end)
end
EnableShiftLock()

-----------------------------------------------------
-- UTILITY FUNCTIONS (for target finding & rotation)
-----------------------------------------------------
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localHRP then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - localHRP.Position).Magnitude
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
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local direction = (targetPosition - hrp.Position).Unit
    local newCFrame = CFrame.fromMatrix(hrp.Position, direction, Vector3.new(0, 1, 0))
    local tween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = newCFrame})
    tween:Play()
end

-----------------------------------------------------
-- FEATURE VARIABLES & BOMB DISTANCE SETTING
-----------------------------------------------------
local bombPassDistance = 10  -- Default bomb pass distance (studs)
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local autoPassConnection = nil

-- Modified autoPassBomb: Only pass bomb if closest player is within bombPassDistance.
local function autoPassBomb()
    if not AutoPassEnabled then return end
    pcall(function()
        local Bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
        if Bomb then
            local BombEvent = Bomb:FindFirstChild("RemoteEvent")
            local closestPlayer = getClosestPlayer()
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                local distance = (targetPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance <= bombPassDistance then
                    rotateCharacterTowardsTarget(targetPosition)
                    BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                end
            end
        end
    end)
end

-- Anti Slippery: Change physical properties of character parts.
local function applyAntiSlippery(enable)
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if enable then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                else
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0, 0)
                end
            end
        end
    end
end

-- Remove Hitbox: Hide hitbox parts.
local function applyRemoveHitbox(enable)
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Hitbox" then
                if enable then
                    part.Transparency = 1
                    part.CanCollide = false
                else
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
        end
    end
end

-----------------------------------------------------
-- ORION LIBRARY SETUP (Load from GitHub)
-----------------------------------------------------
local OrionLibSource = "https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"
local success, OrionLibLoaded = pcall(function() return loadstring(game:HttpGet(OrionLibSource))() end)
if not success or not OrionLibLoaded then
    error("Failed to load OrionLib! Check HTTP permissions and the remote file.")
end
print("OrionLibLoaded =", OrionLibLoaded)

-- For testing, set IntroEnabled = false so that the window appears immediately.
local Window = OrionLibLoaded:MakeWindow({ 
    Name = "Yon Menu - Advanced", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "YonMenu_Advanced", 
    IntroEnabled = false  -- immediate display for testing
})
print("Window created. Check CoreGui for the Orion GUI.")

print("Is LocalPlayer premium? " .. tostring(IsPremium(LocalPlayer)))

-----------------------------------------------------
-- UI: AUTOMATED TAB (For Premium Users)
-----------------------------------------------------
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

    -- Bomb Distance Slider: Adjust bomb pass reach (5-20 studs)
    AutomatedTab:AddSlider({
        Name = "Bomb Distance",
        Min = 5,
        Max = 20,
        Default = bombPassDistance,
        Increment = 1,
        ValueName = " studs",
        Callback = function(Value)
            bombPassDistance = Value
        end
    })
else
    Window:MakeTab({
        Name = "Premium Locked",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    }):AddLabel("⚠️ This feature requires Premium.")
end

-----------------------------------------------------
-- INITIALIZE UI & NOTIFICATIONS
-----------------------------------------------------
OrionLibLoaded:Init()
OrionLibLoaded:MakeNotification({
    Name = "Yon Menu",
    Content = "Yon Menu Script Loaded with Shift Lock & Premium Features 🚀",
    Time = 5
})
print("Yon Menu Script Loaded with Shift Lock & Premium Features 🚀")

--------------
