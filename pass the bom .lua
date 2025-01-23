--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

--// Variables
local bombPassDistance = 10
local passToClosest = true
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local autoPassConnection = nil

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

-- Function to pass the bomb to the closest player
local function passBomb()
    if not AutoPassEnabled then return end

    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (closestPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
        if distance <= bombPassDistance then
            local bomb = LocalPlayer.Character:FindFirstChild("Bomb")
            if bomb then
                -- Tween the bomb visually to the target player
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
            print("No players within bomb pass distance. Attempting to move closer.")
            moveToClosestPlayer()
        end
    else
        print("No valid closest player found.")
    end
end

--========================--
--  UI CREATION FUNCTIONS --
--========================--

local function createYonkaiMenu()
    -- Create a ScreenGui for Mobile
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YonkaiMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main frame
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

    -- Drop shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 50, 1, 50)
    shadow.Image = "rbxassetid://1316045217" -- Shadow image asset ID
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = 0
    shadow.Parent = mainFrame

    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
    titleLabel.Text = "Yonkai Menu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 28
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Gradient effect for title
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
    })
    titleGradient.Parent = titleLabel

    -- Adding buttons to the main frame
    local function createButton(text, position)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.8, 0, 0.15, 0)
        button.Position = position
        button.Text = text .. ": OFF"
        button.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 20
        button.Font = Enum.Font.SourceSans
        button.Parent = mainFrame

        -- Rounded corners
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 10)
        buttonCorner.Parent = button

        return button
    end

    local antiSlipperyButton = createButton("Anti-Slippery", UDim2.new(0.1, 0, 0.2, 0))
    local removeHitboxButton = createButton("Remove Hitbox", UDim2.new(0.1, 0, 0.4, 0))
    local autoPassBombButton = createButton("Auto Pass Bomb", UDim2.new(0.1, 0, 0.6, 0))

    -- Toggle button to show/hide menu
    local toggleButton = Instance.new("ImageButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(0, 20, 0, 20)
    toggleButton.Image = "rbxassetid://6031075938" -- Icon asset ID
    toggleButton.BackgroundTransparency = 1
    toggleButton.Parent = screenGui

    toggleButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    -- Button functionalities
    antiSlipperyButton.MouseButton1Click:Connect(function()
        AntiSlipperyEnabled = not AntiSlipperyEnabled
        antiSlipperyButton.Text = "Anti-Slippery: " .. (AntiSlipperyEnabled and "ON" or "OFF")
    end)

    removeHitboxButton.MouseButton1Click:Connect(function()
        RemoveHitboxEnabled = not RemoveHitboxEnabled
        removeHitboxButton.Text = "Remove Hitbox: " .. (RemoveHitboxEnabled and "ON" or "OFF")
    end)

    autoPassBombButton.MouseButton1Click:Connect(function()
        AutoPassEnabled = not AutoPassEnabled
        autoPassBombButton.Text = "Auto Pass Bomb: " .. (AutoPassEnabled and "ON" or "OFF")
        if AutoPassEnabled then
            autoPassConnection = RunService.Stepped:Connect(passBomb)
        else
            if autoPassConnection then
                autoPassConnection:Disconnect()
                autoPassConnection = nil
            end
        end
    end)
end

-- Initialize the menu
createYonkaiMenu()

print("Yonkai Menu Script Loaded with Auto Pass Bomb and Enhanced Features")
