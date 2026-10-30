local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local targetName = "TargetName"
local distance = 4

task.spawn(function()
    while task.wait() do
        local target = Players:FindFirstChild(targetName)
        if not target then warn("цель не найдена:", targetName) continue end
        local tChar, myChar = target.Character, lp.Character
        if not (tChar and myChar) then warn("нет Character") continue end
        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not (tRoot and myRoot) then warn("нет HumanoidRootPart") continue end

        pcall(function() myRoot:SetNetworkOwner(lp) end)

        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, distance)
    end
end)
