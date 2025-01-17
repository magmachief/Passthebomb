-- Load dependencies
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Variables
local AutoDodgePlayersEnabled = false
local CollectCoinsEnabled = false
local AntiAFKEnabled = false
local AutoPassBombEnabled = false

-- Logging function
local function logMessage(message)
    print("[Script]: " .. message)
end

-- Function to move to target position
local function moveToTarget(position)
    Character.HumanoidRootPart.CFrame = CFrame.new(position)
end
-- Load GUI library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Game Helper", HidePremium = true, SaveConfig = true, ConfigFolder = "OrionConfig"})

-- Create a tab for main features
local Tab = Window:MakeTab({
    Name = "Main Features",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Add toggles for features
Tab:AddToggle({
    Name = "Auto Dodge Players",
    Default = false,
    Callback = function(state)
        AutoDodgePlayersEnabled = state
        logMessage("Auto Dodge Players: " .. tostring(state))
    end
})

Tab:AddToggle({
    Name = "Collect Coins",
    Default = false,
    Callback = function(state)
        CollectCoinsEnabled = state
        logMessage("Collect Coins: " .. tostring(state))
    end
})

Tab:AddToggle({
    Name = "Anti-AFK",
    Default = false,
    Callback = function(state)
        AntiAFKEnabled = state
        if state then
            logMessage("Anti-AFK activated.")
        else
            logMessage("Anti-AFK deactivated.")
        end
    end
})

Tab:AddToggle({
    Name = "Auto Pass Bomb",
    Default = false,
    Callback = function(state)
        AutoPassBombEnabled = state
        logMessage("Auto Pass Bomb: " .. tostring(state))
    end
})
-- Auto Dodge Players
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

-- Collect Coins
RunService.Heartbeat:Connect(function()
    if CollectCoinsEnabled then
        for _, coin in pairs(workspace:GetDescendants()) do
            if coin:IsA("BasePart") and coin.Name == "Coin" then
                moveToTarget(coin.Position)
                logMessage("Collected coin at: " .. tostring(coin.Position))
                wait(0.2)
            end
        end
    end
end)

-- Auto Pass Bomb
RunService.Heartbeat:Connect(function()
    if AutoPassBombEnabled then
        local closestPlayer = nil
        local closestDistance = math.huge

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local playerRoot = player.Character.HumanoidRootPart
                local distance = (Character.HumanoidRootPart.Position - playerRoot.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end

        if closestPlayer and closestDistance <= 50 then -- Adjust distance threshold as needed
            local bomb = Character:FindFirstChild("Bomb")
            if bomb then
                moveToTarget(closestPlayer.Character.HumanoidRootPart.Position)
                logMessage("Passed bomb to: " .. closestPlayer.Name)
            end
        end
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if AntiAFKEnabled then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        logMessage("Anti-AFK triggered.")
    end
end)
-- Cleanup function
local function cleanup()
    AutoDodgePlayersEnabled = false
    CollectCoinsEnabled = false
    AntiAFKEnabled = false
    AutoPassBombEnabled = false
    logMessage("All features disabled.")
end

-- Add a stop button to the GUI
Tab:AddButton({
    Name = "Stop Script",
    Callback = function()
        cleanup()
        OrionLib:Destroy()
    end
})
