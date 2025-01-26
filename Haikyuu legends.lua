--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--// Variables
local LocalPlayer = Players.LocalPlayer
local JumpPowerEnabled = false
local HitboxExtenderEnabled = false
local JumpPower = 100
local SpikePower = 200
local HitboxMultiplier = 2

--// Functions
local function setJumpPower(value)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = value
        print("Jump Power set to:", value)
    end
end

local function applySpikePower(force)
    local ball = Workspace:FindFirstChild("Volleyball")
    if ball and ball:IsA("BasePart") then
        ball.Velocity = Vector3.new(0, force, 0)
        print("Spike Power applied:", force)
    end
end

local function extendHitbox(multiplier)
    local ball = Workspace:FindFirstChild("Volleyball")
    if ball and ball:IsA("BasePart") then
        ball.Size = ball.Size * multiplier
        print("Hitbox extended by multiplier:", multiplier)
    end
end

local function stopMatch()
    local matchScript = Workspace:FindFirstChild("MatchScript")
    if matchScript then
        matchScript.Disabled = true
        print("Match stopped.")
    end
end

local function autoServe()
    local ball = Workspace:FindFirstChild("Volleyball")
    if ball and ball:IsA("BasePart") then
        ball.Velocity = Vector3.new(0, 100, 50)
        print("Auto serve executed.")
    end
end

--// UI with OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({ Name = "Haikyuu Legends Menu", HidePremium = false, SaveConfig = true, ConfigFolder = "HaikyuuMenu" })
local MainTab = Window:MakeTab({ Name = "Main Features", Icon = "rbxassetid://4483345998", PremiumOnly = false })

MainTab:AddToggle({
    Name = "Enable Jump Power",
    Default = JumpPowerEnabled,
    Callback = function(value)
        JumpPowerEnabled = value
        if JumpPowerEnabled then
            setJumpPower(JumpPower)
        end
    end
})

MainTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = JumpPower,
    Increment = 10,
    Callback = function(value)
        JumpPower = value
        if JumpPowerEnabled then
            setJumpPower(value)
        end
    end
})

MainTab:AddButton({
    Name = "Apply Spike Power",
    Callback = function()
        applySpikePower(SpikePower)
    end
})

MainTab:AddToggle({
    Name = "Enable Hitbox Extender",
    Default = HitboxExtenderEnabled,
    Callback = function(value)
        HitboxExtenderEnabled = value
        if HitboxExtenderEnabled then
            extendHitbox(HitboxMultiplier)
        end
    end
})

MainTab:AddButton({
    Name = "Stop Match",
    Callback = function()
        stopMatch()
    end
})

MainTab:AddButton({
    Name = "Auto Powerful Serve",
    Callback = function()
        autoServe()
    end
})

OrionLib:Init()
