--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local bombHolder = nil
local bombPassDistance = 10
local passToClosest = true
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false

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

-- Function to move towards the closest player
local function moveToClosestPlayer()
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true,
                AgentJumpHeight = 10,
                AgentMaxSlope = 45,
            })
            path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, targetPosition)
            local waypoints = path:GetWaypoints()
            local waypointIndex = 1

            local function followPath()
                if waypointIndex <= #waypoints then
                    local waypoint = waypoints[waypointIndex]
                    humanoid:MoveTo(waypoint.Position)
                    humanoid.MoveToFinished:Connect(function(reached)
                        if reached then
                            waypointIndex = waypointIndex + 1
                            followPath()
                        else
                            -- Path was blocked, recompute path
                            moveToClosestPlayer()
                        end
                    end)
                end
            end

            followPath()
        end
    end
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
                print("No players within bomb pass distance. Moving to closest player.")
                moveToClosestPlayer()
            end
        else
            print("No valid closest player found.")
        end
    end
end

--========================--
--     INITIAL SETUP      --
--========================--

-- Create a ScreenGui for Mobile
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileScreenGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Toggle Button to Open/Close Menu
local Toggle = Instance.new("ImageButton")
Toggle.Name = "Toggle"
Toggle.Parent = ScreenGui
Toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red background for visibility
Toggle.Position = UDim2.new(0.5, -30, 0, 50) -- Positioned near the top center
Toggle.Size = UDim2.new(0, 60, 0, 60) -- 60x60 pixels
Toggle.Image = "rbxassetid://18594014746" -- Replace with your desired image asset ID
Toggle.ScaleType = Enum.ScaleType.Fit

-- Make the Toggle Button Circular
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0.5, 0)
Corner.Parent = Toggle

-- Load OrionLib for UI
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()

--========================--
--  MAIN WINDOW CREATION  --
--========================--

local Window = OrionLib:MakeWindow({
    Name = "Yon Menu - Advanced",
    HidePremium = false,
    IntroEnabled = true,
    IntroText = "Yon Menu",
    SaveConfig = true,
    ConfigFolder = "YonMenu_Advanced",
    IntroIcon = "rbxassetid://9876543210",  -- Replace with your desired intro icon ID
    Icon = "rbxassetid://9876543210",       -- Replace with your desired window icon ID
})

--========================--
--   UPDATE / CHANGELOG   --
--========================--

local UpdateLogTab = Window:MakeTab({
    Name = "Updates Log",
    Icon = "rbxassetid://4483345998", -- Replace with your desired icon ID
    PremiumOnly = false
})

-- List of version updates or changelogs
UpdateLogTab:AddParagraph("Changelog", [[
1. Added random/targeted auto pass logic.
2. Introduced a console tab for execution logs.
3. Enhanced user interface with OrionLib advanced features.
4. Improved Auto Collect Coins functionality.
5. Added Auto Pass Closest Player functionality.
]])

--========================--
--       CONSOLE TAB      --
--========================--

local ConsoleTab = Window:MakeTab({
    Name = "Console",
    Icon = "rbxassetid://4483345998", -- Replace with your desired icon ID
    PremiumOnly = false
})

local logs = {}
local logDisplay

-- Helper function to refresh log display
local function refreshLogDisplay()
    if logDisplay then
        -- Combine all log messages into a single string separated by newlines
        local combined = table.concat(logs, "\n")
        logDisplay:Set(combined)
    end
end

-- Function to log a message to the console
local function logMessage(msg)
    table.insert(logs, "[" .. os.date("%X") .. "] " .. tostring(msg))
    refreshLogDisplay()
end

-- Create a Paragraph for console output
logDisplay = ConsoleTab:AddParagraph("Execution Logs", "")
refreshLogDisplay()

--========================--
--   AUTOMATED TAB        --
--========================--

local AutomatedTab = Window:MakeTab({
    Name = "Automated",
    Icon = "rbxassetid://4483345998", -- Replace with your desired icon ID
    PremiumOnly = false
})

-- Auto Pass Bomb Toggle
AutomatedTab:AddToggle({
    Name = "Auto Pass Bomb",
    Default = AutoPassEnabled,
    Callback = function(value)
        AutoPassEnabled = value
        logMessage("Auto Pass Bomb: " .. (AutoPassEnabled and "Enabled" or "Disabled"))
    end
})

-- Anti-Slippery Toggle
AutomatedTab:AddToggle({
    Name = "Anti Slippery",
    Default = AntiSlipperyEnabled,
    Callback = function(value)
        AntiSlipperyEnabled = value
        logMessage("Anti Slippery: " .. (AntiSlipperyEnabled and "Enabled" or "Disabled"))
        if AntiSlipperyEnabled then
            spawn(function()
                local player = Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                while AntiSlipperyEnabled do
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                        end
                    end
                    wait(0.1)
                end
            end)
        else
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
                end
            end
        end
    end
})

-- Remove Hitbox Toggle
AutomatedTab:AddToggle({
    Name = "Remove Hitbox",
    Default = RemoveHitboxEnabled,
    Callback = function(value)
        RemoveHitboxEnabled = value
        logMessage("Remove Hitbox: " .. (RemoveHitboxEnabled and "Enabled" or "Disabled"))
        if RemoveHitboxEnabled then
            local LocalPlayer = Players.LocalPlayer
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local function removeCollisionPart(character)
                for destructionIteration = 1, 100 do
                    wait()
                    pcall(function()
                        character:WaitForChild("CollisionPart"):Destroy()
                    end)
                end
            end
            removeCollisionPart(Character)
            LocalPlayer.CharacterAdded:Connect(function(character)
                removeCollisionPart(character)
            end)
        end
    end
})

--========================--
--   TOGGLE MENU BUTTON   --
--========================--

Toggle.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
    logMessage("Menu toggled - Now: " .. (ScreenGui.Enabled and "Visible" or "Hidden"))
end)

-- Initialize OrionLib UI
OrionLib:Init()
logMessage("Yon Menu Initialized Successfully")

--========================--
--     FUNCTIONALITIES    --
--========================--

-- Auto Pass Bomb functionality
local autoPassConnection
if AutoPassEnabled then
    autoPassConnection = RunService.Stepped:Connect(function()
        if not AutoPassEnabled then return end
        pcall(function()
            if LocalPlayer.Backpack:FindFirstChild("Bomb") then
                LocalPlayer.Backpack:FindFirstChild("Bomb").Parent = LocalPlayer.Character
            end

            local Bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
            if Bomb then
                local BombEvent = Bomb:FindFirstChild("RemoteEvent")
                local closestPlayer = getClosestPlayer()
                if closestPlayer and closestPlayer.Character then
                    local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        local path = PathfindingService:CreatePath({
                            AgentRadius = 2,
                            AgentHeight = 5,
                            AgentCanJump = true,
                            AgentJumpHeight = 10,
                            AgentMaxSlope = 45,
                        })
                        path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, targetPosition)
                        local waypoints = path:GetWaypoints()
                        local waypointIndex = 1

                        local function followPath()
                            if waypointIndex <= #waypoints then
                                local waypoint = waypoints[waypointIndex]
                                humanoid:MoveTo(waypoint.Position)
                                humanoid.MoveToFinished:Connect(function(reached)
                                    if reached then
                                        waypointIndex = waypointIndex + 1
                                        followPath()
                                    else
                                        -- Path was blocked, recompute path
                                        moveToClosestPlayer()
                                    end
                                end)
                            end
                        end

                        followPath()
                    end
                    BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                end
            end
        end)
    end)
end

-- Anti-Slippery functionality
if AntiSlipperyEnabled then
    spawn(function()
        local player = Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        while AntiSlipperyEnabled do
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                end
            end
            wait(0.1)
        end
    end)
else
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
        end
    end
end

-- Remove Hitbox functionality
if RemoveHitboxEnabled then
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local function removeCollisionPart(character)
        for destructionIteration = 1, 100 do
            wait()
            pcall(function()
                character:WaitForChild("CollisionPart"):Destroy()
            end)
        end
    end
    removeCollisionPart(Character)
    LocalPlayer.CharacterAdded:Connect(function(character)
        removeCollisionPart(character)
    end)
end

print("Pass The Bomb Script Loaded")
