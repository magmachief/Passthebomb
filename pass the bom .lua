--========================--
--     INITIAL SETUP      --
--========================--

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Variables
local bombHolder = nil
local bombPassDistance = 10
local passToClosest = true
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local TargetLocked = false
local LockedTarget = nil -- Stores the currently locked target

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

-- Function to lock onto a target
local function lockTarget()
    if not TargetLocked then
        LockedTarget = getClosestPlayer()
        if LockedTarget then
            TargetLocked = true
            print("Locked onto target:", LockedTarget.Name)
        else
            print("No valid target to lock.")
        end
    else
        TargetLocked = false
        LockedTarget = nil
        print("Target unlocked.")
    end
end

-- Function to move towards the locked target or closest player
local function moveToTarget()
    local targetPlayer = TargetLocked and LockedTarget or getClosestPlayer()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
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
                            moveToTarget()
                        end
                    end)
                end
            end

            followPath()
        end
    else
        print("No valid target to move to.")
    end
end

-- Function to pass the bomb to the locked target or closest player
local function passBomb()
    local targetPlayer = TargetLocked and LockedTarget or getClosestPlayer()
    if bombHolder == LocalPlayer and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (targetPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
        if distance <= bombPassDistance then
            local bomb = LocalPlayer.Character:FindFirstChild("Bomb")
            if bomb then
                local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = TweenService:Create(bomb, tweenInfo, {Position = targetPosition})
                tween:Play()
                tween.Completed:Connect(function()
                    bomb.Parent = targetPlayer.Character
                    print("Bomb passed to:", targetPlayer.Name)
                end)
            end
        else
            print("Target is out of range. Moving closer...")
            moveToTarget()
        end
    end
end

-- Function to create the Yonkai menu
local function createYonkaiMenu()
    -- Create a new ScreenGui and set ResetOnSpawn to false
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YonkaiMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    -- Rounded corners for main frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
    titleLabel.Text = "Yonkai Menu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 28
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Function to create buttons
    local function createButton(text, position)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.8, 0, 0.1, 0)
        button.Position = position
        button.Text = text
        button.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 20
        button.Font = Enum.Font.SourceSans
        button.Parent = mainFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 10)
        buttonCorner.Parent = button

        return button
    end

    -- Create menu buttons
    local lockTargetButton = createButton("Lock Target", UDim2.new(0.1, 0, 0.2, 0))
    local moveToTargetButton = createButton("Move to Target", UDim2.new(0.1, 0, 0.4, 0))
    local passBombButton = createButton("Pass Bomb", UDim2.new(0.1, 0, 0.6, 0))

    -- Button functionalities
    lockTargetButton.MouseButton1Click:Connect(lockTarget)
    moveToTargetButton.MouseButton1Click:Connect(moveToTarget)
    passBombButton.MouseButton1Click:Connect(passBomb)

    print("Yonkai Menu with Lock Target Loaded")
end

-- Ensure the menu is created
createYonkaiMenu()

-- Recreate the menu if the player respawns
LocalPlayer.CharacterAdded:Connect(createYonkaiMenu)
