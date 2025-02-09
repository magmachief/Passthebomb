local shiftlockk = Instance.new("ScreenGui")
local LockButton = Instance.new("ImageButton")
local btnIcon = Instance.new("ImageLabel")

shiftlockk.Name = "shiftlockk"
shiftlockk.Parent = game.CoreGui
shiftlockk.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
shiftlockk.ResetOnSpawn = false

LockButton.Name = "LockButton"
LockButton.Parent = shiftlockk
LockButton.AnchorPoint = Vector2.new(1, 1)
LockButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LockButton.BackgroundTransparency = 1.000
LockButton.BorderColor3 = Color3.fromRGB(27, 42, 53)
LockButton.Position = UDim2.new(1, -50, 1, -50)  -- Adjust this position as needed
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
--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

--// Premium System
local function GrantPremiumToAll()
    for _, player in ipairs(Players:GetPlayers()) do
        player:SetAttribute("Premium", true)
    end
end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("Premium", true)
end)

function IsPremium(player)
    return player:GetAttribute("Premium") == true
end

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

--========================--
--    UTILITY FUNCTIONS   --
--========================--

-- Function to get the closest player
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

-- Rotate Character Towards Target
local function rotateCharacterTowardsTarget(targetPosition)
    local character = LocalPlayer.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local direction = (targetPosition - humanoidRootPart.Position).unit
    local newCFrame = CFrame.fromMatrix(humanoidRootPart.Position, direction, Vector3.new(0, 1, 0))

    local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {CFrame = newCFrame})
    tween:Play()
end

-- Anti-Slippery Function
local function applyAntiSlippery(enabled)
    spawn(function()
        repeat
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = enabled and PhysicalProperties.new(0.7, 0.3, 0.5) or PhysicalProperties.new(0.5, 0.3, 0.5)
                end
            end
            wait(0.1)
        until not AntiSlipperyEnabled
    end)
end

-- Remove Hitbox Function
local function applyRemoveHitbox(enabled)
    if not enabled then return end
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local function removeCollisionPart(character)
        for i = 1, 100 do
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

-- Auto Pass Bomb Function
local function autoPassBomb()
    if not AutoPassEnabled then return end
    pcall(function()
        local Bomb = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Bomb")
        if Bomb then
            local BombEvent = Bomb:FindFirstChild("RemoteEvent")
            local closestPlayer = getClosestPlayer()
            if closestPlayer and closestPlayer.Character then
                local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                if (targetPosition - LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= bombPassDistance then
                    rotateCharacterTowardsTarget(targetPosition)
                    BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                end
            end
        end
    end)
end

-- Apply Features On Respawn
LocalPlayer.CharacterAdded:Connect(function()
    if AntiSlipperyEnabled then applyAntiSlippery(true) end
    if RemoveHitboxEnabled then applyRemoveHitbox(true) end
end)

--========================--
--  ORIONLIB INTERFACE    --
--========================--

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()
local Window = OrionLib:MakeWindow({ Name = "Yon Menu - Advanced", HidePremium = false, SaveConfig = true, ConfigFolder = "YonMenu_Advanced" })

-- Automated Tab
if IsPremium(LocalPlayer) then
    local AutomatedTab = Window:MakeTab({
        Name = "Automated",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = true
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
else
    Window:MakeTab({
        Name = "Premium Locked",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    }):AddLabel("⚠️ This feature requires Premium.")
end

-- UI Theme Selector
Window:AddDropdown({
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

OrionLib:Init()
print("Yon Menu Script Loaded with Premium Adjustments 🚀")
