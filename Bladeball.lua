--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Variables
local defaultRadius = 10
local ballDetectionRadius = LocalPlayer:GetAttribute("DetectionRadius") or defaultRadius
local AutoBlockEnabled = true
local SoundEffectsEnabled = true -- Toggle for sound effects
local detectionCircle = nil
local resizingTween = nil

-- Function to create the detection circle
local function createDetectionCircle()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local circle = Instance.new("Part")
    circle.Name = "DetectionCircle"
    circle.Size = Vector3.new(ballDetectionRadius * 2, 0.1, ballDetectionRadius * 2)
    circle.Shape = Enum.PartType.Ball
    circle.Anchored = true
    circle.CanCollide = false
    circle.Transparency = 1 -- Invisible for gameplay
    circle.Parent = character

    -- Follow player's HumanoidRootPart
    RunService.Stepped:Connect(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            circle.CFrame = character.HumanoidRootPart.CFrame
        end
    end)

    return circle
end

-- Function to flash the detection circle visually
local function flashDetectionCircle()
    if detectionCircle then
        local originalColor = detectionCircle.Color
        local flashDuration = math.clamp(ballDetectionRadius / 20, 0.1, 0.5) -- Scale duration with radius
        local flashBrightness = math.clamp(ballDetectionRadius * 10, 255, 2550) -- Scale brightness

        detectionCircle.Transparency = 0.3 -- Make the circle visible
        detectionCircle.Color = Color3.fromRGB(flashBrightness % 255, 255, 0) -- Bright yellow flash
        wait(flashDuration)
        detectionCircle.Color = originalColor
        detectionCircle.Transparency = 1 -- Reset to invisible
    end
end

-- Function to resize the detection circle with animation and flash
local function resizeDetectionCircle(newRadius)
    ballDetectionRadius = newRadius
    if detectionCircle then
        if resizingTween then
            resizingTween:Cancel() -- Cancel any ongoing tween
        end
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        resizingTween = TweenService:Create(
            detectionCircle,
            tweenInfo,
            { Size = Vector3.new(ballDetectionRadius * 2, 0.1, ballDetectionRadius * 2) }
        )
        resizingTween:Play()
        flashDetectionCircle() -- Trigger visual feedback
    end
end

-- Function to play button click sounds if enabled
local function playClickSound(parent, soundId)
    if SoundEffectsEnabled then
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. soundId
        sound.Volume = 0.5
        sound.Parent = parent
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end
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
        wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), { Size = button.Size + UDim2.new(0, 3, 0, 3) }):Play()
    end)
end

-- Function to create the toggleable menu with slider, buttons, and sound toggle
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
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame

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
    soundToggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
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
    sliderText.Position = UDim2.new(0, 0, 0.4, 0)
    sliderText.BackgroundTransparency = 1
    sliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderText.TextSize = 16
    sliderText.Font = Enum.Font.SourceSans
    sliderText.Text = "Radius: " .. ballDetectionRadius
    sliderText.Parent = mainFrame

    -- "+" Button
    local plusButton = Instance.new("TextButton")
    plusButton.Size = UDim2.new(0.4, 0, 0.15, 0)
    plusButton.Position = UDim2.new(0.55, 0, 0.6, 0)
    plusButton.Text = "+"
    plusButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    plusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusButton.TextSize = 16
    plusButton.Font = Enum.Font.SourceSans
    plusButton.Parent = mainFrame
    animateButton(plusButton)

    plusButton.MouseButton1Click:Connect(function()
        if ballDetectionRadius < 30 then
            resizeDetectionCircle(ballDetectionRadius + 1)
            sliderText.Text = "Radius: " .. ballDetectionRadius
            LocalPlayer:SetAttribute("DetectionRadius", ballDetectionRadius)
            playClickSound(plusButton, "132771265") -- "+" button sound
        end
    end)

    -- "-" Button
    local minusButton = Instance.new("TextButton")
    minusButton.Size = UDim2.new(0.4, 0, 0.15, 0)
    minusButton.Position = UDim2.new(0.05, 0, 0.6, 0)
    minusButton.Text = "-"
    minusButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    minusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusButton.TextSize = 16
    minusButton.Font = Enum.Font.SourceSans
    minusButton.Parent = mainFrame
    animateButton(minusButton)

    minusButton.MouseButton1Click:Connect(function()
        if ballDetectionRadius > 5 then
            resizeDetectionCircle(ballDetectionRadius - 1)
            sliderText.Text = "Radius: " .. ballDetectionRadius
            LocalPlayer:SetAttribute("DetectionRadius", ballDetectionRadius)
            playClickSound(minusButton, "12222058") -- "-" button sound
        end
    end)

    -- Reset Button
    local resetButton = Instance.new("TextButton")
    resetButton.Size = UDim2.new(0.9, 0, 0.15, 0)
    resetButton.Position = UDim2.new(0.05, 0, 0.8, 0)
    resetButton.Text = "Reset"
    resetButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetButton.TextSize = 16
    resetButton.Font = Enum.Font.SourceSans
    resetButton.Parent = mainFrame
    animateButton(resetButton)

    resetButton.MouseButton1Click:Connect(function()
        resizeDetectionCircle(defaultRadius)
        sliderText.Text = "Radius: " .. defaultRadius
        LocalPlayer:SetAttribute("DetectionRadius", defaultRadius)
        playClickSound(resetButton, "1372256") -- Reset button sound
    end)

    -- Toggle Icon
    local toggleIcon = Instance.new("ImageButton")
    toggleIcon.Size = UDim2.new(0, 50, 0, 50)
    toggleIcon.Position = UDim2.new(0, 20, 0, 20)
    toggleIcon.Image = "rbxassetid://6031075938"
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Parent = screenGui

    toggleIcon.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
end

-- Create the detection circle
detectionCircle = createDetectionCircle()

-- Detect and block the ball
detectAndBlockBall()

-- Create the toggle menu with slider, sound toggle, and buttons
createToggleMenu()

-- Handle detection circle visibility
RunService.Stepped:Connect(function()
    if AutoBlockEnabled then
        detectionCircle.Transparency = 1 -- Invisible for gameplay
    else
        detectionCircle.Transparency = 1
    end
end)

print("Blade Ball Auto Block Script Loaded!")
