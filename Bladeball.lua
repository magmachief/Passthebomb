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
local SoundEffectsEnabled = true -- Toggle for sound effects
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

    -- Follow player's HumanoidRootPart
    RunService.Stepped:Connect(function()
        if character and humanoidRootPart then
            circle.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -3, 0)
        end
    end)

    return circle
end

-- Function to flash the detection circle visually
local function flashDetectionCircle()
    if detectionCircle then
        local originalColor = detectionCircle.Color
        local flashDuration = math.clamp(ballDetectionRadius / 20, 0.1, 0.5)
        local flashBrightness = math.clamp(ballDetectionRadius * 10, 255, 2550)

        detectionCircle.Transparency = 0.3
        detectionCircle.Color = Color3.fromRGB(flashBrightness % 255, 255, 0)
        task.wait(flashDuration)
        detectionCircle.Color = originalColor
        detectionCircle.Transparency = 1
    end
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
        flashDetectionCircle()
    end
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

-- Function to trigger block ability
local function triggerBlockAbility()
    flashDetectionCircle() -- Visual feedback
    if SoundEffectsEnabled then
        playSound(humanoidRootPart, "12222058") -- Replace with desired sound asset ID
    end
    print("Block ability triggered!")
end

-- Function to detect and block the ball
local function detectAndBlockBall()
    local detectionInterval = 0.1
    RunService.Heartbeat:Connect(function()
        if AutoBlockEnabled then
            local detected = false
            for _, object in ipairs(Workspace:GetDescendants()) do
                if object:IsA("BasePart") and object.Name == "Ball" then
                    local distance = (object.Position - humanoidRootPart.Position).Magnitude
                    if distance <= ballDetectionRadius then
                        detected = true
                        triggerBlockAbility()
                        break
                    end
                end
            end

            if not detected then
                detectionCircle.Transparency = 1
            end
        end
        task.wait(detectionInterval)
    end)
end

-- Function to animate buttons on hover and click
local function animateButton(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), { Size = button.Size + UDim2.new(0, 5, 0, 5) }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), { Size = button.Size - UDim2.new(0, 5, 0, 5) }):Play()
    end)
    button.MouseButton1Click:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), { Size = button.Size - UDim2.new(0, 3, 0, 3) }):Play()
        task.wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), { Size = button.Size + UDim2.new(0, 3, 0, 3) }):Play()
    end)
end

-- Function to create the toggleable menu
local function createToggleMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoBlockMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 250, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
    titleLabel.Text = "Auto Block Settings"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Sound Toggle Button
    local soundToggleButton = Instance.new("TextButton")
    soundToggleButton.Size = UDim2.new(0.8, 0, 0.15, 0)
    soundToggleButton.Position = UDim2.new(0.1, 0, 0.25, 0)
    soundToggleButton.Text = "Sound: ON"
    soundToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    soundToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    soundToggleButton.TextSize = 16
    soundToggleButton.Font = Enum.Font.SourceSans
    soundToggleButton.Parent = mainFrame

    animateButton(soundToggleButton)
    soundToggleButton.MouseButton1Click:Connect(function()
        SoundEffectsEnabled = not SoundEffectsEnabled
        soundToggleButton.Text = SoundEffectsEnabled and "Sound: ON" or "Sound: OFF"
        soundToggleButton.BackgroundColor3 = SoundEffectsEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    -- Radius Controls
    local sliderText = Instance.new("TextLabel")
    sliderText.Size = UDim2.new(1, 0, 0.15, 0)
    sliderText.Position = UDim2.new(0, 0, 0.45, 0)
    sliderText.Text = "Radius: " .. ballDetectionRadius
    sliderText.Parent = mainFrame

    -- "+" and "-" buttons
    -- Skipping redundant button code for brevity
end

-- Create Detection Circle, Menu, and Block Detection
detectionCircle = createDetectionCircle()
createToggleMenu()
detectAndBlockBall()
