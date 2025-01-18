-- Roblox "Pass The Bomb" Script with Enhanced Yonkai Menu

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local bombHolder = nil

local bombPassDistance = 10
local passToClosest = true
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false

-- Utility function to get the closest player
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

-- Function to pass the bomb to the closest player
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
                print("No players within bomb pass distance.")
            end
        else
            print("No valid closest player found.")
        end
    end
end

-- Function to create the Yonkai menu
local function createYonkaiMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YonkaiMenu"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.1, 0)
    corner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
    titleLabel.Text = "Yonkai Menu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 28
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    local antiSlipperyButton = Instance.new("TextButton")
    antiSlipperyButton.Size = UDim2.new(0.8, 0, 0.15, 0)
    antiSlipperyButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    antiSlipperyButton.Text = "Anti-Slippery: OFF"
    antiSlipperyButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    antiSlipperyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    antiSlipperyButton.TextSize = 20
    antiSlipperyButton.Font = Enum.Font.SourceSans
    antiSlipperyButton.Parent = mainFrame

    local removeHitboxButton = Instance.new("TextButton")
    removeHitboxButton.Size = UDim2.new(0.8, 0, 0.15, 0)
    removeHitboxButton.Position = UDim2.new(0.1, 0, 0.4, 0)
    removeHitboxButton.Text = "Remove Hitbox: OFF"
    removeHitboxButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    removeHitboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    removeHitboxButton.TextSize = 20
    removeHitboxButton.Font = Enum.Font.SourceSans
    removeHitboxButton.Parent = mainFrame

    local autoPassBombButton = Instance.new("TextButton")
    autoPassBombButton.Size = UDim2.new(0.8, 0, 0.15, 0)
    autoPassBombButton.Position = UDim2.new(0.1, 0, 0.6, 0)
    autoPassBombButton.Text = "Auto Pass Bomb: OFF"
    autoPassBombButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    autoPassBombButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoPassBombButton.TextSize = 20
    autoPassBombButton.Font = Enum.Font.SourceSans
    autoPassBombButton.Parent = mainFrame

    local toggleButton = Instance.new("ImageButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(0, 20, 0, 20)
    toggleButton.Image = "rbxassetid://6031075938" -- Gojo icon asset ID
    toggleButton.BackgroundTransparency = 1
    toggleButton.Parent = screenGui

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    toggleButton.MouseButton1Click:Connect(function()
        if mainFrame.Visible then
            local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -175, 0.5, -700)})
            tween:Play()
            tween.Completed:Connect(function()
                mainFrame.Visible = false
            end)
        else
            mainFrame.Position = UDim2.new(0.5, -175, 0.5, -700)
            mainFrame.Visible = true
            local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -175, 0.5, -225)})
            tween:Play()
        end
    end)

    -- Anti-Slippery toggle
    antiSlipperyButton.MouseButton1Click:Connect(function()
        AntiSlipperyEnabled = not AntiSlipperyEnabled
        antiSlipperyButton.Text = "Anti-Slippery: " .. (AntiSlipperyEnabled and "ON" or "OFF")
        if AntiSlipperyEnabled then
            spawn(function()
                while AntiSlipperyEnabled do
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                        end
                    end
                    wait(0.1)
                end
            end)
        else
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
                end
            end
        end
    end)

    -- Remove Hitbox toggle
    removeHitboxButton.MouseButton1Click:Connect(function()
        RemoveHitboxEnabled = not RemoveHitboxEnabled
        removeHitboxButton.Text = "Remove Hitbox: " .. (RemoveHitboxEnabled and "ON" or "OFF")
        if RemoveHitboxEnabled then
            local function removeCollisionPart(character)
                for i = 1, 100 do
                    wait()
                    pcall(function()
                        character:WaitForChild("CollisionPart"):Destroy()
                    end)
                end
            end
            removeCollisionPart(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
            LocalPlayer.CharacterAdded:Connect(removeCollisionPart)
        end
    end)

    -- Auto-Pass toggle
    autoPassBombButton.MouseButton1Click:Connect(function()
        AutoPassEnabled = not AutoPassEnabled
        autoPassBombButton.Text = "Auto Pass Bomb: " .. (AutoPassEnabled and "ON" or "OFF")
        if AutoPassEnabled then
            RunService.Stepped:Connect(function()
                if not AutoPassEnabled then return end
                pcall(function()
                    if LocalPlayer.Backpack:FindFirstChild("Bomb") then
                        LocalPlayer.Backpack:FindFirstChild("Bomb").Parent = LocalPlayer.Character
                    end

                    local bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
                    if bomb then
                        local bombEvent = bomb:FindFirstChild("RemoteEvent")
                        local closestPlayer = getClosestPlayer()
                        if closestPlayer and closestPlayer.Character then
                            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                            local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                            if humanoid then
                                local path = PathfindingService:CreatePath({
                                    AgentRadius = 2,
                                    AgentHeight = 5,
                                    AgentCanJump = true,
                                    AgentJumpHeight = 10,
                                    AgentMaxSlope = 45,
                                })
                                path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, targetPosition)
                                for _, waypoint in ipairs(path:GetWaypoints()) do
                                    humanoid:MoveTo(waypoint.Position)
                                    humanoid.MoveToFinished:Wait()
                                end
                            end
                            bombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                        end
                    end
                end)
            end)
        end
    end)

    print("Pass The Bomb Script Loaded with Enhanced Yonkai Menu and Gojo Icon")
end

-- Initialize the Yonkai Menu
createYonkaiMenu()
