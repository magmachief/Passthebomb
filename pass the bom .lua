--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local DataStoreService = game:GetService("DataStoreService")

--// Local Variables
local LocalPlayer = Players.LocalPlayer
local SettingsStore = DataStoreService:GetDataStore("PlayerSettings")
local screenGui = Instance.new("ScreenGui")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local Settings = {
    AntiSlipperyEnabled = false,
    RemoveHitboxEnabled = false,
    AutoPassEnabled = false,
}

--// Load Saved Settings
local function loadSettings()
    local success, savedSettings = pcall(function()
        return SettingsStore:GetAsync(LocalPlayer.UserId)
    end)
    if success and savedSettings then
        Settings = savedSettings
    end
end

--// Save Current Settings
local function saveSettings()
    pcall(function()
        SettingsStore:SetAsync(LocalPlayer.UserId, Settings)
    end)
end

--// Utility Functions
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not player.Character:FindFirstChild("Bomb") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

local function passBomb()
    if LocalPlayer.Character and Settings.AutoPassEnabled then
        local closestPlayer = getClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local bomb = LocalPlayer.Character:FindFirstChild("Bomb")
            if bomb then
                local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                local tween = TweenService:Create(bomb, tweenInfo, {Position = targetPosition})
                tween:Play()
                tween.Completed:Connect(function()
                    bomb.Parent = closestPlayer.Character
                    print("Bomb passed to:", closestPlayer.Name)
                end)
            end
        end
    end
end

local function applyAntiSlippery(enabled)
    local player = LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    if enabled then
        spawn(function()
            while Settings.AntiSlipperyEnabled do
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                    end
                end
                wait(0.5)
            end
        end)
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
            end
        end
    end
end

local function removeCollisionParts(enabled)
    if enabled then
        local function removeCollisionPart(character)
            for i = 1, 10 do
                wait()
                pcall(function()
                    character:WaitForChild("CollisionPart"):Destroy()
                end)
            end
        end

        removeCollisionPart(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
        LocalPlayer.CharacterAdded:Connect(removeCollisionPart)
    end
end

--// UI Creation Functions
local function createMainFrame()
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.Visible = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.1, 0)
    corner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Text = "Yonkai Enhanced Menu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 28
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame

    return mainFrame
end

local function createButton(parent, text, position, onClick, tooltipText)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0.1, 0)
    button.Position = position
    button.Text = text
    button.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 20
    button.Font = Enum.Font.Gotham
    button.Parent = parent

    local tooltip = Instance.new("TextLabel")
    tooltip.Size = UDim2.new(1, 0, 0.05, 0)
    tooltip.Position = UDim2.new(0, 0, 0.95, 0)
    tooltip.Text = tooltipText
    tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
    tooltip.BackgroundTransparency = 1
    tooltip.TextSize = 14
    tooltip.Font = Enum.Font.Gotham
    tooltip.Visible = false
    tooltip.Parent = parent

    button.MouseEnter:Connect(function()
        tooltip.Visible = true
    end)

    button.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)

    button.MouseButton1Click:Connect(onClick)
    return button
end

local function toggleVisibility(frame)
    if frame.Visible then
        local hideTween = TweenService:Create(frame, tweenInfo, {Position = UDim2.new(0.5, -200, 1.5, 0)})
        hideTween:Play()
        hideTween.Completed:Connect(function()
            frame.Visible = false
        end)
    else
        frame.Position = UDim2.new(0.5, -200, 1.5, 0)
        frame.Visible = true
        local showTween = TweenService:Create(frame, tweenInfo, {Position = UDim2.new(0.5, -200, 0.5, -300)})
        showTween:Play()
    end
end

--// Main Menu Setup
local function setupMenu()
    loadSettings()

    local mainFrame = createMainFrame()
    mainFrame.Parent = screenGui

    createButton(mainFrame, 
        "Anti-Slippery: " .. (Settings.AntiSlipperyEnabled and "ON" or "OFF"),
        UDim2.new(0.1, 0, 0.2, 0),
        function()
            Settings.AntiSlipperyEnabled = not Settings.AntiSlipperyEnabled
            applyAntiSlippery(Settings.AntiSlipperyEnabled)
            saveSettings()
        end,
        "Prevents slippery physics for better control."
    )

    createButton(mainFrame, 
        "Remove Hitbox: " .. (Settings.RemoveHitboxEnabled and "ON" or "OFF"),
        UDim2.new(0.1, 0, 0.4, 0),
        function()
            Settings.RemoveHitboxEnabled = not Settings.RemoveHitboxEnabled
            removeCollisionParts(Settings.RemoveHitboxEnabled)
            saveSettings()
        end,
        "Removes hitbox for better collision handling."
    )

    createButton(mainFrame, 
        "Auto Pass Bomb: " .. (Settings.AutoPassEnabled and "ON" or "OFF"),
        UDim2.new(0.1, 0, 0.6, 0),
        function()
            Settings.AutoPassEnabled = not Settings.AutoPassEnabled
            saveSettings()
        end,
        "Automatically passes the bomb to the closest player."
    )

    local toggleButton = Instance.new("ImageButton")
    toggleButton.Size = UDim2.new(0, 60, 0, 60)
    toggleButton.Position = UDim2.new(0, 20, 0, 20)
    toggleButton.Image = "rbxassetid://6031075938"
    toggleButton.BackgroundTransparency = 1
    toggleButton.Parent = screenGui

    toggleButton.MouseButton1Click:Connect(function()
        toggleVisibility(mainFrame)
    end)

    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--// Initialize
setupMenu()
