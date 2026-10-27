-- HIZOLON PRIVAT SS+ v5 | LocalScript / client-side behavior only
-- MOD: Positioner → Weld Attach (жёсткая привязка к цели)
--[[
SCRIPT HIZOLON PRIVAT SS+ (WELD ATTACH EDITION)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Невидимый персонаж
• Weld Attach — жёсткая привязка к цели (без задержки)
• Разворот ЛИЦОМ к цели
• Корректная пинг-компенсация (без перелёта)
• Управление через GUI
• Размер GUI: ×0.7
Стиль: HIZOLON Fling TSB
Версия: SS+ Weld
]]
-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG = {
    -- Weld Attach
    BEHIND_STUDS = 3,
    HEIGHT_OFFSET = 0,
    WELD_OFFSET = CFrame.new(0, 0, 3), -- смещение от цели при привязке
    -- Невидимость
    INVISIBLE = false,
    EMERGENCY_HP = 30,
    SAFE_ZONE = false,
    AUTO_RESET = false,
    RESET_THRESHOLD = 0.30, -- fraction of MaxHealth
    SAFE_DEPTH = 80,
    SAFE_HEIGHT = 130,
    -- Пинг-компенсация (умеренная, без «перелёта»)
    PING_COMPENSATE = true,
    PREDICTION_MULT = 1.0,
    PING_SAFETY = 1.3,
    -- Ограничения (внутренние)
    MAX_LEAD_TIME = 0.12,
    SMOOTH_FACTOR = 0.15,
}
-- ============================================================
-- GUI SETUP (стиль HIZOLON) — размер ×0.7
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptHizolonPrivatSSPlus"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui
-- Главное окно (300×380 → 210×266)
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
-- Заголовок (30 → 21)
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
Title.Text = "SCRIPT HIZOLON PRIVAT SS+ (WELD)"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 7, 0, 0)
Title.Parent = TitleBar
-- Кнопка закрытия (30×30 → 21×21)
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
-- Свернуть в заголовок без остановки функций
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
    MainFrame.Size = UDim2.fromOffset(210, minimized and 21 or 286)
    MinimizeButton.Text = minimized and "+" or "-"
    for _, child in ipairs(MainFrame:GetChildren()) do
        if child:IsA("GuiObject") and child ~= TitleBar then
            child.Visible = not minimized
        end
    end
end)
-- Статус
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 7, 0, 28)
StatusLabel.Size = UDim2.new(1, -14, 0, 18)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Select target to weld"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame
-- Рамка выбора цели (200 → 140)
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
-- Кнопка START (40 → 28)
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
-- Кнопка STOP
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
-- Два независимых переключателя
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
local InvisToggle = makeToggle("INVIS", 7, 196)
InvisToggle.Position = UDim2.new(0, 7, 0, 258)
local function paintToggle(button, title, enabled)
    button.Text = title .. (enabled and ": ON" or ": OFF")
    button.TextColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 80, 80)
end
paintToggle(SafeToggle, "SAVE ZONA", CONFIG.SAFE_ZONE)
paintToggle(ResetToggle, "AUTO RESET", CONFIG.AUTO_RESET)
paintToggle(InvisToggle, "INVIS", CONFIG.INVISIBLE)
-- ============================================================
-- VARIABLES
-- ============================================================
local SelectedTarget = nil
local PlayerButtons = {}
local BackstabActive = false
local PositionConnection = nil
local InvisConnection = nil
local HealthConnection = nil
local SafePlatform = nil
local SafeReturn = nil
local SafeMode = nil
local EmergencyActive = false
local PreviousAutoRotate = nil
local PreviousPlatformStand = nil
local CharacterConnection = nil
local CleanupConnections = {}
local DeathConnection = nil
local ResetInProgress = false
local CurrentTrackedHumanoid = nil
local ActiveWeld = nil -- WeldConstraint
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
-- INVISIBILITY
-- ============================================================
local Invisibility = {}
local OriginalModifiers = setmetatable({}, {__mode = "k"})
local DescendantConnection = nil
local function hideDescendant(obj)
    if obj:IsA("BasePart") then
        if OriginalModifiers[obj] == nil then
            OriginalModifiers[obj] = obj.LocalTransparencyModifier
        end
        obj.LocalTransparencyModifier = 1
    end
end
function Invisibility.apply()
    local char = Player.Character
    if not char then return end
    for _, obj in ipairs(char:GetDescendants()) do
        hideDescendant(obj)
    end
    if DescendantConnection then DescendantConnection:Disconnect() end
    DescendantConnection = char.DescendantAdded:Connect(function(obj)
        if CONFIG.INVISIBLE then
            hideDescendant(obj)
        end
    end)
end
function Invisibility.remove()
    if DescendantConnection then DescendantConnection:Disconnect() DescendantConnection = nil end
    for obj, original in pairs(OriginalModifiers) do
        if obj and obj.Parent then
            pcall(function() obj.LocalTransparencyModifier = original end)
        end
        OriginalModifiers[obj] = nil
    end
end
-- A client-side platform and LocalTransparencyModifier are local effects.
-- Other players will not necessarily see the same character/platform state.
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
-- Emergency mode: disable tracking, move below the map, and reset.
-- A client cannot guarantee that death is invisible to other players.
local StopBackstab -- forward declaration; initialized below
-- Preserve feature toggles across death/respawn. Roblox server authority
-- determines whether movement, death and appearance replicate to others.
local function emergencyRetreat()
    if ResetInProgress then return end
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return end
    ResetInProgress = true
    local y = math.min(-CONFIG.SAFE_DEPTH, workspace.FallenPartsDestroyHeight - 15)
    -- Suspend movement while dying without changing the user's settings.
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
        -- Local-only corpse concealment. Other clients may still see it.
        if CONFIG.AUTO_RESET then
            for _, obj in ipairs(character:GetDescendants()) do
                if obj:IsA("BasePart") then obj.LocalTransparencyModifier = 1 end
            end
        end
    end)
    checkHealth(hum.Health)
end
-- ============================================================
-- WELD ATTACH v2
-- Жёсткая привязка к цели через WeldConstraint
-- Без задержки: куда цель — туда и вы (физически приварены)
-- + разворот ЛИЦОМ к цели
-- ============================================================
local WeldAttach = {}
-- Создаёт WeldConstraint между своим HRP и HRP цели
function WeldAttach.attach()
    if ResetInProgress or not SelectedTarget or not isAlive(SelectedTarget) then
        return false
    end
    local targetHRP = getHRP(SelectedTarget)
    local myHRP = getHRP(Player)
    if not targetHRP or not myHRP then return false end
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    -- Отвязываем предыдущий weld, если был
    WeldAttach.detach()
    -- Ставим себя на смещение от цели (позади неё)
    local targetCF = targetHRP.CFrame
    local behindPos = targetCF.Position - targetCF.LookVector * CONFIG.BEHIND_STUDS
    behindPos = behindPos + Vector3.new(0, CONFIG.HEIGHT_OFFSET, 0)
    -- Разворот ЛИЦОМ к цели
    local facePos = Vector3.new(targetCF.Position.X, behindPos.Y, targetCF.Position.Z)
    local newCF = CFrame.lookAt(behindPos, facePos)
    myHRP.CFrame = newCF
    myHRP.AssemblyLinearVelocity = Vector3.zero
    myHRP.AssemblyAngularVelocity = Vector3.zero
    -- Отключаем управление ходьбой и авто-поворот
    if hum.AutoRotate then hum.AutoRotate = false end
    if not hum.PlatformStand then hum.PlatformStand = true end
    -- Создаём WeldConstraint
    local weld = Instance.new("WeldConstraint")
    weld.Name = "HizolonWeldAttach"
    weld.Part0 = myHRP
    weld.Part1 = targetHRP
    weld.Parent = myHRP
    ActiveWeld = weld
    return true
end
-- Удаляет WeldConstraint и возвращает управление
function WeldAttach.detach()
    if ActiveWeld then
        pcall(function() ActiveWeld:Destroy() end)
        ActiveWeld = nil
    end
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if PreviousPlatformStand ~= nil then
            hum.PlatformStand = PreviousPlatformStand
        else
            hum.PlatformStand = false
        end
    end
end
-- Проверяет, что weld жив (цель не умерла, не респавнилась)
function WeldAttach.validate()
    if not ActiveWeld then return false end
    if not ActiveWeld.Parent or not ActiveWeld.Part0 or not ActiveWeld.Part1 then
        return false
    end
    if not SelectedTarget or not isAlive(SelectedTarget) then
        return false
    end
    local targetHRP = getHRP(SelectedTarget)
    if not targetHRP or ActiveWeld.Part1 ~= targetHRP then
        return false
    end
    return true
end
-- ============================================================
-- STATUS
-- ============================================================
function UpdateStatus()
    if BackstabActive then
        if SelectedTarget then
            StatusLabel.Text = "WELDED to: " .. SelectedTarget.Name
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            StatusLabel.Text = "No target selected"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    else
        if SelectedTarget then
            StatusLabel.Text = "Target: " .. SelectedTarget.Name
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            StatusLabel.Text = "Select target to weld"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
end
-- ============================================================
-- PLAYER LIST (×0.7)
-- ============================================================
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
-- ============================================================
-- NOTIFICATION
-- ============================================================
local function Message(Title, Text, Time)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = Title,
            Text = Text,
            Duration = Time or 5
        })
    end)
end
-- ============================================================
-- START / STOP
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
        PreviousPlatformStand = myHum.PlatformStand
        myHum.AutoRotate = false
    end
    UpdateStatus()
    Message("Script Hizolon Privat SS+ (WELD)", "Welding to " .. SelectedTarget.Name, 2)
    if CONFIG.SAFE_ZONE then
        removeSafeZone(false)
        CONFIG.SAFE_ZONE = false
        paintToggle(SafeToggle, "SAVE ZONA", false)
    end
    if CONFIG.INVISIBLE then Invisibility.apply() end
    -- Первая привязка — сразу
    WeldAttach.attach()
    -- Каждый кадр проверяем, что weld жив; если цель умерла/респавнилась — перепривязываемся
    PositionConnection = RunService.Heartbeat:Connect(function()
        if not BackstabActive then return end
        if not WeldAttach.validate() then
            if SelectedTarget and isAlive(SelectedTarget) then
                WeldAttach.attach()
            else
                -- цель мертва — отвязываемся и ждём
                WeldAttach.detach()
            end
        end
    end)
end
StopBackstab = function()
    if not BackstabActive then return end
    BackstabActive = false
    if PositionConnection then PositionConnection:Disconnect() PositionConnection = nil end
    if InvisConnection then InvisConnection:Disconnect() InvisConnection = nil end
    WeldAttach.detach()
    if not CONFIG.INVISIBLE then Invisibility.remove() end
    local myHum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if myHum and PreviousAutoRotate ~= nil then myHum.AutoRotate = PreviousAutoRotate end
    PreviousAutoRotate = nil
    PreviousPlatformStand = nil
    UpdateStatus()
    Message("Script Hizolon Privat SS+ (WELD)", "Weld stopped", 2)
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
InvisToggle.MouseButton1Click:Connect(function()
    CONFIG.INVISIBLE = not CONFIG.INVISIBLE
    if CONFIG.INVISIBLE then Invisibility.apply() else Invisibility.remove() end
    paintToggle(InvisToggle, "INVIS", CONFIG.INVISIBLE)
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
    if HealthConnection then HealthConnection:Disconnect() end
    if DeathConnection then DeathConnection:Disconnect() end
    if CharacterConnection then CharacterConnection:Disconnect() end
    if DescendantConnection then DescendantConnection:Disconnect() end
    for _, conn in ipairs(CleanupConnections) do conn:Disconnect() end
    ScreenGui:Destroy()
end)
-- ============================================================
-- PLAYER JOIN / LEAVE
-- ============================================================
table.insert(CleanupConnections, Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    RefreshPlayerList()
end))
table.insert(CleanupConnections, Players.PlayerRemoving:Connect(function(player)
    if SelectedTarget == player then
        SelectedTarget = nil
        if BackstabActive then StopBackstab() end
    end
    task.wait(0.1)
    RefreshPlayerList()
    UpdateStatus()
end))
-- ============================================================
-- RESPAWN HANDLER
-- ============================================================
CharacterConnection = Player.CharacterAdded:Connect(function(character)
    Invisibility.remove()
    WeldAttach.detach()
    PreviousAutoRotate = nil
    PreviousPlatformStand = nil
    if SafePlatform then removeSafeZone(false) end
    monitorHealth(character)
    if BackstabActive then
        local hum = character:WaitForChild("Humanoid", 10)
        if hum then
            PreviousAutoRotate = hum.AutoRotate
            PreviousPlatformStand = hum.PlatformStand
            hum.AutoRotate = false
        end
        -- перепривязка после респавна
        task.defer(function()
            if BackstabActive and SelectedTarget and isAlive(SelectedTarget) then
                WeldAttach.attach()
            end
        end)
    end
    if CONFIG.INVISIBLE then
        task.defer(function()
            if Player.Character == character then Invisibility.apply() end
        end)
    end
end)
if Player.Character then task.defer(monitorHealth, Player.Character) end
-- ============================================================
-- INIT
-- ============================================================
RefreshPlayerList()
UpdateStatus()
Message("Script Hizolon Privat SS+ (WELD)", "Loaded successfully!", 3)
