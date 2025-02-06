--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// Variables
local bombPassDistance = 10
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local autoPassConnection = nil
local pathfindingSpeed = 16 -- Default speed
local uiThemes = {
    ["Dark"] = { Background = Color3.new(0, 0, 0), Text = Color3.new(1, 1, 1) },
    ["Light"] = { Background = Color3.new(1, 1, 1), Text = Color3.new(0, 0, 0) },
    ["Red"] = { Background = Color3.new(1, 0, 0), Text = Color3.new(1, 1, 1) },
}

-- Function to make a UI element draggable
local function makeDraggable(frame)
    if not frame then
        warn("Frame is nil. Cannot make it draggable.")
        return
    end

    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

--========================--
--    UTILITY FUNCTIONS   --
--========================--
-- Function to move the Shift Lock button to the Jump button position
local function moveShiftLockButton()
    -- Get the player's PlayerGui
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- Wait for the Shift Lock button and Jump button to be created
    local shiftLockButton = playerGui:WaitForChild("ShiftLockButton", 10)
    local touchGui = playerGui:WaitForChild("TouchGui", 10)
    local jumpButton = touchGui:WaitForChild("TouchControlFrame"):WaitForChild("JumpButton", 10)

    if shiftLockButton and jumpButton then
        -- Set the Shift Lock button position to the Jump button position
        shiftLockButton.Position = jumpButton.Position
        shiftLockButton.Size = jumpButton.Size

        -- Optionally hide the Jump button if needed
        jumpButton.Visible = false
    else
        warn("ShiftLockButton or JumpButton not found")
    end
end
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

-- Function to rotate the character to look more natural during bomb passing
local function rotateCharacterTowardsTarget(targetPosition)
    local character = LocalPlayer.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    -- Calculate direction to target
    local direction = (targetPosition - humanoidRootPart.Position).unit

    -- Slightly rotate the character to seem active
    humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(10), 0)

    -- Add a slight delay to slow down rotation
    wait(0.2) -- Adjust delay as needed
end

-- Anti-Slippery: Apply or reset physical properties
local function applyAntiSlippery(enabled)
    if enabled then
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
end

-- Remove Hitbox: Destroy collision parts
local function applyRemoveHitbox(enabled)
    if not enabled then return end
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local function removeCollisionPart(character)
        for destructionIteration = 1, 100 do
            wait()
            pcall(function()
                local collisionPart = character:FindFirstChild("CollisionPart")
                if collisionPart then collisionPart:Destroy() end
            end)
        end
    end
    removeCollisionPart(character)
    LocalPlayer.CharacterAdded:Connect(removeCollisionPart)
end

-- Auto Pass Bomb Logic
local function autoPassBomb()
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
                if (targetPosition - LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= bombPassDistance then
                    -- Rotate character slightly toward the target
                    rotateCharacterTowardsTarget(targetPosition)

                    -- Fire the remote event to pass the bomb
                    BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                end
            end
        end
    end)
end

-- Function to hook the bomb timer
local function hookBombTimer()
    local function tryToFindBomb()
        local Bomb = LocalPlayer.Backpack:FindFirstChild("Bomb")
        if Bomb then
            return Bomb
        else
            for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                if item.Name:lower():find("bomb") then
                    return item
                end
            end
        end
        return nil
    end

    local Bomb = tryToFindBomb()
    if Bomb then
        print("Bomb found: " .. Bomb.Name)
        local Timer = Bomb:FindFirstChild("Timer") or Bomb:FindFirstChild("Countdown") -- Adjust the name based on the actual game implementation
        if Timer then
            Timer:GetPropertyChangedSignal("Value"):Connect(function()
                print("Time left: " .. Timer.Value)
                -- You can also update a UI element here to display the remaining time
            end)
        else
            warn("Timer not found on the Bomb")
        end
    else
        warn("Bomb not found in the backpack")
    end
end

--========================--
--  APPLY FEATURES ON RESPAWN --
--========================--
LocalPlayer.CharacterAdded:Connect(function()
    if AntiSlipperyEnabled then applyAntiSlippery(true) end
    if RemoveHitboxEnabled then applyRemoveHitbox(true) end
    hookBombTimer() -- Hook the bomb timer on respawn
    moveShiftLockButton()
end)

--========================--
--  ORIONLIB INTERFACE    --
--========================--

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()
local Window = OrionLib:MakeWindow({ Name = "Yon Menu - Advanced", HidePremium = false, SaveConfig = true, ConfigFolder = "YonMenu_Advanced" })

-- Create a draggable icon
local icon = Instance.new("ImageLabel")
icon.Name = "DragIcon"
icon.Size = UDim2.new(0, 50, 0, 50)
icon.Position = UDim2.new(0, 10, 0, 10)
icon.Image = "rbxassetid://4483345998" -- Replace with your icon asset ID
icon.BackgroundTransparency = 1
icon.Parent = CoreGui

-- Make the icon draggable
makeDraggable(icon)

icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Window:Toggle()
    end
end)

-- Automated Tab
local AutomatedTab = Window:MakeTab({
    Name = "Automated",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

AutomatedTab:AddToggle({
    Name = "Anti Slippery",
    Default = AntiSlipperyEnabled,
    Callback = function(value)
        AntiSlipperyEnabled = value
        applyAntiSlippery(value)
    end
})

AutomatedTab:AddToggle({
    Name = "Remove Hitbox",
    Default = RemoveHitboxEnabled,
    Callback = function(value)
        RemoveHitboxEnabled = value
        applyRemoveHitbox(value)
    end
})

AutomatedTab:AddToggle({
    Name = "Auto Pass Bomb",
    Default = AutoPassEnabled,
    Callback = function(value)
        AutoPassEnabled = value
        if AutoPassEnabled then
            autoPassConnection = RunService.Stepped:Connect(autoPassBomb)
        else
            if autoPassConnection then
                autoPassConnection:Disconnect()
                autoPassConnection = nil
            end
        end
    end
})

AutomatedTab:AddSlider({
    Name = "Bomb Pass Distance",
    Min = 5,
    Max = 30,
    Default = bombPassDistance,
    Increment = 1,
    Callback = function(value)
        bombPassDistance = value
    end
})

AutomatedTab:AddDropdown({
    Name = "Pathfinding Speed",
    Default = "16",
    Options = {"12", "16", "20"},
    Callback = function(value)
        pathfindingSpeed = tonumber(value)
    end
})

AutomatedTab:AddDropdown({
    Name = "UI Theme",
    Default = "Dark",
    Options = { "Dark", "Light", "Red" },
    Callback = function(themeName)
        local theme = uiThemes[themeName]
        if theme then
            -- Apply theme to UI elements here if needed
        else
            warn("Theme not found:", themeName)
        end
    end
})

-- New Features Tab
local NewFeaturesTab = Window:MakeTab({
    Name = "New Features",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

NewFeaturesTab:AddLabel("New exciting features coming soon!")

NewFeaturesTab:AddButton({
    Name = "Teleport to Random Player",
    Callback = function()
        local closestPlayer = getClosestPlayer()
        if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = closestPlayer.Character.HumanoidRootPart.CFrame
        end
    end
})

NewFeaturesTab:AddSlider({
    Name = "Character Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(value)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
})

NewFeaturesTab:AddToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(value)
        if value then
            local character = LocalPlayer.Character
            if character then
                character.Humanoid.MaxHealth = math.huge
                character.Humanoid.Health = math.huge
            end
        else
            local character = LocalPlayer.Character
            if character then
                character.Humanoid.MaxHealth = 100
                character.Humanoid.Health = 100
            end
        end
    end
})

NewFeaturesTab:AddToggle({
    Name = "Invisible Mode",
    Default = false,
    Callback = function(value)
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = value and 1 or 0
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = value and 1 or 0
                end
            end
        end
    end
})

OrionLib:Init()
print("Yon Menu Script Loaded with Enhancements")
