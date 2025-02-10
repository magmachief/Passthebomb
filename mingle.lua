-- Deobfuscating Luraph-protected script
-- Extracting core functionalities: Open/Close Doors, Push Aura, Player Detection in Room, Auto-Room Selection

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Doors = workspace:FindFirstChild("Doors")
local Rooms = workspace:FindFirstChild("Rooms") -- Assuming rooms are stored in a workspace folder

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/refs/heads/main/Orion%20Lib%20Transparent%20%20.lua"))()
local Window = OrionLib:MakeWindow({ Name = "Mingle Carousel Menu", HidePremium = false, SaveConfig = true, ConfigFolder = "MingleSettings" })

-- Menu Tabs
local DoorsTab = Window:MakeTab({ Name = "Doors", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local AutoTab = Window:MakeTab({ Name = "Auto", Icon = "rbxassetid://4483345998", PremiumOnly = false })
local PushTab = Window:MakeTab({ Name = "Push Aura", Icon = "rbxassetid://4483345998", PremiumOnly = false })

-- Function to Open All Doors
local function openAllDoors()
    for _, door in pairs(Doors:GetChildren()) do
        if door:IsA("Model") and door:FindFirstChild("Door") then
            door.Door.Transparency = 0.5
            door.Door.CanCollide = false
        end
    end
end

DoorsTab:AddButton({ Name = "Open All Doors", Callback = openAllDoors })

-- Function to Close All Doors
local function closeAllDoors()
    for _, door in pairs(Doors:GetChildren()) do
        if door:IsA("Model") and door:FindFirstChild("Door") then
            door.Door.Transparency = 0
            door.Door.CanCollide = true
        end
    end
end

DoorsTab:AddButton({ Name = "Close All Doors", Callback = closeAllDoors })

-- Auto-Room Selection
local function autoJoinBestRoom()
    local bestRoom = getBestRoom()
    if bestRoom and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = bestRoom.RoomTrigger.CFrame + Vector3.new(0, 3, 0)
    end
end

AutoTab:AddButton({ Name = "Auto Join Best Room", Callback = autoJoinBestRoom })

-- Push Aura Toggle
local PushAuraEnabled = false
local PushDelay = 0.5

local function enablePushAura()
    PushAuraEnabled = true
    while PushAuraEnabled do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
                if distance < 10 then
                    player.Character.HumanoidRootPart.Velocity = Vector3.new(math.random(-50,50), 50, math.random(-50,50))
                end
            end
        end
        wait(PushDelay)
    end
end

local function disablePushAura()
    PushAuraEnabled = false
end

PushTab:AddToggle({ Name = "Enable Push Aura", Default = false, Callback = function(value)
    if value then enablePushAura() else disablePushAura() end
end })

OrionLib:Init()

print("Deobfuscated script loaded: Menu added with Orion Library")
