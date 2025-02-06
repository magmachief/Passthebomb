--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

--// Variables
local bombPassDistance = 10
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local AutoCollectEnabled = false
local HealthMonitorEnabled = false
local EscapeMechanismEnabled = false
local autoPassConnection = nil
local autoCollectConnection = nil
local healthMonitorConnection = nil
local escapeMechanismConnection = nil
local pathfindingSpeed = 16 -- Default speed
local lastTargetPosition = nil -- Cached position for pathfinding
local maxPassDistance = 20 -- Maximum distance allowed for a bomb pass
local healthThreshold = 20 -- Health threshold for health monitor
local escapeThreshold = 15 -- Distance threshold for escape mechanism
local uiThemes = {
    ["Dark"] = { Background = Color3.new(0, 0, 0), Text = Color3.new(1, 1, 1) },
    ["Light"] = { Background = Color3.new(1, 1, 1), Text = Color3.new(0, 0, 0) },
    ["Red"] = { Background = Color3.new(1, 0, 0), Text = Color3.new(1, 1, 1) },
}

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
    return closestPlayer, shortestDistance
end

-- Function to get the closest item
local function getClosestItem()
    local closestItem = nil
    local shortestDistance = math.huge
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Tool") or item:IsA("Part") then
            local distance = (item.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestItem = item
            end
        end
    end
    return closestItem, shortestDistance
end

-- Function to get the closest health pack
local function getClosestHealthPack()
    local closestHealthPack = nil
    local shortestDistance = math.huge
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Tool") and item:FindFirstChild("HealthPack") then
            local distance = (item.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestHealthPack = item
            end
        end
    end
    return closestHealthPack, shortestDistance
end

-- Function to get the closest safe zone
local function getClosestSafeZone()
    local closestSafeZone = nil
    local shortestDistance = math.huge
    for _, zone in pairs(workspace.SafeZones:GetChildren()) do
        local distance = (zone.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            closestSafeZone = zone
        end
    end
    return closestSafeZone, shortestDistance
end

-- Anti-Slippery: Apply or reset physical properties
local function applyAntiSlippery(enabled)
    if enabled then
        spawn(function()
            while AntiSlipperyEnabled do
                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                    end
                end
                wait(0.1)
            end
        end)
    else
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
            end
        end
    end
end

-- Remove Hitbox: Destroy collision parts
local function applyRemoveHitbox(enabled)
    if not enabled then return end
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local function removeCollisionPart(character)
        for destructionIteration = 1, 100 do
            wait()
            pcall(function()
                local collisionPart = character:FindFirstChild("CollisionPart")
                if collisionPart then collisionPart:Destroy() end
            end)
        end
    end
    removeCollisionPart(character)
    LocalPlayer.CharacterAdded:Connect(removeCollisionPart)
end

-- Function to perform a random 360 spin
local function performRandomSpin(humanoidRootPart)
    local spins = {
        {angle = 10, delay = 0.1},
        {angle = 15, delay = 0.08},
        {angle = 20, delay = 0.06},
        {angle = 10, delay = 0.12},
        {angle = 15, delay = 0.1},
        {angle = 20, delay = 0.08},
    }
    local spin = spins[math.random(1, #spins)]
    for i = 1, 36 do
        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spin.angle), 0)
        wait(spin.delay)
    end
end

-- Auto Pass Bomb Logic
local function autoPassBomb()
    if not AutoPassEnabled then return end
    pcall(function()
        if LocalPlayer.Backpack:FindFirstChild("Bomb") then
            LocalPlayer.Backpack:FindFirstChild("Bomb").Parent = LocalPlayer.Character
        end

        local Bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
        if Bomb then
            local BombEvent = Bomb:FindFirstChild("RemoteEvent")
            local closestPlayer, distance = getClosestPlayer()
            if closestPlayer and closestPlayer.Character and distance <= bombPassDistance then
                local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    -- Rotate toward target
                    local direction = (targetPosition - humanoidRootPart.Position).unit
                    local lookCFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + direction)
                    humanoidRootPart.CFrame = lookCFrame

                    -- Perform random 360 spin
                    performRandomSpin(humanoidRootPart)
                end

                -- Fire the remote event to pass the bomb
                BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
            else
                -- Move to the closest player if they are out of bomb pass distance
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid and closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
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
    end)
end

-- Auto Collect Items Logic
local function autoCollectItems()
    if not AutoCollectEnabled then return end
    pcall(function()
        local closestItem, distance = getClosestItem()
        if closestItem and distance <= bombPassDistance then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:MoveTo(closestItem.Position)
                humanoid.MoveToFinished:Wait()
            end
        end
    end)
end

-- Health Monitor Logic
local function healthMonitor()
    if not HealthMonitorEnabled then return end
    pcall(function()
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health <= healthThreshold then
            local closestHealthPack, distance = getClosestHealthPack()
            if closestHealthPack then
                local path = PathfindingService:CreatePath({
                    AgentRadius = 2,
                    AgentHeight = 5,
                    AgentCanJump = true,
                    AgentJumpHeight = 10,
                    AgentMaxSlope = 45,
                })
                path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, closestHealthPack.Position)
                local waypoints = path:GetWaypoints()
                for _, waypoint in ipairs(waypoints) do
                    humanoid:MoveTo(waypoint.Position)
                    humanoid.MoveToFinished:Wait()
                end
            end
        end
    end)
end

-- Escape Mechanism Logic
local function escapeMechanism()
    if not EscapeMechanismEnabled then return end
    pcall(function()
        local closestPlayer, distance = getClosestPlayer()
        if closestPlayer and distance <= escapeThreshold then
            local closestSafeZone, _ = getClosestSafeZone()
            if closestSafeZone then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    local path = PathfindingService:CreatePath({
                        AgentRadius = 2,
                        AgentHeight = 5,
                        AgentCanJump = true,
                        AgentJumpHeight = 10,
                        AgentMaxSlope = 45,
                    })
                    path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, closestSafeZone.Position)
                    local waypoints = path:GetWaypoints()
                    for _, waypoint in ipairs(waypoints) do
                        humanoid:MoveTo(waypoint.Position)
                        humanoid.MoveToFinished:Wait()
                    end
                end
            end
        end
    end)
end

--========================--
--  APPLY FEATURES ON RESPAWN --
--========================--
LocalPlayer.CharacterAdded:Connect(function()
    if AntiSlipperyEnabled then applyAntiSlippery(true) end
    if RemoveHitboxEnabled then applyRemoveHitbox(true) end
end)

--========================--
--  ORIONLIB INTERFACE    --
--========================--

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()
local Window = OrionLib:MakeWindow({ Name = "Yon Menu - Advanced", HidePremium = false, SaveConfig = true, ConfigFolder = "YonMenu_Advanced" })

-- Automated Tab
local AutomatedTab = Window:MakeTab({
    Name = "Automated",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AutomatedTab:AddToggle({
    Name = "Anti Slippery",
    Default = AntiSlipperyEnabled,
    Callback = function(value)
        AntiSlipperyEnabled = value
        applyAntiSlippery(value)
    end
})

AutomatedTab:AddToggle({
    Name = "Remove Hitbox",
    Default = RemoveHitboxEnabled,
    Callback = function(value)
        RemoveHitboxEnabled = value
        applyRemoveHitbox(value)
    end
})

AutomatedTab:AddToggle({
    Name = "Auto Pass Bomb",
    Default = AutoPassEnabled,
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

AutomatedTab:AddToggle({
    Name = "Auto Collect Items",
    Default = AutoCollectEnabled,
    Callback = function(value)
        AutoCollectEnabled = value
        if AutoCollectEnabled then
            autoCollectConnection = RunService.Stepped:Connect(autoCollectItems)
        else
            if autoCollectConnection then
                autoCollectConnection:Disconnect()
                autoCollectConnection = nil
            end
        end
    end
})

AutomatedTab:AddToggle({
    Name = "Health Monitor",
    Default = HealthMonitorEnabled,
    Callback = function(value)
        HealthMonitorEnabled = value
        if HealthMonitorEnabled then
            healthMonitorConnection = RunService.Stepped:Connect(healthMonitor)
        else
            if healthMonitorConnection then
                healthMonitorConnection:Disconnect()
                healthMonitorConnection = nil
            end
        end
    end
})

AutomatedTab:AddToggle({
    Name = "Escape Mechanism",
    Default = EscapeMechanismEnabled,
    Callback = function(value)
        EscapeMechanismEnabled = value
        if EscapeMechanismEnabled then
            escapeMechanismConnection = RunService.Stepped:Connect(escapeMechanism)
        else
            if escapeMechanismConnection then
                escapeMechanismConnection:Disconnect()
                escapeMechanismConnection = nil
            end
        end
    end
})

AutomatedTab:AddSlider({
    Name = "Bomb Pass Distance",
    Min = 5,
    Max = 30,
    Default = bombPassDistance,
    Increment = 1,
    Callback = function(value)
        bombPassDistance = value
    end
})

AutomatedTab:AddSlider({
    Name = "Health Threshold",
    Min = 10,
    Max = 100,
    Default = healthThreshold,
    Increment = 1,
    Callback = function(value)
        healthThreshold = value
    end
})

AutomatedTab:AddSlider({
    Name = "Escape Threshold",
    Min = 5,
    Max = 50,
    Default = escapeThreshold,
    Increment = 1,
    Callback = function(value)
        escapeThreshold = value
    end
})

AutomatedTab:AddDropdown({
    Name = "Pathfinding Speed",
    Default = "16",
    Options = {"12", "16", "20"},
    Callback = function(value)
        pathfindingSpeed = tonumber(value)
    end
})

AutomatedTab:AddDropdown({
    Name = "UI Theme",
    Default = "Dark",
    Options = { "Dark", "Light", "Red" },
    Callback = function(themeName)
        local theme = uiThemes[themeName]
        if theme then
            -- Apply theme to UI elements here if needed
        else
            warn("Theme not found:", themeName)
        end
    end
})

OrionLib:Init()
print("Yon Menu Script Loaded with Adjustments")
