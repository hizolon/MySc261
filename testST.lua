local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    BEHIND_STUDS   = 2.5,       -- насколько позади цели (studs)
    HEIGHT_OFFSET  = 0,         -- смещение по высоте
    RESPONSIVENESS = 1000,       -- жёсткость AlignPosition (больше = жёстче)
    MAX_FORCE      = 1000000,   -- макс. сила привязки
    MAX_TORQUE     = 1000000,   -- макс. момент для поворота
    ATTACH_RANGE   = 500,       -- если цель дальше — перепривязка
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TSB_Attach"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.fromOffset(220, 320)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 80, 80)
stroke.Thickness = 1.2
stroke.Parent = MainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
title.BorderSizePixel = 0
title.Text = "TSB ATTACH  |  HIZOLON"
title.TextColor3 = Color3.fromRGB(255, 80, 80)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 12
title.Parent = MainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(24, 24)
closeBtn.Position = UDim2.new(1, -24, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 12
closeBtn.Parent = MainFrame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -14, 0, 20)
status.Position = UDim2.fromOffset(7, 30)
status.BackgroundTransparency = 1
status.Text = "Выбери цель"
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.SourceSans
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = MainFrame

local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(1, -14, 0, 180)
listFrame.Position = UDim2.fromOffset(7, 54)
listFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
listFrame.BorderSizePixel = 0
listFrame.Parent = MainFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 4)
listCorner.Parent = listFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -8, 1, -8)
scroll.Position = UDim2.fromOffset(4, 4)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 80, 80)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = listFrame

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0.5, -10, 0, 30)
startBtn.Position = UDim2.fromOffset(7, 244)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
startBtn.BorderSizePixel = 0
startBtn.Text = "START"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Font = Enum.Font.SourceSansBold
startBtn.TextSize = 13
startBtn.Parent = MainFrame

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.5, -10, 0, 30)
stopBtn.Position = UDim2.new(0.5, 3, 0, 244)
stopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
stopBtn.BorderSizePixel = 0
stopBtn.Text = "STOP"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.Font = Enum.Font.SourceSansBold
stopBtn.TextSize = 13
stopBtn.Parent = MainFrame

local SelectedTarget = nil
local PlayerButtons = {}
local AttachActive = false
local AlignPos = nil
local AlignOri = nil
local MyAttachment = nil
local TargetAttachment = nil
local HeartbeatConn = nil
local PreviousPlatformStand = nil
local PreviousAutoRotate = nil

local function getChar(plr)
    if not plr then return nil end
    return plr.Character
end

local function getHRP(plr)
    local char = getChar(plr)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function isAlive(plr)
    local char = getChar(plr)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function notify(text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "TSB Attach",
            Text = text,
            Duration = dur or 2,
        })
    end)
end

local function ensureAttachment(part, name)
    local att = part:FindFirstChild(name)
    if not att then
        att = Instance.new("Attachment")
        att.Name = name
        att.Parent = part
    end
    return att
end

local function destroyAttach()
    if AlignPos then AlignPos:Destroy(); AlignPos = nil end
    if AlignOri then AlignOri:Destroy(); AlignOri = nil end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if PreviousPlatformStand ~= nil then
            hum.PlatformStand = PreviousPlatformStand
        else
            hum.PlatformStand = false
        end
        if PreviousAutoRotate ~= nil then
            hum.AutoRotate = PreviousAutoRotate
        end
    end
    PreviousPlatformStand = nil
    PreviousAutoRotate = nil
    MyAttachment = nil
    TargetAttachment = nil
end

local function applyAttach()
    if not SelectedTarget or not isAlive(SelectedTarget) then return false end

    local myHRP = getHRP(LocalPlayer)
    local tgtHRP = getHRP(SelectedTarget)
    if not myHRP or not tgtHRP then return false end

    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHum or myHum.Health <= 0 then return false end

    destroyAttach()

    PreviousPlatformStand = myHum.PlatformStand
    PreviousAutoRotate = myHum.AutoRotate

    myHum.PlatformStand = true
    myHum.AutoRotate = false

    MyAttachment = ensureAttachment(myHRP, "TSB_MyAtt")
    TargetAttachment = ensureAttachment(tgtHRP, "TSB_TgtAtt")

    AlignPos = Instance.new("AlignPosition")
    AlignPos.Name = "TSB_AlignPos"
    AlignPos.Attachment0 = MyAttachment
    AlignPos.Attachment1 = TargetAttachment
    AlignPos.MaxForce = CONFIG.MAX_FORCE
    AlignPos.Responsiveness = CONFIG.RESPONSIVENESS
    AlignPos.RigidityEnabled = true
    AlignPos.ApplyAtCenterOfMass = false
    AlignPos.Position = Vector3.new(0, CONFIG.HEIGHT_OFFSET, CONFIG.BEHIND_STUDS)
    AlignPos.Parent = myHRP

    AlignOri = Instance.new("AlignOrientation")
    AlignOri.Name = "TSB_AlignOri"
    AlignOri.Attachment0 = MyAttachment
    AlignOri.Attachment1 = TargetAttachment
    AlignOri.MaxTorque = CONFIG.MAX_TORQUE
    AlignOri.Responsiveness = CONFIG.RESPONSIVENESS
    AlignOri.RigidityEnabled = true
    AlignOri.Parent = myHRP

    return true
end

local function startAttach()
    if AttachActive then return end
    if not SelectedTarget then
        status.Text = "Сначала выбери цель!"
        status.TextColor3 = Color3.fromRGB(255, 120, 120)
        task.wait(1)
        status.Text = "Выбери цель"
        status.TextColor3 = Color3.fromRGB(200, 200, 200)
        return
    end
    if not isAlive(SelectedTarget) then
        status.Text = "Цель мертва"
        status.TextColor3 = Color3.fromRGB(255, 120, 120)
        return
    end

    if not applyAttach() then
        status.Text = "Не удалось привязаться"
        return
    end

    AttachActive = true
    status.Text = "ATTACHED → " .. SelectedTarget.Name
    status.TextColor3 = Color3.fromRGB(0, 255, 120)
    notify("Attached to " .. SelectedTarget.Name, 2)

    HeartbeatConn = RunService.Heartbeat:Connect(function()
        if not AttachActive then return end

        if not SelectedTarget or not isAlive(SelectedTarget) then
            status.Text = "Цель потеряна — остановка"
            status.TextColor3 = Color3.fromRGB(255, 120, 120)
            AttachActive = false
            if HeartbeatConn then HeartbeatConn:Disconnect(); HeartbeatConn = nil end
            destroyAttach()
            return
        end

        local myHRP = getHRP(LocalPlayer)
        local tgtHRP = getHRP(SelectedTarget)
        if not myHRP or not tgtHRP then return end

        if not AlignPos or not AlignPos.Parent then
            applyAttach()
            return
        end

        local dist = (myHRP.Position - tgtHRP.Position).Magnitude
        if dist > CONFIG.ATTACH_RANGE then
            applyAttach()
        end
    end)
end

local function stopAttach()
    if not AttachActive then return end
    AttachActive = false
    if HeartbeatConn then HeartbeatConn:Disconnect(); HeartbeatConn = nil end
    destroyAttach()
    status.Text = "Target: " .. (SelectedTarget and SelectedTarget.Name or "—")
    status.TextColor3 = Color3.fromRGB(200, 200, 200)
    notify("Attach stopped", 2)
end

local function refreshList()
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
    end
    PlayerButtons = {}

    local players = Players:GetPlayers()
    table.sort(players, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)

    local y = 2
    for _, plr in ipairs(players) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 22)
            btn.Position = UDim2.fromOffset(2, y)
            btn.BackgroundColor3 = (SelectedTarget == plr)
                and Color3.fromRGB(0, 120, 0)
                or Color3.fromRGB(60, 60, 60)
            btn.BorderSizePixel = 0
            btn.Text = plr.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = scroll
            btn.MouseButton1Click:Connect(function()
                SelectedTarget = plr
                status.Text = "Target: " .. plr.Name
                status.TextColor3 = Color3.fromRGB(200, 200, 200)
                refreshList()
            end)
            PlayerButtons[plr] = btn
            y = y + 24
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 2)
end

startBtn.MouseButton1Click:Connect(startAttach)
stopBtn.MouseButton1Click:Connect(stopAttach)

closeBtn.MouseButton1Click:Connect(function()
    stopAttach()
    ScreenGui:Destroy()
end)

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    refreshList()
end)

Players.PlayerRemoving:Connect(function(plr)
    if SelectedTarget == plr then
        SelectedTarget = nil
        stopAttach()
    end
    task.wait(0.1)
    refreshList()
end)

LocalPlayer.CharacterAdded:Connect(function()
    if AttachActive then
        task.defer(function()
            if AttachActive and SelectedTarget and isAlive(SelectedTarget) then
                applyAttach()
            end
        end)
    end
end)

refreshList()
status.Text = "Выбери цель"
notify("TSB Attach loaded", 3)
