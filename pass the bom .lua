--[[
    Full "Pass the Bomb" Script with Enhanced Features:
    1. Enhanced Auto Pass Bomb logic with optional randomization and preferred targets.
    2. Updates Log in the menu.
    3. Console tab to show execution logs.
    4. Retains original functionalities (Auto Dodge, Collect Coins, etc.).
--]]

--========================--
--     INITIAL SETUP      --
--========================--

-- Create a ScreenGui for Mobile
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileScreenGui"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Toggle Button to Open/Close Menu
local Toggle = Instance.new("ImageButton")
Toggle.Name = "Toggle"
Toggle.Parent = ScreenGui
Toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red background
Toggle.Position = UDim2.new(0.5, -30, 0, 50) -- Positioned near the top center
Toggle.Size = UDim2.new(0, 60, 0, 60) -- 60x60 pixels
Toggle.Image = "rbxassetid://18594014746" -- Replace with your desired image asset ID
Toggle.ScaleType = Enum.ScaleType.Fit

-- Make the Toggle Button Circular
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0.5, 0)
Corner.Parent = Toggle

-- Load OrionLib for UI
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/magmachief/Library-Ui/main/Orion%20Lib%20Transparent%20%20.lua"))()

--========================--
--  MAIN WINDOW CREATION  --
--========================--

local Window = OrionLib:MakeWindow({
    Name = "Yon Menu - Advanced",
    HidePremium = false,
    IntroEnabled = true,
    IntroText = "Yon Menu",
    SaveConfig = true,
    ConfigFolder = "YonMenu_Advanced",
    IntroIcon = "rbxassetid://9876543210",  -- Replace with your desired intro icon ID
    Icon = "rbxassetid://9876543210",       -- Replace with your desired window icon ID
})

--========================--
--   GLOBAL VARIABLES     --
--========================--

-- Feature Toggles
local AutoDodgePlayersEnabled = false
local PlayerDodgeDistance = 15
local CollectCoinsEnabled = false
local AntiSlipperyEnabled = false
local RemoveHitboxEnabled = false
local AutoPassEnabled = false
local UseRandomPassing = false            -- Determines whether to pick a random target or first in list
local PreferredTargets = {"PlayerName1"}  -- Replace with player names you want to prioritize

-- Additional Features
local SecureSpinEnabled = false
local SecureSpinDistance = 5
local DodgeDistance = 10
local SafeArea = {MinX = -100, MaxX = 100, MinZ = -100, MaxZ = 100} -- Define your game's safe area coordinates

-- Bomb Parameters
local BombPassRange = 25
local ShortFuseThreshold = 5

-- Roblox Services
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CollectionService = game:GetService("CollectionService")

-- Player Character
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

--========================--
--   UPDATE / CHANGELOG   --
--========================--

local UpdateLogTab = Window:MakeTab({
    Name = "Updates Log",
    Icon = "rbxassetid://4483345998", -- Replace with your desired icon ID
    PremiumOnly = false
})

-- List of version updates or changelogs
UpdateLogTab:AddParagraph("Changelog", [[
1. Added random/targeted auto pass logic.
2. Introduced a console tab for execution logs.
3. Enhanced user interface with OrionLib advanced features.
4. Improved Auto Collect Coins functionality.
5. Added Auto Pass Closest Player functionality.
]])

--========================--
--       CONSOLE TAB      --
--========================--

local ConsoleTab = Window:MakeTab({
    Name = "Console",
    Icon = "rbxassetid://4483345998", -- Replace with your desired icon ID
    PremiumOnly = false
})

local logs = {}
local logDisplay

-- Helper function to refresh log display
local function refreshLogDisplay()
    if logDisplay then
        -- Combine all log messages into a single string separated by newlines
        local combined = table.concat(logs, "\n")
        logDisplay:Set(combined)
    end
end

-- Function to log a message to the console
local function logMessage(msg)
    table.insert(logs, "[" .. os.date("%X") .. "] " .. tostring(msg))
    refreshLogDisplay()
end

-- Create a Paragraph for console output
logDisplay = ConsoleTab:AddParagraph("Execution Logs", "")
refreshLogDisplay()

--========================--
--   AUTO PASS BOMB LOGIC --
--========================--

-- Returns two lists: valid preferred targets, plus fallback players within range
local function getValidPlayers(bombTimeLeft)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        return {}, {}
    end

    local validPreferred = {}
    local fallbackList = {}
    local localPos = char.HumanoidRootPart.Position

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") and not character:FindFirstChild("Bomb") then
                local dist = (localPos - character.HumanoidRootPart.Position).magnitude
                if dist <= BombPassRange then
                    -- If there's plenty of time, prefer specific targets
                    if bombTimeLeft > ShortFuseThreshold then
                        if table.find(PreferredTargets, player.Name) then
                            table.insert(validPreferred, player)
                        else
                            table.insert(fallbackList, player)
                        end
                    else
                        -- If time is short, treat everyone as fallback
                        table.insert(fallbackList, player)
                    end
                end
            end
        end
    end

    return validPreferred, fallbackList
end

-- Function to pass the bomb to a chosen player
local function passBombIfNeeded()
    local char = LocalPlayer.Character
    if not char then return end

    local bomb = char:FindFirstChild("Bomb")
    if not bomb then return end

    local bombTimeValue = bomb:FindFirstChild("BombTimeLeft")
    local bombTimeLeft = bombTimeValue and bombTimeValue.Value or 9999

    -- If the bomb is about to explode, pass as soon as possible
    local BombEvent = bomb:FindFirstChild("RemoteEvent")
    if not BombEvent then return end

    local validPreferred, fallbackList = getValidPlayers(bombTimeLeft)

    -- If we have valid preferred targets and time left
    if #validPreferred > 0 then
        local chosen
        if UseRandomPassing then
            chosen = validPreferred[math.random(#validPreferred)]
        else
            chosen = validPreferred[1]
        end

        if chosen.Character and chosen.Character:FindFirstChild("CollisionPart") then
            BombEvent:FireServer(chosen.Character, chosen.Character.CollisionPart)
            logMessage("Bomb passed to preferred target: " .. chosen.Name)
            return
        end
    end

    -- Otherwise, pass to fallback
    if #fallbackList > 0 then
        local fallback
        if UseRandomPassing then
            fallback = fallbackList[math.random(#fallbackList)]
        else
            fallback = fallbackList[1]
        end

        if fallback.Character and fallback.Character:FindFirstChild("CollisionPart") then
            BombEvent:FireServer(fallback.Character, fallback.Character.CollisionPart)
            logMessage("Bomb passed to fallback: " .. fallback.Name)
        end
    end
end

--========================--
--       AUTOMATED TAB    --
--========================--

local AutomatedTab = Window:MakeTab({
    Name = "Automated",
    Icon = "rbxassetid://4483345998", -- Replace with your desired icon ID
    PremiumOnly = false
})

-- Auto Dodge Players Toggle
AutomatedTab:AddToggle({
    Name = "Auto Dodge Players",
    Default = AutoDodgePlayersEnabled,
    Callback = function(bool)
        AutoDodgePlayersEnabled = bool
        logMessage("AutoDodgePlayersEnabled set to " .. tostring(bool))
    end
})

-- Player Dodge Distance Slider
AutomatedTab:AddSlider({
    Name = "Player Dodge Distance",
    Min = 10,
    Max = 30,
    Default = 15,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "studs",
    Callback = function(value)
        PlayerDodgeDistance = value
        logMessage("PlayerDodgeDistance set to " .. tostring(value))
    end
})

-- Collect Coins Toggle
AutomatedTab:AddToggle({
    Name = "Collect Coins",
    Default = CollectCoinsEnabled,
    Callback = function(bool)
        CollectCoinsEnabled = bool
        logMessage("CollectCoinsEnabled set to " .. tostring(bool))
    end
})

-- Auto Pass Bomb Toggle
--[[
--AutomatedTab:AddToggle({
    Name = "Auto Pass Bomb",
    Default = AutoPassEnabled,
    Callback = function(bool)
        AutoPassEnabled = bool
        logMessage("AutoPassEnabled set to " .. tostring(bool))
    end
})
]]

-- Use Random Passing Toggle
AutomatedTab:AddToggle({
    Name = "Use Random Passing",
    Default = UseRandomPassing,
    Callback = function(bool)
        UseRandomPassing = bool
        logMessage("UseRandomPassing set to " .. tostring(bool))
    end
})

-- Auto Pass Closest Player Toggle
AutomatedTab:AddToggle({
    Name = "Auto Pass Closest Player",
    Default = AutoPassEnabled,
    Callback = function(bool)
        AutoPassEnabled = bool
        if AutoPassEnabled then
            saveSettings()
            local PathfindingService = game:GetService("PathfindingService")
            local LocalPlayer = game.Players.LocalPlayer
            local Character = LocalPlayer.Character

            game:GetService("RunService").Stepped:Connect(function()
                if not AutoPassEnabled then return end
                pcall(function()
                    if LocalPlayer.Backpack:FindFirstChild("Bomb") then
                        LocalPlayer.Backpack:FindFirstChild("Bomb").Parent = Character
                    end

                    if LocalPlayer.Character:FindFirstChild("Bomb") then
                        local BombEvent = LocalPlayer.Character:FindFirstChild("Bomb"):FindFirstChild("RemoteEvent")

                        -- Find the closest player without a bomb
                        local closestPlayer = nil
                        local closestDistance = math.huge

                        for _, Player in next, game.Players:GetPlayers() do
                            if Player ~= LocalPlayer and Player.Character and Player.Character.Parent == workspace and not Player.Character:FindFirstChild("Bomb") then
                                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestPlayer = Player
                                end
                            end
                        end

                        -- Auto-pass the closest player by moving towards them
                        if closestPlayer then
                            warn("Hitting " .. closestPlayer.Name)
                            
                            -- Move towards the closest player using pathfinding
                            local targetPosition = closestPlayer.Character.HumanoidRootPart.Position
                            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                            
                            if humanoid then
                                local path = PathfindingService:CreatePath({
                                    AgentRadius = 2,
                                    AgentHeight = 5,
                                    AgentCanJump = true,
                                    AgentJumpHeight = 10,
                                    AgentMaxSlope = 45,
                                    AgentCanClimb = false,
                                    AgentCanSwim = false
                                })
                                path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, targetPosition)
                                local waypoints = path:GetWaypoints()

                                for _, waypoint in ipairs(waypoints) do
                                    if not AutoPassEnabled then break end
                                    humanoid:MoveTo(waypoint.Position)
                                    humanoid.MoveToFinished:Wait()
                                end
                            end

                            -- Check if within range to pass the bomb
                            if (LocalPlayer.Character.HumanoidRootPart.Position - targetPosition).magnitude <= SecureSpinDistance then
                                -- Fire the bomb event immediately
                                BombEvent:FireServer(closestPlayer.Character, closestPlayer.Character:FindFirstChild("CollisionPart"))
                                logMessage("Bomb passed to closest player: " .. closestPlayer.Name)
                            end
                        else
                            print("No closest player found")
                        end
                    end
                end)
            end)
        end
    end
})
                     

--========================--
--       OTHERS TAB       --
--========================--

local OtherTab = Window:MakeTab({
    Name = "Others",
    Icon = "rbxassetid://4483345998", -- Replace with your desired icon ID
    PremiumOnly = false
})

-- Secure Spin Toggle
OtherTab:AddToggle({
    Name = "Secure Spin",
    Default = SecureSpinEnabled,
    Callback = function(bool)
        SecureSpinEnabled = bool
        logMessage("SecureSpinEnabled set to " .. tostring(bool))

        local player = LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()

        if SecureSpinEnabled then
            spawn(function()
                while SecureSpinEnabled do
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                        end
                    end
                    wait(0.1)
                end
            end)
        else
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
                end
            end
        end
    end
})

-- Secure Spin Distance Slider
OtherTab:AddSlider({
    Name = "Secure Spin Distance",
    Min = 1,
    Max = 20,
    Default = 5,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "studs",
    Callback = function(value)
        SecureSpinDistance = value
        logMessage("SecureSpinDistance set to " .. tostring(value))
    end
})

-- Anti Slippery Toggle
OtherTab:AddToggle({
    Name = "Anti Slippery",
    Default = false,
    Callback = function(bool)
        AntiSlipperyEnabled = bool
        logMessage("AntiSlipperyEnabled set to " .. tostring(bool))

        local player = LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()

        if AntiSlipperyEnabled then
            spawn(function()
                while AntiSlipperyEnabled do
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                        end
                    end
                    wait(0.1)
                end
            end)
        else
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5)
                end
            end
        end
    end
})

-- Remove Hitbox Toggle
OtherTab:AddToggle({
    Name = "Remove Hitbox",
    Default = false,
    Callback = function(bool)
        RemoveHitboxEnabled = bool
        logMessage("RemoveHitboxEnabled set to " .. tostring(bool))

        if RemoveHitboxEnabled then
            local player = LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            
            local function removeCollisionPart(character)
                for _ = 1, 100 do
                    wait()
                    pcall(function()
                        local collisionPart = character:FindFirstChild("CollisionPart")
                        if collisionPart then
                            collisionPart:Destroy()
                            logMessage("CollisionPart destroyed for " .. character.Name)
                        end
                    end)
                end
            end
            removeCollisionPart(char)
            
            player.CharacterAdded:Connect(function(character)
                removeCollisionPart(character)
            end)
        end
    end
})

--========================--
--     HELPER FUNCTIONS   --
--========================--

-- Check if a position is within the Safe Area
local function isWithinSafeArea(position)
    return position.X >= SafeArea.MinX and position.X <= SafeArea.MaxX
       and position.Z >= SafeArea.MinZ and position.Z <= SafeArea.MaxZ
end

-- Move to Target via Pathfinding
local function moveToTarget(targetPosition)
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
        AgentMaxSlope = 45,
    })

    local success, err = pcall(function()
        path:ComputeAsync(char.HumanoidRootPart.Position, targetPosition)
    end)
    if not success then
        warn("Pathfinding failed: " .. err)
        logMessage("Pathfinding Error: " .. tostring(err))
        return
    end

 -- Iterate through all waypoints and move the humanoid
    for _, waypoint in ipairs(path:GetWaypoints()) do
        if CollectCoinsEnabled or AutoDodgePlayersEnabled then
            humanoid:MoveTo(waypoint.Position)
            local reached = humanoid.MoveToFinished:Wait()
            if not reached then
                logMessage("Failed to reach waypoint: " .. tostring(waypoint.Position))
                return
            end
        else
            break
        end
    end
end

-- Dodge players carrying the bomb
local function dodgePlayers()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Bomb") then
            local distance = (char.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude
            if distance < closestDistance and distance <= PlayerDodgeDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end

    if closestPlayer then
        -- Calculate direction to move away from the player
        local dodgeDirection = (char.HumanoidRootPart.Position - closestPlayer.Character.HumanoidRootPart.Position).unit
        local targetPosition = char.HumanoidRootPart.Position + dodgeDirection * PlayerDodgeDistance
        if isWithinSafeArea(targetPosition) then
            moveToTarget(targetPosition)
            logMessage("Dodged player with bomb: " .. closestPlayer.Name)
        end
    end
end

-- Improved Auto-Collect Coins Function
local function collectCoins()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        logMessage("Character or HumanoidRootPart not found; cannot collect coins.")
        return
    end

    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then
        logMessage("Humanoid not found; cannot move to coins.")
        return
    end

    local closestCoin = nil
    local closestDistance = math.huge
    local rootPos = char.HumanoidRootPart.Position

    -- Search for coins using GetDescendants to include nested objects
    for _, item in pairs(workspace:GetDescendants()) do
        -- Adjust the part types as needed
        if (item:IsA("Part") or item:IsA("MeshPart") or item:IsA("UnionOperation")) and item.Name == "Coin" then
            -- Optional: Use CollectionService tags for efficiency
            -- if not CollectionService:HasTag(item, "Coin") then continue end

            -- Check if the coin is within the Safe Area
            if isWithinSafeArea(item.Position) then
                local distance = (rootPos - item.Position).magnitude
                -- Find the closest coin
                if distance < closestDistance then
                    closestDistance = distance
                    closestCoin = item
                end
            end
        end
    end

    if closestCoin then
        logMessage(string.format("Closest coin found '%s' at distance: %d studs", closestCoin.Name, math.floor(closestDistance)))

        -- Move to the coin's position using Pathfinding
        moveToTarget(closestCoin.Position)

        -- Optional: Wait briefly to ensure collision scripts register the collection
        wait(0.3)
        logMessage("Attempted to collect the coin.")
    else
        -- If no coin was found, log a message or do nothing
        logMessage("No coins found within the Safe Area.")
    end
end

--========================--
--       MAIN LOOP        --
--========================--

RunService.Stepped:Connect(function()
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        -- Auto Dodge
        if AutoDodgePlayersEnabled then
            pcall(dodgePlayers)
        end

        -- Collect Coins
        if CollectCoinsEnabled then
            pcall(collectCoins)
        end

        -- Auto Pass Bomb
        if AutoPassEnabled then
            pcall(passBombIfNeeded)
        end
    end
end)

--========================--
--   TOGGLE MENU BUTTON   --
--========================--

Toggle.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
    logMessage("Menu toggled - Now: " .. (ScreenGui.Enabled and "Visible" or "Hidden"))
end)

-- Initialize OrionLib UI
OrionLib:Init()
logMessage("Yon Menu Initialized Successfully")
