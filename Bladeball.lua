--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local ballDetectionRadius = 10 -- Radius for the detection area
local AutoBlockEnabled = true -- Initial state of the auto-block feature
local detectionCircle = nil

-- Function to create the detection circle
local function createDetectionCircle()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local circle = Instance.new("Part")
    circle.Name = "DetectionCircle"
    circle.Size = Vector3.new(ballDetectionRadius * 2, ballDetectionRadius * 2, ballDetectionRadius * 2)
    circle.Shape = Enum.PartType.Ball
    circle.Anchored = true
    circle.CanCollide = false
    circle.Transparency = 0.5
    circle.Color = Color3.fromRGB(0, 255, 0)
    circle.CFrame = character.HumanoidRootPart.CFrame
    circle.Parent = character

    -- Update the position of the detection circle to follow the player
    RunService.Stepped:Connect(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            circle.CFrame = character.HumanoidRootPart.CFrame
        end
    end)

    return circle
end

-- Function to trigger block ability
local function triggerBlockAbility()
    -- Simulate pressing the block key (e.g., "E")
    UserInputService.InputBegan:Fire({KeyCode = Enum.KeyCode.E})
    print("Block ability activated!")
end

-- Function to detect the ball and trigger block ability
local function detectAndBlockBall()
    if detectionCircle then
        detectionCircle.Touched:Connect(function(hit)
            if hit:IsA("BasePart") and hit.Name == "Ball" then
                print("Ball detected within the block area!")
                triggerBlockAbility()
            end
        end)
    end
end

-- Function to create the toggleable menu
local function createToggleMenu()
    -- Create a new ScreenGui and set ResetOnSpawn to false
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoBlockMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 100)
    mainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
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
    titleLabel.Size = UDim2.new(1, 0, 0.3, 0)
    titleLabel.Text = "Auto Block"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.8, 0, 0.4, 0)
    toggleButton.Position = UDim2.new(0.1, 0, 0.5, 0)
    toggleButton.Text = "ON"
    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
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
        AutoBlockEnabled = not AutoBlockEnabled
        toggleButton.Text = AutoBlockEnabled and "ON" or "OFF"
        toggleButton.BackgroundColor3 = AutoBlockEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)

    -- Toggle icon to show/hide the main menu
    local toggleIcon = Instance.new("ImageButton")
    toggleIcon.Size = UDim2.new(0, 50, 0, 50)
    toggleIcon.Position = UDim2.new(0, 20, 0, 20)
    toggleIcon.Image = "rbxassetid://6031075938" -- Gojo icon asset ID
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Parent = screenGui

    -- Adding UI elements to enhance the toggle icon appearance
    local toggleIconCorner = Instance.new("UICorner")
    toggleIconCorner.CornerRadius = UDim.new(0, 10)
    toggleIconCorner.Parent = toggleIcon

    local toggleIconStroke = Instance.new("UIStroke")
    toggleIconStroke.Thickness = 2
    toggleIconStroke.Color = Color3.fromRGB(255, 255, 255)
    toggleIconStroke.Parent = toggleIcon

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- Toggle icon functionality to show/hide the main menu
    toggleIcon.MouseButton1Click:Connect(function()
        if mainFrame.Visible then
            local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -100, 0.5, -200)})
            tween:Play()
            tween.Completed:Connect(function()
                mainFrame.Visible = false
            end)
        else
            mainFrame.Position = UDim2.new(0.5, -100, 0.5, -200)
            mainFrame.Visible = true
            local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -100, 0.5, -50)})
            tween:Play()
        end
    end)
end

-- Create the detection circle
detectionCircle = createDetectionCircle()

-- Detect and block the ball
detectAndBlockBall()

-- Create the toggle menu
createToggleMenu()

-- Automation to enable/disable the detection
RunService.Stepped:Connect(function()
    if AutoBlockEnabled then
        detectionCircle.Transparency = 0.5
    else
        detectionCircle.Transparency = 1
    end
end)

print("Blade Ball Auto Block Script Loaded with Toggle Menu and Icon")
