local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CONFIG = {
    BEHIND_STUDS = 3,
    HEIGHT_OFFSET = 0,
    FPS_BOOST = false,
    EMERGENCY_HP = 30,
    SAFE_ZONE = false,
    AUTO_RESET = false,
    RESET_THRESHOLD = 0.30,
    SAFE_DEPTH = 80,
    SAFE_HEIGHT = 130,
    PING_COMPENSATE = true,
    PREDICTION_MULT = 1.0,
    PING_SAFETY = 1.3,
    MAX_LEAD_TIME = 0.12,
    SMOOTH_FACTOR = 0.15,
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptHizolonPrivatSSPlus"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 210, 0, 265)
MainFrame.Position = UDim2.new(0.5, -105, 0.5, -132)
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
Title.Size = UDim2.new(1, -48, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "SCRIPT HIZOLON PRIVAT SS+"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 7, 0, 0)
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Position = UDim2.new(1, -21, 0, 0)
CloseButton.Size = UDim2.new(0, 21, 0, 21)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 11
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseButton

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "Minimize"
MinimizeButton.Position = UDim2.new(1, -42, 0, 0)
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
    MainFrame.Size = UDim2.fromOffset(210, minimized and 21 or 265)
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
local FPSToggle = makeToggle("FPS BOOST", 7, 196)
FPSToggle.Position = UDim2.new(0, 7, 0, 258)

local function paintToggle(button, title, enabled)
    button.Text = title .. (enabled and ": ON" or ": OFF")
    button.TextColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 80, 80)
end

paintToggle(SafeToggle, "SAVE ZONA", CONFIG.SAFE_ZONE)
paintToggle(ResetToggle, "AUTO RESET", CONFIG.AUTO_RESET)
paintToggle(FPSToggle, "FPS BOOST", CONFIG.FPS_BOOST)

local SelectedTarget = nil
local PlayerButtons = {}
local BackstabActive = false
local PositionConnection = nil
local HealthConnection = nil
local SafePlatform = nil
local SafeReturn = nil
local SafeMode = nil
local EmergencyActive = false
local PreviousAutoRotate = nil
local CharacterConnection = nil
local CleanupConnections = {}
local DeathConnection = nil
local ResetInProgress = false
local CurrentTrackedHumanoid = nil

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

local FPSBoost = {}
local OriginalTextures = setmetatable({}, {__mode = "k"})
local OriginalMaterials = setmetatable({}, {__mode = "k"})
local OriginalSky = nil
local OriginalAtmosphere = nil
local OriginalClouds = nil
local FPSActive = false
local FPSDescendantConnection = nil
local FPSWorldConnection = nil

local function boostObj(obj)
    if not obj or not obj.Parent then return end
    if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then
        if OriginalTextures[obj] == nil then
            OriginalTextures[obj] = obj.Texture or obj.ColorMap or true
        end
        if obj:IsA("SurfaceAppearance") then
            obj.ColorMap = ""
            obj.NormalMap = ""
            obj.RoughnessMap = ""
            obj.MetalnessMap = ""
        else
            obj.Texture = ""
        end
    elseif obj:IsA("MeshPart") then
        if obj.TextureID and obj.TextureID ~= "" then
            if OriginalTextures[obj] == nil then
                OriginalTextures[obj] = obj.TextureID
            end
            obj.TextureID = ""
        end
    elseif obj:IsA("Sky") then
        if OriginalSky == nil then
            OriginalSky = {
                SkyboxBk = obj.SkyboxBk,
                SkyboxDn = obj.SkyboxDn,
                SkyboxFt = obj.SkyboxFt,
                SkyboxLf = obj.SkyboxLf,
                SkyboxRt = obj.SkyboxRt,
                SkyboxUp = obj.SkyboxUp,
            }
        end
        obj.SkyboxBk = ""
        obj.SkyboxDn = ""
        obj.SkyboxFt = ""
        obj.SkyboxLf = ""
        obj.SkyboxRt = ""
        obj.SkyboxUp = ""
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke")
        or obj:IsA("Sparkles") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("Explosion") then
        obj.Enabled = false
    elseif obj:IsA("BasePart") then
        if OriginalMaterials[obj] == nil then
            OriginalMaterials[obj] = obj.Material
        end
        obj.Material = Enum.Material.SmoothPlastic
    end
end

function FPSBoost.apply()
    if FPSActive then return end
    FPSActive = true
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(boostObj, obj)
    end
    for _, obj in ipairs(workspace:GetChildren()) do
        pcall(boostObj, obj)
    end
    local atmo = workspace:FindFirstChildOfClass("Atmosphere")
    if atmo then
        if OriginalAtmosphere == nil then
            OriginalAtmosphere = {
                Density = atmo.Density,
                Haze = atmo.Haze,
                Glare = atmo.Glare,
            }
        end
        atmo.Density = 0
        atmo.Haze = 0
        atmo.Glare = 0
    end
    local clouds = workspace:FindFirstChildOfClass("Clouds")
    if clouds then
        if OriginalClouds == nil then
            OriginalClouds = { Cover = clouds.Cover, Density = clouds.Density }
        end
        clouds.Cover = 0
        clouds.Density = 0
    end
    if FPSDescendantConnection then FPSDescendantConnection:Disconnect() end
    FPSDescendantConnection = workspace.DescendantAdded:Connect(function(obj)
        if FPSActive then
            pcall(boostObj, obj)
        end
    end)
    if FPSWorldConnection then FPSWorldConnection:Disconnect() end
    FPSWorldConnection = workspace.ChildAdded:Connect(function(obj)
        if FPSActive then
            pcall(boostObj, obj)
        end
    end)
end

function FPSBoost.remove()
    if not FPSActive then return end
    FPSActive = false
    if FPSDescendantConnection then FPSDescendantConnection:Disconnect(); FPSDescendantConnection = nil end
    if FPSWorldConnection then FPSWorldConnection:Disconnect(); FPSWorldConnection = nil end
    for obj, original in pairs(OriginalTextures) do
        if obj and obj.Parent then
            pcall(function()
                if obj:IsA("SurfaceAppearance") then
                    if original ~= true then obj.ColorMap = original end
                elseif obj:IsA("MeshPart") then
                    obj.TextureID = original
                else
                    obj.Texture = original
                end
            end)
        end
        OriginalTextures[obj] = nil
    end
    for obj, original in pairs(OriginalMaterials) do
        if obj and obj.Parent then
            pcall(function() obj.Material = original end)
        end
        OriginalMaterials[obj] = nil
    end
    if OriginalSky then
        local sky = workspace:FindFirstChildOfClass("Sky")
        if sky then
            pcall(function()
                sky.SkyboxBk = OriginalSky.SkyboxBk
                sky.SkyboxDn = OriginalSky.SkyboxDn
                sky.SkyboxFt = OriginalSky.SkyboxFt
                sky.SkyboxLf = OriginalSky.SkyboxLf
                sky.SkyboxRt = OriginalSky.SkyboxRt
                sky.SkyboxUp = OriginalSky.SkyboxUp
            end)
        end
        OriginalSky = nil
    end
    if OriginalAtmosphere then
        local atmo = workspace:FindFirstChildOfClass("Atmosphere")
        if atmo then
            pcall(function()
                atmo.Density = OriginalAtmosphere.Density
                atmo.Haze = OriginalAtmosphere.Haze
                atmo.Glare = OriginalAtmosphere.Glare
            end)
        end
        OriginalAtmosphere = nil
    end
    if OriginalClouds then
        local clouds = workspace:FindFirstChildOfClass("Clouds")
        if clouds then
            pcall(function()
                clouds.Cover = OriginalClouds.Cover
                clouds.Density = OriginalClouds.Density
            end)
        end
        OriginalClouds = nil
    end
end

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

local StopBackstab

local function emergencyRetreat()
    if ResetInProgress then return end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return end
    ResetInProgress = true
    local y = math.min(-CONFIG.SAFE_DEPTH, workspace.FallenPartsDestroyHeight - 15)
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
    CurrentTrackedHumanoid = hum
    local function checkHealth(health)
        if CONFIG.AUTO_RESET and not ResetInProgress and health > 0
            and hum.MaxHealth > 0 and health / hum.MaxHealth <= CONFIG.RESET_THRESHOLD then
            emergencyRetreat()
        end
    end
    HealthConnection = hum.HealthChanged:Connect(checkHealth)
    DeathConnection = hum.Died:Connect(function()
    end)
    checkHealth(hum.Health)
end

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
            local axis = angVel.Unit
            local rotDelta = CFrame.fromAxisAngle(axis, angle)
            predictedLook = (rotDelta * targetLook).Unit
        end
        predictedPos = predictedPos + Vector3.new(0, vel.Y * leadTime * 0.5, 0)
    end
    local behindPos = predictedPos - predictedLook * CONFIG.BEHIND_STUDS
    behindPos = behindPos + Vector3.new(0, CONFIG.HEIGHT_OFFSET, 0)
    local facePos = Vector3.new(predictedPos.X, behindPos.Y, predictedPos.Z)
    if (facePos - behindPos).Magnitude < 0.01 then return CFrame.new(behindPos) end
    local faceCFrame = CFrame.lookAt(behindPos, facePos)
    return faceCFrame
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

function UpdateStatus()
    if BackstabActive then
        if SelectedTarget then
            StatusLabel.Text = "Backstabbing: " .. SelectedTarget.Name
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        else
            StatusLabel.Text = "No target selected"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    else
        if SelectedTarget then
            StatusLabel.Text = "Target: " .. SelectedTarget.Name
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            StatusLabel.Text = "Select target to backstab"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
end

local function RefreshPlayerList()
    for _, child in pairs(PlayerScrollFrame:GetChildren()) do
        child:Destroy()
    end
    PlayerButtons = {}
    local PlayerList = Players:GetPlayers()
    table.sort(PlayerList, function(a, b) return a.Name:lower() < b.Name:lower() end)
    local yPosition = 4
    for _, player in ipairs(PlayerList) do
        if player ~= Player then
            local PlayerEntry = Instance.new("Frame")
            PlayerEntry.Size = UDim2.new(1, -7, 0, 21)
            PlayerEntry.Position = UDim2.new(0, 4, 0, yPosition)
            PlayerEntry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            PlayerEntry.BorderSizePixel = 0
            PlayerEntry.Parent = PlayerScrollFrame
            local EntryCorner = Instance.new("UICorner")
            EntryCorner.CornerRadius = UDim.new(0, 4)
            EntryCorner.Parent = PlayerEntry
            local Checkbox = Instance.new("TextButton")
            Checkbox.Size = UDim2.new(0, 17, 0, 17)
            Checkbox.Position = UDim2.new(0, 2, 0.5, -8)
            Checkbox.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            Checkbox.BorderSizePixel = 0
            Checkbox.Text = ""
            Checkbox.Parent = PlayerEntry
            local CheckCorner = Instance.new("UICorner")
            CheckCorner.CornerRadius = UDim.new(0, 3)
            CheckCorner.Parent = Checkbox
            local Checkmark = Instance.new("TextLabel")
            Checkmark.Size = UDim2.new(1, 0, 1, 0)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✓"
            Checkmark.TextColor3 = Color3.fromRGB(0, 255, 0)
            Checkmark.TextSize = 12
            Checkmark.Font = Enum.Font.SourceSansBold
            Checkmark.Visible = (SelectedTarget == player)
            Checkmark.Parent = Checkbox
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -25, 1, 0)
            NameLabel.Position = UDim2.new(0, 21, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = player.Name
            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLabel.TextSize = 11
            NameLabel.Font = Enum.Font.SourceSans
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = PlayerEntry
            local ClickArea = Instance.new("TextButton")
            ClickArea.Size = UDim2.new(1, 0, 1, 0)
            ClickArea.BackgroundTransparency = 1
            ClickArea.Text = ""
            ClickArea.ZIndex = 2
            ClickArea.Parent = PlayerEntry
            ClickArea.MouseButton1Click:Connect(function()
                if SelectedTarget == player then
                    SelectedTarget = nil
                    Checkmark.Visible = false
                else
                    SelectedTarget = player
                    for _, data in pairs(PlayerButtons) do
                        data.Checkmark.Visible = false
                    end
                    Checkmark.Visible = true
                end
                UpdateStatus()
            end)
            PlayerButtons[player.Name] = {
                Entry = PlayerEntry,
                Checkmark = Checkmark
            }
            yPosition = yPosition + 25
        end
    end
    PlayerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition + 4)
end

local function Message(Title, Text, Time)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = Title,
            Text = Text,
            Duration = Time or 5
        })
    end)
end

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

StopBackstab = function()
    if not BackstabActive then return end
    BackstabActive = false
    if PositionConnection then PositionConnection:Disconnect() PositionConnection = nil end
    local myHum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if myHum and PreviousAutoRotate ~= nil then myHum.AutoRotate = PreviousAutoRotate end
    PreviousAutoRotate = nil
    UpdateStatus()
    Message("Script Hizolon Privat SS+", "Backstab stopped", 2)
end

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

FPSToggle.MouseButton1Click:Connect(function()
    CONFIG.FPS_BOOST = not CONFIG.FPS_BOOST
    if CONFIG.FPS_BOOST then
        FPSBoost.apply()
    else
        FPSBoost.remove()
    end
    paintToggle(FPSToggle, "FPS BOOST", CONFIG.FPS_BOOST)
end)

ResetToggle.MouseButton1Click:Connect(function()
    CONFIG.AUTO_RESET = not CONFIG.AUTO_RESET
    paintToggle(ResetToggle, "AUTO RESET", CONFIG.AUTO_RESET)
    if CONFIG.AUTO_RESET then
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and hum.MaxHealth > 0 and hum.Health / hum.MaxHealth < CONFIG.RESET_THRESHOLD then
            emergencyRetreat()
        end
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    StopBackstab()
    removeSafeZone(true)
    if CONFIG.FPS_BOOST then
        FPSBoost.remove()
        CONFIG.FPS_BOOST = false
    end
    if HealthConnection then HealthConnection:Disconnect() end
    if DeathConnection then DeathConnection:Disconnect() end
    if CharacterConnection then CharacterConnection:Disconnect() end
    for _, conn in ipairs(CleanupConnections) do conn:Disconnect() end
    ScreenGui:Destroy()
end)

table.insert(CleanupConnections, Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    RefreshPlayerList()
end))

table.insert(CleanupConnections, Players.PlayerRemoving:Connect(function(player)
    if SelectedTarget == player then
        SelectedTarget = nil
    end
    task.wait(0.1)
    RefreshPlayerList()
    UpdateStatus()
end))

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

RefreshPlayerList()
UpdateStatus()
Message("Script Hizolon Privat SS+", "Loaded successfully!", 3)
