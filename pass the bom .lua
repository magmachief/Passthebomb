--[[ 
    Custom UI Script using Orion Library
    - Loads Orion Lib Transparent from GitHub.
    - Creates three tabs: Home, Settings, and Toggles.
    - The Toggles tab contains three toggles:
         • Auto Pass Bomb
         • Anti Slippery
         • Remove Hitbox
    This version also includes a getClosestPlayer() function so that the Auto Pass Bomb toggle 
    will select the nearest target instead of a random one.
    No sugar-coating: this is lean and forward‑thinking. Modify as needed.
]]--

-----------------------------------------------------
-- LOAD ORION LIBRARY
-----------------------------------------------------
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/refs/heads/main/Orion%20Lib%20Transparent%20.lua"))()
-- Create the main window. (Adjust IntroEnabled, Name, etc. as desired.)
local Window = OrionLib:MakeWindow({
    Name = "Yonkai",
    IntroEnabled = true,
    SaveConfig = false
})

-----------------------------------------------------
-- CREATE TABS (Home, Settings, Toggles)
-----------------------------------------------------
local HomeTab = Window:MakeTab({
    Name = "Home",
    Icon = "rbxassetid://6031075937"  -- Change to your desired icon asset
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://6031075937"
})

local TogglesTab = Window:MakeTab({
    Name = "Toggles",
    Icon = "rbxassetid://6031075937"
})

-- For demonstration, add a simple label in Home and Settings.
HomeTab:AddLabel("Welcome Home!")
SettingsTab:AddLabel("Settings Tab")

-----------------------------------------------------
-- HELPER FUNCTION: Get Closest Player
-----------------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return nil end
    local hrp = localCharacter:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local distance = (targetHRP.Position - hrp.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-----------------------------------------------------
-- HELPER FUNCTION: Rotate Character Towards Target
-----------------------------------------------------
local TweenService = game:GetService("TweenService")
local function rotateCharacterTowardsTarget(targetPosition)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    local direction = (targetPosition - humanoidRootPart.Position).Unit
    local newCFrame = CFrame.fromMatrix(humanoidRootPart.Position, direction, Vector3.new(0,1,0))
    local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = newCFrame})
    tween:Play()
end

-----------------------------------------------------
-- TOGGLES (Added to the Toggles Tab)
-----------------------------------------------------
-- Toggle Variables
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false

-- Auto Pass Bomb Toggle (Now using getClosestPlayer)
TogglesTab:AddToggle({
    Name = "Auto Pass Bomb",
    Default = false,
    Flag = "AutoPassBomb",  -- Save flag (if using config saving)
    Callback = function(Value)
        AutoPassEnabled = Value
        if Value then
            spawn(function()
                while AutoPassEnabled do
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Bomb") then
                            local passTarget = getClosestPlayer()
                            if passTarget and passTarget.Character and passTarget.Character:FindFirstChild("HumanoidRootPart") then
                                rotateCharacterTowardsTarget(passTarget.Character.HumanoidRootPart.Position)
                                -- Pass the bomb by setting its CFrame to the target's HumanoidRootPart CFrame
                                player.Character.Bomb.CFrame = passTarget.Character.HumanoidRootPart.CFrame
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

-- Anti Slippery Toggle
TogglesTab:AddToggle({
    Name = "Anti Slippery",
    Default = false,
    Flag = "AntiSlippery",
    Callback = function(Value)
        AntiSlipperyEnabled = Value
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if Value then
                        part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, 0.5)
                    else
                        part.CustomPhysicalProperties = PhysicalProperties.new()  -- Default properties
                    end
                end
            end
        end
    end
})

-- Remove Hitbox Toggle
TogglesTab:AddToggle({
    Name = "Remove Hitbox",
    Default = false,
    Flag = "RemoveHitbox",
    Callback = function(Value)
        RemoveHitboxEnabled = Value
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name == "Hitbox" then
                    if Value then
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
})

-----------------------------------------------------
-- INITIALIZE & NOTIFY
-----------------------------------------------------
OrionLib:Init()  -- Loads your saved config if applicable.
OrionLib:MakeNotification({
    Name = "Custom UI",
    Content = "Custom UI with toggles loaded successfully!",
    Time = 5
})
