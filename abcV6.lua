-- HIZOLON PRIVAT SS+ v5 | LocalScript / client-side behavior only
-- MOD: INVIS → FPS BOOST (удаление текстур/частиц/материалов)
--[[
SCRIPT HIZOLON PRIVAT SS+
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Позиционирование строго позади цели
• Разворот ЛИЦОМ к цели
• Корректная пинг-компенсация (без перелёта)
• Управление через GUI
• FPS BOOST — удаление текстур/частиц/материалов
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
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG = {
-- Позиционирование
BEHIND_STUDS = 3,
HEIGHT_OFFSET = 0,
-- FPS BOOST
FPS_BOOST = false,
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
-- Главное окно (210×265 — убрана строка INVIS)
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
-- Заголовок (21)
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
-- Кнопка закрытия (21×21)
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
-- Свернуть в заголовок
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
-- Статус
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
-- Рамка выбора цели (140)
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
-- Кнопка START (28)
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
-- Переключатели (только SAVE ZONA и AUTO RESET + FPS BOOST)
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
-- FPS BOOST
-- Удаляет текстуры, частицы, материалы и световые эффекты
-- Сохраняет оригиналы для восстановления
-- ============================================================
local FPSBoost = {}
local OriginalTextures = setmetatable({}, {__mode = "k"})   -- Texture / Decal / SurfaceAppearance / MeshPart.TextureID
local OriginalMaterials = setmetatable({}, {__mode = "k"})  -- BasePart.Material
local OriginalSky = nil
local OriginalAtmosphere = nil
local OriginalClouds = nil
local FPSActive = false
local FPSDescendantConnection = nil
local FPSWorldConnection = nil

local TEXTURE_CLASSES = {
    "Texture", "Decal", "SurfaceAppearance", "Sky"
}
local PARTICLE_CLASSES = {
    "ParticleEmitter", "Fire", "Smoke", "Sparkles", "Trail", "Beam", "Explosion"
}
local MATERIAL_TARGETS = {
    "BasePart"
}

local function boostTexture(obj)
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
    end
end

local function boostP
