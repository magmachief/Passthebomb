--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Variables
local defaultRadius = 10
local ballDetectionRadius = LocalPlayer:GetAttribute("DetectionRadius") or defaultRadius
local AutoBlockEnabled = true
local SoundEffectsEnabled = true
local detectionCircle = nil
local resizingTween = nil

-- Function to create the detection circle
local function createDetectionCircle()
    local circle = Instance.new("Part")
    circle.Name = "DetectionCircle"
    circle.Size = Vector3.new(ballDetectionRadius * 2, 0.1, ballDetectionRadius * 2)
    circle.Shape = Enum.PartType.Cylinder
    circle.Anchored = true
    circle.CanCollide = false
    circle.Transparency = 1
    circle.Parent = character

    RunService.Stepped:Connect(function()
        if character and humanoidRootPart then
            circle.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -3, 0)
        end
    end)

    return circle
end

-- Function to resize the detection circle
local function resizeDetectionCircle(newRadius)
    ballDetectionRadius = newRadius
    if detectionCircle then
        if resizingTween then
            resizingTween:Cancel()
        end
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        resizingTween = TweenService:Create(
            detectionCircle,
            tweenInfo,
            { Size = Vector3.new(ballDetectionRadius * 2, 0.1, ballDetectionRadius * 2) }
        )
        resizingTween:Play()
    end
end

-- Function to reset settings
local function resetSettings()
    ballDetectionRadius = defaultRadius
    AutoBlockEnabled = true
    SoundEffectsEnabled = true
    resizeDetectionCircle(defaultRadius)
end

-- Function to play sound
local function playSound(parent, soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = 0.5
    sound.Parent = parent
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Function to create a toggleable menu
local function createToggleMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoBlockMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 250, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = true
    mainFrame.Parent = screenGui

    -- Corner Radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Text = "Auto Block Settings"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Sound Toggle
    local soundToggleButton = Instance.new("TextButton")
    soundToggleButton.Size = UDim2.new(0.8, 0, 0.12, 0)
    soundToggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    soundToggleButton.Text = "Sound: ON"
    soundToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    soundToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    soundToggleButton.TextSize = 16
    soundToggleButton.Font = Enum.Font.SourceSans
    soundToggleButton.Parent = mainFrame

    soundToggleButton.MouseButton1Click:Connect(function()
        SoundEffectsEnabled = not SoundEffectsEnabled
        soundToggleButton.Text = SoundEffectsEnabled and "Sound: ON" or "Sound: OFF"
        soundToggleButton.BackgroundColor3 = SoundEffectsEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    -- Radius Controls
    local radiusLabel = Instance.new("TextLabel")
    radiusLabel.Size = UDim2.new(0.8, 0, 0.12, 0)
    radiusLabel.Position = UDim2.new(0.1, 0, 0.35, 0)
    radiusLabel.Text = "Radius: " .. ballDetectionRadius
    radiusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    radiusLabel.BackgroundTransparency = 1
    radiusLabel.TextSize = 16
    radiusLabel.Font = Enum.Font.SourceSans
    radiusLabel.Parent = mainFrame

    -- "+" Button
    local plusButton = Instance.new("TextButton")
    plusButton.Size = UDim2.new(0.3, 0, 0.1, 0)
    plusButton.Position = UDim2.new(0.6, 0, 0.5, 0)
    plusButton.Text = "+"
    plusButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    plusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusButton.TextSize = 16
    plusButton.Font = Enum.Font.SourceSans
    plusButton.Parent = mainFrame

    plusButton.MouseButton1Click:Connect(function()
        if ballDetectionRadius < 30 then
            ballDetectionRadius += 1
            resizeDetectionCircle(ballDetectionRadius)
            radiusLabel.Text = "Radius: " .. ballDetectionRadius
        end
    end)

    -- "-" Button
    local minusButton = Instance.new("TextButton")
    minusButton.Size = UDim2.new(0.3, 0, 0.1, 0)
    minusButton.Position = UDim2.new(0.1, 0, 0.5, 0)
    minusButton.Text = "-"
    minusButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    minusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusButton.TextSize = 16
    minusButton.Font = Enum.Font.SourceSans
    minusButton.Parent = mainFrame

    minusButton.MouseButton1Click:Connect(function()
        if ballDetectionRadius > 5 then
            ballDetectionRadius -= 1
            resizeDetectionCircle(ballDetectionRadius)
            radiusLabel.Text = "Radius: " .. ballDetectionRadius
        end
    end)

    -- Auto Block Toggle
    local autoBlockToggleButton = Instance.new("TextButton")
    autoBlockToggleButton.Size = UDim2.new(0.8, 0, 0.12, 0)
    autoBlockToggleButton.Position = UDim2.new(0.1, 0, 0.65, 0)
    autoBlockToggleButton.Text = "Auto Block: ON"
    autoBlockToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    autoBlockToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoBlockToggleButton.TextSize = 16
    autoBlockToggleButton.Font = Enum.Font.SourceSans
    autoBlockToggleButton.Parent = mainFrame

    autoBlockToggleButton.MouseButton1Click:Connect(function()
        AutoBlockEnabled = not AutoBlockEnabled
        autoBlockToggleButton.Text = AutoBlockEnabled and "Auto Block: ON" or "Auto Block: OFF"
        autoBlockToggleButton.BackgroundColor3 = AutoBlockEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    -- Reset Button
    local resetButton = Instance.new("TextButton")
    resetButton.Size = UDim2.new(0.8, 0, 0.12, 0)
    resetButton.Position = UDim2.new(0.1, 0, 0.8, 0)
    resetButton.Text = "Reset"
    resetButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetButton.TextSize = 16
    resetButton.Font = Enum.Font.SourceSans
    resetButton.Parent = mainFrame

    resetButton.MouseButton1Click:Connect(function()
        resetSettings()
        soundToggleButton.Text = "Sound: ON"
        soundToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        autoBlockToggleButton.Text = "Auto Block: ON"
        autoBlockToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        radiusLabel.Text = "Radius: " .. defaultRadius
    end)
end

-- Create menu and circle
detectionCircle = createDetectionCircle()
createToggleMenu()
