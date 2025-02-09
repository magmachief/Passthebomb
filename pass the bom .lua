local shiftlockk = Instance.new("ScreenGui")
local LockButton = Instance.new("ImageButton")
local btnIcon = Instance.new("ImageLabel")

shiftlockk.Name = "shiftlockk"
shiftlockk.Parent = game.CoreGui
shiftlockk.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
shiftlockk.ResetOnSpawn = false

LockButton.Name = "LockButton"
LockButton.Parent = shiftlockk
LockButton.AnchorPoint = Vector2.new(0.5, 0.5)
LockButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LockButton.BackgroundTransparency = 1.000
LockButton.BorderColor3 = Color3.fromRGB(27, 42, 53)
LockButton.Position = UDim2.new(0.785, 0, 0.865, 0)
LockButton.Size = UDim2.new(0, 60, 0, 60)
LockButton.ZIndex = 3
LockButton.Image = "rbxassetid://530406505"
LockButton.ImageColor3 = Color3.fromRGB(0, 133, 199)
LockButton.ImageRectOffset = Vector2.new(2, 2)
LockButton.ImageRectSize = Vector2.new(98, 98)
LockButton.ImageTransparency = 0.400
LockButton.ScaleType = Enum.ScaleType.Fit

btnIcon.Name = "btnIcon"
btnIcon.Parent = LockButton
btnIcon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btnIcon.BackgroundTransparency = 1.000
btnIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
btnIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
btnIcon.ZIndex = 3
btnIcon.Image = "rbxasset://textures/ui/mouseLock_off.png"
btnIcon.ImageColor3 = Color3.fromRGB(0, 0, 0)
btnIcon.ScaleType = Enum.ScaleType.Fit
btnIcon.SliceCenter = Rect.new(-160, 0, 100, 0)

local function DragThingy(ui, dragui)
    if not dragui then dragui = ui end
    local UserInputService = game:GetService("UserInputService")
    
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        ui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    dragui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ui.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

DragThingy(LockButton)

local function YDYMLAX_fake_script()
    local script = Instance.new('LocalScript', LockButton)

    local Input = game:GetService("UserInputService")
    local V = false

    local main = script.Parent

    main.MouseButton1Click:Connect(function()
        V = not V
        main.btnIcon.ImageColor3 = V and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(0, 0, 0)
        if V then
            ForceShiftLock()
        else
            EndForceShiftLock()
        end
    end)

    local g = nil
    local GameSettings = UserSettings():GetService("UserGameSettings")
    local J = nil

    function ForceShiftLock()
        local i, k = pcall(function()
            return GameSettings.RotationType
        end)
        _ = i
        g = k
        J = game:GetService("RunService").RenderStepped:Connect(function()
            pcall(function()
                GameSettings.RotationType = Enum.RotationType.CameraRelative
            end)
        end)
    end

    function EndForceShiftLock()
        if J then
            pcall(function()
                GameSettings.RotationType = g or Enum.RotationType.MovementRelative
            end)
            J:Disconnect()
        end
    end
end
coroutine.wrap(YDYMLAX_fake_script)()

-- Double-tap functionality
local lastTapTime = 0
local doubleTapTime = 0.5 -- seconds
local isDraggable = true

LockButton.MouseButton1Click:Connect(function()
    local currentTime = tick()
    if currentTime - lastTapTime <= doubleTapTime then
        isDraggable = not isDraggable
        if isDraggable then
            DragThingy(LockButton)
        end
    end
    lastTapTime = currentTime
end)

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CoreGui = game:GetService("CoreGui")
local Camera = game.Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Variables
local bombPassDistance = 10
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local autoPassConnection = nil
local pathfindingSpeed = 16 -- Default speed
local isFlickMode = true -- Flick mode enabled by default
local uiTheme = "Dark" -- Default UI theme
local uiThemes = {
    ["Dark"] = { Background = Color3.fromRGB(0, 0, 0), Text = Color3.fromRGB(255, 255, 255) },
    ["Light"] = { Background = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(0, 0, 0) },
    ["Red"] = { Background = Color3.fromRGB(255, 0, 0), Text = Color3.fromRGB(255, 255, 255) },
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

local function rotateCharacter()
    local character = LocalPlayer.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    -- Rotate the character slightly
    humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(10), 0) -- Adjust angle as needed

    -- Add a slight delay to control rotation speed
    wait(0.2) -- Adjust delay as needed
end

-- Function to smoothly rotate the camera towards the target
local function flickToTarget(targetPosition)
    if not targetPosition then return end

    local startCFrame = Camera.CFrame
    local endCFrame = CFrame.new(Camera.CFrame.Position, targetPosition) -- Look at target

    -- Animate the flick effect
    for i = 0, 1, flickSpeed do
        Camera.CFrame = startCFrame:Lerp(endCFrame, i)
        RunService.RenderStepped:Wait()
    end

    -- Reset camera smoothly after flick
    wait(0.2)
    for i = 0, 1, flickSpeed do
        Camera.CFrame = endCFrame:Lerp(startCFrame, i)
        RunService.RenderStepped:Wait()
    end
end

-- Function to get the closest player with a bomb
local function getClosestPlayerWithBomb()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Bomb") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
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
                    -- Fire the remote event to pass the bomb
                    if isFlickMode then
                        flickToTarget(targetPosition)
                    else
                        rotateCharacter()
                    end
                    BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                end
            end
        end
    end)
end

-- Auto pass bomb if enabled
RunService.Stepped:Connect(function()
    if AutoPassEnabled then
        autoPassBomb()
    end
end)

--========================--
--  APPLY FEATURES ON RESPAWN --
--========================--
LocalPlayer.CharacterAdded:Connect(function()
    if AntiSlipperyEnabled then applyAntiSlippery(true) end
    if RemoveHitboxEnabled then applyRemoveHitbox(true) end
end)

--========================--
--  CUSTOMIZABLE UI COLORS --
--========================--

-- Function to update UI colors
local function updateUITheme(themeName)
    if uiThemes[themeName] then
        local theme = uiThemes[themeName]
        -- Update UI colors (example: if you have buttons, change their color)
        print("UI Theme Updated to:", themeName)
    else
        warn("Theme not found:", themeName)
    end
end

--========================--
-- MOBILE-FRIENDLY GESTURE SUPPORT --
--========================--
UserInputService.TouchSwipe:Connect(function(direction)
    if direction == Enum.SwipeDirection.Left then
        isFlickMode = false -- Switch to Rotate Mode
        print("Switched to Rotate Mode")
    elseif direction == Enum.SwipeDirection.Right then
        isFlickMode = true -- Switch to Flick Mode
        print("Switched to Flick Mode")
    end
end)

--========================--
--  ORIONLIB INTERFACE    --
--========================--

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()
local Window = OrionLib:MakeWindow({ Name = "Yon Menu - Advanced", HidePremium = false, SaveConfig = true, ConfigFolder = "YonMenu_Advanced" })

-- Make the OrionLib window draggable (if needed)
makeDraggable(Window.Container)

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
        uiTheme = themeName
        updateUITheme(themeName)
    end
})

AutomatedTab:AddDropdown({
    Name = "Bomb Pass Mode",
    Default = "rotate",
    Options = { "rotate", "flick" },
    Callback = function(value)
        isFlickMode = (value == "flick")
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
OrionLib:Init()
