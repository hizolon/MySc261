-- Wuh
local SERVER_COUNTRY = "??"   -- Example: "DE", "US"; "??" means unknown.
local WIDTH, HEIGHT, GAP = 70, 26, 4
local TOP_OFFSET = 42

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
if not player then return end

local env = _G
if type(getgenv) == "function" then
    local ok, result = pcall(getgenv)
    if ok and type(result) == "table" then env = result end
end

if type(env.__GringoTSBHudStop) == "function" then
    pcall(env.__GringoTSBHudStop)
end

local parent = player:WaitForChild("PlayerGui")
if type(gethui) == "function" then
    local ok, hidden = pcall(gethui)
    if ok and hidden then parent = hidden end
end

local old = parent:FindFirstChild("GringoTSBStatsHUD")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "GringoTSBStatsHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100

local parented = pcall(function() gui.Parent = parent end)
if not parented then
    gui.Parent = player:WaitForChild("PlayerGui")
end

local bar = Instance.new("Frame")
bar.Name = "Statistics"
bar.AnchorPoint = Vector2.new(0.5, 0)
bar.Position = UDim2.new(0.5, 0, 0, TOP_OFFSET)
bar.Size = UDim2.fromOffset(WIDTH * 4 + GAP * 3, HEIGHT)
bar.BackgroundTransparency = 1
bar.BorderSizePixel = 0
bar.Parent = gui

local function counter(index, initial)
    local bg = Instance.new("Frame")
    bg.Name = "Stat" .. index
    bg.Position = UDim2.fromOffset((index - 1) * (WIDTH + GAP), 0)
    bg.Size = UDim2.fromOffset(WIDTH, HEIGHT)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.BorderSizePixel = 0
    bg.Parent = bar

    local radius = Instance.new("UICorner")
    radius.CornerRadius = UDim.new(0, 6)
    radius.Parent = bg

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -2, 1, 0)
    label.Position = UDim2.fromOffset(1, 0)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 10
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Text = initial
    label.Parent = bg
    return label
end

local pingText = counter(1, "--ms (??)")
local fpsText = counter(2, "-- FPS")
local timeText = counter(3, "00:00:00")
local playersText = counter(4, "--/-- plrs")

local startAt = os.clock()
local frames, accumulated = 0, 0
local renderConnection
local alive = true

local function update()
    local ok, latency = pcall(function()
        return player:GetNetworkPing()
    end)
    local ping = (ok and type(latency) == "number")
        and tostring(math.floor(latency * 1000 + 0.5)) or "--"
    pingText.Text = ping .. "ms (" .. SERVER_COUNTRY .. ")"

    local elapsed = math.floor(os.clock() - startAt)
    local h = math.floor(elapsed / 3600)
    local m = math.floor(elapsed / 60) % 60
    local s = elapsed % 60
    timeText.Text = string.format("%02d:%02d:%02d", h, m, s)
    playersText.Text = tostring(#Players:GetPlayers()) .. "/" ..
        tostring(Players.MaxPlayers) .. " plrs"
end

renderConnection = RunService.RenderStepped:Connect(function(dt)
    if not alive then return end
    frames = frames + 1
    accumulated = accumulated + dt
    if accumulated >= 0.5 then
        fpsText.Text = tostring(math.floor(frames / accumulated + 0.5)) .. " FPS"
        frames, accumulated = 0, 0
        update()
    end
end)

update()

env.__GringoTSBHudStop = function()
    alive = false
    if renderConnection then renderConnection:Disconnect() end
    if gui then gui:Destroy() end
    env.__GringoTSBHudStop = nil
end
