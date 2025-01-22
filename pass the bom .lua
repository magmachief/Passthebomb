--========================--
--     INITIAL SETUP      --
--========================--

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Variables
local bombHolder = nil
local bombPassDistance = 10
local passToClosest = true
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local autoPassConnection

-- Debug Utility
local function logDebug(message)
    print("[DEBUG]: " .. message)
end

-- Helper function to get the closest player
local function getClosestPlayer()
    logDebug("Calculating the closest player...")
    local closestPlayer = nil
    local shortestDistance = math.huge
    local localRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not localRootPart then
        logDebug("Local player root part not found.")
        return nil
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local bomb = player.Character:FindFirstChild("Bomb")

            if rootPart and not bomb then
                local distance = (rootPart.Position - localRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    if closestPlayer then
        logDebug("Closest player found: " .. closestPlayer.Name)
    else
        logDebug("No closest player found.")
    end

    return closestPlayer
end

-- Optimized anti-slippery
local function toggleAntiSlippery(enabled)
    logDebug("Toggling Anti-Slippery: " .. tostring(enabled))
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = enabled
                and PhysicalProperties.new(0.7, 0.3, 0.5)
                or PhysicalProperties.new(0.5, 0.3, 0.5)
        end
    end
end

-- Optimized remove hitbox
local function toggleRemoveHitbox(enabled)
    logDebug("Toggling Remove Hitbox: " .. tostring(enabled))
    if enabled then
        local function removeCollisionPart(character)
            local collisionPart = character:FindFirstChild("CollisionPart")
            if collisionPart then
                collisionPart:Destroy()
            end
        end

        removeCollisionPart(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
        LocalPlayer.CharacterAdded:Connect(removeCollisionPart)
    end
end

-- Function to pass the bomb
local function passBomb()
    if bombHolder == LocalPlayer and passToClosest then
        logDebug("Attempting to pass the bomb.")
        local closestPlayer = getClosestPlayer()
        if closestPlayer then
            local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
            local bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")

            if bomb then
                local tween = TweenService:Create(bomb, TweenInfo.new(0.5), {Position = targetPosition})
                tween:Play()
                tween.Completed:Connect(function()
                    bomb.Parent = closestPlayer.Character
                    logDebug("Bomb successfully passed to: " .. closestPlayer.Name)
                end)
            else
                logDebug("No bomb found to pass.")
            end
        else
            logDebug("No valid closest player.")
        end
    end
end

-- Auto-pass bomb
local function toggleAutoPassBomb(enabled)
    logDebug("Toggling Auto Pass Bomb: " .. tostring(enabled))
    if enabled then
        autoPassConnection = RunService.Stepped:Connect(function()
            pcall(function()
                local bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
                if bomb then
                    passBomb()
                end
            end)
        end)
    elseif autoPassConnection then
        autoPassConnection:Disconnect()
        autoPassConnection = nil
    end
end

-- Yonkai Menu creation utilities
local function createButton(parent, text, position, clickCallback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0.15, 0)
    button.Position = position
    button.Text = text .. ": OFF"
    button.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 20
    button.Font = Enum.Font.SourceSans
    button.Parent = parent

    -- Rounded corners for the button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = button

    button.MouseButton1Click:Connect(clickCallback)
    return button
end

local function createYonkaiMenu()
    logDebug("Creating Yonkai menu.")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YonkaiMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    -- Toggle button
    local toggleButton = Instance.new("ImageButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(0, 20, 0, 20)
    toggleButton.Image = "rbxassetid://6031075938"
    toggleButton.BackgroundTransparency = 1
    toggleButton.Parent = screenGui

    local function toggleMenu()
        mainFrame.Visible = not mainFrame.Visible
    end

    toggleButton.MouseButton1Click:Connect(toggleMenu)

    -- Buttons for features
    local antiSlipperyButton = createButton(mainFrame, "Anti-Slippery", UDim2.new(0.1, 0, 0.2, 0), function()
        AntiSlipperyEnabled = not AntiSlipperyEnabled
        antiSlipperyButton.Text = "Anti-Slippery: " .. (AntiSlipperyEnabled and "ON" or "OFF")
        toggleAntiSlippery(AntiSlipperyEnabled)
    end)

    local removeHitboxButton = createButton(mainFrame, "Remove Hitbox", UDim2.new(0.1, 0, 0.4, 0), function()
        RemoveHitboxEnabled = not RemoveHitboxEnabled
        removeHitboxButton.Text = "Remove Hitbox: " .. (RemoveHitboxEnabled and "ON" or "OFF")
        toggleRemoveHitbox(RemoveHitboxEnabled)
    end)

    local autoPassBombButton = createButton(mainFrame, "Auto Pass Bomb", UDim2.new(0.1, 0, 0.6, 0), function()
        AutoPassEnabled = not AutoPassEnabled
        autoPassBombButton.Text = "Auto Pass Bomb: " .. (AutoPassEnabled and "ON" or "OFF")
        toggleAutoPassBomb(AutoPassEnabled)
    end)
end

createYonkaiMenu()
