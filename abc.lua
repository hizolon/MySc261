-- HIZOLON PRIVAT SS+ v5 | LocalScript / client-side behavior only
--[[
██████╗ ██████╗ ██╗██████╗ ██╗ ██╗ █████╗ ████████╗
██╔══██╗██╔════╝██║██╔══██╗██║ ██║██╔══██╗╚══██╔══╝
██████╔╝██║ ██║██████╔╝██║ ██║███████║ ██║
██╔═══╝ ██║ ██║██╔══██╗╚██╗ ██╔╝██╔══██║ ██║
██║ ╚██████╗██║██║ ██║ ╚████╔╝ ██║ ██║ ██║
╚═╝ ╚═════╝╚═╝╚═╝ ╚═╝ ╚═══╝ ╚═╝ ╚═╝ ╚═╝
SCRIPT HIZOLON PRIVAT SS+
─────────────────────────
• WALL HACK (no-collision, держится на земле)
• NULL (пустая кнопка)
• Позиционирование строго позади цели
• Разворот ЛИЦОМ к цели
• Корректная пинг-компенсация (без перелёта)
• Управление через GUI
• Размер GUI: ×0.7
Стиль: HIZOLON Fling TSB
Версия: SS+
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
-- Позиционирование
BEHIND_STUDS = 3,
HEIGHT_OFFSET = 0,
-- Невидимость (функции убраны, оставлены поля для совместимости)
INVISIBLE = false,
EMERGENCY_HP = 30,
SAFE_ZONE = false,
AUTO_RESET = false,
RESET_THRESHOLD = 0.30,
SAFE_DEPTH = 80,
SAFE_HEIGHT = 130,
-- Пинг-компенсация
PING_COMPENSATE = true,
PREDICTION_MULT = 1.0,
PING_SAFETY = 1.3,
-- Ограничения
MAX_LEAD_TIME = 0.12,
SMOOTH_FACTOR = 0.15,
-- Wall Hack
WALLHACK_ENABLED = false,
-- Точка SAVE ZONA
SAFE_TELEPORT_CFRAME = CFrame.new(
-216.581772, -10000.0029, -145.716171,
0.852498353, -1.00300547e-07, 0.522729933,
6.29894217e-08, 1, 8.91515128e-08
),
}
-- ============================================================
-- GUI SETUP — размер ×0.7
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptHizolonPrivatSSPlus"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui
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
-- Две кнопки вместо INVIS: WALL HACK (слева) и NULL (справа)
local WallHackToggle = makeToggle("WALL HACK", 7, 94)
WallHackToggle.Position = UDim2.new(0, 7, 0, 258)
local NullToggle = makeToggle("NULL", 108, 95)
NullToggle.Position = UDim2.new(0, 108, 0, 258)
local function paintToggle(button, title, enabled)
button.Text = title .. (enabled and ": ON" or ": OFF")
button.TextColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 80,
80)
end
paintToggle(SafeToggle, "SAVE ZONA", CONFIG.SAFE_ZONE)
paintToggle(ResetToggle, "AUTO RESET", CONFIG.AUTO_RESET)
paintToggle(WallHackToggle, "WALL HACK", CONFIG.WALLHACK_ENABLED)
paintToggle(NullToggle, "NULL", false)
-- ============================================================
-- VARIABLES
-- ============================================================
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
local WallHackConnection = nil
local OriginalCollisions = setmetatable({}, {__mode = "k"})
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
-- WALL HACK (no-collision, держится на земле)
-- ============================================================
local WallHack = {}
function WallHack.apply()
local char = Player.Character
if not char then return end
for _, obj in ipairs(char:GetDescendants()) do
if obj:IsA("BasePart") then
if OriginalCollisions[obj] == nil then
OriginalCollisions[obj] = obj.CanCollide
end
obj.CanCollide = false
end
end
if WallHackConnection then WallHackConnection:Disconnect() end
WallHackConnection = char.DescendantAdded:Connect(function(obj)
if CONFIG.WALLHACK_ENABLED and obj:IsA("BasePart") then
if OriginalCollisions[obj] == nil then
OriginalCollisions[obj] = obj.CanCollide
end
obj.CanCollide = false
end
end)
end
function WallHack.remove()
if WallHackConnection then WallHackConnection:Disconnect(); WallHackConnection = nil
end
for obj, original in pairs(OriginalCollisions) do
if obj and obj.Parent then
pcall(function() obj.CanCollide = original end)
end
OriginalCollisions[obj] = nil
end
end
-- ============================================================
-- SAFE ZONE (телепорт строго на заданные координаты)
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
local targetCF = CONFIG.SAFE_TELEPORT_CFRAME
local destination = targetCF.Position
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
platform.CFrame = CFrame.new(destination - Vector3.new(0, 5, 0))
platform.Parent = workspace
SafePlatform = platform
hrp.CFrame = targetCF
hrp.AssemblyLinearVelocity = Vector3.zero
hrp.AssemblyAngularVelocity = Vector3.zero
return true
end
-- ============================================================
-- EMERGENCY / HEALTH MONITOR
-- ============================================================
local StopBackstab -- forward declaration
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
local hum = character:FindFirstChildOfClass("Humanoid") or
character:WaitForChild("Humanoid", 10)
if not hum then return end
CurrentTrackedHumanoid = hum
local function checkHealth(health)
if CONFIG.AUTO_RESET and not ResetInProgress and health > 0
and hum.MaxHealth > 0 and health / hum.MaxHealth <=
CONFIG.RESET_THRESHOLD then
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
-- POSITIONER v2
-- ============================================================
local Positioner = {}
function Positioner.getBehindCFrame(targetHRP)
if not targetHRP then return nil end
local targetCF = targetHRP.CFrame
local targetPos = targetHRP.Position
local targetLook = targetCF.LookVector
local pingRaw = getPing() / 1000
local leadTime = math.min(pingRaw * CONFIG.PING_SAFETY,
CONFIG.MAX_LEAD_TIME)
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
-- ============================================================
-- STATUS
-- ============================================================
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
if myHum and PreviousAutoRotate ~= nil then myHum.AutoRotate = PreviousAutoRotate
end
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
-- WALL HACK toggle
WallHackToggle.MouseButton1Click:Connect(function()
CONFIG.WALLHACK_ENABLED = not CONFIG.WALLHACK_ENABLED
if CONFIG.WALLHACK_ENABLED then WallHack.apply() else WallHack.remove() end
paintToggle(WallHackToggle, "WALL HACK", CONFIG.WALLHACK_ENABLED)
end)
-- NULL toggle (пустая заглушка)
NullToggle.MouseButton1Click:Connect(function()
-- TODO: функция будет добавлена позже
paintToggle(NullToggle, "NULL", false)
end)
ResetToggle.MouseButton1Click:Connect(function()
CONFIG.AUTO_RESET = not CONFIG.AUTO_RESET
paintToggle(ResetToggle, "AUTO RESET", CONFIG.AUTO_RESET)
if CONFIG.AUTO_RESET then
local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
if hum and hum.Health > 0 and hum.MaxHealth > 0 and hum.Health / hum.MaxHealth <
CONFIG.RESET_THRESHOLD then emergencyRetreat() end
end
end)
CloseButton.MouseButton1Click:Connect(function()
StopBackstab()
removeSafeZone(true)
WallHack.remove()
if HealthConnection then HealthConnection:Disconnect() end
if DeathConnection then DeathConnection:Disconnect() end
if CharacterConnection then CharacterConnection:Disconnect() end
if WallHackConnection then WallHackConnection:Disconnect() end
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
end
task.wait(0.1)
RefreshPlayerList()
UpdateStatus()
end))
-- ============================================================
-- RESPAWN HANDLER
-- ============================================================
CharacterConnection = Player.CharacterAdded:Connect(function(character)
PreviousAutoRotate = nil
if SafePlatform then removeSafeZone(false) end
monitorHealth(character)
if BackstabActive then
local hum = character:WaitForChild("Humanoid", 10)
if hum then PreviousAutoRotate = hum.AutoRotate; hum.AutoRotate = false end
end
if CONFIG.WALLHACK_ENABLED then
task.defer(function()
if Player.Character == character then WallHack.apply() end
end)
end
end)
if Player.Character then task.defer(monitorHealth, Player.Character) end
-- ============================================================
-- INIT
-- ============================================================
RefreshPlayerList()
UpdateStatus()
Message("Script Hizolon Privat SS+", "Loaded successfully!", 3)
