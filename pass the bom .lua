--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

-- Default Settings and Preferences
local bombHolder = nil
local bombPassDistance = 10
local passToClosest = true
local preferences = {
    AntiSlipperyEnabled = false,
    RemoveHitboxEnabled = false,
    AutoPassEnabled = false,
    Theme = "Dark", -- Dark, Light, Ocean, Sunset
    ButtonLayout = "Vertical", -- Vertical or Horizontal
    Font = Enum.Font.Gotham, -- Default font
}

-- Theme presets
local themes = {
    Dark = {Background = Color3.fromRGB(30, 30, 30), TextColor = Color3.fromRGB(255, 255, 255)},
    Light = {Background = Color3.fromRGB(230, 230, 230), TextColor = Color3.fromRGB(0, 0, 0)},
    Ocean = {Background = Color3.fromRGB(0, 128, 255), TextColor = Color3.fromRGB(255, 255, 255)},
    Sunset = {Background = Color3.fromRGB(255, 128, 0), TextColor = Color3.fromRGB(0, 0, 0)},
}

-- Play a sound effect
local function playSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 1
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- Get the closest player
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

-- Move to the closest player
local function moveToClosestPlayer()
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true,
                AgentJumpHeight = 10,
                AgentMaxSlope = 45,
            })
            path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, targetPosition)
            local waypoints = path:GetWaypoints()
            local waypointIndex = 1

            local function followPath()
                if waypointIndex <= #waypoints then
                    local waypoint = waypoints[waypointIndex]
                    humanoid:MoveTo(waypoint.Position)
                    humanoid.MoveToFinished:Connect(function(reached)
                        if reached then
                            waypointIndex = waypointIndex + 1
                            followPath()
                        else
                            -- Path blocked; recompute
                            moveToClosestPlayer()
                        end
                    end)
                end
            end

            followPath()
        end
    end
end

-- Pass the bomb to the closest player
local function passBomb()
    if bombHolder == LocalPlayer and passToClosest then
        local closestPlayer = getClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (closestPlayer.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance <= bombPassDistance then
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
                print("No players within bomb pass distance. Moving to closest player.")
                moveToClosestPlayer()
            end
        else
            print("No valid closest player found.")
        end
    end
end

-- Anti-Slippery functionality
local function applyAntiSlippery(enabled)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if enabled then
        print("Anti-Slippery: ON")
        while preferences.AntiSlipperyEnabled do
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                end
            end
            RunService.Heartbeat:Wait()
        end
    else
        print("Anti-Slippery: OFF")
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
            end
        end
    end
end

-- Remove Hitbox functionality
local function removeHitbox(enabled)
    local function cleanHitbox(character)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "CollisionPart" then
                part:Destroy()
            end
        end
    end

    if enabled then
        print("Remove Hitbox: ON")
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        cleanHitbox(character)
        LocalPlayer.CharacterAdded:Connect(cleanHitbox)
    else
        print("Remove Hitbox: OFF")
    end
end

-- Show confirmation popup with animations and sound
local function showConfirmationPopup(actionText, onConfirm)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local popupFrame = Instance.new("Frame")
    popupFrame.Size = UDim2.new(0, 0, 0, 0) -- Start small for scaling animation
    popupFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    popupFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    popupFrame.BackgroundColor3 = themes[preferences.Theme].Background
    popupFrame.Parent = screenGui

    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, 10)
    popupCorner.Parent = popupFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
    titleLabel.Text = actionText
    titleLabel.TextColor3 = themes[preferences.Theme].TextColor
    titleLabel.TextSize = 20
    titleLabel.Font = preferences.Font
    titleLabel.TextWrapped = true
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = popupFrame

    local yesButton = Instance.new("TextButton")
    yesButton.Size = UDim2.new(0.4, 0, 0.3, 0)
    yesButton.Position = UDim2.new(0.1, 0, 0.6, 0)
    yesButton.Text = "Yes"
    yesButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    yesButton.Font = preferences.Font
    yesButton.TextColor3 = themes[preferences.Theme].TextColor
    yesButton.Parent = popupFrame

    local noButton = Instance.new("TextButton")
    noButton.Size = UDim2.new(0.4, 0, 0.3, 0)
    noButton.Position = UDim2.new(0.5, 0, 0.6, 0)
    noButton.Text = "No"
    noButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    noButton.Font = preferences.Font
    noButton.TextColor3 = themes[preferences.Theme].TextColor
    noButton.Parent = popupFrame

    playSound("1234567890", 1) -- Replace with your sound asset ID
    popupFrame.BackgroundTransparency = 1
    local fadeIn = TweenService:Create(popupFrame, TweenInfo.new(0.5), {Size = UDim2.new(0, 300, 0, 150), BackgroundTransparency = 0})
    fadeIn:Play()

    yesButton.MouseButton1Click:Connect(function()
        playSound("1234567891", 1) -- Confirm sound
        onConfirm()
        screenGui:Destroy()
    end)

    noButton.MouseButton1Click:Connect(function()
        playSound("1234567892", 1) -- Cancel sound
        local fadeOut = TweenService:Create(popupFrame, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)
end

-- Create the Advanced Menu
local function createAdvancedMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
    mainFrame.BackgroundColor3 = themes[preferences.Theme].Background
    mainFrame.Parent = screenGui

    local buttonLayout = Instance.new(preferences.ButtonLayout == "Vertical" and "UIListLayout" or "UIGridLayout")
    if buttonLayout:IsA("UIListLayout") then
        buttonLayout.Padding = UDim.new(0.02, 0)
    else
        buttonLayout.CellSize = UDim2.new(0.4, 0, 0.1, 0)
        buttonLayout.CellPadding = UDim2.new(0.02, 0)
    end
    buttonLayout.Parent = mainFrame

    local function createToggleButton(text, preferenceKey, toggleFunction)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.8, 0, 0.1, 0)
        button.Text = text .. ": " .. (preferences[preferenceKey] and "ON" or "OFF")
        button.BackgroundColor3 = preferences[preferenceKey] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 128, 255)
        button.TextColor3 = themes[preferences.Theme].TextColor
        button.Font = preferences.Font
        button.Parent = mainFrame

        button.MouseButton1Click:Connect(function()
            playSound("1234567893", 0.5) -- Button click sound
            preferences[preferenceKey] = not preferences[preferenceKey]
            button.Text = text .. ": " .. (preferences[preferenceKey] and "ON" or "OFF")
            button.BackgroundColor3 = preferences[preferenceKey] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 128, 255)
            toggleFunction(preferences[preferenceKey])
        end)
    end

    -- Add toggle buttons with their respective functions
    createToggleButton("Anti-Slippery", "AntiSlipperyEnabled", applyAntiSlippery)
    createToggleButton("Remove Hitbox", "RemoveHitboxEnabled", removeHitbox)
    createToggleButton("Auto Pass Bomb", "AutoPassEnabled", function(enabled)
        if enabled then
            print("Auto Pass Bomb: ON")
            RunService.Stepped:Connect(passBomb)
        else
            print("Auto Pass Bomb: OFF")
        end
    end)
end

-- Initialize the menu
createAdvancedMenu()
