-- HIZOLON PRIVAT SS+ v5.3 | LocalScript
-- FPS BOOST (full, no notifications) + ESP + Backstab positioner
-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local MaterialService = game:GetService("MaterialService")
local Player = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG = {
    BEHIND_STUDS = 3,
    HEIGHT_OFFSET = 0,
    AUTO_RESET = false,
    RESET_THRESHOLD = 0.30,
    SAFE_DEPTH = 80,
    SAFE_HEIGHT = 130,
    PING_COMPENSATE = true,
    PREDICTION_MULT = 1.0,
    PING_SAFETY = 1.3,
    MAX_LEAD_TIME = 0.12,
    FPS_BOOST = false,
    ESP = false,
    SAFE_ZONE = false,

    -- FPS BOOST настройки (адаптировано из RIP#6666, без уведомлений)
    FPS_SETTINGS = {
        Players = {
            ["Ignore Me"] = true,
            ["Ignore Others"] = true,
            ["Ignore Tools"] = true,
        },
        Meshes = {
            NoMesh = false,
            NoTexture = false,
            Destroy = false,
        },
        Images = {
            Invisible = true,
            Destroy = false,
        },
        Explosions = {
            Smaller = true,
            Invisible = false,
            Destroy = false,
        },
        Particles = {
            Invisible = true,
            Destroy = false,
        },
        TextLabels = {
            LowerQuality = false,
            Invisible = false,
            Destroy = false,
        },
        MeshParts = {
            LowerQuality = true,
            Invisible = false,
            NoTexture = false,
            NoMesh = false,
            Destroy = false,
        },
        Other = {
            ["FPS Cap"] = true,
            ["No Camera Effects"] = true,
            ["No Clothes"] = true,
            ["Low Water Graphics"] = true,
            ["No Shadows"] = true,
            ["Low Rendering"] = true,
            ["Low Quality Parts"] = true,
            ["Low Quality Models"] = true,
            ["Reset Materials"] = true,
            ["Lower Quality MeshParts"] = true,
            ClearNilInstances = false,
        },
    },
    FPS_IGNORE = {}, -- объекты, которые не трогать: {workspace.Map, workspace.Map2}
    FPS_LOADED_WAIT = 1,
}

-- ============================================================
-- GUI PARENT
-- ============================================================
local function getGuiParent()
    local ok, parent = pcall(function() return CoreGui end)
    if ok and parent then return parent end
    return Player:WaitForChild("PlayerGui")
end

-- ============================================================
-- GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptHizolonPrivatSSPlus"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = getGuiParent()

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 210, 0, 286)
MainFrame.Position = UDim2.new(0.5, -105, 0.5, -143)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainFrameStroke = Instance.new("UIStroke")
MainFrameStroke.Color = Color3.fromRGB(255, 80, 80)
MainFrameStroke.Thickness = 1.2
MainFrameStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 21)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 4)
TitleBarCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -26, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "SCRIPT HIZOLON PRIVAT SS+"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 7, 0, 0)
Title.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "Minimize"
MinimizeButton.Position = UDim2.new(1, -21, 0, 0)
MinimizeButton.Size = UDim2.fromOffset(21, 21)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 15
MinimizeButton.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 4)
MinCorner.Parent = MinimizeButton

local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    MainFrame.Size = UDim2.fromOffset(210, minimized and 21 or 286)
    MinimizeButton.Text = minimized and "+" or "-"
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child:IsA("GuiObject") and child ~= TitleBar then
            child.Visible = not minimized
        end
    end
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 7, 0, 28)
StatusLabel.Size = UDim2.new(1, -14, 0, 18)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Select target to backstab"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local SelectionFrame = Instance.new("Frame")
SelectionFrame.Position = UDim2.new(0, 7, 0, 49)
SelectionFrame.Size = UDim2.new(1, -14, 0, 140)
SelectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SelectionFrame.BorderSizePixel = 0
SelectionFrame.Parent = MainFrame

local SelectionCorner = Instance.new("UICorner")
SelectionCorner.CornerRadius = UDim.new(0, 4)
SelectionCorner.Parent = SelectionFrame

local PlayerScrollFrame = Instance.new("ScrollingFrame")
PlayerScrollFrame.Position = UDim2.new(0, 4, 0, 4)
PlayerScrollFrame.Size = UDim2.new(1, -8, 1, -8)
PlayerScrollFrame.BackgroundTransparency = 1
PlayerScrollFrame.BorderSizePixel = 0
PlayerScrollFrame.ScrollBarThickness = 4
PlayerScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 80, 80)
PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScrollFrame.Parent = SelectionFrame

local StartButton = Instance.new("TextButton")
StartButton.Position = UDim2.new(0, 7, 0, 196)
StartButton.Size = UDim2.new(0.5, -10, 0, 28)
StartButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
StartButton.BorderSizePixel = 0
StartButton.Text = "START"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Font = Enum.Font.SourceSansBold
StartButton.TextSize = 12
StartButton.Parent = MainFrame

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 4)
StartCorner.Parent = StartButton

local StopButton = Instance.new("TextButton")
StopButton.Position = UDim2.new(0.5, 3, 0, 196)
StopButton.Size = UDim2.new(0.5, -10, 0, 28)
StopButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
StopButton.BorderSizePixel = 0
StopButton.Text = "STOP"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.Font = Enum.Font.SourceSansBold
StopButton.TextSize = 12
StopButton.Parent = MainFrame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 4)
StopCorner.Parent = StopButton

local function makeToggle(name, x, width)
    local button = Instance.new("TextButton")
    button.Name = name:gsub(" ", "")
    button.Position = UDim2.new(0, x, 0, 231)
    button.Size = UDim2.new(0, width, 0, 21)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(255, 80, 80)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 10
    button.Parent = MainFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    return button
end

local SafeToggle = makeToggle("SAVE ZONA", 7, 94)
local ResetToggle = makeToggle("AUTO RESET", 108, 95)
local FpsBoostToggle = makeToggle("FPS BOOST", 7, 94)
FpsBoostToggle.Position = UDim2.new(0, 7, 0, 258)
local EspToggle = makeToggle("ESP", 108, 95)
EspToggle.Position = UDim2.new(0, 108, 0, 258)

local function paintToggle(button, title, enabled)
    button.Text = title .. (enabled and ": ON" or ": OFF")
    button.TextColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 80, 80)
end

paintToggle(SafeToggle, "SAVE ZONA", CONFIG.SAFE_ZONE)
paintToggle(ResetToggle, "AUTO RESET", CONFIG.AUTO_RESET)
paintToggle(FpsBoostToggle, "FPS BOOST", CONFIG.FPS_BOOST)
paintToggle(EspToggle, "ESP", CONFIG.ESP)

-- ============================================================
-- STATE
-- ============================================================
local SelectedTarget = nil
local PlayerButtons = {}
local BackstabActive = false
local PositionConnection = nil
local HealthConnection = nil
local DeathConnection = nil
local SafePlatform = nil
local SafeReturn = nil
local SafeMode = nil
local PreviousAutoRotate = nil
local CharacterConnection = nil
local CleanupConnections = {}
local ResetInProgress = false

local FpsBoostConnection = nil
local FpsAddConnection = nil
local FpsHidden = setmetatable({}, {__mode = "k"})
local EspGui = nil
local EspConnection = nil
local EspEntries = {}

-- ============================================================
-- UTILITIES
-- ============================================================
local function getPing()
    local ok, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ok and ping or 50
end
local function isAlive(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end
local function getHRP(plr)
    if not plr or not plr.Character then return nil end
    return plr.Character:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
-- SAFE ZONE / AUTO RESET
-- ============================================================
local function removeSafeZone(restorePosition)
    if restorePosition and SafeReturn then
        local hrp = getHRP(Player)
        if hrp then
            hrp.CFrame = SafeReturn
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
    if SafePlatform then SafePlatform:Destroy(); SafePlatform = nil end
    SafeReturn = nil
    SafeMode = nil
end

local function createSafeZone(mode)
    local hrp = getHRP(Player)
    if not hrp then return false end
    if SafePlatform then SafePlatform:Destroy(); SafePlatform = nil end
    SafeReturn = SafeReturn or hrp.CFrame
    SafeMode = mode or "above"
    local y = SafeMode == "below" and -CONFIG.SAFE_DEPTH or CONFIG.SAFE_HEIGHT
    local destination = Vector3.new(hrp.Position.X, y, hrp.Position.Z)
    local platform = Instance.new("Part")
    platform.Name = "HizolonLocalSafeZone"
    platform.Size = Vector3.new(28, 2, 28)
    platform.Anchored = true
    platform.CanCollide = true
    platform.CanTouch = false
    platform.CanQuery = false
    platform.CastShadow = false
    platform.Material = Enum.Material.SmoothPlastic
    platform.Color = Color3.fromRGB(0, 0, 0)
    platform.Transparency = SafeMode == "below" and 1 or 0.65
    platform.CFrame = CFrame.new(destination)
    platform.Parent = workspace
    SafePlatform = platform
    hrp.CFrame = CFrame.new(destination + Vector3.new(0, 5, 0))
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function emergencyRetreat()
    if ResetInProgress then return end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return end
    ResetInProgress = true
    local y = -CONFIG.SAFE_DEPTH
    pcall(function()
        y = math.min(y, workspace.FallenPartsDestroyHeight - 15)
    end)
    hrp.CFrame = CFrame.new(hrp.Position.X, y, hrp.Position.Z)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    StatusLabel.Text = "AUTO RESET: LOW HP"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 180, 40)
    hum.Health = 0
end

local function monitorHealth(character)
    if HealthConnection then HealthConnection:Disconnect(); HealthConnection = nil end
    if DeathConnection then DeathConnection:Disconnect(); DeathConnection = nil end
    ResetInProgress = false
    local hum = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
    if not hum then return end
    local function checkHealth(health)
        if CONFIG.AUTO_RESET and not ResetInProgress and health > 0
            and hum.MaxHealth > 0 and health / hum.MaxHealth <= CONFIG.RESET_THRESHOLD then
            emergencyRetreat()
        end
    end
    HealthConnection = hum.HealthChanged:Connect(checkHealth)
    DeathConnection = hum.Died:Connect(function()
        if CONFIG.AUTO_RESET then
            for _, obj in ipairs(character:GetDescendants()) do
                if obj:IsA("BasePart") then obj.LocalTransparencyModifier = 1 end
            end
        end
    end)
    checkHealth(hum.Health)
end

-- ============================================================
-- POSITIONER
-- ============================================================
local Positioner = {}
function Positioner.getBehindCFrame(targetHRP)
    if not targetHRP then return nil end
    local targetCF = targetHRP.CFrame
    local targetPos = targetHRP.Position
    local targetLook = targetCF.LookVector
    local pingRaw = getPing() / 1000
    local leadTime = math.min(pingRaw * CONFIG.PING_SAFETY, CONFIG.MAX_LEAD_TIME)
    local predictedPos = targetPos
    local predictedLook = targetLook
    if CONFIG.PING_COMPENSATE then
        local vel = targetHRP.AssemblyLinearVelocity
        local predMult = math.clamp(CONFIG.PREDICTION_MULT, 0.5, 1.5)
        predictedPos = targetPos + vel * leadTime * predMult
        local angVel = targetHRP.AssemblyAngularVelocity
        if angVel.Magnitude > 0.1 then
            local angle = angVel.Magnitude * leadTime * predMult
            angle = math.clamp(angle, -math.pi / 2, math.pi / 2)
            local rotDelta = CFrame.fromAxisAngle(angVel.Unit, angle)
            predictedLook = (rotDelta * targetLook).Unit
        end
        predictedPos = predictedPos + Vector3.new(0, vel.Y * leadTime * 0.5, 0)
    end
    local behindPos = predictedPos - predictedLook * CONFIG.BEHIND_STUDS
    behindPos = behindPos + Vector3.new(0, CONFIG.HEIGHT_OFFSET, 0)
    local facePos = Vector3.new(predictedPos.X, behindPos.Y, predictedPos.Z)
    if (facePos - behindPos).Magnitude < 0.01 then return CFrame.new(behindPos) end
    return CFrame.lookAt(behindPos, facePos)
end
function Positioner.teleport()
    if ResetInProgress or not SelectedTarget or not isAlive(SelectedTarget) then return end
    local targetHRP = getHRP(SelectedTarget)
    local myHRP = getHRP(Player)
    if not targetHRP or not myHRP then return end
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    if hum.AutoRotate then hum.AutoRotate = false end
    local newCF = Positioner.getBehindCFrame(targetHRP)
    if not newCF then return end
    myHRP.CFrame = newCF
    myHRP.AssemblyLinearVelocity = Vector3.zero
    myHRP.AssemblyAngularVelocity = Vector3.zero
end

-- ============================================================
-- STATUS
-- ============================================================
function UpdateStatus()
    if BackstabActive and SelectedTarget then
        StatusLabel.Text = "Backstabbing: " .. SelectedTarget.Name
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    elseif SelectedTarget then
        StatusLabel.Text = "Target: " .. SelectedTarget.Name
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        StatusLabel.Text = "Select target to backstab"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- ============================================================
-- PLAYER LIST  (Никнейм (@Username))
-- ============================================================
local function RefreshPlayerList()
    for _, child in pairs(PlayerScrollFrame:GetChildren()) do child:Destroy() end
    PlayerButtons = {}
    local list = Players:GetPlayers()
    table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)
    local y = 4
    for _, plr in ipairs(list) do
        if plr ~= Player then
            local entry = Instance.new("Frame")
            entry.Size = UDim2.new(1, -7, 0, 21)
            entry.Position = UDim2.new(0, 4, 0, y)
            entry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            entry.BorderSizePixel = 0
            entry.Parent = PlayerScrollFrame

            local c1 = Instance.new("UICorner")
            c1.CornerRadius = UDim.new(0, 4)
            c1.Parent = entry

            local check = Instance.new("TextButton")
            check.Size = UDim2.new(0, 17, 0, 17)
            check.Position = UDim2.new(0, 2, 0.5, -8)
            check.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            check.BorderSizePixel = 0
            check.Text = ""
            check.Parent = entry

            local c2 = Instance.new("UICorner")
            c2.CornerRadius = UDim.new(0, 3)
            c2.Parent = check

            local mark = Instance.new("TextLabel")
            mark.Size = UDim2.new(1, 0, 1, 0)
            mark.BackgroundTransparency = 1
            mark.Text = "✓"
            mark.TextColor3 = Color3.fromRGB(0, 255, 0)
            mark.TextSize = 12
            mark.Font = Enum.Font.SourceSansBold
            mark.Visible = (SelectedTarget == plr)
            mark.Parent = check

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -25, 1, 0)
            nameLabel.Position = UDim2.new(0, 21, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 11
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = entry

            local click = Instance.new("TextButton")
            click.Size = UDim2.new(1, 0, 1, 0)
            click.BackgroundTransparency = 1
            click.Text = ""
            click.ZIndex = 2
            click.Parent = entry

            click.MouseButton1Click:Connect(function()
                if SelectedTarget == plr then
                    SelectedTarget = nil
                    mark.Visible = false
                else
                    SelectedTarget = plr
                    for _, d in pairs(PlayerButtons) do d.mark.Visible = false end
                    mark.Visible = true
                end
                UpdateStatus()
            end)

            PlayerButtons[plr.Name] = { mark = mark }
            y = y + 25
        end
    end
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, y + 4)
end

-- ============================================================
-- NOTIFICATION (только HIZOLON — свои)
-- ============================================================
local function Message(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = duration or 5 })
    end)
end

-- ============================================================
-- FPS BOOST (полный, без уведомлений)
-- ============================================================
local FPS_CAN_BE_ENABLED = { "ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles" }
local FPS_SET = CONFIG.FPS_SETTINGS

local function isPartOfOtherCharacter(inst)
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and inst:IsDescendantOf(v.Character) then
            return true
        end
    end
    return false
end

local function isDescendantOfIgnore(inst)
    for _, v in ipairs(CONFIG.FPS_IGNORE) do
        if typeof(v) == "Instance" and inst:IsDescendantOf(v) then
            return true
        end
    end
    return false
end

local function remember(obj, kind, value)
    if FpsHidden[obj] == nil then
        FpsHidden[obj] = { kind = kind, value = value }
    end
end

local function checkIfBad(inst)
    if not inst or not inst.Parent then return end
    if isDescendantOfIgnore(inst) then return end

    -- Пропуск игроков / себя / инструментов
    if FPS_SET.Players["Ignore Others"] and isPartOfOtherCharacter(inst) then return end
    if FPS_SET.Players["Ignore Me"] and Player.Character and inst:IsDescendantOf(Player.Character) then return end
    if FPS_SET.Players["Ignore Tools"] and (inst:IsA("BackpackItem") or inst:FindFirstAncestorWhichIsA("BackpackItem")) then return end
    if inst:IsDescendantOf(Players) then return end

    -- DataModelMesh
    if inst:IsA("DataModelMesh") then
        if inst:IsA("SpecialMesh") then
            if FPS_SET.Meshes.NoMesh then
                remember(inst, "meshId", inst.MeshId)
                pcall(function() inst.MeshId = "" end)
            end
            if FPS_SET.Meshes.NoTexture then
                remember(inst, "textureId", inst.TextureId)
                pcall(function() inst.TextureId = "" end)
            end
        end
        if FPS_SET.Meshes.Destroy then inst:Destroy() end
        return
    end

    -- FaceInstance
    if inst:IsA("FaceInstance") then
        if FPS_SET.Images.Invisible then
            remember(inst, "transparency", inst.Transparency)
            remember(inst, "shiny", inst.Shiny)
            pcall(function() inst.Transparency = 1; inst.Shiny = 1 end)
        end
        if FPS_SET.Images.Destroy then inst:Destroy() end
        return
    end

    -- ShirtGraphic
    if inst:IsA("ShirtGraphic") then
        if FPS_SET.Images.Invisible then
            remember(inst, "graphic", inst.Graphic)
            pcall(function() inst.Graphic = "" end)
        end
        if FPS_SET.Images.Destroy then inst:Destroy() end
        return
    end

    -- Particles / Trails / etc
    if table.find(FPS_CAN_BE_ENABLED, inst.ClassName) then
        if FPS_SET.Particles.Invisible then
            remember(inst, "enabled", inst.Enabled)
            pcall(function() inst.Enabled = false end)
        end
        if FPS_SET.Particles.Destroy then inst:Destroy() end
        return
    end

    -- PostEffect
    if inst:IsA("PostEffect") and FPS_SET.Other["No Camera Effects"] then
        remember(inst, "enabled", inst.Enabled)
        pcall(function() inst.Enabled = false end)
        return
    end

    -- Explosion
    if inst:IsA("Explosion") then
        if FPS_SET.Explosions.Smaller or FPS_SET.Explosions.Invisible then
            remember(inst, "blastPressure", inst.BlastPressure)
            remember(inst, "blastRadius", inst.BlastRadius)
            pcall(function() inst.BlastPressure = 1; inst.BlastRadius = 1 end)
        end
        if FPS_SET.Explosions.Invisible then
            remember(inst, "visible", inst.Visible)
            pcall(function() inst.Visible = false end)
        end
        if FPS_SET.Explosions.Destroy then inst:Destroy() end
        return
    end

    -- Одежда / SurfaceAppearance / BaseWrap
    if (inst:IsA("Clothing") or inst:IsA("SurfaceAppearance") or inst:IsA("BaseWrap")) and FPS_SET.Other["No Clothes"] then
        inst:Destroy()
        return
    end

    -- BasePart (не MeshPart)
    if inst:IsA("BasePart") and not inst:IsA("MeshPart") then
        if FPS_SET.Other["Low Quality Parts"] then
            remember(inst, "material", inst.Material)
            remember(inst, "reflectance", inst.Reflectance)
            pcall(function() inst.Material = Enum.Material.Plastic; inst.Reflectance = 0 end)
        end
        return
    end

    -- TextLabel в workspace
    if inst:IsA("TextLabel") and inst:IsDescendantOf(workspace) then
        if FPS_SET.TextLabels.LowerQuality then
            remember(inst, "font", inst.Font)
            remember(inst, "textSize", inst.TextSize)
            remember(inst, "textScaled", inst.TextScaled)
            remember(inst, "richText", inst.RichText)
            pcall(function()
                inst.Font = Enum.Font.SourceSans
                inst.TextScaled = false
                inst.RichText = false
                inst.TextSize = 14
            end)
        end
        if FPS_SET.TextLabels.Invisible then
            remember(inst, "visible", inst.Visible)
            pcall(function() inst.Visible = false end)
        end
        if FPS_SET.TextLabels.Destroy then inst:Destroy() end
        return
    end

    -- Model
    if inst:IsA("Model") and FPS_SET.Other["Low Quality Models"] then
        remember(inst, "lod", inst.LevelOfDetail)
        pcall(function() inst.LevelOfDetail = 1 end)
        return
    end

    -- MeshPart
    if inst:IsA("MeshPart") then
        if FPS_SET.MeshParts.LowerQuality or FPS_SET.Other["Lower Quality MeshParts"] then
            remember(inst, "renderFidelity", inst.RenderFidelity)
            remember(inst, "reflectance", inst.Reflectance)
            remember(inst, "material", inst.Material)
            pcall(function()
                inst.RenderFidelity = Enum.RenderFidelity.Performance
                inst.Reflectance = 0
                inst.Material = Enum.Material.Plastic
            end)
        end
        if FPS_SET.MeshParts.Invisible then
            remember(inst, "transparency", inst.Transparency)
            pcall(function() inst.Transparency = 1 end)
        end
        if FPS_SET.MeshParts.NoTexture then
            remember(inst, "textureId", inst.TextureID)
            pcall(function() inst.TextureID = "" end)
        end
        if FPS_SET.MeshParts.NoMesh then
            remember(inst, "meshId", inst.MeshId)
            pcall(function() inst.MeshId = "" end)
        end
        if FPS_SET.MeshParts.Destroy then inst:Destroy() end
        return
    end
end

local function sweepFpsBoost()
    if not CONFIG.FPS_BOOST then return end
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(checkIfBad, obj)
    end
end

local function applyGlobalFpsSettings()
    -- Low Water Graphics
    if FPS_SET.Other["Low Water Graphics"] then
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            pcall(function()
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
            end)
            if sethiddenproperty then
                pcall(sethiddenproperty, terrain, "Decoration", false)
            end
        end
    end

    -- No Shadows
    if FPS_SET.Other["No Shadows"] then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.ShadowSoftness = 0
        end)
        if sethiddenproperty then
            pcall(sethiddenproperty, Lighting, "Technology", 2)
        end
    end

    -- Low Rendering
    if FPS_SET.Other["Low Rendering"] then
        pcall(function()
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end)
    end

    -- Reset Materials
    if FPS_SET.Other["Reset Materials"] then
        pcall(function()
            for _, v in ipairs(MaterialService:GetChildren()) do v:Destroy() end
            MaterialService.Use2022Materials = false
        end)
    end

    -- FPS Cap
    if FPS_SET.Other["FPS Cap"] then
        if setfpscap then
            pcall(setfpscap, 1e6)
        end
    end

    -- ClearNilInstances
    if FPS_SET.Other.ClearNilInstances and getnilinstances then
        pcall(function()
            for _, v in ipairs(getnilinstances()) do
                pcall(v.Destroy, v)
            end
        end)
    end
end

local function restoreGlobalFpsSettings()
    -- Откат только того, что можно откатить
    if FPS_SET.Other["Low Water Graphics"] then
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            pcall(function()
                terrain.WaterWaveSize = 0.15
                terrain.WaterWaveSpeed = 10
                terrain.WaterReflectance = 0.1
                terrain.WaterTransparency = 0.1
            end)
        end
    end
    if FPS_SET.Other["No Shadows"] then
        pcall(function()
            Lighting.GlobalShadows = true
            Lighting.ShadowSoftness = 0.2
        end)
    end
    if FPS_SET.Other["Low Rendering"] then
        pcall(function()
            settings().Rendering.QualityLevel = 21
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        end)
    end
    if FPS_SET.Other["FPS Cap"] and setfpscap then
        pcall(setfpscap, 60)
    end
end

local function startFpsBoost()
    if FpsBoostConnection then return end
    applyGlobalFpsSettings()
    sweepFpsBoost()
    FpsAddConnection = game.DescendantAdded:Connect(function(obj)
        if not CONFIG.FPS_BOOST then return end
        task.wait(CONFIG.FPS_LOADED_WAIT)
        if CONFIG.FPS_BOOST then
            pcall(checkIfBad, obj)
        end
    end)
    local acc = 0
    FpsBoostConnection = RunService.Heartbeat:Connect(function(dt)
        if not CONFIG.FPS_BOOST then return end
        acc = acc + dt
        if acc >= 2 then
            acc = 0
            sweepFpsBoost()
        end
    end)
end

local function stopFpsBoost()
    if FpsBoostConnection then FpsBoostConnection:Disconnect(); FpsBoostConnection = nil end
    if FpsAddConnection then FpsAddConnection:Disconnect(); FpsAddConnection = nil end
    -- Восстановление запомненных свойств
    for obj, data in pairs(FpsHidden) do
        if obj and obj.Parent then
            pcall(function()
                if data.kind == "transparency" then obj.Transparency = data.value
                elseif data.kind == "enabled" then obj.Enabled = data.value
                elseif data.kind == "material" then obj.Material = data.value
                elseif data.kind == "reflectance" then obj.Reflectance = data.value
                elseif data.kind == "renderFidelity" then obj.RenderFidelity = data.value
                elseif data.kind == "lod" then obj.LevelOfDetail = data.value
                elseif data.kind == "graphic" then obj.Graphic = data.value
                elseif data.kind == "textureId" then
                    if obj:IsA("MeshPart") then obj.TextureID = data.value
                    else obj.TextureId = data.value end
                elseif data.kind == "meshId" then obj.MeshId = data.value
                elseif data.kind == "font" then obj.Font = data.value
                elseif data.kind == "textSize" then obj.TextSize = data.value
                elseif data.kind == "textScaled" then obj.TextScaled = data.value
                elseif data.kind == "richText" then obj.RichText = data.value
                elseif data.kind == "visible" then obj.Visible = data.value
                elseif data.kind == "shiny" then obj.Shiny = data.value
                elseif data.kind == "blastPressure" then obj.BlastPressure = data.value
                elseif data.kind == "blastRadius" then obj.BlastRadius = data.value
                end
            end)
        end
        FpsHidden[obj] = nil
    end
    restoreGlobalFpsSettings()
end

-- ============================================================
-- ESP
-- ============================================================
local function createEspGui()
    if EspGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "HizolonESP"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = getGuiParent()
    EspGui = gui
end

local function destroyEspGui()
    if EspGui then EspGui:Destroy(); EspGui = nil end
    EspEntries = {}
end

local function ensureEspEntry(plr)
    local entry = EspEntries[plr]
    if entry and entry.frame and entry.frame.Parent then return entry end
    local frame = Instance.new("Frame")
    frame.Name = "Box_" .. plr.Name
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.ZIndex = 5
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = frame
    frame.Parent = EspGui

    local line = Instance.new("Frame")
    line.Name = "Line_" .. plr.Name
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    line.Visible = false
    line.ZIndex = 5
    line.Parent = EspGui

    entry = { frame = frame, line = line, stroke = stroke }
    EspEntries[plr] = entry
    return entry
end

local function updateEsp()
    if not EspGui then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    for plr, entry in pairs(EspEntries) do
        local hide = true
        if plr ~= Player and isAlive(plr) then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            if hrp and head then
                local headVec, headOn = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local footVec, footOn = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))
                if headOn or footOn then
                    local topY, botY = headVec.Y, footVec.Y
                    if topY > botY then topY, botY = botY, topY end
                    local height = math.max(botY - topY, 6)
                    local width = height * 0.55
                    local centerX = headVec.X
                    entry.frame.Position = UDim2.fromOffset(centerX - width / 2, topY)
                    entry.frame.Size = UDim2.fromOffset(width, height)
                    entry.frame.Visible = true
                    local lineTop = topY + height
                    local lineBottom = lineTop + math.max(height * 0.35, 8)
                    entry.line.Position = UDim2.fromOffset(centerX - 0.75, lineTop)
                    entry.line.Size = UDim2.fromOffset(1.5, lineBottom - lineTop)
                    entry.line.Visible = true
                    hide = false
                end
            end
        end
        if hide then
            entry.frame.Visible = false
            entry.line.Visible = false
        end
    end
end

local function startEsp()
    createEspGui()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then ensureEspEntry(plr) end
    end
    if EspConnection then return end
    EspConnection = RunService.RenderStepped:Connect(updateEsp)
end

local function stopEsp()
    if EspConnection then EspConnection:Disconnect(); EspConnection = nil end
    destroyEspGui()
end

-- ============================================================
-- START / STOP BACKSTAB
-- ============================================================
local function StartBackstab()
    if BackstabActive then return end
    if not SelectedTarget then
        StatusLabel.Text = "No target selected!"
        task.wait(1)
        UpdateStatus()
        return
    end
    BackstabActive = true
    local myHum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if myHum then
        PreviousAutoRotate = myHum.AutoRotate
        myHum.AutoRotate = false
    end
    UpdateStatus()
    Message("Script Hizolon Privat SS+", "Backstabbing " .. SelectedTarget.Name, 2)
    if CONFIG.SAFE_ZONE then
        removeSafeZone(false)
        CONFIG.SAFE_ZONE = false
        paintToggle(SafeToggle, "SAVE ZONA", false)
    end
    Positioner.teleport()
    PositionConnection = RunService.PreSimulation:Connect(function()
        pcall(Positioner.teleport)
    end)
end

local function StopBackstab()
    if not BackstabActive then return end
    BackstabActive = false
    if PositionConnection then PositionConnection:Disconnect(); PositionConnection = nil end
    local myHum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if myHum and PreviousAutoRotate ~= nil then myHum.AutoRotate = PreviousAutoRotate end
    PreviousAutoRotate = nil
    UpdateStatus()
    Message("Script Hizolon Privat SS+", "Backstab stopped", 2)
end

-- ============================================================
-- BUTTON CONNECTIONS
-- ============================================================
StartButton.MouseButton1Click:Connect(StartBackstab)
StopButton.MouseButton1Click:Connect(StopBackstab)

SafeToggle.MouseButton1Click:Connect(function()
    CONFIG.SAFE_ZONE = not CONFIG.SAFE_ZONE
    if CONFIG.SAFE_ZONE then
        if BackstabActive then StopBackstab() end
        createSafeZone("above")
    else
        removeSafeZone(true)
    end
    paintToggle(SafeToggle, "SAVE ZONA", CONFIG.SAFE_ZONE)
end)

ResetToggle.MouseButton1Click:Connect(function()
    CONFIG.AUTO_RESET = not CONFIG.AUTO_RESET
    paintToggle(ResetToggle, "AUTO RESET", CONFIG.AUTO_RESET)
    if CONFIG.AUTO_RESET then
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and hum.MaxHealth > 0
            and hum.Health / hum.MaxHealth < CONFIG.RESET_THRESHOLD then
            emergencyRetreat()
        end
    end
end)

FpsBoostToggle.MouseButton1Click:Connect(function()
    CONFIG.FPS_BOOST = not CONFIG.FPS_BOOST
    if CONFIG.FPS_BOOST then
        startFpsBoost()
    else
        stopFpsBoost()
    end
    paintToggle(FpsBoostToggle, "FPS BOOST", CONFIG.FPS_BOOST)
end)

EspToggle.MouseButton1Click:Connect(function()
    CONFIG.ESP = not CONFIG.ESP
    if CONFIG.ESP then
        startEsp()
    else
        stopEsp()
    end
    paintToggle(EspToggle, "ESP", CONFIG.ESP)
end)

-- ============================================================
-- PLAYER JOIN / LEAVE
-- ============================================================
table.insert(CleanupConnections, Players.PlayerAdded:Connect(function(plr)
    task.wait(0.5)
    RefreshPlayerList()
    if CONFIG.ESP and EspGui and plr ~= Player then ensureEspEntry(plr) end
end))

table.insert(CleanupConnections, Players.PlayerRemoving:Connect(function(plr)
    if SelectedTarget == plr then SelectedTarget = nil end
    local entry = EspEntries[plr]
    if entry then
        if entry.frame then entry.frame:Destroy() end
        if entry.line then entry.line:Destroy() end
        EspEntries[plr] = nil
    end
    task.wait(0.1)
    RefreshPlayerList()
    UpdateStatus()
end))

-- ============================================================
-- RESPAWN
-- ============================================================
CharacterConnection = Player.CharacterAdded:Connect(function(character)
    PreviousAutoRotate = nil
    if SafePlatform then removeSafeZone(false) end
    monitorHealth(character)
    if BackstabActive then
        local hum = character:WaitForChild("Humanoid", 10)
        if hum then PreviousAutoRotate = hum.AutoRotate; hum.AutoRotate = false end
    end
end)

if Player.Character then task.defer(monitorHealth, Player.Character) end

-- ============================================================
-- INIT
-- ============================================================
RefreshPlayerList()
UpdateStatus()
Message("Script Hizolon Privat SS+", "Loaded successfully!", 3)
