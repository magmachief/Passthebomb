local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local AutoDodgePlayersEnabled = false
local CollectCoinsEnabled = false

-- Utility Functions
local function logMessage(message)
    print("[Yon Menu]: " .. message)
end

local function moveToTarget(targetPosition)
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
    else
        logMessage("Character or HumanoidRootPart not found.")
    end
end
local Window = OrionLib:MakeWindow({
    Name = "Yon Menu - Advanced",
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "YonMenuConfig"
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

Tab:AddToggle({
    Name = "Auto Dodge Players",
    Default = false,
    Callback = function(value)
        AutoDodgePlayersEnabled = value
        logMessage("Auto Dodge Players: " .. tostring(value))
    end
})

Tab:AddToggle({
    Name = "Collect Coins",
    Default = false,
    Callback = function(value)
        CollectCoinsEnabled = value
        logMessage("Collect Coins: " .. tostring(value))
    end
})
-- Auto Dodge Players Loop
RunService.Heartbeat:Connect(function()
    if AutoDodgePlayersEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local enemyRoot = player.Character.HumanoidRootPart
                local distance = (Character.HumanoidRootPart.Position - enemyRoot.Position).Magnitude
                if distance < 10 then
                    local dodgeDirection = (Character.HumanoidRootPart.Position - enemyRoot.Position).unit * 20
                    local newPosition = Character.HumanoidRootPart.Position + dodgeDirection
                    moveToTarget(newPosition)
                    logMessage("Dodged " .. player.Name)
                end
            end
        end
    end
end)

-- Collect Coins Loop
RunService.Heartbeat:Connect(function()
    if CollectCoinsEnabled then
        for _, coin in pairs(workspace:GetDescendants()) do
            if coin:IsA("BasePart") and coin.Name == "Coin" then
                moveToTarget(coin.Position)
                logMessage("Collected a coin at: " .. tostring(coin.Position))
                wait(0.2) -- Prevents instant teleport spam
            end
        end
    end
end)
-- Cleanup when script is disabled or user exits
local function cleanup()
    AutoDodgePlayersEnabled = false
    CollectCoinsEnabled = false
    logMessage("Script stopped, all features disabled.")
end

-- Add an exit button to the GUI
Tab:AddButton({
    Name = "Stop Script",
    Callback = function()
        cleanup()
        OrionLib:Destroy()
    end
})

