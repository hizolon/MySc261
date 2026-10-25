local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

print("[StatsGUI] start")

if not LocalPlayer then
    print("[StatsGUI] ERROR: LocalPlayer is nil")
    return
end

local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not playerGui then
    playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
end
if not playerGui then
    print("[StatsGUI] ERROR: PlayerGui not found")
    return
end

local old = playerGui:FindFirstChild("ServerStatsGUI")
if old then old:Destroy() end

local W, H, SP, X, Y = 60, 24, 4, 10, 10

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerStatsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = playerGui

print("[StatsGUI] ScreenGui created")

local function makePlate(i)
    local f = Instance.new("Frame")
    f.Size = UDim2.fromOffset(W, H)
    f.Position = UDim2.fromOffset(X, Y + (i - 1) * (H + SP))
    f.BackgroundColor3 = Color3.new(0, 0, 0)
    f.BackgroundTransparency = 0.5
    f.BorderSizePixel = 0
    f.Parent = ScreenGui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = f
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromScale(1, 1)
    l.BackgroundTransparency = 1
    l.Text = "..."
    l.TextColor3 = Color3.new(1, 1, 1)
    l.TextSize = 12
    l.Font = Enum.Font.SourceSansBold
    l.TextXAlignment = Enum.TextXAlignment.Center
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = f
    return l
end

local pingL = makePlate(1)
local fpsL = makePlate(2)
local timeL = makePlate(3)
local plrsL = makePlate(4)

print("[StatsGUI] plates created")

local startTime = tick()
local fpsFrames, fpsLast, fpsValue = 0, tick(), 0
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
    timeL.Text = string.format("%d:%02d:%02d", h, m, s)

    if accum >= 0.25 then
        accum = 0

        local ping = 0
        local ok, val = pcall(function()
            return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if ok and tonumber(val) then ping = tonumber(val) end
        local region = ping < 40 and "LOCAL" or ping < 80 and "EU" or ping < 140 and "US" or ping < 220 and "ASIA" or "FAR"
        pingL.Text = string.format("%d ms (%s)", math.floor(ping + 0.5), region)

        fpsL.Text = string.format("%d FPS", fpsValue)

        local cur = #Players:GetPlayers()
        local max = 0
        local okMax, mv = pcall(function() return Players.MaxPlayers end)
        if okMax and type(mv) == "number" and mv > 0 then max = mv end
        plrsL.Text = max > 0 and string.format("%d/%d plrs", cur, max) or string.format("%d plrs", cur)
    end
end)

print("[StatsGUI] done")
