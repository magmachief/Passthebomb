--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Variables
local defaultRadius = 10
local ballDetectionRadius = defaultRadius
local AutoBlockEnabled = false
local SpamClickEnabled = false
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

-- Advanced Auto-Block Function
local function advancedAutoBlock()
    while AutoBlockEnabled and task.wait() do
        for _, ball in pairs(Workspace:WaitForChild("Balls", 30):GetChildren()) do
            if ball:IsA("BasePart") and humanoidRootPart then
                -- Face the ball and press the block key
                humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position, ball.Position)
                Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, ball.Position)
                if character:FindFirstChild("Highlight") then
                    humanoidRootPart.CFrame = CFrame.new(ball.Position)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                end
            end
        end
    end
end

-- Spam Click Detection Function
local function detectSpam()
    local ballsFolder = Workspace:WaitForChild("Balls", 30)
    local oldBall = nil
    while SpamClickEnabled do
        task.wait()
        local ball = ballsFolder:FindFirstChildOfClass("Part")
        if ball and oldBall ~= ball then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            oldBall = ball
        end
    end
end

-- Function to create a toggleable menu
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
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
    titleLabel.Text = "Auto Block Settings"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- AutoBlock Toggle
    local autoBlockButton = Instance.new("TextButton")
    autoBlockButton.Size = UDim2.new(0.8, 0, 0.12, 0)
    autoBlockButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    autoBlockButton.Text = "Auto Block: OFF"
    autoBlockButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    autoBlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoBlockButton.Font = Enum.Font.SourceSans
    autoBlockButton.TextSize = 16
    autoBlockButton.Parent = mainFrame

    autoBlockButton.MouseButton1Click:Connect(function()
        AutoBlockEnabled = not AutoBlockEnabled
        autoBlockButton.Text = AutoBlockEnabled and "Auto Block: ON" or "Auto Block: OFF"
        autoBlockButton.BackgroundColor3 = AutoBlockEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        if AutoBlockEnabled then
            task.spawn(advancedAutoBlock)
        end
    end)

    -- Spam Click Toggle
    local spamClickButton = Instance.new("TextButton")
    spamClickButton.Size = UDim2.new(0.8, 0, 0.12, 0)
    spamClickButton.Position = UDim2.new(0.1, 0, 0.35, 0)
    spamClickButton.Text = "Spam Click: OFF"
    spamClickButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    spamClickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spamClickButton.Font = Enum.Font.SourceSans
    spamClickButton.TextSize = 16
    spamClickButton.Parent = mainFrame

    spamClickButton.MouseButton1Click:Connect(function()
        SpamClickEnabled = not SpamClickEnabled
        spamClickButton.Text = SpamClickEnabled and "Spam Click: ON" or "Spam Click: OFF"
        spamClickButton.BackgroundColor3 = SpamClickEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        if SpamClickEnabled then
            task.spawn(detectSpam)
        end
    end)

    -- Radius Controls
    local sliderText = Instance.new("TextLabel")
    sliderText.Size = UDim2.new(1, 0, 0.15, 0)
    sliderText.Position = UDim2.new(0, 0, 0.5, 0)
    sliderText.BackgroundTransparency = 1
    sliderText.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderText.TextSize = 16
    sliderText.Font = Enum.Font.SourceSans
    sliderText.Text = "Radius: " .. ballDetectionRadius
    sliderText.Parent = mainFrame

    local plusButton = Instance.new("TextButton")
    plusButton.Size = UDim2.new(0.4, 0, 0.12, 0)
    plusButton.Position = UDim2.new(0.55, 0, 0.65, 0)
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
        end
    end)

    local minusButton = Instance.new("TextButton")
    minusButton.Size = UDim2.new(0.4, 0, 0.12, 0)
    minusButton.Position = UDim2.new(0.05, 0, 0.65, 0)
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
        end
    end)

    -- Reset Button
    local resetButton = Instance.new("TextButton")
    resetButton.Size = UDim2.new(0.8, 0, 0.12, 0)
    resetButton.Position = UDim2.new(0.1, 0, 0.8, 0)
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
    end)

    -- Toggle Icon
    local toggleIcon = Instance.new("ImageButton")
    toggleIcon.Size = UDim2.new(0, 50, 0, 50)
    toggleIcon.Position = UDim2.new(0, 20, 0, 20)
    toggleIcon.Image = "rbxassetid://6031075938" -- Use an appropriate icon asset ID
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Parent = screenGui

    toggleIcon.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
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

-- Initialize
detectionCircle = createDetectionCircle()
createToggleMenu()

print("Blade Ball Auto Block Script Loaded!")
