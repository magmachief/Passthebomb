--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")

local LocalPlayer = Players.LocalPlayer

--// Variables
local bombPassDistance = 10
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local autoPassConnection = nil

-- Console Logs
local logs = {}

-- Function to add log messages
local function addLog(message)
    table.insert(logs, "[" .. os.date("%X") .. "] " .. tostring(message))
end

-- Function to format logs for display
local function getLogString()
    return table.concat(logs, "\n")
end

--========================--
--    UTILITY FUNCTIONS   --
--========================--

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

-- Function to move closer to the nearest player
local function moveToClosestPlayer()
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true,
                AgentJumpHeight = 10,
                AgentMaxSlope = 45,
            })
            path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, closestPlayer.Character.HumanoidRootPart.Position)
            local waypoints = path:GetWaypoints()
            for _, waypoint in ipairs(waypoints) do
                humanoid:MoveTo(waypoint.Position)
                humanoid.MoveToFinished:Wait()
            end
        end
    end
end

-- Function to handle auto pass bomb
local function autoPassBomb()
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
                addLog("Passing bomb to: " .. closestPlayer.Name)
                BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
            else
                addLog("No valid player to pass the bomb.")
            end
        else
            addLog("No bomb found in character.")
        end
    end)
end

--========================--
--  APPLY FEATURES ON RESPAWN
--========================--
LocalPlayer.CharacterAdded:Connect(function()
    if AntiSlipperyEnabled then
        -- Apply Anti-Slippery on respawn
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
            end
        end
    end

    if RemoveHitboxEnabled then
        -- Apply Remove Hitbox on respawn
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "CollisionPart" then
                part:Destroy()
            end
        end
    end
end)


--========================--
--  ORIONLIB INTERFACE    --
--========================--

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()

local Window = OrionLib:MakeWindow({
    Name = "Yon Menu - Advanced",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "YonMenu_Advanced",
})

-- Updates Tab
local UpdatesTab = Window:MakeTab({
    Name = "Updates",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

UpdatesTab:AddParagraph("Changelog", [[
- Auto reapply features on respawn.
- Enhanced Anti-Slippery and Remove Hitbox.
- Added persistent feature toggles.
]])

-- Console Tab
local ConsoleTab = Window:MakeTab({
    Name = "Console",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local logParagraph = ConsoleTab:AddParagraph("Logs", getLogString())

-- Function to refresh console logs
local function refreshLogs()
    logParagraph:Set(getLogString())
end

-- Automated Tab
local AutomatedTab = Window:MakeTab({
    Name = "Automated",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AutomatedTab:AddToggle({
    Name = "Auto Pass Bomb",
    Default = AutoPassEnabled,
    Callback = function(value)
        AutoPassEnabled = value
        addLog("Auto Pass Bomb: " .. (AutoPassEnabled and "Enabled" or "Disabled"))
        refreshLogs()

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

AutomatedTab:AddToggle({
    Name = "Anti Slippery",
    Default = AntiSlipperyEnabled,
    Callback = function(value)
        AntiSlipperyEnabled = value
        addLog("Anti Slippery: " .. (AntiSlipperyEnabled and "Enabled" or "Disabled"))
        refreshLogs()

        if AntiSlipperyEnabled then
            spawn(function()
                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
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
            -- Reset properties when toggled off
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
                end
            end
        end
    end
})

AutomatedTab:AddToggle({
    Name = "Remove Hitbox",
    Default = RemoveHitboxEnabled,
    Callback = function(value)
        RemoveHitboxEnabled = value
        addLog("Remove Hitbox: " .. (RemoveHitboxEnabled and "Enabled" or "Disabled"))
        refreshLogs()

        if RemoveHitboxEnabled then
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name == "CollisionPart" then
                    part:Destroy()
                end
            end
        end
    end
})


-- Initialize OrionLib UI
OrionLib:Init()
addLog("Yon Menu Initialized Successfully")
refreshLogs()

print("Yon Menu Script Loaded with Enhanced Features")
