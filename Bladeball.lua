--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local ball = nil
local ballDetectionRadius = 50 -- Adjust this based on game mechanics
local sendBackDistance = 10 -- Distance within which to send the ball back
local AutoSendBallEnabled = false -- Initial state of the auto-send feature

-- Function to detect the ball
local function detectBall()
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Ball" then
            local distance = (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance <= ballDetectionRadius then
                ball = part
                return true
            end
        end
    end
    ball = nil
    return false
end

-- Function to get the closest player
local function getClosestPlayer()
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

-- Function to send the ball back to the closest player
local function sendBallBack()
    if ball and ball.Parent then
        local closestPlayer = getClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (closestPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance <= sendBackDistance then
                local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = TweenService:Create(ball, tweenInfo, {Position = targetPosition})
                tween:Play()
                tween.Completed:Connect(function()
                    print("Ball sent back to:", closestPlayer.Name)
                end)
            else
                print("No players within send-back distance.")
            end
        else
            print("No valid closest player found.")
        end
    end
end

-- Function to create the toggleable menu
local function createToggleMenu()
    -- Create a new ScreenGui and set ResetOnSpawn to false
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoSendBallMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 100)
    mainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Parent = screenGui

    -- Rounded corners for main frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
    titleLabel.Text = "Auto Send Ball"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.8, 0, 0.4, 0)
    toggleButton.Position = UDim2.new(0.1, 0, 0.5, 0)
    toggleButton.Text = "OFF"
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 20
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.Parent = mainFrame

    -- Rounded corners for the button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = toggleButton

    -- Button shadow effect
    local buttonShadow = Instance.new("ImageLabel")
    buttonShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    buttonShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    buttonShadow.Size = UDim2.new(1, 10, 1, 10)
    buttonShadow.Image = "rbxassetid://1316045217" -- Shadow image asset ID
    buttonShadow.ImageColor3 = Color3.new(0, 0, 0)
    buttonShadow.ImageTransparency = 0.5
    buttonShadow.BackgroundTransparency = 1
    buttonShadow.ZIndex = 0
    buttonShadow.Parent = toggleButton

    -- Toggle button functionality
    toggleButton.MouseButton1Click:Connect(function()
        AutoSendBallEnabled = not AutoSendBallEnabled
        toggleButton.Text = AutoSendBallEnabled and "ON" or "OFF"
        toggleButton.BackgroundColor3 = AutoSendBallEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

-- Automation
RunService.Stepped:Connect(function()
    if AutoSendBallEnabled then
        if detectBall() then
            sendBallBack()
        end
    end
end)

-- Create the toggle menu
createToggleMenu()

print("Blade Ball Auto Send Back Script Loaded with Toggle Menu")
