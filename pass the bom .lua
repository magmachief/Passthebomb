-- Custom UI Library for Roblox
-- Optimized, clean, and modern UI framework

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- UI Container
local UI = Instance.new("ScreenGui")
UI.Name = "CustomUI"
UI.Parent = game.CoreGui

-- UI Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false -- Ensure it starts hidden
MainFrame.Parent = UI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "Custom UI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    DragToggle.Visible = true
end)

-- Sidebar for Navigation
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -120, 1, -40)
TabContainer.Position = UDim2.new(0, 120, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabContainer.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 10)
TabCorner.Parent = TabContainer

-- Function to create tabs
local function CreateTab(name, callback)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Parent = Sidebar

    TabButton.MouseButton1Click:Connect(callback)
end

-- Example tabs
CreateTab("Home", function()
    print("Home tab clicked")
end)

CreateTab("Settings", function()
    print("Settings tab clicked")
end)

-- Function to rotate character towards target
local function rotateCharacterTowardsTarget(targetPosition)
    local character = LocalPlayer.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local direction = (targetPosition - humanoidRootPart.Position).unit
    local newCFrame = CFrame.fromMatrix(humanoidRootPart.Position, direction, Vector3.new(0, 1, 0))

    local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = newCFrame})
    tween:Play()
end

-- Feature Toggles
local function CreateToggle(name, callback)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 120, 0, 40)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    ToggleButton.Text = name
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = TabContainer

    ToggleButton.MouseButton1Click:Connect(function()
        local active = ToggleButton.BackgroundColor3 == Color3.fromRGB(50, 200, 50)
        ToggleButton.BackgroundColor3 = active and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 200, 50)
        callback(not active)
    end)
end

-- Implement Feature Toggles
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false

CreateToggle("Auto Pass Bomb", function(state)
    AutoPassEnabled = state
    if state then
        RunService.RenderStepped:Connect(function()
            if AutoPassEnabled then
                -- Auto Pass Bomb logic
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Bomb") then
                        -- Rotate and pass the bomb to another player
                        local passTarget = Players:GetPlayers()[math.random(1, #Players:GetPlayers())]
                        if passTarget and passTarget.Character then
                            rotateCharacterTowardsTarget(passTarget.Character.HumanoidRootPart.Position)
                            player.Character.Bomb.CFrame = passTarget.Character.HumanoidRootPart.CFrame
                        end
                    end
                end
            end
        end)
    end
end)

CreateToggle("Anti Slippery", function(state)
    AntiSlipperyEnabled = state
    if state then
        -- Anti Slippery logic
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, 0.5)
            end
        end
    else
        -- Reset to default
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new()
            end
        end
    end
end)

CreateToggle("Remove Hitbox", function(state)
    RemoveHitboxEnabled = state
    if state then
        -- Remove Hitbox logic
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Hitbox" then
                part.Transparency = 1
                part.CanCollide = false
            end
        end
    else
        -- Reset Hitbox
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Hitbox" then
                part.Transparency = 0
                part.CanCollide = true
            end
        end
    end
end)

-- Notifications
local function ShowNotification(message)
    local Notification = Instance.new("TextLabel")
    Notification.Size = UDim2.new(0, 300, 0, 50)
    Notification.Position = UDim2.new(0.5, -150, 0, -60)
    Notification.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Notification.Text = message
    Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    Notification.Font = Enum.Font.GothamBold
    Notification.Parent = UI

    TweenService:Create(Notification, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -150, 0, 20)}):Play()
    wait(2)
    TweenService:Create(Notification, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -150, 0, -60)}):Play()
    wait(0.5)
    Notification:Destroy()
end
-- Toggle UI Function
local function ToggleUI()
    MainFrame.Visible = not MainFrame.Visible
    DragToggle.Visible = not MainFrame.Visible
end

-- Draggable Toggle Button
local DragToggle = Instance.new("TextButton")
DragToggle.Size = UDim2.new(0, 40, 0, 40)
DragToggle.Position = UDim2.new(0, 10, 0, 10)
DragToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DragToggle.Text = "≡"
DragToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
DragToggle.Font = Enum.Font.GothamBold
DragToggle.Parent = UI

local DragToggleCorner = Instance.new("UICorner")
DragToggleCorner.CornerRadius = UDim.new(0, 10)
DragToggleCorner.Parent = DragToggle

local draggingToggle = false
local dragInputToggle, dragStartToggle, startPosToggle

local function updateToggle(input)
    local delta = input.Position - dragStartToggle
    DragToggle.Position = UDim2.new(0, startPosToggle.X.Offset + delta.X, 0, startPosToggle.Y.Offset + delta.Y)
end

DragToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingToggle = true
        dragStartToggle = input.Position
        startPosToggle = DragToggle.Position
    end
end)

DragToggle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInputToggle = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInputToggle and draggingToggle then
        updateToggle(input)
    end
end)

DragToggle.MouseButton1Click:Connect(ToggleUI)

-- Keybind Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F2 then
        ToggleUI()
    end
end)
ShowNotification("Welcome to Custom UI!")

print("Custom UI Loaded Successfully")
