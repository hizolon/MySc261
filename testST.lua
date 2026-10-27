local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[StatsGUI] Нужен LocalScript или Executor!")
    return
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("[StatsGUI] PlayerGui не найден")
    return
end

local old = playerGui:FindFirstChild("ServerStatsGUI")
if old then old:Destroy() end

local W, H, SP, X, Y = 64, 24, 4, 10, 10

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServerStatsGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999
screenGui.Parent = playerGui

local function makePlate(index)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(W, H)
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = UDim2.new(1, -X, 0, Y + (index - 1) * (H + SP))
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "..."
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.SourceSansBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = frame

    return label
end

local pingLabel = makePlate(1)
local fpsLabel = makePlate(2)
local timeLabel = makePlate(3)
local playersLabel = makePlate(4)

local creditFrame = Instance.new("Frame")
creditFrame.Size = UDim2.fromOffset(W, H)
creditFrame.AnchorPoint = Vector2.new(1, 0)
creditFrame.Position = UDim2.new(1, -X, 0, Y + 4 * (H + SP))
creditFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
creditFrame.BackgroundTransparency = 0.5
creditFrame.BorderSizePixel = 0
creditFrame.Parent = screenGui

local creditCorner = Instance.new("UICorner")
creditCorner.CornerRadius = UDim.new(0, 6)
creditCorner.Parent = creditFrame

local creditStroke = Instance.new("UIStroke")
creditStroke.Color = Color3.fromRGB(255, 255, 255)
creditStroke.Thickness = 1.5
creditStroke.Parent = creditFrame

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.fromScale(1, 1)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "By: flarnux"
creditLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
creditLabel.TextSize = 12
creditLabel.Font = Enum.Font.SourceSansBold
creditLabel.TextXAlignment = Enum.TextXAlignment.Center
creditLabel.TextYAlignment = Enum.TextYAlignment.Center
creditLabel.Parent = creditFrame

local startTime = tick()
local fpsFrames = 0
local fpsLast = tick()
local fpsValue = 0
local accum = 0

RunService.RenderStepped:Connect(function()
    fpsFrames = fpsFrames + 1
    local now = tick()
    if now - fpsLast >= 1 then
        fpsValue = math.floor(fpsFrames / (now - fpsLast) + 0.5)
        fpsFrames = 0
        fpsLast = now
    end
end)

RunService.Heartbeat:Connect(function(dt)
    accum = accum + dt
    local elapsed = math.floor(tick() - startTime)
    local h = math.floor(elapsed / 3600)
    local m = math.floor((elapsed % 3600) / 60)
    local s = elapsed % 60
    timeLabel.Text = string.format("%d:%02d:%02d", h, m, s)

    if accum >= 0.25 then
        accum = 0

        local ping = 0
        local ok, val = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if ok and tonumber(val) then
            ping = tonumber(val)
        end

        local country
        if ping < 40 then
            country = "LOCAL"
        elseif ping < 80 then
            country = "EU"
        elseif ping < 140 then
            country = "US"
        elseif ping < 220 then
            country = "ASIA"
        else
            country = "FAR"
        end
        pingLabel.Text = string.format("%d ms (%s)", math.floor(ping + 0.5), country)

        fpsLabel.Text = string.format("%d FPS", fpsValue)

        local cur = #Players:GetPlayers()
        local max = 0
        local okMax, mv = pcall(function()
            return Players.MaxPlayers
        end)
        if okMax and type(mv) == "number" and mv > 0 then
            max = mv
        end
        playersLabel.Text = max > 0 and string.format("%d/%d plrs", cur, max) or string.format("%d plrs", cur)
    end
end)
