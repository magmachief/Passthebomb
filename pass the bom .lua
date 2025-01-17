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
mainFrame.Size = UDim2.new(0, 300, 0, 300)  -- Increased height for mobile
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)  -- Center the frame
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.2, 0)  -- Increased the height for title
titleLabel.Text = "Super Tech Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.TextSize = 24
titleLabel.TextBold = true
titleLabel.Parent = mainFrame

-- Anti-Slippery Toggle Button
local antiSlipperyButton = Instance.new("TextButton")
antiSlipperyButton.Size = UDim2.new(0.8, 0, 0.25, 0)  -- Increased button size for easy tapping
antiSlipperyButton.Position = UDim2.new(0.1, 0, 0.25, 0)  -- Adjusted position
antiSlipperyButton.Text = "Anti-Slippery: OFF"
antiSlipperyButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
antiSlipperyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
antiSlipperyButton.TextSize = 18
antiSlipperyButton.TextButtonMode = Enum.TextButtonMode.Border
antiSlipperyButton.Parent = mainFrame

-- Remove Hitbox Toggle Button
local removeHitboxButton = Instance.new("TextButton")
removeHitboxButton.Size = UDim2.new(0.8, 0, 0.25, 0)  -- Increased button size
removeHitboxButton.Position = UDim2.new(0.1, 0, 0.6, 0)  -- Adjusted position
removeHitboxButton.Text = "Remove Hitbox: OFF"
removeHitboxButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
removeHitboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
removeHitboxButton.TextSize = 18
removeHitboxButton.TextButtonMode = Enum.TextButtonMode.Border
removeHitboxButton.Parent = mainFrame

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

print("Super Tech Menu Loaded with Anti-Slippery and No Hitbox options!")
