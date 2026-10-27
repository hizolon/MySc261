--!nocheck
-- Follow_Weld.lua — жёсткая привязка к цели через WeldConstraint
-- Персонаж приварен к цели (не оторвётся, даже если цель летает)

local TARGET_NAME = "TargetPlayerName"  -- ← имя цели
local OFFSET = CFrame.new(0, 0, 4)      -- смещение от цели

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local target = nil
local weld = nil

local function findTarget()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name == TARGET_NAME then return p end
    end
    return nil
end

local function waitForTarget()
    while true do
        target = findTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        task.wait(0.1)
    end
end

waitForTarget()

-- Ждём свой персонаж
while not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
    task.wait(0.1)
end

local myRoot = LocalPlayer.Character.HumanoidRootPart
local tgtRoot = target.Character.HumanoidRootPart

-- Создаём WeldConstraint
weld = Instance.new("WeldConstraint")
weld.Part0 = myRoot
weld.Part1 = tgtRoot
weld.Parent = myRoot

-- Ставим себя на смещение от цели
myRoot.CFrame = tgtRoot.CFrame * OFFSET

-- Отключаем физику, чтобы не дёргался
myRoot.Anchored = false
local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
if hum then
    hum.PlatformStand = true  -- отключаем управление ходьбой
end

print("[Follow] приварен к " .. TARGET_NAME)

-- Чтобы отвязаться:
-- weld:Destroy()
-- hum.PlatformStand = false
