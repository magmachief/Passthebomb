--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

--// GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YonkaiMenu"
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.2, 0)
title.Text = "Yonkai Menu"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.FredokaOne
title.TextScaled = true
title.Parent = mainFrame

--// Settings
local Settings = {
    AntiSlipperyEnabled = false,
    RemoveHitboxEnabled = false,
    AutoPassEnabled = false
}

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
                local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
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
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
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

--// Toggle Buttons
local function createButton(text, position, featureName, toggleFunction)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0.1, 0)
    button.Position = position
    button.Text = text .. ": OFF"
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = mainFrame

    button.MouseButton1Click:Connect(function()
        Settings[featureName] = not Settings[featureName]
        button.Text = text .. ": " .. (Settings[featureName] and "ON" or "OFF")
        toggleFunction(Settings[featureName])
    end)
end

createButton("Anti-Slippery", UDim2.new(0.1, 0, 0.3, 0), "AntiSlipperyEnabled", applyAntiSlippery)
createButton("Remove Collision Parts", UDim2.new(0.1, 0, 0.5, 0), "RemoveHitboxEnabled", removeCollisionParts)
createButton("Auto Pass Bomb", UDim2.new(0.1, 0, 0.7, 0), "AutoPassEnabled", passBomb)

--// Show GUI
mainFrame.Visible = true
