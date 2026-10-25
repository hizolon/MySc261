local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    PLATE_WIDTH = 60,
    PLATE_HEIGHT = 24,
    PLATE_SPACING = 4,
    PLATE_X = 10,
    PLATE_Y = 10,
    BG_COLOR = Color3.fromRGB(0, 0, 0),
    BG_TRANSPARENCY = 0.5,
    TEXT_COLOR = Color3.fromRGB(255, 255, 255),
    TEXT_SIZE = 12,
    FONT = Enum.Font.SourceSansBold,
    CORNER_RADIUS = UDim.new(0, 6),
}

local function getMaxPlayers()
    local ok, max = pcall(function() return Players.MaxPlayers end)
    if ok and type(max) == "number" and max > 0 then
        return max
    end
    local ok2, stat = pcall(function()
        return Stats.Network.ServerStatsItem["Max Players"]:GetValue()
    end)
    if ok2 and tonumber(stat) then return tonumber(stat) end
    return 0
end

local function getRegionShort(ping)
    if ping < 40 then return "LOCAL" end
    if ping < 80 then return "EU" end
    if ping < 140 then return "US" end
    if ping < 220 then return "ASIA" end
    return "FAR"
end

local function getPing()
    local ok, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    return ok and tonumber(ping) or 0
end

local fpsValue = 0
local fpsFrames = 0
local fpsLast = tick()

RunService.RenderStepped:Connect(function()
    fpsFrames = fpsFrames + 1
    local now = tick()
    if now - fpsLast >= 1 then
        fpsValue = math.floor(fpsFrames / (now - fpsLast) + 0.5)
        fpsFrames = 0
        fpsLast = now
    end
end)

local startTime = tick()

local function formatTime(seconds)
    seconds = math.floor(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%d:%02d:%02d", h, m, s)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerStatsGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local function makePlate(index)
    local frame = Instance.new("Frame")
    frame.Name = "StatPlate_" .. index
    frame.Size = UDim2.fromOffset(CONFIG.PLATE_WIDTH, CONFIG.PLATE_HEIGHT)
    frame.Position = UDim2.fromOffset(
        CONFIG.PLATE_X,
        CONFIG.PLATE_Y + (index - 1) * (CONFIG.PLATE_HEIGHT + CONFIG.PLATE_SPACING)
    )
    frame.BackgroundColor3 = CONFIG.BG_COLOR
    frame.BackgroundTransparency = CONFIG.BG_TRANSPARENCY
    frame.BorderSizePixel = 0
    frame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CONFIG.CORNER_RADIUS
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = ""
    label.TextColor3 = CONFIG.TEXT_COLOR
    label.TextSize = CONFIG.TEXT_SIZE
    label.Font = CONFIG.FONT
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = frame

    return frame, label
end

local pingPlate, pingLabel = makePlate(1)
local fpsPlate, fpsLabel = makePlate(2)
local timerPlate, timerLabel = makePlate(3)
local playersPlate, playersLabel = makePlate(4)

local updateAccum = 0

RunService.Heartbeat:Connect(function(dt)
    updateAccum = updateAccum + dt
    timerLabel.Text = formatTime(tick() - startTime)

    if updateAccum >= 0.25 then
        updateAccum = 0

        local ping = getPing()
        local region = getRegionShort(ping)
        pingLabel.Text = string.format("%d ms (%s)", math.floor(ping + 0.5), region)

        fpsLabel.Text = string.format("%d FPS", fpsValue)

        local current = #Players:GetPlayers()
        local maxP = getMaxPlayers()
        if maxP > 0 then
            playersLabel.Text = string.format("%d/%d plrs", current, maxP)
        else
            playersLabel.Text = string.format("%d plrs", current)
        end
    end
end)

LocalPlayer.AncestryChanged:Connect(function(_, parent)
    if not parent then
        ScreenGui:Destroy()
    end
end)
