--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

--// Variables
local LocalPlayer = Players.LocalPlayer
local JumpPowerEnabled = false
local HitboxExtenderEnabled = false
local AutoSpikeEnabled = false
local AutoBlockEnabled = false
local AutoPassEnabled = false
local JumpPower = 100
local SpikePower = 200
local HitboxMultiplier = 2

-- Check if the ball has been passed
local ballPassed = false

--// Functions
local function setJumpPower(value)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = value
        print("Jump Power set to:", value)
    else
        print("Humanoid not found!")
    end
end

local function applySpikePower(force)
    local ball = Workspace:FindFirstChild("Volleyball")
    if ball and ball:IsA("BasePart") then
        ball.Velocity = Vector3.new(0, force, 0)
        print("Spike Power applied:", force)
    else
        print("Volleyball not found!")
    end
end

local function extendHitbox(multiplier)
    local ball = Workspace:FindFirstChild("Volleyball")
    if ball and ball:IsA("BasePart") then
        ball.Size = ball.Size * multiplier
        print("Hitbox extended by multiplier:", multiplier)
    else
        print("Volleyball not found!")
    end
end

local function stopMatch()
    local matchScript = Workspace:FindFirstChild("MatchScript")
    if matchScript then
        matchScript.Disabled = true
        print("Match stopped.")
    else
        print("MatchScript not found!")
    end
end

local function autoServe()
    local ball = Workspace:FindFirstChild("Volleyball")
    if ball and ball:IsA("BasePart") then
        ball.Velocity = Vector3.new(0, 100, 50)
        print("Auto serve executed.")
    else
        print("Volleyball not found!")
    end
end

local function autoSpike()
    local ball = Workspace:FindFirstChild("Volleyball")
    if ball and ball:IsA("BasePart") and ballPassed then
        local distance = (ball.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if distance < 10 then
            applySpikePower(SpikePower)
        else
            print("Ball is too far for a spike.")
        end
    else
        print("Ball not found or not passed yet.")
    end
end

local function autoBlock()
    local ball = Workspace:FindFirstChild("Volleyball")
    if ball and ball:IsA("BasePart") then
        local distance = (ball.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if distance < 10 then
            -- Set character's orientation to face the ball
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, ball.Position)
            print("Auto block executed.")
        else
            print("Ball is too far to block.")
        end
    else
        print("Volleyball not found!")
    end
end

local function autoPass()
    local ball = Workspace:FindFirstChild("Volleyball")
    if ball and ball:IsA("BasePart") then
        local distance = (ball.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if distance < 10 then
            -- Apply slight velocity to the ball to simulate a pass
            ball.Velocity = Vector3.new(10, 10, 10)
            ballPassed = true
            print("Auto pass executed.")
        else
            print("Ball is too far to pass.")
        end
    else
        print("Volleyball not found!")
    end
end

local function approachBall()
    local ball = Workspace:FindFirstChild("Volleyball")
    if ball and ball:IsA("BasePart") then
        local distance = (ball.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        if distance > 10 then
            -- Move towards the ball
            LocalPlayer.Character.Humanoid:MoveTo(ball.Position)
            print("Approaching ball.")
        else
            print("Already close to the ball.")
        end
    else
        print("Volleyball not found!")
    end
end

--// UI with OrionLib
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()
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

MainTab:AddToggle({
    Name = "Enable Auto Spike",
    Default = AutoSpikeEnabled,
    Callback = function(value)
        AutoSpikeEnabled = value
    end
})

MainTab:AddToggle({
    Name = "Enable Auto Block",
    Default = AutoBlockEnabled,
    Callback = function(value)
        AutoBlockEnabled = value
    end
})

MainTab:AddToggle({
    Name = "Enable Auto Pass",
    Default = AutoPassEnabled,
    Callback = function(value)
        AutoPassEnabled = value
    end
})

OrionLib:Init()

-- Auto Spike, Block, Pass, and Approach logic
RunService.Stepped:Connect(function()
    if AutoSpikeEnabled then
        autoSpike()
    end
    if AutoBlockEnabled then
        autoBlock()
    end
    if AutoPassEnabled then
        autoPass()
    end
    if AutoSpikeEnabled or AutoBlockEnabled or AutoPassEnabled then
        approachBall()
    end
end)
