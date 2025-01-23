--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/refs/heads/main/Orion%20Lib.lua"))()

-- Orion Menu
local Window = OrionLib:MakeWindow({
    Name = "Yonkai Menu",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "YonkaiMenuConfig"
})

-- Default Settings and Preferences
local preferences = {
    AntiSlipperyEnabled = false,
    RemoveHitboxEnabled = false,
    AutoPassEnabled = false,
}

local UIHidden = false
local MainWindow = Window -- Reference to the main Orion window

-- Tabs
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Features in Main Tab
MainTab:AddToggle({
    Name = "Anti-Slippery",
    Default = preferences.AntiSlipperyEnabled,
    Callback = function(value)
        preferences.AntiSlipperyEnabled = value
        print("Anti-Slippery:", value and "Enabled" or "Disabled")
    end
})

MainTab:AddToggle({
    Name = "Remove Hitbox",
    Default = preferences.RemoveHitboxEnabled,
    Callback = function(value)
        preferences.RemoveHitboxEnabled = value
        print("Remove Hitbox:", value and "Enabled" or "Disabled")
    end
})

MainTab:AddToggle({
    Name = "Auto Pass Bomb",
    Default = preferences.AutoPassEnabled,
    Callback = function(value)
        preferences.AutoPassEnabled = value
        print("Auto Pass Bomb:", value and "Enabled" or "Disabled")
    end
})

-- Settings Tab
SettingsTab:AddDropdown({
    Name = "Theme",
    Default = "Dark",
    Options = {"Dark", "Light", "Ocean", "Sunset"},
    Callback = function(theme)
        print("Theme switched to:", theme)
    end
})

-- Mobile-Friendly Toggle Button
local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0.8, -60) -- Bottom-left corner for mobile
toggleButton.Image = "rbxassetid://6031075938" -- Replace with a relevant icon
toggleButton.BackgroundTransparency = 1
toggleButton.Parent = game.CoreGui

-- Toggle functionality
toggleButton.MouseButton1Click:Connect(function()
    UIHidden = not UIHidden
    MainWindow.Visible = not UIHidden

    -- Optional: Notification for menu visibility state
    OrionLib:MakeNotification({
        Name = UIHidden and "Menu Hidden" or "Menu Opened",
        Content = UIHidden and "Tap the toggle button to reopen the interface." or "Tap the toggle button to hide the interface.",
        Time = 5
    })
end)

-- Finalize Orion Menu
OrionLib:Init()
