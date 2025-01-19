--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local ballDetectionRadius = 50 -- Adjust this based on game mechanics
local sendBackDistance = 10 -- Distance within which to send the ball back
local AutoSendBallEnabled = false -- Initial state of the auto-send feature
local AutoParryEnabled = false -- Initial state of the auto-parry feature
local detectionCircle = nil

-- Function to detect the ball
local function detectBall()
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Ball" then
            local distance = (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance <= ballDetectionRadius then
                return part
            end
        end
    end
    return nil
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
local function sendBallBack(ball)
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

-- Function to create the detection circle
local function createDetectionCircle()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local circle = Instance.new("Part")
    circle.Name = "DetectionCircle"
    circle.Size = Vector3.new(ballDetectionRadius * 2, 1, ballDetectionRadius * 2)
    circle.Shape = Enum.PartType.Cylinder
    circle.Anchored = true
    circle.CanCollide = false
    circle.Transparency = 0.5
    circle.Color = Color3.fromRGB(0, 255, 0)
    circle.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -3, 0)
    circle.Parent = character

    -- Update the position of the detection circle to follow the player
    RunService.Stepped:Connect(function()
        if character and character:FindFirstChild("HumanoidRootPart") then
            circle.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, -3, 0)
        end
    end)

    return circle
end

-- Function to detect and parry the ball
local function detectAndParryBall()
    if detectionCircle then
        detectionCircle.Touched:Connect(function(hit)
            if hit:IsA("BasePart") and hit.Name == "Ball" then
                print("Ball detected within the parry area!")
                -- Implement your parry logic here
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = (hit.Position - LocalPlayer.Character.HumanoidRootPart.Position).unit * 50
                bodyVelocity.Parent = hit
                wait(0.1)
                bodyVelocity:Destroy()
            end
        end)
    end
end

-- Function to create the toggleable menu
local function createToggleMenu()
    -- Create a new ScreenGui and set ResetOnSpawn to false
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoFeaturesMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 150)
    mainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
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
    titleLabel.Size = UDim2.new(1, 0, 0.2, 0)
    titleLabel.Text = "Auto Features"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Create a function to create toggle buttons
    local function createToggleButton(text, position, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.8, 0, 0.2, 0)
        button.Position = position
        button.Text = text .. ": OFF"
        button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 20
        button.Font = Enum.Font.SourceSans
        button.Parent = mainFrame

        -- Rounded corners for the button
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 10)
        buttonCorner.Parent = button

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
        buttonShadow.Parent = button

        -- Toggle button functionality
        button.MouseButton1Click:Connect(function()
            local enabled = callback()
            button.Text = text .. ": " .. (enabled and "ON" or "OFF")
            button.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        end)
        
        return button
    end

    -- Create toggle buttons
    createToggleButton("Auto Send Ball", UDim2.new(0.1, 0, 0.3, 0), function()
        AutoSendBallEnabled = not AutoSendBallEnabled
        return AutoSendBallEnabled
    end)

    createToggleButton("Auto Parry", UDim2.new(0.1, 0, 0.6, 0), function()
        AutoParryEnabled = not AutoParryEnabled
        return AutoParryEnabled
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
            local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -100, 0.5, -75)})
            tween:Play()
        end
    end)
end

-- Create the detection circle
detectionCircle = createDetectionCircle()

-- Create the toggle menu
createToggleMenu()

-- Automation to enable/disable the detection
RunService.Stepped:Connect(function()
    if AutoSendBallEnabled then
        local ball = detectBall()
        if ball then
            sendBallBack(ball)
        end
    end

    if AutoParryEnabled then
        detectionCircle.Transparency = 0.5
        detectAndParryBall()
    else
        detectionCircle.Transparency = 1
    end
end)

print("Blade Ball Auto Features Script Loaded with Toggle Menu and Icon")
