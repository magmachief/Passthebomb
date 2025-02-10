--[[ 
    Full Custom UI Script with Integrated Console Tab

    This script creates a custom UI with a Sidebar and a TabContainer.
    It includes three tabs: Home, Settings, and Console.
    The Console tab is loaded by a modified console module that creates a Frame
    so it can be parented to TabContainer.

    No sugar-coating: this is lean and forward‑thinking. Modify as needed.
]]--

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-----------------------------
-- Main UI Setup
-----------------------------
local UI = Instance.new("ScreenGui")
UI.Name = "CustomUI"
UI.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = UI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Text = "Custom UI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    DragToggle.Visible = true
end)

-- Sidebar (Navigation)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

-- Tab Container (Content)
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -120, 1, -40)
TabContainer.Position = UDim2.new(0, 120, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabContainer.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 10)
TabCorner.Parent = TabContainer

-----------------------------
-- Tab Creation Function
-----------------------------
local function CreateTab(name, callback)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, 0, 0, 40)
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Parent = Sidebar

    TabButton.MouseButton1Click:Connect(callback)
end

-----------------------------
-- Home & Settings Tabs
-----------------------------
CreateTab("Home", function()
    -- Clear TabContainer
    for _, child in ipairs(TabContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local homeLabel = Instance.new("TextLabel")
    homeLabel.Size = UDim2.new(1, 0, 1, 0)
    homeLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    homeLabel.Text = "Welcome Home"
    homeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    homeLabel.Font = Enum.Font.GothamBold
    homeLabel.Parent = TabContainer
end)

CreateTab("Settings", function()
    -- Clear TabContainer
    for _, child in ipairs(TabContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local settingsLabel = Instance.new("TextLabel")
    settingsLabel.Size = UDim2.new(1, 0, 1, 0)
    settingsLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    settingsLabel.Text = "Settings Tab"
    settingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsLabel.Font = Enum.Font.GothamBold
    settingsLabel.Parent = TabContainer
end)

-----------------------------
-- Console Module (Modified)
-----------------------------
local output = {}

-- This function now accepts a config and parent (the TabContainer) and creates a Frame
function output:load(config, parent)
    if parent:FindFirstChild("Output") then
        parent.Output:Destroy()
    end

    local G2L = {}
    G2L["1"] = Instance.new("Frame")
    G2L["1"].Name = "Output"
    G2L["1"].Size = config.Size
    G2L["1"].BackgroundColor3 = Color3.fromRGB(47, 47, 47)
    G2L["1"].Parent = parent

    local UICorner1 = Instance.new("UICorner", G2L["1"])
    UICorner1.CornerRadius = UDim.new(0, 3)

    -- Topbar
    G2L["topbar"] = Instance.new("Frame", G2L["1"])
    G2L["topbar"].Size = UDim2.new(1, 0, 0, 27)
    G2L["topbar"].BackgroundColor3 = Color3.fromRGB(54, 54, 54)
    G2L["topbar"].Name = "topbar"
    local topbarCorner = Instance.new("UICorner", G2L["topbar"])
    topbarCorner.CornerRadius = UDim.new(0, 4)
    local topbarLabel = Instance.new("TextLabel", G2L["topbar"])
    topbarLabel.Size = UDim2.new(1, 0, 1, 0)
    topbarLabel.BackgroundTransparency = 1
    topbarLabel.Text = "Output v1.2"
    topbarLabel.TextColor3 = Color3.fromRGB(161, 161, 161)
    topbarLabel.Font = Enum.Font.GothamBold
    topbarLabel.TextSize = 14

    -- Close button for console (optional)
    G2L["closeBtn"] = Instance.new("TextButton", G2L["topbar"])
    G2L["closeBtn"].Size = UDim2.new(0, 27, 0, 27)
    G2L["closeBtn"].Position = UDim2.new(1, -29, 0, 0)
    G2L["closeBtn"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    G2L["closeBtn"].BackgroundTransparency = 1
    G2L["closeBtn"].Text = "X"
    G2L["closeBtn"].TextColor3 = Color3.fromRGB(255, 255, 255)
    G2L["closeBtn"].Font = Enum.Font.GothamBold
    G2L["closeBtn"].MouseButton1Click:Connect(function()
        G2L["1"]:Destroy()
    end)

    -- Optionsbar (Clear and Filter)
    G2L["optionsbar"] = Instance.new("Frame", G2L["1"])
    G2L["optionsbar"].Size = UDim2.new(1, 0, 0, 27)
    G2L["optionsbar"].Position = UDim2.new(0, 0, 0, 25)
    G2L["optionsbar"].BackgroundColor3 = Color3.fromRGB(47, 47, 47)
    G2L["optionsbar"].BackgroundTransparency = 0.6
    G2L["optionsbar"].Name = "optionsbar"
    local optionsbarStroke = Instance.new("UIStroke", G2L["optionsbar"])
    optionsbarStroke.Color = Color3.fromRGB(31, 31, 31)

    local clearBtn = Instance.new("TextButton", G2L["optionsbar"])
    clearBtn.Size = UDim2.new(0, 27, 0, 27)
    clearBtn.Position = UDim2.new(1, -29, 0, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.BackgroundTransparency = 1
    clearBtn.Text = "C"
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.Font = Enum.Font.GothamBold

    local filterFrame = Instance.new("Frame", G2L["optionsbar"])
    filterFrame.Name = "Filter"
    filterFrame.Size = UDim2.new(1, 0, 1, 0)
    filterFrame.BackgroundTransparency = 1
    local filterBox = Instance.new("TextBox", filterFrame)
    filterBox.Name = "Box"
    filterBox.Size = UDim2.new(0.98, 0, 1, 0)
    filterBox.BackgroundTransparency = 1
    filterBox.PlaceholderText = "Filter..."
    filterBox.Text = ""
    filterBox.TextColor3 = Color3.fromRGB(191, 191, 191)
    filterBox.Font = Enum.Font.GothamBold
    filterBox.TextSize = 13

    -- Console Display Area
    G2L["ConsoleArea"] = Instance.new("ScrollingFrame", G2L["1"])
    G2L["ConsoleArea"].Name = "Console"
    G2L["ConsoleArea"].Size = UDim2.new(1, 0, 0, 155)
    G2L["ConsoleArea"].Position = UDim2.new(0, 0, 0, 51)
    G2L["ConsoleArea"].CanvasSize = UDim2.new(0, 0, 0, 0)
    G2L["ConsoleArea"].ScrollBarThickness = 7
    G2L["ConsoleArea"].ScrollBarImageColor3 = Color3.fromRGB(71, 71, 71)
    G2L["ConsoleArea"].BackgroundTransparency = 1
    local consoleLayout = Instance.new("UIListLayout", G2L["ConsoleArea"])
    consoleLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Command Bar
    G2L["cmdr"] = Instance.new("Frame", G2L["1"])
    G2L["cmdr"].Name = "cmdr"
    G2L["cmdr"].Size = UDim2.new(1, 0, 0, 27)
    G2L["cmdr"].Position = UDim2.new(0, 0, 0, 217)
    G2L["cmdr"].BackgroundColor3 = Color3.fromRGB(31, 31, 31)
    local cmdrStroke = Instance.new("UIStroke", G2L["cmdr"])
    cmdrStroke.Color = Color3.fromRGB(31, 31, 31)
    local cmdrFrame = Instance.new("Frame", G2L["cmdr"])
    cmdrFrame.Name = "cmd"
    cmdrFrame.Size = UDim2.new(1, 0, 0.73, 0)
    cmdrFrame.BackgroundTransparency = 1
    local cmdrBox = Instance.new("TextBox", cmdrFrame)
    cmdrBox.Name = "Box"
    cmdrBox.Size = UDim2.new(0.98, 0, 1, 0)
    cmdrBox.BackgroundTransparency = 1
    cmdrBox.PlaceholderText = "Run a command"
    cmdrBox.Text = ""
    cmdrBox.TextColor3 = Color3.fromRGB(191, 191, 191)
    cmdrBox.Font = Enum.Font.GothamBold
    cmdrBox.TextSize = 13

    -- Simulated logging (using LogService)
    local latest = {name = "", output = "", count = 1}
    local colors = {
        [Enum.MessageType.MessageOutput] = Color3.new(1, 1, 1),
        [Enum.MessageType.MessageInfo] = Color3.fromRGB(0, 162, 255),
        [Enum.MessageType.MessageWarning] = Color3.fromRGB(255, 255, 0),
        [Enum.MessageType.MessageError] = Color3.fromRGB(255, 0, 0)
    }
    game:GetService("LogService").MessageOut:Connect(function(outputText, messageType)
        if outputText == latest.output then
            latest.count = latest.count + 1
            local existingMessage = G2L["ConsoleArea"]:FindFirstChild(tostring(latest.name))
            if existingMessage then
                existingMessage.Content.Text = outputText .. " (x" .. latest.count .. ")"
            end
        else
            latest.count = 1
            local newLine = Instance.new("Frame")
            newLine.Name = tostring(tick())
            newLine.Size = UDim2.new(1, 0, 0, 20)
            newLine.BackgroundTransparency = 1
            newLine.Parent = G2L["ConsoleArea"]
            
            local content = Instance.new("TextLabel", newLine)
            content.Name = "Content"
            content.Size = UDim2.new(1, 0, 1, 0)
            content.BackgroundTransparency = 1
            content.Text = outputText
            content.TextColor3 = colors[messageType] or Color3.new(1, 1, 1)
            content.Font = Enum.Font.GothamBold
            content.TextSize = 14
            content.TextXAlignment = Enum.TextXAlignment.Left
            
            local timestamp = Instance.new("TextLabel", newLine)
            timestamp.Name = "Timestamp"
            timestamp.Size = UDim2.new(0, 50, 1, 0)
            timestamp.Position = UDim2.new(1, -50, 0, 0)
            timestamp.BackgroundTransparency = 1
            timestamp.Text = os.date("%H:%M:%S", os.time())
            timestamp.TextColor3 = Color3.fromRGB(121, 121, 121)
            timestamp.Font = Enum.Font.GothamBold
            timestamp.TextSize = 14
            
            latest.name = newLine.Name
            latest.output = outputText
        end
        wait(0.1)
    end)
    
    -- Clear Console on button click
    clearBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(G2L["ConsoleArea"]:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        G2L["ConsoleArea"].CanvasPosition = Vector2.new(0, 0)
    end)
    
    -- Command execution (placeholder – replace with your own logic)
    local function executeCommand(code)
        print("Command executed: " .. code)
    end
    cmdrBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local code = cmdrBox.Text
            print(">", code)
            executeCommand(code)
            cmdrBox.Text = ""
        end
    end)
    
    return G2L["1"]
end

-----------------------------
-- Console Tab
-----------------------------
CreateTab("Console", function()
    -- Clear TabContainer first
    for _, child in ipairs(TabContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    -- Load the console UI into TabContainer
    local consoleUI = output:load({Size = TabContainer.Size}, TabContainer)
end)

-----------------------------
-- Feature Toggles & Functions
-----------------------------
local function rotateCharacterTowardsTarget(targetPosition)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    local direction = (targetPosition - humanoidRootPart.Position).Unit
    local newCFrame = CFrame.fromMatrix(humanoidRootPart.Position, direction, Vector3.new(0, 1, 0))
    local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = newCFrame})
    tween:Play()
end

local function CreateToggle(name, callback)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 120, 0, 40)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    ToggleButton.Text = name
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = TabContainer

    ToggleButton.MouseButton1Click:Connect(function()
        local active = ToggleButton.BackgroundColor3 == Color3.fromRGB(50, 200, 50)
        ToggleButton.BackgroundColor3 = active and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 200, 50)
        callback(not active)
    end)
end

local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false

CreateToggle("Auto Pass Bomb", function(state)
    AutoPassEnabled = state
    if state then
        RunService.RenderStepped:Connect(function()
            if AutoPassEnabled then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Bomb") then
                        local passTarget = Players:GetPlayers()[math.random(1, #Players:GetPlayers())]
                        if passTarget and passTarget.Character then
                            rotateCharacterTowardsTarget(passTarget.Character.HumanoidRootPart.Position)
                            player.Character.Bomb.CFrame = passTarget.Character.HumanoidRootPart.CFrame
                        end
                    end
                end
            end
        end)
    end
end)

CreateToggle("Anti Slippery", function(state)
    AntiSlipperyEnabled = state
    if state then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, 0.5)
            end
        end
    else
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new()
            end
        end
    end
end)

CreateToggle("Remove Hitbox", function(state)
    RemoveHitboxEnabled = state
    if state then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Hitbox" then
                part.Transparency = 1
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name == "Hitbox" then
                part.Transparency = 0
                part.CanCollide = true
            end
        end
    end
end)

-----------------------------
-- Notifications & UI Toggle
-----------------------------
local function ShowNotification(message)
    local Notification = Instance.new("TextLabel")
    Notification.Size = UDim2.new(0, 300, 0, 50)
    Notification.Position = UDim2.new(0.5, -150, 0, -60)
    Notification.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Notification.Text = message
    Notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    Notification.Font = Enum.Font.GothamBold
    Notification.Parent = UI

    TweenService:Create(Notification, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -150, 0, 20)}):Play()
    wait(2)
    TweenService:Create(Notification, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -150, 0, -60)}):Play()
    wait(0.5)
    Notification:Destroy()
end

local function ToggleUI()
    MainFrame.Visible = not MainFrame.Visible
    DragToggle.Visible = not MainFrame.Visible
end

-- Draggable Toggle Button
local DragToggle = Instance.new("TextButton")
DragToggle.Size = UDim2.new(0, 40, 0, 40)
DragToggle.Position = UDim2.new(0, 10, 0, 10)
DragToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
DragToggle.Text = "≡"
DragToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
DragToggle.Font = Enum.Font.GothamBold
DragToggle.Parent = UI

local DragToggleCorner = Instance.new("UICorner")
DragToggleCorner.CornerRadius = UDim.new(0, 10)
DragToggleCorner.Parent = DragToggle

local draggingToggle = false
local dragInputToggle, dragStartToggle, startPosToggle

local function updateToggle(input)
    local delta = input.Position - dragStartToggle
    DragToggle.Position = UDim2.new(0, startPosToggle.X.Offset + delta.X, 0, startPosToggle.Y.Offset + delta.Y)
end

DragToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingToggle = true
        dragStartToggle = input.Position
        startPosToggle = DragToggle.Position
    end
end)

DragToggle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInputToggle = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInputToggle and draggingToggle then
        updateToggle(input)
    end
end)

DragToggle.MouseButton1Click:Connect(ToggleUI)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F2 then
        ToggleUI()
    end
end)

ShowNotification("Welcome to Custom UI!")
print("Custom UI Loaded Successfully")
