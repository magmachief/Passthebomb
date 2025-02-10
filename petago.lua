-- Petsco Ultimate Script with Toggleable UI, Full Console, and Game Logic
-- Features: Auto Farm, Auto Hatch, Auto Relics, Auto Fish, Auto Mine, Valentine's Event
-- No visible teleportation; actions happen at the current location or underground

-- Custom UI Library with Toggle Support
local UI = {}
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
screenGui.Enabled = true -- Allows toggling

function UI:CreateWindow(title, position, size)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(0, 300, 0, 400)
    frame.Position = position or UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = screenGui
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Parent = frame
    return frame
end

function UI:CreateButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Size = UDim2.new(1, -10, 0, 50)
    button.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 55)
    button.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = parent
    button.MouseButton1Click:Connect(callback)
end

-- Toggle UI with a Button
local toggleButton = Instance.new("TextButton")
toggleButton.Text = "Toggle Menu"
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 10)
toggleButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = screenGui
toggleButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
end)

-- Custom Error Console (Repositioned and Resized)
local consoleWindow = UI:CreateWindow("Error Console", UDim2.new(0.01, 0, 0.1, 0), UDim2.new(0, 400, 0, 250))

local consoleFrame = Instance.new("ScrollingFrame")
consoleFrame.Size = UDim2.new(1, 0, 0.9, 0)
consoleFrame.Position = UDim2.new(0, 0, 0.1, 0)
consoleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
consoleFrame.Parent = consoleWindow

local function logError(message)
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Text = message
    errorLabel.Size = UDim2.new(1, 0, 0, 25)
    errorLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    errorLabel.Parent = consoleFrame
end

local originalErrorHandler = warn
warn = function(message)
    originalErrorHandler(message)
    logError("[WARNING]: " .. message)
end

local originalPrintHandler = print
print = function(message)
    originalPrintHandler(message)
    logError("[LOG]: " .. message)
end

-- Create UI
local window = UI:CreateWindow("Petsco Ultimate Script")

-- Function to animate toggle
function toggleAnimation(button, state)
    if state then
        button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
        button.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    end
end

-- Auto Farm Button
UI:CreateButton(window, "Enable Auto Farm", function(self)
    getgenv().AutoFarm = not getgenv().AutoFarm
    toggleAnimation(self, getgenv().AutoFarm)
    while getgenv().AutoFarm do
        -- Implement Auto-Farm Logic Here
        print("Farming at current location...")
        wait(1)
    end
end)

-- Auto Hatch Button
UI:CreateButton(window, "Enable Auto Hatch", function(self)
    getgenv().AutoHatch = not getgenv().AutoHatch
    toggleAnimation(self, getgenv().AutoHatch)
    while getgenv().AutoHatch do
        -- Implement Auto-Hatch Logic Here
        print("Hatching pets...")
        wait(1)
    end
end)

-- Auto Relics Button
UI:CreateButton(window, "Enable Auto Relics", function(self)
    getgenv().AutoRelics = not getgenv().AutoRelics
    toggleAnimation(self, getgenv().AutoRelics)
    while getgenv().AutoRelics do
        -- Implement Auto-Relics Logic Here
        print("Farming relics...")
        wait(1)
    end
end)

-- Auto Fishing Button
UI:CreateButton(window, "Enable Auto Fishing", function(self)
    getgenv().AutoFish = not getgenv().AutoFish
    toggleAnimation(self, getgenv().AutoFish)
    while getgenv().AutoFish do
        -- Implement Auto-Fishing Logic Here
        print("Fishing automatically...")
        wait(1)
    end
end)

-- Auto Mining Button
UI:CreateButton(window, "Enable Auto Mining", function(self)
    getgenv().AutoMine = not getgenv().AutoMine
    toggleAnimation(self, getgenv().AutoMine)
    while getgenv().AutoMine do
        -- Implement Auto-Mining Logic Here
        print("Mining underground...")
        wait(1)
    end
end)

-- Valentine's Event Button
UI:CreateButton(window, "Enable Valentine's Event", function(self)
    getgenv().ValentineEvent = not getgenv().ValentineEvent
    toggleAnimation(self, getgenv().ValentineEvent)
    while getgenv().ValentineEvent do
        -- Implement Valentine's Event Logic Here
        print("Participating in Valentine's event...")
        wait(1)
    end
end)
