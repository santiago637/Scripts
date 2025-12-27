-- CommandsModule.lua (100% client-side)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local module = {}

local flying = false
local noclip = false
local flySpeed = 50 -- velocidad base

-- FLY mejorado con control direccional
function module.Fly(arg)
    local character = localPlayer.Character
    if not character then return end

    -- Ajustar velocidad si hay argumento
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

        local root = character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Variables de control
        local moveDir = Vector3.new(0,0,0)

        -- Conectar input
        local conn1 = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                moveDir = moveDir + Vector3.new(0,0,-1)
            elseif input.KeyCode == Enum.KeyCode.S then
                moveDir = moveDir + Vector3.new(0,0,1)
            elseif input.KeyCode == Enum.KeyCode.A then
                moveDir = moveDir + Vector3.new(-1,0,0)
            elseif input.KeyCode == Enum.KeyCode.D then
                moveDir = moveDir + Vector3.new(1,0,0)
            elseif input.KeyCode == Enum.KeyCode.Space then
                moveDir = moveDir + Vector3.new(0,1,0)
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                moveDir = moveDir + Vector3.new(0,-1,0)
            end
        end)

        local conn2 = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                moveDir = moveDir - Vector3.new(0,0,-1)
            elseif input.KeyCode == Enum.KeyCode.S then
                moveDir = moveDir - Vector3.new(0,0,1)
            elseif input.KeyCode == Enum.KeyCode.A then
                moveDir = moveDir - Vector3.new(-1,0,0)
            elseif input.KeyCode == Enum.KeyCode.D then
                moveDir = moveDir - Vector3.new(1,0,0)
            elseif input.KeyCode == Enum.KeyCode.Space then
                moveDir = moveDir - Vector3.new(0,1,0)
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                moveDir = moveDir - Vector3.new(0,-1,0)
            end
        end)

        -- Loop de vuelo
        task.spawn(function()
            while flying do
                if root then
                    root.Velocity = moveDir.Unit * flySpeed
                end
                task.wait()
            end
            -- Al apagar fly
            if humanoid then humanoid.PlatformStand = false end
            conn1:Disconnect()
            conn2:Disconnect()
        end)
    else
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- NOCLIP mejorado
function module.Noclip()
    local character = localPlayer.Character
    if not character then return end

    noclip = not noclip

    if noclip then
        -- Activar noclip
        task.spawn(function()
            while noclip and character.Parent do
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
                task.wait()
            end
        end)
    else
        -- Restaurar colisiones al desactivar
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- WALKSPEED (con valor por defecto = 3)
function module.WalkSpeed(value)
    local character = localPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Si no hay argumento, usar 3 como velocidad
    local num = tonumber(value)
    if not num then
        num = 3
    end

    humanoid.WalkSpeed = num

    -- Feedback opcional
    print("WalkSpeed ajustado a:", num)
end

return module
