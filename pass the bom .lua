local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local bombHolder = nil

local bombPassDistance = 10 
local passToClosest = true
local AutoPassEnabled = false

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
                -- Move the bomb to the closest player
                local bomb = LocalPlayer.Character:FindFirstChild("Bomb")
                if bomb then
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

    if RemoveHitboxEnabled then
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

local function antiSlippery()
    local player = LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()

    if AntiSlipperyEnabled then
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

RunService.Heartbeat:Connect(function()
    updateBombHolder()
    if bombHolder == LocalPlayer and AutoPassEnabled then
        passBomb()
    end
    
    if AntiSlipperyEnabled then
        antiSlippery()
    end
    if RemoveHitboxEnabled then
        removeHitbox()
    end
end)

-- GUI Elements --
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SuperTechMenu"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450) -- Adjusted for mobile
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225) -- Centered
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Visible = false
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.1, 0)
corner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.15, 0) -- Title takes 15% of height
titleLabel.Text = "Super Tech Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.TextSize = 28
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Anti-Slippery Toggle Button
local antiSlipperyButton = Instance.new("TextButton")
antiSlipperyButton.Size = UDim2.new(0.8, 0, 0.15, 0) -- Adjusted for visibility
antiSlipperyButton.Position = UDim2.new(0.1, 0, 0.2, 0)
antiSlipperyButton.Text = "Anti-Slippery: OFF"
antiSlipperyButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
antiSlipperyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
antiSlipperyButton.TextSize = 20
antiSlipperyButton.Font = Enum.Font.SourceSans
antiSlipperyButton.Parent = mainFrame
local antiSlipperyCorner = Instance.new("UICorner")
antiSlipperyCorner.CornerRadius = UDim.new(0.1, 0)
antiSlipperyCorner.Parent = antiSlipperyButton

-- Remove Hitbox Toggle Button
local removeHitboxButton = Instance.new("TextButton")
removeHitboxButton.Size = UDim2.new(0.8, 0, 0.15, 0)
removeHitboxButton.Position = UDim2.new(0.1, 0, 0.4, 0)
removeHitboxButton.Text = "Remove Hitbox: OFF"
removeHitboxButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
removeHitboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
removeHitboxButton.TextSize = 20
removeHitboxButton.Font = Enum.Font.SourceSans
removeHitboxButton.Parent = mainFrame
local removeHitboxCorner = Instance.new("UICorner")
removeHitboxCorner.CornerRadius = UDim.new(0.1, 0)
removeHitboxCorner.Parent = removeHitboxButton

-- Auto Pass Bomb Toggle Button
local autoPassBombButton = Instance.new("TextButton")
autoPassBombButton.Size = UDim2.new(0.8, 0, 0.15, 0)
autoPassBombButton.Position = UDim2.new(0.1, 0, 0.6, 0)
autoPassBombButton.Text = "Auto Pass Bomb: OFF"
autoPassBombButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
autoPassBombButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoPassBombButton.TextSize = 20
autoPassBombButton.Font = Enum.Font.SourceSans
autoPassBombButton.Parent = mainFrame
local autoPassBombCorner = Instance.new("UICorner")
autoPassBombCorner.CornerRadius = UDim.new(0.1, 0)
autoPassBombCorner.Parent = autoPassBombButton

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
        local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -175, 0.5, -700)})
        tween:Play()
        tween.Completed:Connect(function()
            mainFrame.Visible = false
        end)
    else
        mainFrame.Position = UDim2.new(0.5, -175, 0.5, -700)
        mainFrame.Visible = true
        local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -175, 0.5, -225)})
        tween:Play()
    end
end)

-- Button Toggle Functions
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false

antiSlipperyButton.MouseButton1Click:Connect(function()
    AntiSlipperyEnabled = not AntiSlipperyEnabled
    antiSlipperyButton.Text = "Anti-Slippery: " .. (AntiSlipperyEnabled and "ON" or "OFF")
    antiSlippery()
end)

removeHitboxButton.MouseButton1Click:Connect(function()
    RemoveHitboxEnabled = not RemoveHitboxEnabled
    removeHitboxButton.Text = "Remove Hitbox: " .. (RemoveHitboxEnabled and "ON" or "OFF")
    removeHitbox()
end)

autoPassBombButton.MouseButton1Click:Connect(function()
    AutoPassEnabled = not AutoPassEnabled
    autoPassBombButton.Text = "Auto Pass Bomb: " .. (AutoPassEnabled and "ON" or "OFF")
end)

print("Pass The Bomb Script Loaded with Enhanced Super Tech Menu")
