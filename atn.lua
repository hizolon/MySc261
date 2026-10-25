-- ============================================
-- Уведомления от flarnux
-- Запускать как LocalScript или через Executor
-- ============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[flarnux] LocalPlayer = nil. Нужен LocalScript или Executor!")
    return
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("[flarnux] PlayerGui не найден")
    return
end

print("[flarnux] старт")

local old = playerGui:FindFirstChild("FlarnuxNotifications")
if old then old:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlarnuxNotifications"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

local function createNotification(index)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(320, 70)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 50, 50)
    stroke.Thickness = 2
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -16, 0, 24)
    title.Position = UDim2.fromOffset(8, 6)
    title.BackgroundTransparency = 1
    title.Text = "!!ATTENTION!!"
    title.TextColor3 = Color3.fromRGB(255, 60, 60)
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, -16, 0, 30)
    body.Position = UDim2.fromOffset(8, 30)
    body.BackgroundTransparency = 1
    body.Text = "Этот пиздатый скрипт создал flarnux"
    body.TextColor3 = Color3.fromRGB(255, 255, 255)
    body.TextSize = 14
    body.Font = Enum.Font.SourceSans
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.Parent = frame

    local targetY = 10 + (index - 1) * 78
    frame.Position = UDim2.fromOffset(-400, targetY)

    TweenService:Create(
        frame,
        TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = UDim2.fromOffset(10, targetY) }
    ):Play()
end

for i = 1, 10 do
    task.wait(0.15)
    createNotification(i)
end

print("[flarnux] 10 уведомлений создано")

task.wait(8)

for _, child in ipairs(screenGui:GetChildren()) do
    if child:IsA("Frame") then
        TweenService:Create(child, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
        for _, sub in ipairs(child:GetDescendants()) do
            if sub:IsA("TextLabel") then
                TweenService:Create(sub, TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
            elseif sub:IsA("UIStroke") then
                TweenService:Create(sub, TweenInfo.new(0.5), { Transparency = 1 }):Play()
            end
        end
    end
end

task.wait(1)
screenGui:Destroy()
print("[flarnux] завершено")
