local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local targetName = "TargetName"
local distance = 4

RunService.RenderStepped:Connect(function()
    local target = Players:FindFirstChild(targetName)
    if not target then return end
    local tChar, myChar = target.Character, lp.Character
    if not (tChar and myChar) then return end
    local tRoot = tChar:FindFirstChild("HumanoidRootPart")
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not (tRoot and myRoot) then return end

    -- жёстко позади цели, с её поворотом
    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, distance)
end)
