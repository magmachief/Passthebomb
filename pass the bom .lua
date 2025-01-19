--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

local bombHolder = nil
local bombPassDistance = 10
local passToClosest = true
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false

-- Function to get the closest player
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

-- Function to move towards the closest player
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
                            -- Path was blocked, recompute path
                            moveToClosestPlayer()
                        end
                    end)
                end
            end

            followPath()
        end
    end
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
                print("No players within bomb pass distance. Moving to closest player.")
                moveToClosestPlayer()
            end
        else
            print("No valid closest player found.")
        end
    end
end

-- Function to create the Yonkai menu
local function createYonkaiMenu()
    -- Create a new ScreenGui and set ResetOnSpawn to false
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

    -- Rounded corners for main frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame

    -- Drop shadow effect for main frame
    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 50, 1, 50)
    shadow.Image = "rbxassetid://1316045217" -- Shadow image asset ID
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.BackgroundTransparency = 1
    shadow.ZIndex = 0
    shadow.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.15, 0)
    titleLabel.Text = "Yonkai Menu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 28
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Adding a gradient effect to the title
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
    })
    titleGradient.Parent = titleLabel

    -- Function to create buttons
    local function createButton(text, position)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.8, 0, 0.15, 0)
        button.Position = position
        button.Text = text .. ": OFF"
        button.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 20
        button.Font = Enum.Font.SourceSans
        button.Parent = mainFrame

        -- Rounded corners for the button
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 10)
        buttonCorner.Parent = button

        -- Button shadow effect
        local buttonShadow = Instance.new("ImageLabel")
        buttonShadow.AnchorPoint = Vector2.new(0.5, 0.5)
        buttonShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        buttonShadow.Size = UDim2.new(1, 10, 1, 10)
        buttonShadow.Image = "rbxassetid://1316045217" -- Shadow image asset ID
        buttonShadow.ImageColor3 = Color3.new(0, 0, 0)
        buttonShadow.ImageTransparency = 0.5
        buttonShadow.BackgroundTransparency = 1
        buttonShadow.ZIndex = 0
        buttonShadow.Parent = button

        return button
    end

    local antiSlipperyButton = createButton("Anti-Slippery", UDim2.new(0.1, 0, 0.2, 0))
    local removeHitboxButton = createButton("Remove Hitbox", UDim2.new(0.1, 0, 0.4, 0))
    local autoPassBombButton = createButton("Auto Pass Bomb", UDim2.new(0.1, 0, 0.6, 0))

    -- Toggle button to show/hide the main menu
    local toggleButton = Instance.new("ImageButton")
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Position = UDim2.new(0, 20, 0, 20)
    toggleButton.Image = "rbxassetid://6031075938" -- Gojo icon asset ID
    toggleButton.BackgroundTransparency = 1
    toggleButton.Parent = screenGui

    -- Adding UI elements to enhance the toggle button appearance
    local toggleButtonCorner = Instance.new("UICorner")
    toggleButtonCorner.CornerRadius = UDim.new(0, 10)
    toggleButtonCorner.Parent = toggleButton

    local toggleButtonStroke = Instance.new("UIStroke")
    toggleButtonStroke.Thickness = 2
    toggleButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    toggleButtonStroke.Parent = toggleButton

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- Toggle button functionality to show/hide the main menu
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

    -- Anti-Slippery button functionality
    antiSlipperyButton.MouseButton1Click:Connect(function()
        AntiSlipperyEnabled = not AntiSlipperyEnabled
        antiSlipperyButton.Text = "Anti-Slippery: " .. (AntiSlipperyEnabled and "ON" or "OFF")
        if AntiSlipperyEnabled then
            spawn(function()
                local player = Players.LocalPlayer
                local character = player.Character or player.CharacterAdded:Wait()
                while AntiSlipperyEnabled do
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                        end
                    end
                    wait(0.1)
                end
            end)
        else
            local player = Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
                end
            end
        end
    end)

    -- Remove Hitbox button functionality
    removeHitboxButton.MouseButton1Click:Connect(function()
        RemoveHitboxEnabled = not RemoveHitboxEnabled
        removeHitboxButton.Text = "Remove Hitbox: " .. (RemoveHitboxEnabled and "ON" or "OFF")
        if RemoveHitboxEnabled then
            local LocalPlayer = Players.LocalPlayer
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local function removeCollisionPart(character)
                for destructionIteration = 1, 100 do
                    wait()
                    pcall(function()
                        character:WaitForChild("CollisionPart"):Destroy()
                    end)
                end
            end
            removeCollisionPart(Character)
            LocalPlayer.CharacterAdded:Connect(function(character)
                removeCollisionPart(character)
            end)
        end
    end)

    -- Auto Pass Bomb button functionality
    local autoPassConnection
    autoPassBombButton.MouseButton1Click:Connect(function()
        AutoPassEnabled = not AutoPassEnabled
        autoPassBombButton.Text = "Auto Pass Bomb: " .. (AutoPassEnabled and "ON" or "OFF")
        if AutoPassEnabled then
            autoPassConnection = RunService.Stepped:Connect(function()
                if not AutoPassEnabled then return end
                pcall(function()
                    if LocalPlayer.Backpack:FindFirstChild("Bomb") then
                        LocalPlayer.Backpack:FindFirstChild("Bomb").Parent = LocalPlayer.Character
                    end

                    local Bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
                    if Bomb then
                        local BombEvent = Bomb:FindFirstChild("RemoteEvent")
                        local closestPlayer = getClosestPlayer()
                        if closestPlayer and closestPlayer.Character then
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
                                                -- Path was blocked, recompute path
                                                moveToClosestPlayer()
                                            end
                                        end)
                                    end
                                end

                                followPath()
                            end
                            BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                        end
                    end
                end)
            end)
        else
            if autoPassConnection then
                autoPassConnection:Disconnect()
            end
        end
    end)

    print("Pass The Bomb Script Loaded with Enhanced Yonkai Menu and Gojo Icon")
end

-- Ensure the menu is created and toggle button stays visible
createYonkaiMenu()

-- Recreate the menu if the player respawns
LocalPlayer.CharacterAdded:Connect(createYonkaiMenu)
