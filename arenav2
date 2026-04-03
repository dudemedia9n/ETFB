local PlaceId = game.PlaceId
if PlaceId == 131623223084840 then
    local function equipAnububu()
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local backpack = player:FindFirstChildOfClass("Backpack")
        
        if humanoid and backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool:GetAttribute("BrainrotName") == "Anububu" then
                    -- Check the Scale attribute
                    local scale = tool:GetAttribute("Scale")
                    if scale and scale > 0.8 and scale < 1.2 then
                        humanoid:EquipTool(tool)
                        break
                    end
                end
            end
        end
        
        task.wait(0.1)
        
        local Event = game:GetService("ReplicatedStorage").Shared.Remotes.Networking["RE/ArenaPortal/ArenaQueueJoin"]
        pcall(function()
            Event:FireServer("TsunamiArena_FFA_8")
        end)
    end
    
    equipAnububu()
    return 
end

-- Infinity filter
local INFINITY_NAMES = {
    ["Meta Technetta"] = true,
    ["Doomini Tiktookini"] = true,
    ["Tung Tung Clownissimo"] = true,
    ["Anububu"] = true,
    ["Magmew"] = true,
    ["Noobini Infeeny"] = true
}

-- Configuration
local HITBOX_SIZE = Vector3.new(25, 25, 25)
local ARENA_FOLDER_NAME = "ArenaBrainrots"

_G.OriginalArenaData = _G.OriginalArenaData or {}

-- Settings
local autoHarpoonEnabled = true
local tweenSpeed = 1300 -- studs/sec for brainrot
local CARRY_TWEEN_SPEED = 2000 -- speed for middle/final
local ARRIVAL_THRESHOLD = 0.0005
local MIN_TWEEN_TIME = 0.0005
local HARPOON_COOLDOWN = 0
local lastHarpoonTime = 0
local fireRange = 175
local arrivalDelay = 0.2 -- arrival delay in seconds (0-1 sec)
local heightOffset = 0 -- height offset for harpoon

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Sit = false
    
    local connections = {}
    
    local function handleBadState(newState)
        if newState == Enum.HumanoidStateType.Ragdoll or 
           newState == Enum.HumanoidStateType.FallingDown or 
           newState == Enum.HumanoidStateType.PlatformStanding or
           newState == Enum.HumanoidStateType.Seated then
            humanoid.Sit = false
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            if character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.Anchored = false
            end
            return true
        end
        return false
    end
    
    handleBadState(humanoid:GetState())
    
    table.insert(connections, humanoid.StateChanged:Connect(function(_, newState)
        handleBadState(newState)
    end))
    
    for _, seat in pairs(workspace:GetDescendants()) do
        if seat:IsA("Seat") then
            table.insert(connections, seat:GetPropertyChangedSignal("Occupant"):Connect(function()
                if seat.Occupant == humanoid then
                    task.wait(0.04)
                    humanoid.Sit = false
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end))
        end
    end
    
    table.insert(connections, humanoid.Died:Connect(function()
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
    end))
end

-- SMART AUTO EQUIP (Harpoon + Wave Shield)
task.spawn(function()
    while true do
        task.wait(0.1)
        if not char then continue end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then continue end

        local carrying = char:FindFirstChild("RenderedBrainrot") ~= nil
        local backpack = player:FindFirstChildOfClass("Backpack")

        local function findTool(gearType)
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") and tool:GetAttribute("GearType") == gearType then
                    return tool
                end
            end
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool:GetAttribute("GearType") == gearType then
                        return tool
                    end
                end
            end
            return nil
        end

        local desiredGear = carrying and "Wave Shield" or "Harpoon Gun"
        local tool = findTool(desiredGear)

        if tool then
            if tool.Parent ~= char then
                humanoid:EquipTool(tool)
            end
            if not char:FindFirstChild(tool.Name) then
                tool.Parent = char
                humanoid:EquipTool(tool)
            end
        end
    end
end)

-- Execution positions
local PRE_CARRY_POS = Vector3.new(5601.8251953125, 3.184265375137329, 2696.59814453125) -- middle pos
local TARGET_POSITIONS = {
    Vector3.new(7183.76220703125, 3.184265375137329, 2690.36376953125),
    Vector3.new(5611.3349609375, 3.1843338012695312, 1092.7916259765625),
    Vector3.new(4021.99951171875, 3.184265375137329, 2684.496337890625),
    Vector3.new(5612.6328125, 3.184196710586548, 4285.27880859375)
}

task.wait(2)

local function getClosestTarget(pos)
    local closest = nil
    local shortestDist = math.huge
    for _, tPos in ipairs(TARGET_POSITIONS) do
        local dist = (pos - tPos).Magnitude
        if dist < shortestDist then
            shortestDist = dist
            closest = tPos
        end
    end
    return closest
end


local FINAL_EXECUTION_POS = getClosestTarget(hrp.Position)

local harpoonRemote = ReplicatedStorage:WaitForChild("Shared")
    :WaitForChild("Remotes")
    :WaitForChild("Networking")
    :WaitForChild("RE/Harpoon/HarpoonActivate")

local function expandHitboxes()
    local folder = workspace:FindFirstChild(ARENA_FOLDER_NAME)
    if not folder then return end
    for _, obj in ipairs(folder:GetChildren()) do
        local root = obj:FindFirstChild("Root", true) or obj:FindFirstChildWhichIsA("BasePart")
        if root then
            if _G.OriginalArenaData[root] == nil then
                _G.OriginalArenaData[root] = {
                    Size = root.Size,
                    Transparency = root.Transparency,
                    CanCollide = root.CanCollide,
                    Massless = root.Massless
                }
            end
            root.Massless = true
            root.Size = HITBOX_SIZE
            root.Transparency = 0.8
            root.CanCollide = false
            root.CanTouch = true
            root.CanQuery = true
        end
    end
end

local function getClosestBrainrot()
    local folder = workspace:FindFirstChild(ARENA_FOLDER_NAME)
    if not folder then return nil end
    local closest = nil
    local shortestDist = math.huge
    for _, obj in ipairs(folder:GetChildren()) do
        local root = obj:FindFirstChild("Root", true) or obj:FindFirstChildWhichIsA("BasePart")
        if root then
            -- Check if this brainrot matches our infinity filter
            local isInfinity = false
            for _, child in ipairs(obj:GetChildren()) do
                if INFINITY_NAMES[child.Name] then 
                    isInfinity = true 
                    break 
                end
            end
            
            if isInfinity then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = root
                end
            end
        end
    end
    return closest
end

-- GUI setup
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("AutoHarpoonGUI") then
        playerGui.AutoHarpoonGUI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoHarpoonGUI"
    screenGui.Parent = playerGui

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 200, 0, 50)
    toggleButton.Position = UDim2.new(0, 10, 0, 10)
    toggleButton.Text = autoHarpoonEnabled and "Auto-Harpoon: ON" or "Auto-Harpoon: OFF"
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
    toggleButton.TextColor3 = Color3.new(1,1,1)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextScaled = true
    toggleButton.Parent = screenGui
    toggleButton.MouseButton1Click:Connect(function()
        autoHarpoonEnabled = not autoHarpoonEnabled
        toggleButton.Text = autoHarpoonEnabled and "Auto-Harpoon: ON" or "Auto-Harpoon: OFF"
    end)

    local speedBox = Instance.new("TextBox")
    speedBox.Size = UDim2.new(0,180,0,50)
    speedBox.Position = UDim2.new(0,10,0,70)
    speedBox.Text = tostring(tweenSpeed)
    speedBox.PlaceholderText = "Tween Speed (50-5000)"
    speedBox.BackgroundColor3 = Color3.fromRGB(0,170,255)
    speedBox.TextColor3 = Color3.new(1,1,1)
    speedBox.Font = Enum.Font.SourceSansBold
    speedBox.TextScaled = true
    speedBox.ClearTextOnFocus = false
    speedBox.Parent = screenGui
    speedBox.FocusLost:Connect(function()
        local val = tonumber(speedBox.Text)
        if val then tweenSpeed = math.clamp(val,50,5000) end
        speedBox.Text = tostring(tweenSpeed)
    end)

    local execSpeedBox = Instance.new("TextBox")
    execSpeedBox.Size = UDim2.new(0,180,0,50)
    execSpeedBox.Position = UDim2.new(0,10,0,130)
    execSpeedBox.Text = tostring(CARRY_TWEEN_SPEED)
    execSpeedBox.PlaceholderText = "Execution Spot Tween Speed"
    execSpeedBox.BackgroundColor3 = Color3.fromRGB(0,170,255)
    execSpeedBox.TextColor3 = Color3.new(1,1,1)
    execSpeedBox.Font = Enum.Font.SourceSansBold
    execSpeedBox.TextScaled = true
    execSpeedBox.ClearTextOnFocus = false
    execSpeedBox.Parent = screenGui

    local arrivalBox = Instance.new("TextBox")
    arrivalBox.Size = UDim2.new(0,180,0,50)
    arrivalBox.Position = UDim2.new(0,10,0,190)
    arrivalBox.Text = tostring(arrivalDelay*1000)
    arrivalBox.PlaceholderText = "Arrival Delay (0-1000 ms)"
    arrivalBox.BackgroundColor3 = Color3.fromRGB(0,170,255)
    arrivalBox.TextColor3 = Color3.new(1,1,1)
    arrivalBox.Font = Enum.Font.SourceSansBold
    arrivalBox.TextScaled = true
    arrivalBox.ClearTextOnFocus = false
    arrivalBox.Parent = screenGui

    local heightBox = Instance.new("TextBox")
    heightBox.Size = UDim2.new(0,180,0,50)
    heightBox.Position = UDim2.new(0,10,0,250)
    heightBox.Text = tostring(heightOffset)
    heightBox.PlaceholderText = "Height Offset (-100 to 100)"
    heightBox.BackgroundColor3 = Color3.fromRGB(0,170,255)
    heightBox.TextColor3 = Color3.new(1,1,1)
    heightBox.Font = Enum.Font.SourceSansBold
    heightBox.TextScaled = true
    heightBox.ClearTextOnFocus = false
    heightBox.Parent = screenGui
end

createGUI()
player.CharacterAdded:Connect(function(charNew)
    char = charNew
    hrp = char:WaitForChild("HumanoidRootPart")
    createGUI()
end)

local carryStage = "middle"

while true do
    expandHitboxes()
    local carrying = char:FindFirstChild("RenderedBrainrot") ~= nil

    if carrying then
        local middlePos = PRE_CARRY_POS
        local finalPos = FINAL_EXECUTION_POS

        if carryStage == "middle" then
            local tweenInfo = TweenInfo.new((hrp.Position - middlePos).Magnitude / CARRY_TWEEN_SPEED, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(middlePos)})
            tween:Play()

            while tween.PlaybackState == Enum.PlaybackState.Playing do
                local target = getClosestBrainrot()
                carrying = char:FindFirstChild("RenderedBrainrot") ~= nil
                if carrying or target then -- Stop if carrying or any brainrot exists
                    tween:Cancel()
                    break
                end
                task.wait(0.05)
            end

            carryStage = "final"

        elseif carryStage == "final" then
            if (hrp.Position - finalPos).Magnitude > 1 then
                local dist = (hrp.Position - finalPos).Magnitude
                local tweenTime = math.max(dist / CARRY_TWEEN_SPEED, MIN_TWEEN_TIME)
                local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime), {CFrame = CFrame.new(finalPos)})
                tween:Play()
                tween.Completed:Wait()
            end

            task.wait(arrivalDelay)
        end

    else
        carryStage = "middle"
        -- Tween to middle if no brainrots at all
        local target = getClosestBrainrot()
        if not target then
            local middlePos = PRE_CARRY_POS
            local tweenInfo = TweenInfo.new((hrp.Position - middlePos).Magnitude / CARRY_TWEEN_SPEED, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(middlePos)})
            tween:Play()
            tween.Completed:Wait()
        end
    end

    -- Auto-Harpoon
    if autoHarpoonEnabled then
        local target = getClosestBrainrot()
        if target and target.Parent then
            local targetPos = target.Position + Vector3.new(55, heightOffset, 0)
            local distance = (hrp.Position - targetPos).Magnitude
            if distance > 175 then
                local tweenTime = math.max(distance / tweenSpeed, MIN_TWEEN_TIME)
                local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime), {CFrame = CFrame.new(targetPos)})
                tween:Play()
            end

            local now = tick()
            if (hrp.Position - target.Position).Magnitude <= fireRange and now - lastHarpoonTime >= HARPOON_COOLDOWN then
                lastHarpoonTime = now
                pcall(function()
                    harpoonRemote:FireServer(target.Position)
                end)
            end
        end
    end

    task.wait(ARRIVAL_THRESHOLD)
end
