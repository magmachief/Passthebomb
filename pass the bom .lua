--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local bombPassDistance = 10
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

-- Function to create a 3D menu
local function create3DMenu()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Create the 3D Menu model
    local menuModel = Instance.new("Model")
    menuModel.Name = "3DMenu"
    menuModel.Parent = workspace

    local menuBase = Instance.new("Part")
    menuBase.Size = Vector3.new(6, 1, 4)
    menuBase.Position = humanoidRootPart.Position + Vector3.new(0, 3, -7)
    menuBase.Anchored = true
    menuBase.BrickColor = BrickColor.new("Bright blue")
    menuBase.Name = "MenuBase"
    menuBase.Parent = menuModel

    -- Utility function to create buttons with proximity prompt
    local function createButton(name, color, position, callback)
        local button = Instance.new("Part")
        button.Size = Vector3.new(5, 1, 1)
        button.Position = menuBase.Position + position
        button.Anchored = true
        button.BrickColor = BrickColor.new(color)
        button.Name = name
        button.Parent = menuModel

        local prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = name
        prompt.ObjectText = "Press E"
        prompt.RequiresLineOfSight = false
        prompt.HoldDuration = 0.5
        prompt.Parent = button

        prompt.Triggered:Connect(callback)

        -- Add animation when interacting
        prompt.Triggered:Connect(function()
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(button, tweenInfo, {Size = Vector3.new(5.2, 1.2, 1.2)})
            tween:Play()
            tween.Completed:Connect(function()
                local resetTween = TweenService:Create(button, tweenInfo, {Size = Vector3.new(5, 1, 1)})
                resetTween:Play()
            end)
        end)

        return button
    end

    -- Anti-Slippery button
    createButton("Anti-Slippery", "Bright green", Vector3.new(0, 1, 1.5), function()
        AntiSlipperyEnabled = not AntiSlipperyEnabled
        print("Anti-Slippery:", AntiSlipperyEnabled and "ON" or "OFF")

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

    -- Remove Hitbox button
    createButton("Remove Hitbox", "Bright yellow", Vector3.new(0, 1, 0), function()
        RemoveHitboxEnabled = not RemoveHitboxEnabled
        print("Remove Hitbox:", RemoveHitboxEnabled and "ON" or "OFF")

        if RemoveHitboxEnabled then
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local function removeCollisionParts()
                for _, part in pairs(character:GetDescendants()) do
                    if part.Name == "CollisionPart" then
                        part:Destroy()
                    end
                end
            end
            removeCollisionParts()
            character.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "CollisionPart" then
                    descendant:Destroy()
                end
            end)
        end
    end)

    -- Auto Pass Bomb button
    createButton("Auto Pass Bomb", "Bright red", Vector3.new(0, 1, -1.5), function()
        AutoPassEnabled = not AutoPassEnabled
        print("Auto Pass Bomb:", AutoPassEnabled and "ON" or "OFF")

        if AutoPassEnabled then
            spawn(function()
                while AutoPassEnabled do
                    local closestPlayer = getClosestPlayer()
                    if closestPlayer and closestPlayer.Character then
                        local bomb = LocalPlayer.Backpack:FindFirstChild("Bomb") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb"))
                        if bomb then
                            bomb.Parent = closestPlayer.Character
                            print("Bomb passed to:", closestPlayer.Name)
                        end
                    end
                    wait(1)
                end
            end)
        end
    end)

    print("3D Menu created!")
end

-- Create the menu when the player spawns
LocalPlayer.CharacterAdded:Connect(create3DMenu)

-- Create the menu initially
if LocalPlayer.Character then
    create3DMenu()
end
