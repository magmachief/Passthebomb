-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- Premium System
local function GrantPremiumToAll()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        player:SetAttribute("Premium", true)  -- Match existing "Premium"
    end
end

game:GetService("Players").PlayerAdded:Connect(function(player)
    player:SetAttribute("Premium", true)  -- Match existing "Premium"
end)

function IsPremium(player)
    return player:GetAttribute("Premium") == true  -- Match existing "Premium"
end

-- Premium features logic
GrantPremiumToAll()

-- Bomb Distance
local bombDistance = 10
local bombDistanceSliderConnection = nil

local function updateBombDistance(value)
    bombDistance = value
    print("Bomb Distance set to: " .. bombDistance)
end

-- UI Elements (using Orion for UI)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()
local Window = OrionLib:MakeWindow({ Name = "Advanced Features", HidePremium = false, SaveConfig = true, ConfigFolder = "Advanced_Config" })

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

    -- Bomb Distance Slider
    AutomatedTab:AddSlider({
        Name = "Bomb Distance",
        Min = 5,
        Max = 20,
        Default = 10,
        Callback = function(value)
            updateBombDistance(value)
        end
    })
else
    Window:MakeTab({
        Name = "Premium Locked",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    }):AddLabel("⚠️ This feature requires Premium.")
end

OrionLib:Init()
print("Yon Menu Script Loaded with Premium Features 🚀")
