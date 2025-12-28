-- CommandsModule.lua (100% client-side, seguro para Delta)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local module = {}

-- Estados
local flying = false
local noclip = false
local espEnabled = false
local xrayEnabled = false
local killauraEnabled = false
local handleKillEnabled = false
local aimbotEnabled = false

-- Config
local flySpeed = 50

-- Util: distancia entre dos partes
local function dist(a, b)
    if not a or not b then return math.huge end
    local ap = a.Position
    local bp = b.Position
    return (ap - bp).Magnitude
end

-- Util: obtener TeamColor seguro
local function getTeamColor(player)
    if player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 0, 0) -- rojo por defecto si no tiene equipo
end

-- FLY (PC: WASD/Q/E, móvil: joystick y salto para subir)
function module.Fly(arg, disable)
    local character = localPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if disable then
        flying = false
        if humanoid then humanoid.PlatformStand = false end
        return
    end

    local num = tonumber(arg)
    if num then
        flySpeed = num * 10
    end

    flying = true
    if humanoid then humanoid.PlatformStand = true end

    local moveDir = Vector3.new(0, 0, 0)
    local conn1, conn2

    -- PC: teclas
    if not UserInputService.TouchEnabled then
        conn1 = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then moveDir += Vector3.new(0, 0, -1)
            elseif input.KeyCode == Enum.KeyCode.S then moveDir += Vector3.new(0, 0, 1)
            elseif input.KeyCode == Enum.KeyCode.A then moveDir += Vector3.new(-1, 0, 0)
            elseif input.KeyCode == Enum.KeyCode.D then moveDir += Vector3.new(1, 0, 0)
            elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Q then moveDir += Vector3.new(0, 1, 0)
            elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.E then moveDir += Vector3.new(0, -1, 0)
            end
        end)
        conn2 = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then moveDir -= Vector3.new(0, 0, -1)
            elseif input.KeyCode == Enum.KeyCode.S then moveDir -= Vector3.new(0, 0, 1)
            elseif input.KeyCode == Enum.KeyCode.A then moveDir -= Vector3.new(-1, 0, 0)
            elseif input.KeyCode == Enum.KeyCode.D then moveDir -= Vector3.new(1, 0, 0)
            elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Q then moveDir -= Vector3.new(0, 1, 0)
            elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.E then moveDir -= Vector3.new(0, -1, 0)
            end
        end)
    end

    task.spawn(function()
        while flying and character.Parent do
            if root then
                if UserInputService.TouchEnabled and humanoid then
                    -- Móvil: usar dirección horizontal del joystick
                    local dir = humanoid.MoveDirection
                    local vel = Vector3.new(dir.X, 0, dir.Z)

                    -- Subir si el jugador presiona salto (Jump)
                    if humanoid.Jump then
                        vel = vel + Vector3.new(0, 1, 0)
                    end

                    root.Velocity = vel.Magnitude > 0 and vel.Unit * flySpeed or Vector3.new(0, 0, 0)
                else
                    -- PC
                    if moveDir.Magnitude > 0 then
                        root.Velocity = moveDir.Unit * flySpeed
                    else
                        root.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end
            task.wait()
        end
        if humanoid then humanoid.PlatformStand = false end
        if conn1 then conn1:Disconnect() end
        if conn2 then conn2:Disconnect() end
    end)
end

-- NOCLIP
function module.Noclip(disable)
    local character = localPlayer.Character
    if not character then return end

    if disable then
        noclip = false
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        return
    end

    noclip = true
    task.spawn(function()
        while noclip and character.Parent do
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            task.wait()
        end
    end)
end

-- WALKSPEED (default = 3 si no se pasa número)
function module.WalkSpeed(value)
    local character = localPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local num = tonumber(value) or 3
    humanoid.WalkSpeed = num
end

-- ESP con color por equipo y Billboard minimalista
function module.ESP(disable)
    if disable then
        espEnabled = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local hl = player.Character:FindFirstChild("ESPHighlight")
                if hl then hl:Destroy() end
                local bb = player.Character:FindFirstChild("ESPBillboard")
                if bb then bb:Destroy() end
            end
        end
        return
    end

    espEnabled = true
    task.spawn(function()
        while espEnabled do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if root and humanoid then
                        -- Highlight con color de equipo
                        local hl = player.Character:FindFirstChild("ESPHighlight")
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "ESPHighlight"
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Parent = player.Character
                        end
                        hl.FillColor = getTeamColor(player)

                        -- Billboard minimalista encima de la cabeza
                        local bb = player.Character:FindFirstChild("ESPBillboard")
                        if not bb then
                            bb = Instance.new("BillboardGui")
                            bb.Name = "ESPBillboard"
                            bb.Size = UDim2.new(0, 120, 0, 20)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.Adornee = root
                            bb.AlwaysOnTop = true
                            bb.Parent = player.Character

                            local text = Instance.new("TextLabel")
                            text.Size = UDim2.new(1, 0, 1, 0)
                            text.BackgroundTransparency = 1
                            text.TextColor3 = Color3.fromRGB(255, 255, 255)
                            text.TextTransparency = 0.2
                            text.Font = Enum.Font.Merriweather
                            text.TextScaled = true
                            text.Parent = bb
                        end

                        local text = bb:FindFirstChildOfClass("TextLabel")
                        if text then
                            text.Text = player.Name .. " | HP: " .. math.floor(humanoid.Health)
                        end
                    end
                end
            end
            task.wait(0.4)
        end
    end)
end

-- XRAY (transparencia ajustable 1–10)
function module.XRay(value, disable)
    if disable then
        xrayEnabled = false
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
        return
    end

    local num = tonumber(value)
    local transparency = 0.7
    if num and num >= 1 and num <= 10 then
        transparency = num / 10
    end

    xrayEnabled = true
    task.spawn(function()
        while xrayEnabled do
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Parent ~= localPlayer.Character then
                    part.Transparency = transparency
                end
            end
            task.wait(0.8)
        end
    end)
end

-- KILLAURA (daño simulado client-side cercano)
function module.Killaura(range, disable)
    if disable then
        killauraEnabled = false
        return
    end

    local radius = tonumber(range) or 15
    killauraEnabled = true

    task.spawn(function()
        while killauraEnabled do
            local myChar = localPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myChar and myRoot then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= localPlayer and p.Character then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        local root = p.Character:FindFirstChild("HumanoidRootPart")
                        if hum and root and hum.Health > 0 then
                            if dist(myRoot, root) <= radius then
                                -- daño simulado (no siempre tendrá efecto en todos los juegos)
                                hum:TakeDamage(5)
                            end
                        end
                    end
                end
            end
            task.wait(0.3)
        end
    end)
end

-- HANDLE KILL (usa Tool con Handle si existe)
function module.HandleKill(range, disable)
    if disable then
        handleKillEnabled = false
        return
    end

    local radius = tonumber(range) or 15
    handleKillEnabled = true

    task.spawn(function()
        while handleKillEnabled do
            local myChar = localPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local tool = myChar and myChar:FindFirstChildOfClass("Tool")
            if myChar and myRoot and tool and tool:FindFirstChild("Handle") then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= localPlayer and p.Character then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        local root = p.Character:FindFirstChild("HumanoidRootPart")
                        if hum and root and hum.Health > 0 then
                            if dist(myRoot, root) <= radius then
                                -- Intento de uso del arma client-side
                                pcall(function()
                                    tool:Activate()
                                end)
                                -- daño simulado (si el servidor no valida, puede no aplicar)
                                hum:TakeDamage(10)
                            end
                        end
                    end
                end
            end
            task.wait(0.4)
        end
    end)
end

-- AIMBOT (apunta la cámara al enemigo más cercano dentro del rango)
function module.Aimbot(range, disable)
    local camera = workspace.CurrentCamera
    if disable then
        aimbotEnabled = false
        return
    end

    local radius = tonumber(range) or 150 -- rango en studs
    aimbotEnabled = true

    task.spawn(function()
        while aimbotEnabled do
            local myChar = localPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myChar and myRoot and camera then
                local nearest, nearestHum, nearestRoot
                local nearestDist = math.huge

                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= localPlayer and p.Character then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        local root = p.Character:FindFirstChild("HumanoidRootPart")
                        local head = p.Character:FindFirstChild("Head")
                        if hum and root and hum.Health > 0 then
                            local d = dist(myRoot, root)
                            if d < nearestDist and d <= radius then
                                nearest = p
                                nearestHum = hum
                                nearestRoot = head or root
                                nearestDist = d
                            end
                        end
                    end
                end

                if nearest and nearestRoot then
                    -- Apuntar la cámara hacia el target
                    local camPos = camera.CFrame.Position
                    local look = CFrame.new(camPos, nearestRoot.Position)
                    camera.CFrame = look
                end
            end
            RunService.RenderStepped:Wait()
        end
    end)
end

return module
