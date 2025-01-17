local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

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

-- Dragging functionality for the menu
local dragging = false
local dragInput, mousePos, framePos

local function startDrag(input)
    dragging = true
    mousePos = input.Position
    framePos = mainFrame.Position

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end

local function updateDrag(input)
    if dragging then
        local delta = input.Position - mousePos
        mainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startDrag(input)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

-- Button Toggle Functions
local antiSlipperyEnabled = false
local removeHitboxEnabled = false

antiSlipperyButton.MouseButton1Click:Connect(function()
    antiSlipperyEnabled = not antiSlipperyEnabled
    antiSlipperyButton.Text = "Anti-Slippery: " .. (antiSlipperyEnabled and "ON" or "OFF")
end)

removeHitboxButton.MouseButton1Click:Connect(function()
    removeHitboxEnabled = not removeHitboxEnabled
    removeHitboxButton.Text = "Remove Hitbox: " .. (removeHitboxEnabled and "ON" or "OFF")
end)

print("Super Tech Menu Loaded Successfully!")
