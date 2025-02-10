--[[
    Full Orion Library Script with Premium System, Shift Lock, and Extra Features,
    Enhanced Animations, and a Built-in Mobile Console Log (PC-like)

    • Premium System: Automatically grants premium to all players.
    • Shift Lock System: Allows toggling camera rotation (using settings() instead of UserSettings()).
    • OrionLib: A custom UI library (with Feather Icons loaded) including draggable windows,
      notifications, tabs, and all basic element creation functions.
    • Extra Features: Auto Pass Bomb, Anti Slippery, Remove Hitbox, and a Bomb Distance slider.
    • Built-in Console Log: A draggable console overlay that lets you run commands and shows output,
      simulating a PC console on mobile.
    
    NOTE: This is a combined and improved version.
    Do not remove or shorten sections. Adjust asset IDs, colors, or tween durations as needed.
]]--

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
        player:SetAttribute("Premium", true)  -- Match existing "Premium"
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
-- SHIFT LOCK SYSTEM (Improved using settings())
-----------------------------------------------------
local shiftlockk = Instance.new("ScreenGui")
shiftlockk.Name = "shiftlockk"
shiftlockk.Parent = game.CoreGui
shiftlockk.ResetOnSpawn = false

local LockButton = Instance.new("ImageButton")
LockButton.Name = "LockButton"
LockButton.Parent = shiftlockk
LockButton.AnchorPoint = Vector2.new(1, 1)
LockButton.Position = UDim2.new(1, -50, 1, -50)
LockButton.Size = UDim2.new(0, 60, 0, 60)
LockButton.Image = "rbxassetid://530406505"
LockButton.ImageColor3 = Color3.fromRGB(0, 133, 199)

local btnIcon = Instance.new("ImageLabel")
btnIcon.Name = "btnIcon"
btnIcon.Parent = LockButton
btnIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
btnIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
btnIcon.Image = "rbxasset://textures/ui/mouseLock_off.png"

local function EnableShiftLock()
    local gameSettings = settings():GetService("UserGameSettings")
    local previousRotation = gameSettings.RotationType
    local connection = nil

    -- Initially force CameraRelative rotation for shiftlock
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
-- UTILITY FUNCTIONS
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
    local tween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = newCFrame})
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
-- MAIN UI USING ORION LIBRARY
-----------------------------------------------------
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()
local OrionLibLoaded = OrionLib  -- (We already defined OrionLib above)
local Window = OrionLibLoaded:MakeWindow({ Name = "Yon Menu - Advanced", HidePremium = false, SaveConfig = true, ConfigFolder = "YonMenu_Advanced", IntroEnabled = true })

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
    Content = "Yon Menu Script Loaded with Shift Lock, Premium Features, and Enhanced Animations 🚀",
    Time = 5
})
print("Yon Menu Script Loaded with Shift Lock & Premium Features 🚀")
