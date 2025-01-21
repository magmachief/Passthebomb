--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

--// Variables
local bombHolder = nil
local bombPassDistance = 10
local passToClosest = true
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local menuCreated = false
local activeConnections = {}

-- Function to get the closest player
local function getClosestPlayer()
    local closestPlayer, shortestDistance = nil, math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not player.Character:FindFirstChild("Bomb") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
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
            for _, waypoint in ipairs(path:GetWaypoints()) do
                humanoid:MoveTo(waypoint.Position)
                humanoid.MoveToFinished:Wait()
            end
        end
    end
end

-- Function to pass the bomb
local function passBomb()
    if bombHolder == LocalPlayer and passToClosest then
        local closestPlayer = getClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (closestPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance <= bombPassDistance then
                local bomb = LocalPlayer.Character:FindFirstChild("Bomb")
                if bomb then
                    bomb.Parent = closestPlayer.Character
                    print("Bomb passed to:", closestPlayer.Name)
                end
            else
                print("No players within bomb pass distance.")
            end
        end
    end
end

-- Function to manage menu creation
local function createYonkaiMenu()
    if menuCreated then return end
    menuCreated = true

    -- Create UI elements here (same as your script)
    -- Connect toggle buttons, ensuring connections are stored and can be cleaned later

    print("Yonkai Menu created.")
end

-- Clean up connections
local function cleanupConnections()
    for _, connection in ipairs(activeConnections) do
        connection:Disconnect()
    end
    table.clear(activeConnections)
end

-- Manage respawn handling
LocalPlayer.CharacterAdded:Connect(function()
    cleanupConnections()
    createYonkaiMenu()
end)

-- Ensure the menu is created initially
createYonkaiMenu()

print("Optimized script loaded.")
