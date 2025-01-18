--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

--// Variables
local LocalPlayer = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")

local Settings = {
    AntiSlipperyEnabled = false,
    RemoveHitboxEnabled = false,
    AutoPassBombEnabled = false,
}

--// Anti-Slippery Functionality (Retained Original Logic)
local function toggleAntiSlippery(state)
    if state then
        -- Prevent slippery movements
        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, LocalPlayer.Character.HumanoidRootPart.Velocity.Y, 0)
    else
        -- Allow natural movement
        LocalPlayer.Character.HumanoidRootPart.Velocity = LocalPlayer.Character.HumanoidRootPart.Velocity
    end
end

--// Remove Hitbox Functionality (Retained Original Logic)
local function toggleRemoveHitbox(state)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if state then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false -- Disable collisions
            end
        end
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true -- Enable collisions
            end
        end
    end
end

--// Auto Pass Bomb Functionality (Retained Original Logic)
local function toggleAutoPassBomb(state)
    if state then
        while Settings.AutoPassBombEnabled do
            task.wait(0.5)
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if target then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame -- Pass bomb
                    end
                end
            end
        end
    end
end

--// UI Creation Functions
local function createMainFrame()
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false

    -- Gradient Background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 128, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 64, 128))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame

    -- Rounded Corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.1, 0)
    corner.Parent = mainFrame

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Text = "✨ Yonkai ✨"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 32
    titleLabel.Font = Enum.Font.FredokaOne
    titleLabel.Parent = mainFrame

    return mainFrame
end

local function createButton(parent, text, position, onClick)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0.1, 0)
    button.Position = position
    button.Text = text
    button.TextScaled = true
    button.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.Parent = parent

    -- Gradient on Button
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 128)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 128, 255))
    }
    gradient.Parent = button

    -- Rounded Corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.15, 0)
    corner.Parent = button

    button.MouseButton1Click:Connect(onClick)
    return button
end

--// Main Menu Setup
local function setupMenu()
    local mainFrame = createMainFrame()
    mainFrame.Parent = screenGui

    createButton(mainFrame, 
        "Anti-Slippery: " .. (Settings.AntiSlipperyEnabled and "ON" or "OFF"),
        UDim2.new(0.1, 0, 0.25, 0),
        function()
            Settings.AntiSlipperyEnabled = not Settings.AntiSlipperyEnabled
            toggleAntiSlippery(Settings.AntiSlipperyEnabled)
        end
    )

    createButton(mainFrame, 
        "Remove Hitbox: " .. (Settings.RemoveHitboxEnabled and "ON" or "OFF"),
        UDim2.new(0.1, 0, 0.45, 0),
        function()
            Settings.RemoveHitboxEnabled = not Settings.RemoveHitboxEnabled
            toggleRemoveHitbox(Settings.RemoveHitboxEnabled)
        end
    )

    createButton(mainFrame, 
        "Auto Pass Bomb: " .. (Settings.AutoPassBombEnabled and "ON" or "OFF"),
        UDim2.new(0.1, 0, 0.65, 0),
        function()
            Settings.AutoPassBombEnabled = not Settings.AutoPassBombEnabled
            toggleAutoPassBomb(Settings.AutoPassBombEnabled)
        end
    )

    local toggleButton = Instance.new("ImageButton")
    toggleButton.Size = UDim2.new(0, 60, 0, 60)
    toggleButton.Position = UDim2.new(0, 20, 0, 20)
    toggleButton.Image = "rbxassetid://6031075938"
    toggleButton.BackgroundTransparency = 1
    toggleButton.Parent = screenGui

    toggleButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)

    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--// Initialize
setupMenu()
