--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

--// Settings
local Settings = {
    BombPassDistance = 10, -- Maximum distance to pass the bomb
    BombPassCooldown = 2,  -- Cooldown for passing the bomb (seconds)
    AgentRadius = 2,       -- Pathfinding agent radius
    AgentHeight = 5,       -- Pathfinding agent height
    AgentCanJump = true,   -- Whether the agent can jump
    AgentJumpHeight = 10,  -- Jump height of the agent
    AgentMaxSlope = 45     -- Max slope for pathfinding
}

--// Variables
local bombHolder = nil
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local passCooldown = false
local leaderboardGui = nil
local passCount = 0

--// Utility Functions
local function debounce(func, delay)
    local isDebounced = false
    return function(...)
        if not isDebounced then
            isDebounced = true
            func(...)
            task.delay(delay, function()
                isDebounced = false
            end)
        end
    end
end

local function createLeaderboard()
    leaderboardGui = Instance.new("ScreenGui")
    leaderboardGui.Name = "BombLeaderboard"
    leaderboardGui.ResetOnSpawn = false
    leaderboardGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.25, 0, 0.15, 0)
    frame.Position = UDim2.new(0.75, -10, 0, 10)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.Parent = leaderboardGui

    local title = Instance.new("TextLabel")
    title.Text = "Bomb Leaderboard"
    title.Size = UDim2.new(1, 0, 0.3, 0)
    title.BackgroundTransparency = 1
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = frame

    local bombHolderLabel = Instance.new("TextLabel")
    bombHolderLabel.Name = "BombHolderLabel"
    bombHolderLabel.Text = "Holder: None"
    bombHolderLabel.Size = UDim2.new(1, 0, 0.35, 0)
    bombHolderLabel.Position = UDim2.new(0, 0, 0.3, 0)
    bombHolderLabel.BackgroundTransparency = 1
    bombHolderLabel.TextScaled = true
    bombHolderLabel.Font = Enum.Font.SourceSans
    bombHolderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    bombHolderLabel.Parent = frame

    local passCountLabel = Instance.new("TextLabel")
    passCountLabel.Name = "PassCountLabel"
    passCountLabel.Text = "Passes: 0"
    passCountLabel.Size = UDim2.new(1, 0, 0.35, 0)
    passCountLabel.Position = UDim2.new(0, 0, 0.65, 0)
    passCountLabel.BackgroundTransparency = 1
    passCountLabel.TextScaled = true
    passCountLabel.Font = Enum.Font.SourceSans
    passCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    passCountLabel.Parent = frame
end

local function updateLeaderboard()
    if leaderboardGui then
        local bombHolderLabel = leaderboardGui:FindFirstChild("BombHolderLabel", true)
        local passCountLabel = leaderboardGui:FindFirstChild("PassCountLabel", true)

        if bombHolderLabel then
            bombHolderLabel.Text = "Holder: " .. (bombHolder and bombHolder.Name or "None")
        end
        if passCountLabel then
            passCountLabel.Text = "Passes: " .. passCount
        end
    end
end

local function createBombEffect(bomb, effectType)
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Parent = bomb
    particleEmitter.Texture = "rbxassetid://1189127972" -- Sample texture
    particleEmitter.Speed = NumberRange.new(5, 10)
    particleEmitter.Lifetime = NumberRange.new(0.5, 1)

    if effectType == "explode" then
        particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    else
        particleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
    end

    particleEmitter:Emit(20)
    task.delay(1, function()
        particleEmitter:Destroy()
    end)
end

local function getClosestPlayer()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("LocalPlayer's character or HumanoidRootPart not available.")
        return nil
    end

    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

local function passBomb()
    if passCooldown then return end
    passCooldown = true
    task.delay(Settings.BombPassCooldown, function()
        passCooldown = false
    end)

    if bombHolder == LocalPlayer then
        local closestPlayer = getClosestPlayer()
        if closestPlayer then
            local bomb = LocalPlayer.Character:FindFirstChild("Bomb")
            if bomb then
                createBombEffect(bomb, "pass")
                bomb.Parent = closestPlayer.Character
                bombHolder = closestPlayer
                passCount += 1
                updateLeaderboard()
                print("Bomb passed to:", closestPlayer.Name)
            end
        else
            print("No valid players within range to pass the bomb.")
        end
    end
end

local function moveToClosestPlayer()
    local closestPlayer = getClosestPlayer()
    if closestPlayer then
        local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            local path = PathfindingService:CreatePath({
                AgentRadius = Settings.AgentRadius,
                AgentHeight = Settings.AgentHeight,
                AgentCanJump = Settings.AgentCanJump,
                AgentJumpHeight = Settings.AgentJumpHeight,
                AgentMaxSlope = Settings.AgentMaxSlope
            })

            path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, targetPosition)
            local waypoints = path:GetWaypoints()

            for _, waypoint in ipairs(waypoints) do
                humanoid:MoveTo(waypoint.Position)
                humanoid.MoveToFinished:Wait()
            end
        end
    else
        print("No valid players found to move to.")
    end
end

--// Create Menu (Original Script Preserved)
local function createYonkaiMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YonkaiMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame

    local toggleButton = Instance.new("ImageButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(0, 20, 0, 20)
    toggleButton.Image = "rbxassetid://6031075938"
    toggleButton.BackgroundTransparency = 1
    toggleButton.Parent = screenGui

    toggleButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    print("Yonkai Menu Initialized")
end

--// Initialize
createYonkaiMenu()
createLeaderboard()
print("Pass the Bomb script fully loaded with all features.")
