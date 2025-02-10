--[[
    FULL LOCAL SCRIPT
    -------------------------------
    This script loads OrionLib from GitHub, sets up Premium and Shift Lock systems,
    defines extra features (including a bomb distance slider), and creates a UI window.
    It now also includes built-in console functions so you can press F9 to toggle
    a console window.
    
    Make sure this script is a LocalScript (client-side) and your executor allows HTTP requests.
--]]

-----------------------------------------------------
-- SERVICES & LOCAL VARIABLES
-----------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-----------------------------------------------------
-- PREMIUM SYSTEM
-----------------------------------------------------
local function GrantPremiumToAll()
    for _, player in ipairs(Players:GetPlayers()) do
        player:SetAttribute("Premium", true)
    end
end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("Premium", true)
end)

local function IsPremium(player)
    return player:GetAttribute("Premium") == true
end

GrantPremiumToAll()

-----------------------------------------------------
-- SHIFT LOCK SYSTEM
-----------------------------------------------------
-- Shift Lock System (Revised)
local shiftlockk = Instance.new("ScreenGui")
local LockButton = Instance.new("ImageButton")
local btnIcon = Instance.new("ImageLabel")

shiftlockk.Name = "shiftlockk"
shiftlockk.Parent = game.CoreGui
shiftlockk.ResetOnSpawn = false

LockButton.Name = "LockButton"
LockButton.Parent = shiftlockk
LockButton.AnchorPoint = Vector2.new(1, 1)
LockButton.Position = UDim2.new(1, -50, 1, -50)
LockButton.Size = UDim2.new(0, 60, 0, 60)
LockButton.Image = "rbxassetid://530406505"
LockButton.ImageColor3 = Color3.fromRGB(0, 133, 199)

btnIcon.Name = "btnIcon"
btnIcon.Parent = LockButton
btnIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
btnIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
btnIcon.Image = "rbxasset://textures/ui/mouseLock_off.png"

local function EnableShiftLock()
    local gameSettings = settings():GetService("UserGameSettings")
    local previousRotation = gameSettings.RotationType
    local connection = nil

    -- Initially enable shift lock
    connection = RunService.RenderStepped:Connect(function()
        pcall(function()
            gameSettings.RotationType = Enum.RotationType.CameraRelative
        end)
    end)

    LockButton.MouseButton1Click:Connect(function()
        if connection then
            connection:Disconnect()
            connection = nil
            gameSettings.RotationType = previousRotation
            print("Shift Lock disabled")
        else
            connection = RunService.RenderStepped:Connect(function()
                pcall(function()
                    gameSettings.RotationType = Enum.RotationType.CameraRelative
                end)
            end)
            print("Shift Lock enabled")
        end
    end)
end
EnableShiftLock()

-----------------------------------------------------
-- UTILITY FUNCTIONS (for target finding & rotation)
-----------------------------------------------------
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localHRP then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - localHRP.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

local function rotateCharacterTowardsTarget(targetPosition)
    local character = LocalPlayer.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local direction = (targetPosition - hrp.Position).Unit
    local newCFrame = CFrame.fromMatrix(hrp.Position, direction, Vector3.new(0, 1, 0))
    local tween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = newCFrame})
    tween:Play()
end

-----------------------------------------------------
-- FEATURE VARIABLES & BOMB DISTANCE SETTING
-----------------------------------------------------
local bombPassDistance = 10  -- Default bomb pass distance (studs)
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local autoPassConnection = nil

-- Modified autoPassBomb: Only pass bomb if closest player is within bombPassDistance.
local function autoPassBomb()
    if not AutoPassEnabled then return end
    pcall(function()
        local Bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
        if Bomb then
            local BombEvent = Bomb:FindFirstChild("RemoteEvent")
            local closestPlayer = getClosestPlayer()
            if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                local distance = (targetPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance <= bombPassDistance then
                    rotateCharacterTowardsTarget(targetPosition)
                    BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                end
            end
        end
    end)
end

-- Anti Slippery: Change physical properties of character parts.
local function applyAntiSlippery(enable)
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if enable then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                else
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0, 0)
                end
            end
        end
    end
end

-- Remove Hitbox: Hide hitbox parts.
local function applyRemoveHitbox(enable)
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Hitbox" then
                if enable then
                    part.Transparency = 1
                    part.CanCollide = false
                else
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
        end
    end
end

-----------------------------------------------------
-- ORION LIBRARY SETUP (Load from GitHub)
-----------------------------------------------------
local OrionLibSource = "https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"
local success, OrionLibLoaded = pcall(function() return loadstring(game:HttpGet(OrionLibSource))() end)
if not success or not OrionLibLoaded then
    error("Failed to load OrionLib! Check HTTP permissions and the remote file.")
end
print("OrionLibLoaded =", OrionLibLoaded)

-- For testing, set IntroEnabled = false so that the window appears immediately.
local Window = OrionLibLoaded:MakeWindow({ 
    Name = "Yon Menu - Advanced", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "YonMenu_Advanced", 
    IntroEnabled = false  -- immediate display for testing
})
print("Window created. Check CoreGui for the Orion GUI.")

print("Is LocalPlayer premium? " .. tostring(IsPremium(LocalPlayer)))

-----------------------------------------------------
-- UI: AUTOMATED TAB (For Premium Users)
-----------------------------------------------------
if IsPremium(LocalPlayer) then
    local AutomatedTab = Window:MakeTab({
        Name = "Automated",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = true
    })

    AutomatedTab:AddToggle({
        Name = "Anti Slippery",
        Default = false,
        Callback = function(value)
            AntiSlipperyEnabled = value
            applyAntiSlippery(value)
        end
    })

    AutomatedTab:AddToggle({
        Name = "Remove Hitbox",
        Default = false,
        Callback = function(value)
            RemoveHitboxEnabled = value
            applyRemoveHitbox(value)
        end
    })

    AutomatedTab:AddToggle({
        Name = "Auto Pass Bomb",
        Default = false,
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

    -- Bomb Distance Slider: Adjust bomb pass reach (5-20 studs)
    AutomatedTab:AddSlider({
        Name = "Bomb Distance",
        Min = 5,
        Max = 20,
        Default = bombPassDistance,
        Increment = 1,
        ValueName = " studs",
        Callback = function(Value)
            bombPassDistance = Value
        end
    })
else
    Window:MakeTab({
        Name = "Premium Locked",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    }):AddLabel("⚠️ This feature requires Premium.")
end

-----------------------------------------------------
-- INITIALIZE UI & NOTIFICATIONS
-----------------------------------------------------
---------------------------------------
-- BUILT-IN CONSOLE FUNCTIONS
-- These functions allow you to display a console on the client.
-----------------------------------------------------
function OrionLibLoaded:MakeConsole()
    -- Create a new ScreenGui for the console
    local consoleGui = Instance.new("ScreenGui")
    consoleGui.Name = "OrionConsole"
    if syn then
        syn.protect_gui(consoleGui)
        consoleGui.Parent = game:GetService("CoreGui")
    else
        consoleGui.Parent = game:GetService("CoreGui")
    end

    local consoleFrame = Instance.new("Frame")
    consoleFrame.Name = "ConsoleFrame"
    consoleFrame.Size = UDim2.new(0, 400, 0, 300)
    consoleFrame.Position = UDim2.new(0.5, -200, 1, 0) -- start off-screen at the bottom
    consoleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    consoleFrame.BorderSizePixel = 0
    consoleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    consoleFrame.Parent = consoleGui

    local titleBar = Instance.new("Frame", consoleFrame)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.Text = "Orion Console"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.FredokaOne
    titleLabel.TextSize = 18

    local closeButton = Instance.new("TextButton", titleBar)
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.BackgroundTransparency = 1
    closeButton.Font = Enum.Font.FredokaOne
    closeButton.TextSize = 18

    local outputFrame = Instance.new("ScrollingFrame", consoleFrame)
    outputFrame.Name = "OutputFrame"
    outputFrame.Size = UDim2.new(1, -10, 1, -70)
    outputFrame.Position = UDim2.new(0, 5, 0, 35)
    outputFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    outputFrame.BorderSizePixel = 0
    outputFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    outputFrame.ScrollBarThickness = 5

    local listLayout = Instance.new("UIListLayout", outputFrame)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)

    local inputBox = Instance.new("TextBox", consoleFrame)
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -10, 0, 30)
    inputBox.Position = UDim2.new(0, 5, 1, -35)
    inputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    inputBox.TextColor3 = Color3.new(1, 1, 1)
    inputBox.ClearTextOnFocus = false
    inputBox.PlaceholderText = "Enter command..."
    inputBox.Font = Enum.Font.FredokaOne
    inputBox.TextSize = 16

    local appearTween = TweenService:Create(consoleFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Position = UDim2.new(0.5, 0, 0.5, 0)})
    appearTween:Play()

    closeButton.MouseButton1Click:Connect(function()
        local disappearTween = TweenService:Create(consoleFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
            {Position = UDim2.new(0.5, 0, 1.5, 0)})
        disappearTween:Play()
        disappearTween.Completed:Connect(function()
            consoleGui:Destroy()
            self.ConsoleOpen = false
        end)
    end)

    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local command = inputBox.Text
            inputBox.Text = ""
            local logLine = Instance.new("TextLabel", outputFrame)
            logLine.Size = UDim2.new(1, 0, 0, 20)
            logLine.BackgroundTransparency = 1
            logLine.TextColor3 = Color3.new(1, 1, 1)
            logLine.Font = Enum.Font.FredokaOne
            logLine.TextSize = 16
            logLine.Text = "> " .. command
            logLine.LayoutOrder = #outputFrame:GetChildren() + 1

            outputFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)

            local success, result = pcall(function() return loadstring(command)() end)
            local resultLine = Instance.new("TextLabel", outputFrame)
            resultLine.Size = UDim2.new(1, 0, 0, 20)
            resultLine.BackgroundTransparency = 1
            resultLine.TextColor3 = success and Color3.new(0.5, 1, 0.5) or Color3.new(1, 0.5, 0.5)
            resultLine.Font = Enum.Font.FredokaOne
            resultLine.TextSize = 16
            resultLine.Text = success and tostring(result) or "Error: " .. tostring(result)
            resultLine.LayoutOrder = #outputFrame:GetChildren() + 1

            outputFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
        end
    end)

    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = consoleFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            consoleFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    self.ConsoleGUI = consoleGui
    self.ConsoleOpen = true
end

function OrionLibLoaded:ToggleConsole()
    if self.ConsoleOpen and self.ConsoleGUI then
        self.ConsoleGUI:Destroy()
        self.ConsoleOpen = false
    else
        self:MakeConsole()
    end
end

-----------------------------------------------------
-- OPTIONAL: Keybind to Toggle Console (Press F9)
-----------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F9 then
        OrionLibLoaded:ToggleConsole()
    end
end)
OrionLibLoaded:Init()
OrionLibLoaded:MakeNotification({
    Name = "Yon Menu",
    Content = "Yon Menu Script Loaded with Shift Lock & Premium Features 🚀",
    Time = 5
})
print("Yon Menu Script Loaded with Shift Lock & Premium Features 🚀")

--------------
