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
local currentTarget = nil -- Target lock to avoid back-and-forth switching

local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false

-- Debounce function to prevent rapid toggling
local function debounce(func, delay)
    local isDebounced = false
    return function(...)
        if not isDebounced then
            isDebounced = true
            func(...)
            task.delay(delay, function()
                isDebounced = false
            end)
        end
    end
end

-- Function to get the closest player
local function getClosestPlayer()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        print("LocalPlayer's character or HumanoidRootPart not available.")
        return nil
    end

    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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

-- Function to handle auto-passing the bomb with target lock
local function autoPassBomb()
    if AutoPassEnabled then
        local Bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
        if Bomb then
            -- Assign a target if none exists or if the target becomes invalid
            if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
                currentTarget = getClosestPlayer()
            end

            if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
                local targetPosition = currentTarget.Character.HumanoidRootPart.Position
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:MoveTo(targetPosition)
                    humanoid.MoveToFinished:Connect(function(reached)
                        if reached then
                            local BombEvent = Bomb:FindFirstChild("RemoteEvent")
                            if BombEvent then
                                BombEvent:FireServer(currentTarget.Character, currentTarget.Character:FindFirstChild("CollisionPart"))
                                currentTarget = nil -- Release the target lock after passing the bomb
                            end
                        end
                    end)
                end
            else
                print("Target invalid or too far. Recomputing...")
                currentTarget = nil
            end
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
    mainFrame.Size = UDim2.new(0, 350, 0, 550) -- Increased height for the slider
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -275)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    -- Rounded corners for main frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame

    -- Title Label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
    titleLabel.Text = "Yonkai Menu"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = 28
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = mainFrame

    -- Function to create buttons
    local function createButton(text, position)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.8, 0, 0.1, 0)
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

        return button
    end

    -- Buttons
    local antiSlipperyButton = createButton("Anti-Slippery", UDim2.new(0.1, 0, 0.2, 0))
    local removeHitboxButton = createButton("Remove Hitbox", UDim2.new(0.1, 0, 0.35, 0))
    local autoPassBombButton = createButton("Auto Pass Bomb", UDim2.new(0.1, 0, 0.5, 0))

    -- Slider for bombPassDistance
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.8, 0, 0.1, 0)
    sliderFrame.Position = UDim2.new(0.1, 0, 0.65, 0)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = mainFrame

    local slider = Instance.new("ImageButton")
    slider.Size = UDim2.new(0, 20, 1, 0)
    slider.Position = UDim2.new((bombPassDistance - 5) / 50, 0, 0, 0) -- Normalize initial position
    slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    slider.Parent = sliderFrame

    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(1, 0, 0.5, 0)
    sliderLabel.Position = UDim2.new(0, 0, -0.5, 0)
    sliderLabel.Text = "Bomb Pass Distance: " .. bombPassDistance
    sliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.TextSize = 16
    sliderLabel.Font = Enum.Font.SourceSans
    sliderLabel.Parent = sliderFrame

    -- Slider functionality
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    sliderFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativePosition = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            slider.Position = UDim2.new(relativePosition, 0, 0, 0)
            bombPassDistance = math.floor(5 + relativePosition * 50) -- Range: 5 to 55
            sliderLabel.Text = "Bomb Pass Distance: " .. bombPassDistance
        end
    end)

    -- Toggle button to show/hide the main menu
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
            local tween = TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(0.5, -175, 0.5, -275)})
            tween:Play()
        end
    end)

    -- Anti-Slippery button functionality
    antiSlipperyButton.MouseButton1Click:Connect(function()
        AntiSlipperyEnabled = not AntiSlipperyEnabled
        antiSlipperyButton.Text = "Anti-Slippery: " .. (AntiSlipperyEnabled and "ON" or "OFF")
    end)

    -- Remove Hitbox button functionality
    removeHitboxButton.MouseButton1Click:Connect(function()
        RemoveHitboxEnabled = not RemoveHitboxEnabled
        removeHitboxButton.Text = "Remove Hitbox: " .. (RemoveHitboxEnabled and "ON" or "OFF")
    end)

    -- Auto Pass Bomb button functionality
    autoPassBombButton.MouseButton1Click:Connect(function()
        AutoPassEnabled = not AutoPassEnabled
        autoPassBombButton.Text = "Auto Pass Bomb: " .. (AutoPassEnabled and "ON" or "OFF")
        if AutoPassEnabled then
            RunService.Stepped:Connect(autoPassBomb)
        else
            currentTarget = nil -- Reset the target lock
        end
    end)
end

-- Ensure the menu is created and toggle button stays visible
createYonkaiMenu()
