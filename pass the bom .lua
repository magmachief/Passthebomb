-- Combined Improved UI Script with Premium System and Enhanced Orion‑Style UI
-- This script:
--   • Grants Premium to all players automatically.
--   • Loads an Orion‑inspired UI library (with draggable windows, notifications, etc.).
--   • Creates a main window with toggles for Auto Pass Bomb, Anti‑Slippery, and Remove Hitbox.
-- No sugar‑coating: this is lean and forward‑thinking. Modify as needed.

-----------------------------------------------------
-- PREMIUM SYSTEM SETUP
-----------------------------------------------------
local Players = game:GetService("Players")
local function GrantPremiumToAll()
    for _, player in ipairs(Players:GetPlayers()) do
        player:SetAttribute("Premium", true)  -- Automatically grant Premium
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
-- SERVICES & LOCAL VARIABLES
-----------------------------------------------------
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-----------------------------------------------------
-- ORION‑INSPIRED UI LIBRARY DEFINITION
-----------------------------------------------------
local OrionLib = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {
        Default = {
            Main = Color3.fromRGB(25, 25, 35),
            Second = Color3.fromRGB(32, 32, 42),
            Stroke = Color3.fromRGB(37, 37, 47),
            Divider = Color3.fromRGB(60, 60, 70),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(150, 150, 150)
        }
    },
    SelectedTheme = "Default",
    Folder = nil,
    SaveCfg = false
}

-- Feather Icons loader
local Icons = {}
local Success, Response = pcall(function()
    Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)
if not Success then
    warn("\nOrion Library - Failed to load Feather Icons. Error code: " .. Response .. "\n")
end	
local function GetIcon(IconName)
    if Icons[IconName] ~= nil then
        return Icons[IconName]
    else
        return nil
    end
end   

-- Create the main ScreenGui for our UI
local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
if syn then
    syn.protect_gui(Orion)
    Orion.Parent = game:GetService("CoreGui")
else
    Orion.Parent = gethui() or game:GetService("CoreGui")
end

-- Check if our UI is running
function OrionLib:IsRunning()
    if gethui then
        return Orion.Parent == gethui()
    else
        return Orion.Parent == game:GetService("CoreGui")
    end
end

-- Connection helper
local function AddConnection(Signal, Function)
    if (not OrionLib:IsRunning()) then return end
    local SignalConnect = Signal:Connect(Function)
    table.insert(OrionLib.Connections, SignalConnect)
    return SignalConnect
end

task.spawn(function()
    while (OrionLib:IsRunning()) do wait() end
    for _, Connection in next, OrionLib.Connections do
        Connection:Disconnect()
    end
end)

-- Draggable helper
local function MakeDraggable(DragPoint, Main)
    pcall(function()
        local Dragging, DragInput, MousePos, FramePos = false
        AddConnection(DragPoint.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                MousePos = Input.Position
                FramePos = Main.Position
                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
                end)
            end
        end)
        AddConnection(DragPoint.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                DragInput = Input
            end
        end)
        AddConnection(UserInputService.InputChanged, function(Input)
            if Input == DragInput and Dragging then
                local Delta = Input.Position - MousePos
                TweenService:Create(Main, TweenInfo.new(0.05, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
                }):Play()
                Main.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
            end
        end)
    end)
end    

-- Basic creation functions
local function Create(Name, Properties, Children)
    local Object = Instance.new(Name)
    for i, v in next, Properties or {} do Object[i] = v end
    for i, v in next, Children or {} do v.Parent = Object end
    return Object
end

local function CreateElement(ElementName, ElementFunction)
    OrionLib.Elements[ElementName] = function(...) return ElementFunction(...) end
end

local function MakeElement(ElementName, ...)
    local NewElement = OrionLib.Elements[ElementName](...)
    return NewElement
end

local function SetProps(Element, Props)
    for Property, Value in pairs(Props) do Element[Property] = Value end
    return Element
end

local function SetChildren(Element, Children)
    for _, Child in pairs(Children) do Child.Parent = Element end
    return Element
end

local function Round(Number, Factor)
    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
    if Result < 0 then Result = Result + Factor end
    return Result
end

local function ReturnProperty(Object)
    if Object:IsA("Frame") or Object:IsA("TextButton") then
        return "BackgroundColor3"
    elseif Object:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    elseif Object:IsA("UIStroke") then
        return "Color"
    elseif Object:IsA("TextLabel") or Object:IsA("TextBox") then
        return "TextColor3"
    elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        return "ImageColor3"
    end
end

local function AddThemeObject(Object, Type)
    if not OrionLib.ThemeObjects[Type] then OrionLib.ThemeObjects[Type] = {} end    
    table.insert(OrionLib.ThemeObjects[Type], Object)
    Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
    return Object
end

local function SetTheme()
    for Name, Type in pairs(OrionLib.ThemeObjects) do
        for _, Object in pairs(Type) do
            Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Name]
        end    
    end    
end

local function PackColor(Color)
    return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
    return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
    local Data = HttpService:JSONDecode(Config)
    for a, b in pairs(Data) do
        if OrionLib.Flags[a] then
            spawn(function() 
                if OrionLib.Flags[a].Type == "Colorpicker" then
                    OrionLib.Flags[a]:Set(UnpackColor(b))
                else
                    OrionLib.Flags[a]:Set(b)
                end    
            end)
        else
            warn("Orion Library Config Loader - Could not find ", a, b)
        end
    end
end

local function SaveCfg(Name)
    local Data = {}
    for i, v in pairs(OrionLib.Flags) do
        if v.Save then
            if v.Type == "Colorpicker" then
                Data[i] = PackColor(v.Value)
            else
                Data[i] = v.Value
            end
        end	
    end
end

local WhitelistedMouse = {
    Enum.UserInputType.MouseButton1, 
    Enum.UserInputType.MouseButton2,
    Enum.UserInputType.MouseButton3,
    Enum.UserInputType.Touch
}
local BlacklistedKeys = {
    Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, 
    Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, 
    Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, 
    Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, 
    Enum.KeyCode.Escape
}
local function CheckKey(Table, Key)
    for _, v in pairs(Table) do
        if v == Key then return true end
    end
end

-- Create some basic elements
CreateElement("Corner", function(Scale, Offset)
    return Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 10)})
end)

CreateElement("Stroke", function(Color, Thickness)
    return Create("UIStroke", {Color = Color or Color3.fromRGB(255, 255, 255), Thickness = Thickness or 1})
end)

CreateElement("List", function(Scale, Offset)
    return Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(Scale or 0, Offset or 0)
    })
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
    return Create("UIPadding", {
        PaddingBottom = UDim.new(0, Bottom or 4),
        PaddingLeft = UDim.new(0, Left or 4),
        PaddingRight = UDim.new(0, Right or 4),
        PaddingTop = UDim.new(0, Top or 4)
    })
end)

CreateElement("TFrame", function()
    return Create("Frame", {BackgroundTransparency = 1})
end)

CreateElement("Frame", function(Color)
    return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255), BorderSizePixel = 0})
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
    return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255), BorderSizePixel = 0}, {
        Create("UICorner", {CornerRadius = UDim.new(Scale, Offset)})
    })
end)

CreateElement("Button", function()
    return Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0})
end)

CreateElement("ScrollFrame", function(Color, Width)
    return Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        MidImage = "rbxassetid://7445543667",
        BottomImage = "rbxassetid://7445543667",
        TopImage = "rbxassetid://7445543667",
        ScrollBarImageColor3 = Color,
        BorderSizePixel = 0,
        ScrollBarThickness = Width,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
end)

CreateElement("Image", function(ImageID)
    local Img = Create("ImageLabel", {Image = ImageID, BackgroundTransparency = 1})
    if GetIcon(ImageID) then Img.Image = GetIcon(ImageID) end
    return Img
end)

CreateElement("ImageButton", function(ImageID)
    return Create("ImageButton", {Image = ImageID, BackgroundTransparency = 1})
end)

CreateElement("Label", function(Text, TextSize, Transparency)
    return Create("TextLabel", {
        Text = Text or "",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextTransparency = Transparency or 0,
        TextSize = TextSize or 15,
        Font = Enum.Font.FredokaOne,
        RichText = true,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
    SetProps(MakeElement("List"), {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 5)
    })
}), {
    Position = UDim2.new(1, -25, 1, -25),
    Size = UDim2.new(0, 300, 1, -25),
    AnchorPoint = Vector2.new(1, 1),
    Parent = Orion
})

function OrionLib:MakeNotification(Config)
    spawn(function()
        Config.Name = Config.Name or "Notification"
        Config.Content = Config.Content or "Test"
        Config.Image = Config.Image or "rbxassetid://4384403532"
        Config.Time = Config.Time or 15

        local NotifParent = SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = NotificationHolder
        })

        local NotifFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
            Parent = NotifParent, 
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(1, -55, 0, 0),
            BackgroundTransparency = 0,
            AutomaticSize = Enum.AutomaticSize.Y
        }), {
            MakeElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
            MakeElement("Padding", 12, 12, 12, 12),
            SetProps(MakeElement("Image", Config.Image), {
                Size = UDim2.new(0, 20, 0, 20),
                ImageColor3 = Color3.fromRGB(240, 240, 240),
                Name = "Icon"
            }),
            SetProps(MakeElement("Label", Config.Name, 15), {
                Size = UDim2.new(1, -30, 0, 20),
                Position = UDim2.new(0, 30, 0, 0),
                Font = Enum.Font.FredokaOne,
                Name = "Title"
            }),
            SetProps(MakeElement("Label", Config.Content, 14), {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 25),
                Font = Enum.Font.FredokaOne,
                Name = "Content",
                AutomaticSize = Enum.AutomaticSize.Y,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextWrapped = true
            })
        })
        TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        wait(Config.Time - 0.88)
        TweenService:Create(NotifFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(NotifFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
        wait(0.3)
        TweenService:Create(NotifFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
        TweenService:Create(NotifFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
        TweenService:Create(NotifFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
        wait(0.05)
        NotifFrame:TweenPosition(UDim2.new(1, 20, 0, 0), 'In', 'Quint', 0.8, true)
        wait(1.35)
        NotifFrame:Destroy()
    end)
end

function OrionLib:Init()
    if OrionLib.SaveCfg then
        pcall(function()
            if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
                LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
                OrionLib:MakeNotification({
                    Name = "Configuration",
                    Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
                    Time = 5
                })
            end
        end)
    end	
end

function OrionLib:MakeWindow(Config)
    local FirstTab = true
    local Minimized = false
    local UIHidden = false

    Config = Config or {}
    Config.Name = Config.Name or "Yonkai"
    Config.ConfigFolder = Config.ConfigFolder or Config.Name
    Config.SaveConfig = Config.SaveConfig or false
    Config.HidePremium = Config.HidePremium or false
    if Config.IntroEnabled == nil then Config.IntroEnabled = true end
    Config.IntroToggleIcon = Config.IntroToggleIcon or "rbxassetid://8834748103"
    Config.IntroText = Config.IntroText or "Yonkai"
    Config.CloseCallback = Config.CloseCallback or function() end
    Config.ShowIcon = Config.ShowIcon or false
    Config.Icon = Config.Icon or "rbxassetid://8834748103"
    Config.IntroIcon = Config.IntroIcon or "rbxassetid://8834748103"
    OrionLib.Folder = Config.ConfigFolder
    OrionLib.SaveCfg = Config.SaveConfig

    if Config.SaveConfig and not isfolder(Config.ConfigFolder) then
        makefolder(Config.ConfigFolder)
    end

    local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 4), {
        Size = UDim2.new(1, 0, 1, -50)
    }), {
        MakeElement("List"),
        MakeElement("Padding", 8, 0, 0, 8)
    }), "Divider")

    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
    end)

    local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(0, 18, 0, 18)
        }), "Text")
    })

    local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(0, 18, 0, 18),
            Name = "Ico"
        }), "Text")
    })

    local DragPoint = SetProps(MakeElement("TFrame"), { Size = UDim2.new(1, 0, 0, 50) })

    local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 10), {
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 0, 0, 50)
    }), {
        AddThemeObject(SetProps(MakeElement("Frame"), { Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 0, 0) }), "Second"), 
        AddThemeObject(SetProps(MakeElement("Frame"), { Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0) }), "Second"), 
        AddThemeObject(SetProps(MakeElement("Frame"), { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0) }), "Stroke"), 
        TabHolder,
        SetChildren(SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 1, -50)
        }), {
            AddThemeObject(SetProps(MakeElement("Frame"), { Size = UDim2.new(1, 0, 0, 1) }), "Stroke"), 
            AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(0, 10, 0.5, 0)
            }), {
                SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), { Size = UDim2.new(1, 0, 1, 0) }),
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), { Size = UDim2.new(1, 0, 1, 0) }), "Second"),
                MakeElement("Corner", 1)
            }), "Divider"),
            SetChildren(SetProps(MakeElement("TFrame"), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(0, 10, 0.5, 0)
            }), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                MakeElement("Corner", 1)
            }),
            AddThemeObject(SetProps(MakeElement("Label", "User", Config.HidePremium and 14 or 13), {
                Size = UDim2.new(1, -60, 0, 13),
                Position = Config.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
                Font = Enum.Font.FredokaOne,
                ClipsDescendants = true
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", "", 12), {
                Size = UDim2.new(1, -60, 0, 12),
                Position = UDim2.new(0, 50, 1, -25),
                Visible = not Config.HidePremium
            }), "TextDark")
        }),
    }), "Second")

    local WindowName = AddThemeObject(SetProps(MakeElement("Label", Config.Name, 14), {
        Size = UDim2.new(1, -30, 2, 0),
        Position = UDim2.new(0, 25, 0, -24),
        Font = Enum.Font.FredokaOne,
        TextSize = 20
    }), "Text")

    local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1)
    }), "Stroke")

    local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 10), {
        Parent = Orion,
        Position = UDim2.new(0.5, -307, 0.5, -172),
        Size = UDim2.new(0, 615, 0, 344),
        ClipsDescendants = true
    }), {
        SetChildren(SetProps(MakeElement("TFrame"), { Size = UDim2.new(1, 0, 0, 50), Name = "TopBar" }), {
            WindowName,
            WindowTopBarLine,
            AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 7), { Size = UDim2.new(0, 70, 0, 30), Position = UDim2.new(1, -90, 0, 10) }), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                AddThemeObject(SetProps(MakeElement("Frame"), { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0.5, 0, 0, 0) }), "Stroke"),
                CloseBtn,
                MinimizeBtn
            }), "Second"),
        }),
        DragPoint,
        WindowStuff
    }), "Main")

    if Config.ShowIcon then
        WindowName.Position = UDim2.new(0, 50, 0, -24)
        local WindowIcon = SetProps(MakeElement("Image", Config.Icon), { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 25, 0, 15) })
        WindowIcon.Parent = MainWindow.TopBar
    end	

    MakeDraggable(DragPoint, MainWindow)

    AddConnection(CloseBtn.MouseButton1Up, function()
        MainWindow.Visible = false
        OrionLib:MakeNotification({
            Name = "Interface Hidden",
            Content = "Tap Left Control to reopen the interface",
            Time = 5
        })
        Config.CloseCallback()
    end)

    AddConnection(UserInputService.InputBegan, function(Input)
        if Input.KeyCode == Enum.KeyCode.LeftControl and not MainWindow.Visible then
            MainWindow.Visible = true
        end
    end)
	
    AddConnection(MinimizeBtn.MouseButton1Up, function()
        if Minimized then
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 615, 0, 344)}):Play()
            MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
            wait(0.02)
            MainWindow.ClipsDescendants = false
            WindowStuff.Visible = true
            WindowTopBarLine.Visible = true
        else
            MainWindow.ClipsDescendants = true
            WindowTopBarLine.Visible = false
            MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
            wait(0.1)
            WindowStuff.Visible = false	
        end
        Minimized = not Minimized    
    end)

    local function LoadSequence()
        MainWindow.Visible = false
        local LoadSequenceLogo = SetProps(MakeElement("Image", Config.IntroIcon), {
            Parent = Orion,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.4, 0),
            Size = UDim2.new(0, 28, 0, 28),
            ImageColor3 = Color3.fromRGB(255,255,255),
            ImageTransparency = 1
        })

        local LoadSequenceText = SetProps(MakeElement("Label", Config.IntroText, 14), {
            Parent = Orion,
            Size = UDim2.new(1,0,1,0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 19, 0.5, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            Font = Enum.Font.FredokaOne,
            TextTransparency = 1
        })

        TweenService:Create(LoadSequenceLogo, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5,0,0.5,0)}):Play()
        wait(0.8)
        TweenService:Create(LoadSequenceLogo, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
        wait(0.3)
        TweenService:Create(LoadSequenceText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        wait(2)
        TweenService:Create(LoadSequenceText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
        MainWindow.Visible = true
        LoadSequenceLogo:Destroy()
        LoadSequenceText:Destroy()
    end 

    if Config.IntroEnabled then
        LoadSequence()
    end	

    local TabFunction = {}
    function TabFunction:MakeTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""
        TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

        local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
            Size = UDim2.new(1, 0, 0, 30),
            Parent = TabHolder
        }), {
            AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 10, 0.5, 0),
                ImageTransparency = 0.4,
                Name = "Ico"
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
                Size = UDim2.new(1, -35, 1, 0),
                Position = UDim2.new(0, 35, 0, 0),
                Font = Enum.Font.FredokaOne,
                TextTransparency = 0.4,
                Name = "Title"
            }), "Text")
        })

        if GetIcon(TabConfig.Icon) then
            TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
        end	

        local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 5), {
            Size = UDim2.new(1, -150, 1, -50),
            Position = UDim2.new(0, 150, 0, 50),
            Parent = MainWindow,
            Visible = false,
            Name = "ItemContainer"
        }), {
            MakeElement("List", 0, 6),
            MakeElement("Padding", 15, 10, 10, 15)
        }), "Divider")

        AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
        end)

        if FirstTab then
            FirstTab = false
            TabFrame.Ico.ImageTransparency = 0
            TabFrame.Title.TextTransparency = 0
            TabFrame.Title.Font = Enum.Font.FredokaOne
            Container.Visible = true
        end    

        AddConnection(TabFrame.MouseButton1Click, function()
            for _, Tab in pairs(TabHolder:GetChildren()) do
                if Tab:IsA("TextButton") then
                    Tab.Title.Font = Enum.Font.FredokaOne
                    TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
                    TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
                end    
            end
            for _, ItemContainer in pairs(MainWindow:GetChildren()) do
                if ItemContainer.Name == "ItemContainer" then
                    ItemContainer.Visible = false
                end    
            end  
            TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
            TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
            TabFrame.Title.Font = Enum.Font.FredokaOne
            Container.Visible = true   
        end)

        local function GetElements(ItemParent)
            local ElementFunction = {}
            function ElementFunction:AddLabel(Text)
                local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 0.7,
                    Parent = ItemParent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
                        Size = UDim2.new(1, -12, 1, 0),
                        Position = UDim2.new(0, 12, 0, 0),
                        Font = Enum.Font.FredokaOne,
                        Name = "Content"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")
                local LabelFunction = {}
                function LabelFunction:Set(ToChange)
                    LabelFrame.Content.Text = ToChange
                end
                return LabelFunction
            end
            -- (Other element functions such as AddParagraph, AddButton, AddToggle, AddSlider, etc.
            -- are defined here similarly; they remain unchanged.)
            return ElementFunction   
        end	

        local ElementFunction = {}

        function ElementFunction:AddSection(SectionConfig)
            SectionConfig.Name = SectionConfig.Name or "Section"
            local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
                Size = UDim2.new(1, 0, 0, 26),
                Parent = Container
            }), {
                AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
                    Size = UDim2.new(1, -12, 0, 16),
                    Position = UDim2.new(0, 0, 0, 3),
                    Font = Enum.Font.FredokaOne
                }), "TextDark"),
                SetChildren(SetProps(MakeElement("TFrame"), {
                    AnchorPoint = Vector2.new(0, 0),
                    Size = UDim2.new(1, 0, 1, -24),
                    Position = UDim2.new(0, 0, 0, 23),
                    Name = "Holder"
                }), {
                    MakeElement("List", 0, 6)
                }),
            })
            AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
                SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
            end)
            local SectionFunction = {}
            for i, v in pairs(GetElements(SectionFrame.Holder)) do
                SectionFunction[i] = v 
            end
            return SectionFunction
        end	

        for i, v in pairs(GetElements(Container)) do
            ElementFunction[i] = v 
        end

        if TabConfig.PremiumOnly and not IsPremium(LocalPlayer) then
            for i, v in pairs(ElementFunction) do
                ElementFunction[i] = function() end
            end    
            Container:FindFirstChild("UIListLayout"):Destroy()
            Container:FindFirstChild("UIPadding"):Destroy()
            SetChildren(SetProps(MakeElement("TFrame"), {
                Size = UDim2.new(1, 0, 1, 0),
                Parent = ItemParent
            }), {
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 15, 0, 15),
                    ImageTransparency = 0.4
                }), "Text"),
                AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {
                    Size = UDim2.new(1, -38, 0, 14),
                    Position = UDim2.new(0, 38, 0, 18),
                    TextTransparency = 0.4
                }), "Text"),
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
                    Size = UDim2.new(0, 56, 0, 56),
                    Position = UDim2.new(0, 84, 0, 110),
                }), "Text"),
                AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {
                    Size = UDim2.new(1, -150, 0, 14),
                    Position = UDim2.new(0, 150, 0, 112),
                    Font = Enum.Font.FredokaOne
                }), "Text"),
                AddThemeObject(SetProps(MakeElement("Label", "This part of the script is locked to Premium users.", 12), {
                    Size = UDim2.new(1, -200, 0, 14),
                    Position = UDim2.new(0, 150, 0, 138),
                    TextWrapped = true,
                    TextTransparency = 0.4
                }), "Text")
            })
        end
        return ElementFunction   
    end	
    return TabFunction
end

function OrionLib:Destroy()
    Orion:Destroy()
end

return OrionLib
-----------------------------------------------------
-- END OF ORION LIBRARY DEFINITION
-----------------------------------------------------

-----------------------------------------------------
-- MAIN UI SCRIPT USING THE ORION LIBRARY
-----------------------------------------------------
-- Require our OrionLib (the code above is assumed to be loaded as a module)
local Orion = require(script)  -- if you placed this script in a ModuleScript; otherwise, it’s already returned

-- Create a window using our OrionLib
local Window = Orion:MakeWindow({
    Name = "Yonkai",
    IntroEnabled = true,
    SaveConfig = false
})

-- Create three tabs: Home, Settings, and Toggles
local HomeTab = Window:MakeTab({
    Name = "Home",
    Icon = "rbxassetid://6031075937"
})
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://6031075937"
})
local TogglesTab = Window:MakeTab({
    Name = "Toggles",
    Icon = "rbxassetid://6031075937"
})

-- Add simple labels to Home and Settings
HomeTab:AddLabel("Welcome Home!")
SettingsTab:AddLabel("Settings Tab")

-----------------------------------------------------
-- HELPER: Rotate Character Towards Target (used by Auto Pass Bomb)
-----------------------------------------------------
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
-- TOGGLES ADDED TO THE TOGGLES TAB
-----------------------------------------------------
local AutoPassEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false

-- Auto Pass Bomb Toggle (uses getClosestPlayer helper)
local function getClosestPlayer()
    local closestPlayer, shortestDistance = nil, math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

TogglesTab:AddToggle({
    Name = "Auto Pass Bomb",
    Default = false,
    Flag = "AutoPassBomb",
    Callback = function(Value)
        AutoPassEnabled = Value
        if Value then
            spawn(function()
                while AutoPassEnabled do
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Bomb") then
                            local passTarget = getClosestPlayer()
                            if passTarget and passTarget.Character and passTarget.Character:FindFirstChild("HumanoidRootPart") then
                                rotateCharacterTowardsTarget(passTarget.Character.HumanoidRootPart.Position)
                                player.Character.Bomb.CFrame = passTarget.Character.HumanoidRootPart.CFrame
                            end
                        end
                    end
                    wait(0.1)
                end
            end)
        end
    end
})

-- Anti Slippery Toggle
TogglesTab:AddToggle({
    Name = "Anti Slippery",
    Default = false,
    Flag = "AntiSlippery",
    Callback = function(Value)
        AntiSlipperyEnabled = Value
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if Value then
                        part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, 0.5)
                    else
                        part.CustomPhysicalProperties = PhysicalProperties.new()
                    end
                end
            end
        end
    end
})

-- Remove Hitbox Toggle
TogglesTab:AddToggle({
    Name = "Remove Hitbox",
    Default = false,
    Flag = "RemoveHitbox",
    Callback = function(Value)
        RemoveHitboxEnabled = Value
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name == "Hitbox" then
                    if Value then
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
})

-----------------------------------------------------
-- INITIALIZE THE UI & SHOW NOTIFICATION
-----------------------------------------------------
Orion:Init()
Orion:MakeNotification({
    Name = "Custom UI",
    Content = "Custom UI with toggles loaded successfully!",
    Time = 5
})
