---------------------------------------------------------------------
-- 🔧 SERVICES Y CONTEXTO BÁSICO
---------------------------------------------------------------------

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer

local module = {
    Movement = {},
    Visual = {},
    Utility = {},
    Combat = {}, -- <- aquí meterás tus funciones de combate
    _Internal = {}
}

---------------------------------------------------------------------
-- 🌐 CONTEXTO COMPARTIDO
---------------------------------------------------------------------

local context = {
    LocalPlayer = localPlayer,
    Camera = workspace.CurrentCamera,
    Connections = {},
    Flags = {
        Flying = false,
        InfiniteJump = false,
        Noclip = false,
        ESPEnabled = false,
        XRayEnabled = false
    }
}

module._Internal.Context = context

---------------------------------------------------------------------
-- ⚙️ SETTINGS BÁSICOS
---------------------------------------------------------------------

module.Settings = {
    Movement = {
        DefaultWalkSpeed = 16,
        FlySpeedBase = 60,
        FlySpeedMin = 20,
        FlySpeedMax = 250
    },
    Visual = {
        ESPUpdateDelay = 0.35,
        XRayUpdateDelay = 0.4,
        XRayDefaultTransparency = 0.7
    },
    Utility = {
        LogPrefix = "[FloopaHub] "
    }
}

---------------------------------------------------------------------
-- 📜 LOGGING Y MENSAJES
---------------------------------------------------------------------

function module.Utility.Log(message)
    print(module.Settings.Utility.LogPrefix .. tostring(message))
end

function module.Utility.Warn(message)
    warn(module.Settings.Utility.LogPrefix .. tostring(message))
end

function module.Utility.Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Info",
            Text = text or "",
            Duration = duration or 3
        })
    end)
end

---------------------------------------------------------------------
-- 🔧 UTILITY: MATH, PLAYERS, VALIDACIONES
---------------------------------------------------------------------

-- Distancia segura entre dos partes
function module.Utility.Dist(a, b)
    if not a or not b then
        return math.huge
    end
    return (a.Position - b.Position).Magnitude
end

-- Obtener color de equipo
function module.Utility.GetTeamColor(player)
    if player and player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 0, 0)
end

-- Validar Character y HumanoidRootPart
function module.Utility.GetCharacterRoot(plr)
    plr = plr or context.LocalPlayer
    if not plr then
        return nil, nil
    end

    local char = plr.Character
    if not char then
        return nil, nil
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        return char, nil
    end

    return char, root
end

-- Obtener Humanoid de un jugador
function module.Utility.GetHumanoid(plr)
    plr = plr or context.LocalPlayer
    local char = plr and plr.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- Obtener jugadores cercanos dentro de un rango
function module.Utility.GetNearbyPlayers(maxDistance)
    local myChar, myRoot = module.Utility.GetCharacterRoot(context.LocalPlayer)
    if not myRoot then
        return {}
    end

    local nearby = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= context.LocalPlayer and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")

            if root and hum and hum.Health > 0 then
                local d = (myRoot.Position - root.Position).Magnitude
                if d <= maxDistance then
                    table.insert(nearby, {
                        player = p,
                        root = root,
                        humanoid = hum,
                        distance = d
                    })
                end
            end
        end
    end

    table.sort(nearby, function(a, b)
        return a.distance < b.distance
    end)

    return nearby
end

-- Helper para registrar conexiones y limpiarlas luego
function module._Internal.AddConnection(name, conn)
    if not conn then return end
    if context.Connections[name] then
        pcall(function()
            context.Connections[name]:Disconnect()
        end)
    end
    context.Connections[name] = conn
end

function module._Internal.Disconnect(name)
    local conn = context.Connections[name]
    if conn then
        pcall(function()
            conn:Disconnect()
        end)
        context.Connections[name] = nil
    end
end

---------------------------------------------------------------------
-- 🛫 MOVEMENT
---------------------------------------------------------------------

local flySpeed = module.Settings.Movement.FlySpeedBase

---------------------------------------------------------------------
-- FLY libre 6D sin gravedad, con alias de velocidad
---------------------------------------------------------------------
-- Uso:
--   module.Movement.Fly(range, disable)
--   range: número opcional -> multiplica la velocidad base
--   disable: true/false -> desactiva el vuelo
---------------------------------------------------------------------

function module.Movement.Fly(arg, disable)
    local char, root = module.Utility.GetCharacterRoot(context.LocalPlayer)
    if not char or not root then
        module.Utility.Warn("Fly: Character o HumanoidRootPart no disponibles.")
        return
    end

    local hum = module.Utility.GetHumanoid(context.LocalPlayer)

    if disable then
        context.Flags.Flying = false
        if hum then
            hum.PlatformStand = false
        end
        module._Internal.Disconnect("Fly_InputBegan")
        module._Internal.Disconnect("Fly_InputEnded")
        return
    end

    local num = tonumber(arg)
    if num then
        flySpeed = math.clamp(
            num * 10,
            module.Settings.Movement.FlySpeedMin,
            module.Settings.Movement.FlySpeedMax
        )
    else
        flySpeed = module.Settings.Movement.FlySpeedBase
    end

    context.Flags.Flying = true
    if hum then
        hum.PlatformStand = true
    end

    local moveVec = Vector3.new(0, 0, 0)

    local connBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end

        if input.KeyCode == Enum.KeyCode.W then
            moveVec += Vector3.new(0, 0, -1)
        elseif input.KeyCode == Enum.KeyCode.S then
            moveVec += Vector3.new(0, 0, 1)
        elseif input.KeyCode == Enum.KeyCode.A then
            moveVec += Vector3.new(-1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            moveVec += Vector3.new(1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.Space then
            moveVec += Vector3.new(0, 1, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            moveVec += Vector3.new(0, -1, 0)
        end
    end)

    local connEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        if gpe then return end

        if input.KeyCode == Enum.KeyCode.W then
            moveVec -= Vector3.new(0, 0, -1)
        elseif input.KeyCode == Enum.KeyCode.S then
            moveVec -= Vector3.new(0, 0, 1)
        elseif input.KeyCode == Enum.KeyCode.A then
            moveVec -= Vector3.new(-1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            moveVec -= Vector3.new(1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.Space then
            moveVec -= Vector3.new(0, 1, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            moveVec -= Vector3.new(0, -1, 0)
        end
    end)

    module._Internal.AddConnection("Fly_InputBegan", connBegan)
    module._Internal.AddConnection("Fly_InputEnded", connEnded)

    task.spawn(function()
        while context.Flags.Flying and char.Parent do
            char, root = module.Utility.GetCharacterRoot(context.LocalPlayer)
            if not char or not root then break end

            local dir = moveVec
            if dir.Magnitude > 0 then
                root.Velocity = dir.Unit * flySpeed
            else
                root.Velocity = Vector3.new(0, 0, 0)
            end

            task.wait()
        end

        if hum then
            hum.PlatformStand = false
        end
        module._Internal.Disconnect("Fly_InputBegan")
        module._Internal.Disconnect("Fly_InputEnded")
    end)
end

---------------------------------------------------------------------
-- INFINITE JUMP (toggle real)
---------------------------------------------------------------------

local infiniteJumpConnection = nil

function module.Movement.InfiniteJump(enable)
    if enable then
        if context.Flags.InfiniteJump then
            return
        end
        context.Flags.InfiniteJump = true

        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if not context.Flags.InfiniteJump then return end
            local hum = module.Utility.GetHumanoid(context.LocalPlayer)
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)

        module._Internal.AddConnection("InfiniteJump", infiniteJumpConnection)
        module.Utility.Log("InfiniteJump activado.")
    else
        context.Flags.InfiniteJump = false
        module._Internal.Disconnect("InfiniteJump")
        infiniteJumpConnection = nil
        module.Utility.Log("InfiniteJump desactivado.")
    end
end

---------------------------------------------------------------------
-- WALKSPEED PRO
---------------------------------------------------------------------

function module.Movement.WalkSpeed(value)
    local hum = module.Utility.GetHumanoid(context.LocalPlayer)
    if not hum then
        module.Utility.Warn("WalkSpeed: Humanoid no encontrado.")
        return
    end

    local num = tonumber(value)
    if not num then
        hum.WalkSpeed = module.Settings.Movement.DefaultWalkSpeed
        return
    end

    num = math.clamp(num, 4, 200)
    hum.WalkSpeed = num
end

---------------------------------------------------------------------
-- NOCLIP PRO
---------------------------------------------------------------------

local noclipLoopRunning = false

function module.Movement.Noclip(disable)
    local char = context.LocalPlayer and context.LocalPlayer.Character
    if not char then
        module.Utility.Warn("Noclip: Character no disponible.")
        return
    end

    if disable then
        context.Flags.Noclip = false
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        noclipLoopRunning = false
        return
    end

    context.Flags.Noclip = true

    if noclipLoopRunning then
        return
    end
    noclipLoopRunning = true

    task.spawn(function()
        while context.Flags.Noclip do
            char = context.LocalPlayer and context.LocalPlayer.Character
            if not char or not char.Parent then
                break
            end

            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end

            task.wait()
        end

        char = context.LocalPlayer and context.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end

        noclipLoopRunning = false
    end)
end

---------------------------------------------------------------------
-- 👁 VISUAL
---------------------------------------------------------------------

local espConnection = nil
local xrayCache = {}

---------------------------------------------------------------------
-- ESP PRO (solo Highlight, optimizado)
---------------------------------------------------------------------

function module.Visual.ESP(disable)
    if disable then
        context.Flags.ESPEnabled = false
        if espConnection then
            pcall(function()
                espConnection:Disconnect()
            end)
            espConnection = nil
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= context.LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("ESPHighlight")
                if hl then
                    hl:Destroy()
                end
            end
        end

        module.Utility.Log("ESP desactivado.")
        return
    end

    if context.Flags.ESPEnabled then
        return
    end

    context.Flags.ESPEnabled = true

    local function ensureHighlight(player)
        if not player.Character then return end
        local hl = player.Character:FindFirstChild("ESPHighlight")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "ESPHighlight"
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.3
            hl.OutlineTransparency = 0.1
            hl.Parent = player.Character
        end
        hl.FillColor = module.Utility.GetTeamColor(player)
    end

    local function onCharacterAdded(char)
        if not context.Flags.ESPEnabled then return end
        local player = Players:GetPlayerFromCharacter(char)
        if player and player ~= context.LocalPlayer then
            ensureHighlight(player)
        end
    end

    -- Conexión principal de actualización
    espConnection = RunService.Heartbeat:Connect(function()
        if not context.Flags.ESPEnabled then
            return
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= context.LocalPlayer then
                ensureHighlight(p)
            end
        end
    end)

    module._Internal.AddConnection("ESP_Heartbeat", espConnection)

    -- Conectar a nuevos personajes
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= context.LocalPlayer then
            p.CharacterAdded:Connect(onCharacterAdded)
            if p.Character then
                ensureHighlight(p)
            end
        end
    end

    module.Utility.Log("ESP activado.")
end

---------------------------------------------------------------------
-- XRAY PRO con caché global
---------------------------------------------------------------------

function module.Visual.XRay(value, disable)
    if disable then
        context.Flags.XRayEnabled = false

        for part, data in pairs(xrayCache) do
            if part and part.Parent then
                part.Transparency = data.Transparency
                part.Material = data.Material
                part.Color = data.Color
            end
        end

        table.clear(xrayCache)
        module.Utility.Log("XRay desactivado y restaurado.")
        return
    end

    local transparency = module.Settings.Visual.XRayDefaultTransparency
    local n = tonumber(value)
    if n and n >= 1 and n <= 10 then
        transparency = n / 10
    end

    context.Flags.XRayEnabled = true

    task.spawn(function()
        while context.Flags.XRayEnabled do
            local char = context.LocalPlayer and context.LocalPlayer.Character

            for _, part in ipairs(workspace:GetDescendants()) do
                repeat
                    if not part:IsA("BasePart") then
                        break
                    end

                    if char and part:IsDescendantOf(char) then
                        break
                    end

                    if part.Transparency >= 1 then
                        break
                    end

                    if part:IsA("Terrain") then
                        break
                    end

                    if part:IsA("Decal") or part:IsA("Texture") or part:IsA("Beam") then
                        break
                    end

                    if not xrayCache[part] then
                        xrayCache[part] = {
                            Transparency = part.Transparency,
                            Material = part.Material,
                            Color = part.Color
                        }
                    end

                    part.Transparency = transparency

                    if part.Material == Enum.Material.Neon then
                        part.Color = part.Color:Lerp(Color3.fromRGB(255, 255, 255), 0.1)
                    end

                until true
            end

            task.wait(module.Settings.Visual.XRayUpdateDelay)
        end
    end)

    module.Utility.Log("XRay activado.")
end

---------------------------------------------------------------------
-- ⚔️ COMBAT (ESPACIO PARA TUS FUNCIONES)
---------------------------------------------------------------------
module.Combat.Killaura = function(range, disable)
    -- función para eliminar el círculo si existe
    local function removeCircle()
        local char = localPlayer.Character
        if char then
            local old = char:FindFirstChild("KillauraCircle")
            if old then old:Destroy() end
        end
    end

    if disable then
        killauraEnabled = false
        removeCircle()
        return
    end

    -- rango numérico
    local radius = tonumber(range) or 15
    killauraEnabled = true

    ------------------------------------------------------------------
    -- CÍRCULO VISUAL REDONDO (solo local)
    ------------------------------------------------------------------
    removeCircle()

    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if root then
        local circle = Instance.new("Part")
        circle.Name = "KillauraCircle"
        circle.Shape = Enum.PartType.Ball
        circle.Size = Vector3.new(radius * 2, 0.2, radius * 2)
        circle.Material = Enum.Material.Neon
        circle.Color = Color3.fromRGB(255, 60, 60)
        circle.Transparency = 0.7
        circle.Anchored = true
        circle.CanCollide = false
        circle.Parent = char

        -- Aplastar la esfera para que sea un círculo plano
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.Sphere
        mesh.Scale = Vector3.new(1, 0.05, 1)
        mesh.Parent = circle

        -- Seguir al jugador
        task.spawn(function()
            while killauraEnabled and circle.Parent do
                if root then
                    circle.Position = root.Position - Vector3.new(0, 2.5, 0)
                end
                task.wait()
            end
        end)
    end

------------------------------------------------------------------
-- ATAQUE REAL usando getNearbyPlayers()
------------------------------------------------------------------
task.spawn(function()
    while killauraEnabled do
        local myChar = localPlayer.Character
        local tool = myChar and myChar:FindFirstChildOfClass("Tool")

        if tool then
            local targets = getNearbyPlayers(radius)

            for _, info in ipairs(targets) do
                pcall(function()
                    tool:Activate()
                end)
            end
        end

        task.wait(0.20)
    end
end)

-- HANDLE KILL optimizado: usa getNearbyPlayers() + daño forzado
module.Combat.HandleKill = function(range, disable)
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

            -- si no hay tool o no tiene Handle, no hacemos nada
            if tool and tool:FindFirstChild("Handle") then
                -- obtener jugadores cercanos usando tu nueva función
                local targets = getNearbyPlayers(radius)

                for _, info in ipairs(targets) do
                    local hum = info.humanoid

                    -- activar tool (si el servidor lo permite, hace daño real)
                    pcall(function()
                        tool:Activate()
                    end)

                    -- daño forzado client-side (solo funciona en juegos sin validación)
                    if hum and hum.Health > 0 then
                        hum:TakeDamage(10)
                    end
                end
            end

            task.wait(0.35)
        end
    end)
end

-- AIMBOT (apunta la cámara al enemigo más cercano dentro del rango)
module.Combat.Aimbot = function(range, disable)
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
---------------------------------------------------------------------

---------------------------------------------------------------------
-- 🧷 ALIAS PLANOS PARA COMPATIBILIDAD
---------------------------------------------------------------------
-- Esto permite que tu MainLocalScript siga usando:
--   Commands.Fly(...)
--   Commands.Noclip(...)
--   Commands.WalkSpeed(...)
--   Commands.ESP(...)
--   Commands.XRay(...)
--   Commands.InfiniteJump(...)
--
-- Y tú internamente tienes estructura por categorías.
---------------------------------------------------------------------

function module.Fly(arg, disable)
    return module.Movement.Fly(arg, disable)
end

function module.Noclip(disable)
    return module.Movement.Noclip(disable)
end

function module.WalkSpeed(value)
    return module.Movement.WalkSpeed(value)
end

function module.InfiniteJump(enable)
    return module.Movement.InfiniteJump(enable)
end

function module.ESP(disable)
    return module.Visual.ESP(disable)
end

function module.XRay(value, disable)
    return module.Visual.XRay(value, disable)
end

-- Aliases de combate (tú los implementarás en module.Combat)
function module.Killaura(...)
    if module.Combat.Killaura then
        return module.Combat.Killaura(...)
    else
        module.Utility.Warn("Killaura no implementada en module.Combat.")
    end
end

function module.HandleKill(...)
    if module.Combat.HandleKill then
        return module.Combat.HandleKill(...)
    else
        module.Utility.Warn("HandleKill no implementada en module.Combat.")
    end
end

function module.Aimbot(...)
    if module.Combat.Aimbot then
        return module.Combat.Aimbot(...)
    else
        module.Utility.Warn("Aimbot no implementada en module.Combat.")
    end
end

---------------------------------------------------------------------
-- 🧹 LIMPIEZA (opcional para el futuro)
---------------------------------------------------------------------

function module._Internal.CleanupAll()
    -- Desactivar flags
    context.Flags.Flying = false
    context.Flags.InfiniteJump = false
    context.Flags.Noclip = false
    context.Flags.ESPEnabled = false
    context.Flags.XRayEnabled = false

    -- Desconectar conexiones
    for name, conn in pairs(context.Connections) do
        pcall(function()
            conn:Disconnect()
        end)
        context.Connections[name] = nil
    end

    -- Restaurar XRay si estaba activo
    for part, data in pairs(xrayCache) do
        if part and part.Parent then
            part.Transparency = data.Transparency
            part.Material = data.Material
            part.Color = data.Color
        end
    end
    table.clear(xrayCache)

    module.Utility.Log("CleanupAll ejecutado.")
end

---------------------------------------------------------------------

return module
