-- ============================================
-- Уведомления от flarnux
-- ============================================

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[flarnux] Нужен LocalScript или Executor!")
    return
end

print("[flarnux] старт")

local function waitForCoreGui()
    local tries = 0
    while tries < 50 do
        local ok = pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "test",
                Text = "test",
                Duration = 0
            })
        end)
        if ok then return true end
        tries = tries + 1
        task.wait(0.1)
    end
    return false
end

if not waitForCoreGui() then
    warn("[flarnux] CoreGui не готов принимать уведомления")
    return
end

for i = 1, 10 do
    local ok, err = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "!!ATTENTION!!",
            Text = "Этот пиздатый скрипт создал flarnux",
            Icon = "rbxassetid://0", 
            Duration = 5
        })
    end)

    if not ok then
        warn("[flarnux] Ошибка на уведомлении " .. i .. ": " .. tostring(err))
    end

    task.wait(0.3) 
end

print("[flarnux] 10 уведомлений отправлено")
