--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib.lua"))()
local Window = OrionLib:MakeWindow({Name = "Script Menu", HidePremium = false, SaveConfig = true, ConfigFolder = "Yonkai"})

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
toggleButton.Size = UDim2.new(0, 50, 0, 50) -- Size of the button
toggleButton.Position = UDim2.new(0.5, -25, 0.5, -25) -- Center position
toggleButton.AnchorPoint = Vector2.new(0.5, 0.5) -- Adjust anchor point to center
toggleButton.BackgroundTransparency = 1 -- Fully transparent background
toggleButton.Image = "" -- No image, just a circle
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Set background color to black
toggleButton.ZIndex = 100 -- Ensure the button is on top of most UI elements
toggleButton.Name = "MenuToggleButton"

-- Make the button a circle
local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(1, 0) -- Make it a perfect circle
uicorner.Parent = toggleButton

-- Parent the toggle button to PlayerGui for visibility
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
toggleButton.Parent = playerGui

-- Debug: Print to verify the button is created and parented correctly
print("Toggle button created and parented to PlayerGui")

-- Debug: Verify the button's properties
print("Button Properties: Size:", toggleButton.Size, " Position:", toggleButton.Position, " ZIndex:", toggleButton.ZIndex)

-- Toggle functionality for showing/hiding the menu
toggleButton.MouseButton1Click:Connect(function()
    UIHidden = not UIHidden
    MainWindow.Visible = not UIHidden

    -- Notification feedback
    OrionLib:MakeNotification({
        Name = UIHidden and "Menu Hidden" or "Menu Opened",
        Content = UIHidden and "Tap the toggle button to reopen the interface." or "Tap the toggle button to hide the interface.",
        Time = 5
    })

    -- Debug: Print the current visibility state
    print("Menu visibility toggled. Current state:", UIHidden and "Hidden" or "Visible")
end)

-- Finalize Orion Menu
OrionLib:Init()
