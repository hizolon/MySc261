local Players = game.Players
local lp = Players.LocalPlayer
local targetName = "TargetName"   -- точное имя цели
local distance = 4

task.spawn(function()
    while task.wait() do
        pcall(function()
            local target = Players:FindFirstChild(targetName)
                or workspace:FindFirstChild(targetName, true)

            local tChar = target and (target.Character or target)
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")

            local myChar = lp.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

            if tRoot and myRoot then
                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, distance)
            end
        end)
    end
end)
