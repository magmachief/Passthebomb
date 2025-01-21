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

-- Function to create the hamburger menu
local function createHamburgerMenu()
    -- Screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HamburgerMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Menu Button
    local menuButton = Instance.new("TextButton")
    menuButton.Size = UDim2.new(0, 50, 0, 50)
    menuButton.Position = UDim2.new(0, 20, 0, 20)
    menuButton.Text = "☰"
    menuButton.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
    menuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    menuButton.TextSize = 24
    menuButton.Font = Enum.Font.SourceSansBold
    menuButton.Parent = screenGui

    -- Menu Panel
    local menuPanel = Instance.new("Frame")
    menuPanel.Size = UDim2.new(0, 200, 0, 300)
    menuPanel.Position = UDim2.new(0, 20, 0, 80)
    menuPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    menuPanel.BorderSizePixel = 0
    menuPanel.Visible = false
    menuPanel.Parent = screenGui

    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = menuPanel

    -- Create menu items
    local function createMenuItem(name, position)
        local menuItem = Instance.new("TextButton")
        menuItem.Size = UDim2.new(0.9, 0, 0, 50)
        menuItem.Position = position
        menuItem.Text = name
        menuItem.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
        menuItem.TextColor3 = Color3.fromRGB(255, 255, 255)
        menuItem.TextSize = 20
        menuItem.Font = Enum.Font.SourceSansBold
        menuItem.Parent = menuPanel

        -- Rounded corners
        local menuItemCorner = Instance.new("UICorner")
        menuItemCorner.CornerRadius = UDim.new(0, 10)
        menuItemCorner.Parent = menuItem

        return menuItem
    end

    -- Add items to the menu
    local item1 = createMenuItem("Anti-Slippery", UDim2.new(0.05, 0, 0, 10))
    local item2 = createMenuItem("Remove Hitbox", UDim2.new(0.05, 0, 0, 70))
    local item3 = createMenuItem("Auto Pass Bomb", UDim2.new(0.05, 0, 0, 130))

    -- Menu toggle functionality
    menuButton.MouseButton1Click:Connect(function()
        menuPanel.Visible = not menuPanel.Visible
    end)

    -- Button functionality
    item1.MouseButton1Click:Connect(function()
        AntiSlipperyEnabled = not AntiSlipperyEnabled
        item1.Text = "Anti-Slippery: " .. (AntiSlipperyEnabled and "ON" or "OFF")
    end)

    item2.MouseButton1Click:Connect(function()
        RemoveHitboxEnabled = not RemoveHitboxEnabled
        item2.Text = "Remove Hitbox: " .. (RemoveHitboxEnabled and "ON" or "OFF")
    end)

    item3.MouseButton1Click:Connect(function()
        AutoPassEnabled = not AutoPassEnabled
        item3.Text = "Auto Pass Bomb: " .. (AutoPassEnabled and "ON" or "OFF")
    end)
end

-- Initialize the hamburger menu
createHamburgerMenu()
