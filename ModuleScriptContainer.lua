-- CommandsModule.lua (100% client-side)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local module = {}

local flying = false
local noclip = false
local flySpeed = 50 -- velocidad base

-- FLY (con velocidad opcional)
function module.Fly(arg)
    local character = localPlayer.Character
    if not character then return end

    -- Si hay argumento, multiplicar por 10
    if arg then
        local num = tonumber(arg)
        if num then
            flySpeed = num * 10
        end
    end

    flying = not flying

    if flying then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = true end

        task.spawn(function()
            while flying do
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.new(0, flySpeed, 0)
                end
                task.wait()
            end
        end)
    else
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- NOCLIP
function module.Noclip()
    local character = localPlayer.Character
    if not character then return end

    noclip = not noclip

    task.spawn(function()
        while noclip do
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            task.wait()
        end

        -- Restaurar colisiones
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end)
end

-- WALKSPEED (comando real)
function module.WalkSpeed(value)
    local character = localPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local num = tonumber(value)
        if num then
            humanoid.WalkSpeed = num
        end
    end
end

return module
