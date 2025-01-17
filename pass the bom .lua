local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local bombHolder = nil

-- Settings --
local bombPassDistance = 10 -- Distance to auto-pass the bomb
local passToClosest = true -- Automatically pass the bomb to the closest player

-- Function to get the closest player who isn't holding the bomb
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player ~= bombHolder and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

-- Function to pass the bomb
local function passBomb()
    if bombHolder == LocalPlayer and passToClosest then
        local closestPlayer = getClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (closestPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance <= bombPassDistance then
                -- Simulate passing the bomb (this should be replaced with actual game logic)
                bombHolder = closestPlayer
                print("Bomb passed to:", closestPlayer.Name)
            else
                print("No players within bomb pass distance.")
            end
        else
            print("No valid closest player found.")
        end
    end
end

-- Function to remove hitbox (disable collision)
local function removeHitbox()
    local player = LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()

    if removeHitboxEnabled then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- Function to apply anti-slippery (no sliding)
local function antiSlippery()
    local player = LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()

    if antiSlipperyEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
            end
        end
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
            end
        end
    end
end

-- Detect bomb holder changes
local function updateBombHolder()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Bomb") then
            bombHolder = player
            break
        end
    end
end

-- Main loop
RunService.Heartbeat:Connect(function()
    updateBombHolder()
    if bombHolder == LocalPlayer then
        passBomb()
    end
    
    -- Apply anti-slippery and remove hitbox if enabled
    if antiSlipperyEnabled then
        antiSlippery()
    end
    if removeHitboxEnabled then
        removeHitbox()
    end
end)

-- GUI Elements --
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuperTechMenu"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400) -- Adjusted for mobile
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200) -- Centered
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Visible = false
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.2, 0) -- Title takes 20% of height
titleLabel.Text = "Super Tech Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Anti-Slippery Toggle Button
local antiSlipperyButton = Instance.new("TextButton")
antiSlipperyButton.Size = UDim2.new(0.8, 0, 0.2, 0) -- Adjusted for visibility
antiSlipperyButton.Position = UDim2.new(0.1, 0, 0.3, 0)
antiSlipperyButton.Text = "Anti-Slippery: OFF"
antiSlipperyButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
antiSlipperyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
antiSlipperyButton.TextSize = 18
antiSlipperyButton.Font = Enum.Font.SourceSans
antiSlipperyButton.Parent = mainFrame

-- Remove Hitbox Toggle Button
local removeHitboxButton = Instance.new("TextButton")
removeHitboxButton.Size = UDim2.new(0.8, 0, 0.2, 0)
removeHitboxButton.Position = UDim2.new(0.1, 0, 0.55, 0)
removeHitboxButton.Text = "Remove Hitbox: OFF"
removeHitboxButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
removeHitboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
removeHitboxButton.TextSize = 18
removeHitboxButton.Font = Enum.Font.SourceSans
removeHitboxButton.Parent = mainFrame

-- Icon Image at Top-Left
local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 50, 0, 50) -- Icon size
icon.Position = UDim2.new(0, 10, 0, 10) -- Adjusted position for visibility
icon.Image = "rbxassetid://4483345998" -- Correct asset ID
icon.BackgroundTransparency = 1 -- Transparent background
icon.Parent = screenGui

-- Toggle Button for Menu
local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.Image = "rbxassetid://4483345998"
toggleButton.BackgroundTransparency = 1
toggleButton.Parent = screenGui

-- Animations for Menu
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

toggleButton.MouseButton1Click:Connect(function()
    if mainFrame.Visible then
        local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -150, 0.5, -500)})
        tween:Play()
        tween.Completed:Connect(function()
            mainFrame.Visible = false
        end)
    else
        mainFrame.Position = UDim2.new(0.5, -150, 0.5, -500)
        mainFrame.Visible = true
        local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -150, 0.5, -200)})
        tween:Play()
    end
end)

-- Button Toggle Functions
local antiSlipperyEnabled = false
local removeHitboxEnabled = false

antiSlipperyButton.MouseButton1Click:Connect(function()
    antiSlipperyEnabled = not antiSlipperyEnabled
    antiSlipperyButton.Text = "Anti-Slippery: " .. (antiSlipperyEnabled and "ON" or "OFF")
    antiSlippery()
end)

removeHitboxButton.MouseButton1Click:Connect(function()
    removeHitboxEnabled = not removeHitboxEnabled
    removeHitboxButton.Text = "Remove Hitbox: " .. (removeHitboxEnabled and "ON" or "OFF")
    removeHitbox()
end)

print("Pass The Bomb Script Loaded with Anti-Slippery and No Hitbox")
