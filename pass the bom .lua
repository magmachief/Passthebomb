local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local bombHolder = nil

-- Settings --
local bombPassDistance = 10
local passToClosest = true

local antiSlipperyEnabled = false
local removeHitboxEnabled = false

-- GUI Elements --
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)  -- Increased height for mobile and buttons
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)  -- Adjusted for better positioning
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)  -- Height for title
titleLabel.Text = "Super Tech Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.TextSize = 24
titleLabel.TextBold = true
titleLabel.Parent = mainFrame

-- Anti-Slippery Toggle Button
local antiSlipperyButton = Instance.new("TextButton")
antiSlipperyButton.Size = UDim2.new(0.8, 0, 0.25, 0)  -- Adjusted for mobile
antiSlipperyButton.Position = UDim2.new(0.1, 0, 0.25, 0)  -- Adjusted for visibility
antiSlipperyButton.Text = "Anti-Slippery: OFF"
antiSlipperyButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
antiSlipperyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
antiSlipperyButton.TextSize = 18
antiSlipperyButton.TextButtonMode = Enum.TextButtonMode.Border
antiSlipperyButton.Parent = mainFrame

-- Remove Hitbox Toggle Button
local removeHitboxButton = Instance.new("TextButton")
removeHitboxButton.Size = UDim2.new(0.8, 0, 0.25, 0)
removeHitboxButton.Position = UDim2.new(0.1, 0, 0.6, 0)  -- Adjusted for mobile
removeHitboxButton.Text = "Remove Hitbox: OFF"
removeHitboxButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
removeHitboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
removeHitboxButton.TextSize = 18
removeHitboxButton.TextButtonMode = Enum.TextButtonMode.Border
removeHitboxButton.Parent = mainFrame

-- Icon Image at top-left
local icon = Instance.new("ImageLabel")
icon.Size = UDim2.new(0, 50, 0, 50)  -- Icon size
icon.Position = UDim2.new(0, 10, 0, 60)  -- Position slightly lower to avoid clashing with system icons
icon.Image = "rbxassetid://4483345998"  -- Replace with your actual image asset ID (upload your image to Roblox)
icon.BackgroundTransparency = 1  -- Make the background transparent
icon.Parent = screenGui

-- Variables for dragging functionality
local dragging = false
local dragInput, mousePos, framePos

-- Function to start dragging
local function startDrag(input)
    dragging = true
    dragInput = input
    mousePos = input.Position
    framePos = mainFrame.Position
end

-- Function to drag the menu
local function updateDrag(input)
    if dragging then
        local delta = input.Position - mousePos
        mainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end

-- Function to stop dragging
local function stopDrag()
    dragging = false
end

-- Connect drag events to the menu
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        startDrag(input)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        stopDrag()
    end
end)

-- Function to toggle Anti-Slippery
local function toggleAntiSlippery()
    antiSlipperyEnabled = not antiSlipperyEnabled
    if antiSlipperyEnabled then
        antiSlipperyButton.Text = "Anti-Slippery: ON"
    else
        antiSlipperyButton.Text = "Anti-Slippery: OFF"
    end
end

-- Function to toggle Remove Hitbox
local function toggleRemoveHitbox()
    removeHitboxEnabled = not removeHitboxEnabled
    if removeHitboxEnabled then
        removeHitboxButton.Text = "Remove Hitbox: ON"
    else
        removeHitboxButton.Text = "Remove Hitbox: OFF"
    end
end

-- Connect button clicks to toggle functions
antiSlipperyButton.MouseButton1Click:Connect(toggleAntiSlippery)
removeHitboxButton.MouseButton1Click:Connect(toggleRemoveHitbox)

-- Function to apply Anti-Slippery
local function antiSlippery()
    if antiSlipperyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        humanoid.UseJumpPower = false
        humanoid.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)  -- Zero friction for no slipping
    end
end

-- Function to remove hitbox (disable collision)
local function removeHitbox()
    if removeHitboxEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- Main loop to update settings
RunService.Heartbeat:Connect(function()
    if bombHolder == LocalPlayer then
        passBomb()
    end

    -- Apply Anti-Slippery and Remove Hitbox based on toggles
    antiSlippery()
    removeHitbox()
end)

print("Super Tech Menu Loaded with Anti-Slippery and No Hitbox options, with Draggable Interface!")
