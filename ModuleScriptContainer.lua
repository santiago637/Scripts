-- Floopa Hub - Librería de comandos (Hub principal)
-- v3.1 - Correcciones críticas + rendimiento + otra capa de seguridad

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

-- Espera robusta por LocalPlayer y cámara
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local currentCamera = Workspace.CurrentCamera
if not currentCamera then
    Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
    currentCamera = Workspace.CurrentCamera
end

-- Protección singleton del módulo
local gv = getgenv()
gv.FloopaHub = gv.FloopaHub or {}
if gv.FloopaHub.ModuleContainer then
    return gv.FloopaHub.ModuleContainer
end

-- Estado base
local module = {
    Movement = {},
    Visual = {},
    Utility = {},
    Combat = {},
    _Internal = {}
}

-- Contexto compartido
local context = {
    LocalPlayer = localPlayer,
    Camera = currentCamera,
    Connections = {},
    Flags = {
        Flying = false,
        InfiniteJump = false,
        Noclip = false,
        ESPEnabled = false,
        XRayEnabled = false,
        Killaura = false,
        HandleKill = false,
        Aimbot = false
    },
    _LastESPUpdate = 0,
    _Default = {
        WalkSpeed = 16,
        JumpPower = 50,
        HipHeight = 2
    }
}

module._Internal.Context = context

-- Settings
module.Settings = {
    Movement = {
        DefaultWalkSpeed = 16,
        FlySpeedBase = 60,
        FlySpeedMin = 20,
        FlySpeedMax = 250
    },
    Visual = {
        ESPUpdateDelay = 0.35,
        XRayUpdateDelay = 0.6,
        XRayDefaultTransparency = 0.7
    },
    Utility = {
        LogPrefix = "[FloopaHub] "
    },
    Combat = {
        TeamSafe = true -- evita atacar a compañeros
    }
}

-- Utilidad y notificaciones
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

-- Helpers
function module.Utility.Dist(a, b)
    if not a or not b or not a.Position or not b.Position then
        return math.huge
    end
    return (a.Position - b.Position).Magnitude
end

function module.Utility.GetTeamColor(player)
    if player and player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    end
    return Color3.fromRGB(255, 0, 0)
end

function module.Utility.SameTeam(p1, p2)
    if not module.Settings.Combat.TeamSafe then return false end
    if p1 and p2 and p1.Team and p2.Team then
        return p1.Team == p2.Team
    end
    return false
end

function module.Utility.GetCharacterRoot(plr)
    plr = plr or context.LocalPlayer
    if not plr then return nil, nil end
    local char = plr.Character
    if not char then return nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    return char, root
end

function module.Utility.GetHumanoid(plr)
    plr = plr or context.LocalPlayer
    local char = plr and plr.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

function module.Utility.GetNearbyPlayers(maxDistance)
    local _, myRoot = module.Utility.GetCharacterRoot(context.LocalPlayer)
    if not myRoot then return {} end
    local nearby = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= context.LocalPlayer and p.Character then
            if not module.Utility.SameTeam(context.LocalPlayer, p) then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if root and hum and hum.Health > 0 then
                    local d = (myRoot.Position - root.Position).Magnitude
                    if d <= (tonumber(maxDistance) or 15) then
                        table.insert(nearby, {player=p, root=root, humanoid=hum, distance=d})
                    end
                end
            end
        end
    end
    table.sort(nearby, function(a, b) return a.distance < b.distance end)
    return nearby
end

function module._Internal.AddConnection(name, conn)
    if not conn or typeof(conn) ~= "RBXScriptConnection" then return end
    if context.Connections[name] then
        pcall(function() context.Connections[name]:Disconnect() end)
    end
    context.Connections[name] = conn
end

function module._Internal.Disconnect(name)
    local conn = context.Connections[name]
    if conn then
        pcall(function() conn:Disconnect() end)
        context.Connections[name] = nil
    end
end

-- Mantener cámara actualizada
module._Internal.AddConnection("CameraChange", Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    context.Camera = Workspace.CurrentCamera or context.Camera
end))

---------------------------------------------------------------------
-- AntiLag Extra
---------------------------------------------------------------------
module._Internal.AntiLag = {
    CleanupInterval = 25,   -- cada 25s limpia conexiones y cache
    MaxPlayersBatch = 20,   -- máximo jugadores procesados por ciclo
    MaxPartsBatch = 250     -- máximo partes procesadas por ciclo
}

-- Limpieza periódica de conexiones y cache
task.spawn(function()
    while true do
        task.wait(module._Internal.AntiLag.CleanupInterval)
        -- conexiones huérfanas
        for name, conn in pairs(context.Connections) do
            if conn and not conn.Connected then
                context.Connections[name] = nil
            end
        end
        -- cache de XRay
        for part, data in pairs(xrayCache) do
            if not part or not part.Parent then
                xrayCache[part] = nil
            end
        end
    end
end)

-- Limitador de ESP (procesa en lotes)
local oldESP = espConnection
module._Internal.Disconnect("ESP_Heartbeat")
espConnection = RunService.Heartbeat:Connect(function()
    if not context.Flags.ESPEnabled then return end
    local now = tick()
    if now - (context._LastESPUpdate or 0) < module.Settings.Visual.ESPUpdateDelay then return end
    context._LastESPUpdate = now
    local count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= context.LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("ESPHighlight")
            if not hl then
                hl = Instance.new("Highlight")
                hl.Name = "ESPHighlight"
                hl.Parent = p.Character
            end
            hl.FillColor = module.Utility.GetTeamColor(p)
            count = count + 1
            if count >= module._Internal.AntiLag.MaxPlayersBatch then break end
        end
    end
end)
module._Internal.AddConnection("ESP_Heartbeat", espConnection)

-- Limitador de XRay (procesa en lotes)
task.spawn(function()
    while context.Flags.XRayEnabled do
        local now = tick()
        if now - (module._Internal.Performance.LastXRay or 0) >= module.Settings.Visual.XRayUpdateDelay then
            module._Internal.Performance.LastXRay = now
            local count = 0
            for _, part in ipairs(Workspace:GetChildren()) do
                if part:IsA("BasePart") then
                    if not xrayCache[part] then
                        xrayCache[part] = {
                            Transparency = part.Transparency,
                            Material = part.Material,
                            Color = part.Color
                        }
                    end
                    part.Transparency = module.Settings.Visual.XRayDefaultTransparency
                    count = count + 1
                    if count >= module._Internal.AntiLag.MaxPartsBatch then break end
                end
            end
        end
        task.wait(0.1)
    end
end)

module.Utility.Log("AntiLag extra activado.")


---------------------------------------------------------------------
-- BYPASS AVANZADO (fusionado + endurecido)
---------------------------------------------------------------------
do
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    -- Hook único de __namecall
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        local isInstance = typeof(self) == "Instance"
        local nameLower = isInstance and self.Name:lower() or tostring(self):lower()

        -- Bloquear Kick
        if method == "Kick" then
            -- No-op para preservar flujo sin ruptura
            module.Utility.Warn("Bypass PRO: Kick bloqueado.")
            return nil
        end

        -- Filtrar remotes sospechosos (naive, pero con lista blanca básica)
        if method == "FireServer" or method == "InvokeServer" then
            local bad = (string.find(nameLower, "ban")
                      or string.find(nameLower, "log")
                      or string.find(nameLower, "report")
                      or string.find(nameLower, "anti"))
            local whitelist = (string.find(nameLower, "antique") or string.find(nameLower, "reportcard"))
            if bad and not whitelist then
                module.Utility.Warn("Bypass PRO: Remote bloqueado ("..(isInstance and self.Name or tostring(self))..")")
                return nil
            end
        end

        -- Neutralizar intentos de conectar a Changed del Humanoid (mejor detección)
        if method == "Connect" and tostring(self) == "Changed" then
            -- Devuelve una función vacía (connection fake) para no romper scripts que esperan un callable
            module.Utility.Warn("Bypass PRO: intento de Changed bloqueado.")
            return function() end
        end

        return oldNamecall(self, unpack(args))
    end)

    -- Endurecer __index y __newindex para Humanoid (lectura/escritura)
    local oldIndex = mt.__index
    mt.__index = newcclosure(function(self, key)
        if typeof(self) == "Instance" and self:IsA("Humanoid") then
            if key == "WalkSpeed" then
                return module.Settings.Movement.DefaultWalkSpeed
            elseif key == "JumpPower" then
                return context._Default.JumpPower
            elseif key == "HipHeight" then
                return context._Default.HipHeight
            end
        end
        return oldIndex(self, key)
    end)

    local oldNewIndex = mt.__newindex
    mt.__newindex = newcclosure(function(self, key, value)
        if typeof(self) == "Instance" and self:IsA("Humanoid") then
            -- Permite escritura pero normaliza valores peligrosos
            if key == "WalkSpeed" then
                local v = tonumber(value) or module.Settings.Movement.DefaultWalkSpeed
                return oldNewIndex(self, key, math.clamp(v, 4, 200))
            elseif key == "JumpPower" then
                local v = tonumber(value) or context._Default.JumpPower
                return oldNewIndex(self, key, math.clamp(v, 20, 150))
            elseif key == "HipHeight" then
                local v = tonumber(value) or context._Default.HipHeight
                return oldNewIndex(self, key, math.clamp(v, 0, 5))
            end
        end
        return oldNewIndex(self, key, value)
    end)

    setreadonly(mt, true)
    module.Utility.Log("Bypass avanzado activado (Kick + Remotes + Changed + Spoof R/W).")
end
---------------------------------------------------------------------

-- Movement
local flySpeed = module.Settings.Movement.FlySpeedBase
function module.Movement.Fly(arg, disable)
    local char, root = module.Utility.GetCharacterRoot(context.LocalPlayer)
    if not char or not root then
        module.Utility.Warn("Fly: Character o HumanoidRootPart no disponibles.")
        return
    end

    local hum = module.Utility.GetHumanoid(context.LocalPlayer)

    if disable then
        context.Flags.Flying = false
        if hum then hum.PlatformStand = false end
        module._Internal.Disconnect("Fly_InputBegan")
        module._Internal.Disconnect("Fly_InputEnded")
        return
    end

    local num = tonumber(arg)
    if num then
        flySpeed = math.clamp(num * 10, module.Settings.Movement.FlySpeedMin, module.Settings.Movement.FlySpeedMax)
    else
        flySpeed = module.Settings.Movement.FlySpeedBase
    end

    context.Flags.Flying = true
    if hum then hum.PlatformStand = true end

    local moveVec = Vector3.new(0, 0, 0)

    -- Bypass individual para Fly
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldIndex = mt.__index
    mt.__index = newcclosure(function(self, key)
        if context.Flags.Flying and typeof(self) == "Instance" and self:IsA("Humanoid") then
            if key == "PlatformStand" then
                return false -- spoof: aparenta que no está en PlatformStand
            elseif key == "Velocity" then
                return Vector3.new(0,0,0) -- spoof: aparenta que no hay velocidad rara
            end
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)

    -- Teclado PC
    local connBegan = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then
            moveVec = moveVec + Vector3.new(0, 0, -1)
        elseif input.KeyCode == Enum.KeyCode.S then
            moveVec = moveVec + Vector3.new(0, 0, 1)
        elseif input.KeyCode == Enum.KeyCode.A then
            moveVec = moveVec + Vector3.new(-1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            moveVec = moveVec + Vector3.new(1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then
            moveVec = moveVec + Vector3.new(0, 1, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.Q then
            moveVec = moveVec + Vector3.new(0, -1, 0)
        end
    end)

    local connEnded = UserInputService.InputEnded:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.W then
            moveVec = moveVec - Vector3.new(0, 0, -1)
        elseif input.KeyCode == Enum.KeyCode.S then
            moveVec = moveVec - Vector3.new(0, 0, 1)
        elseif input.KeyCode == Enum.KeyCode.A then
            moveVec = moveVec - Vector3.new(-1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            moveVec = moveVec - Vector3.new(1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then
            moveVec = moveVec - Vector3.new(0, 1, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.Q then
            moveVec = moveVec - Vector3.new(0, -1, 0)
        end
    end)

    module._Internal.AddConnection("Fly_InputBegan", connBegan)
    module._Internal.AddConnection("Fly_InputEnded", connEnded)

    -- Loop principal
    task.spawn(function()
        while context.Flags.Flying do
            char, root = module.Utility.GetCharacterRoot(context.LocalPlayer)
            hum = module.Utility.GetHumanoid(context.LocalPlayer)
            if not char or not root or not hum then break end

            -- Dirección combinada: teclado + stick dinámico
            local dir = moveVec
            if hum.MoveDirection.Magnitude > 0 then
                dir = dir + hum.MoveDirection
            end

            if dir.Magnitude > 0 then
                root.Velocity = dir.Unit * flySpeed
            else
                root.Velocity = Vector3.new(0, 0, 0)
            end

            task.wait()
        end
        if hum then hum.PlatformStand = false end
        module._Internal.Disconnect("Fly_InputBegan")
        module._Internal.Disconnect("Fly_InputEnded")
    end)
end

local infiniteJumpConnection = nil
function module.Movement.InfiniteJump(enable)
    if enable then
        if context.Flags.InfiniteJump then return end
        context.Flags.InfiniteJump = true

        infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if not context.Flags.InfiniteJump then return end
            local hum = module.Utility.GetHumanoid(context.LocalPlayer)
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
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

function module.Movement.WalkSpeed(value)
    local hum = module.Utility.GetHumanoid(context.LocalPlayer)
    if not hum then
        module.Utility.Warn("WalkSpeed: Humanoid no encontrado.")
        return
    end
    local num = tonumber(value)
    if not num then
        hum.WalkSpeed = module.Settings.Movement.DefaultWalkSpeed
        module.Utility.Notify("WalkSpeed", "Valor inválido, usando 16", 2)
        return
    end
    hum.WalkSpeed = math.clamp(num, 4, 200)
end

local noclipLoopRunning = false
function module.Movement.Noclip(disable)
    local char = context.LocalPlayer and context.LocalPlayer.Character
    if not char then
        module.Utility.Warn("Noclip: Character no disponible.")
        return
    end

    if disable then
        context.Flags.Noclip = false
        noclipLoopRunning = false
        -- restaurar solo partes principales para rendimiento
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        return
    end

    context.Flags.Noclip = true
    if noclipLoopRunning then return end
    noclipLoopRunning = true

    task.spawn(function()
        while context.Flags.Noclip do
            char = context.LocalPlayer and context.LocalPlayer.Character
            if not char or not char.Parent then break end
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            task.wait()
        end
        char = context.LocalPlayer and context.LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        noclipLoopRunning = false
    end)
end

-- Visual
local espConnection = nil
local xrayCache = {}

function module.Visual.ESP(disable)
    if disable then
        context.Flags.ESPEnabled = false
        module._Internal.Disconnect("ESP_Heartbeat")
        -- desconectar todas las conexiones CharacterAdded registradas
        for name,_ in pairs(context.Connections) do
            if string.find(name, "^ESP_CharAdded_") then
                module._Internal.Disconnect(name)
            end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= context.LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("ESPHighlight")
                if hl then hl:Destroy() end
            end
        end
        module.Utility.Log("ESP desactivado.")
        return
    end

    if context.Flags.ESPEnabled then return end
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

    espConnection = RunService.Heartbeat:Connect(function()
        if not context.Flags.ESPEnabled then return end
        local now = tick()
        if (context._LastESPUpdate or 0) + module.Settings.Visual.ESPUpdateDelay > now then return end
        context._LastESPUpdate = now
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= context.LocalPlayer then
                ensureHighlight(p)
            end
        end
    end)
    module._Internal.AddConnection("ESP_Heartbeat", espConnection)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= context.LocalPlayer then
            local conn = p.CharacterAdded:Connect(onCharacterAdded)
            module._Internal.AddConnection("ESP_CharAdded_"..p.UserId, conn)
            if p.Character then ensureHighlight(p) end
        end
    end

    module.Utility.Log("ESP activado.")
end

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

    -- Loop optimizado con batching y delay configurable
    task.spawn(function()
        while context.Flags.XRayEnabled do
            local now = tick()
            if now - (module._Internal.Performance.LastXRay or 0) >= module.Settings.Visual.XRayUpdateDelay then
                module._Internal.Performance.LastXRay = now
                local char = context.LocalPlayer and context.LocalPlayer.Character
                local count = 0
                for _, part in ipairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart")
                        and part.Transparency < 1
                        and not (char and part:IsDescendantOf(char))
                    then
                        if not xrayCache[part] then
                            xrayCache[part] = {
                                Transparency = part.Transparency,
                                Material = part.Material,
                                Color = part.Color
                            }
                        end
                        part.Transparency = transparency
                        if part.Material == Enum.Material.Neon and not xrayCache[part].NeonAdjusted then
                            part.Color = part.Color:Lerp(Color3.fromRGB(255, 255, 255), 0.1)
                            xrayCache[part].NeonAdjusted = true
                        end
                        count = count + 1
                        if count >= module._Internal.AntiLag.MaxPartsBatch then break end
                    end
                end
            end
            task.wait(0.1)
        end
    end)

    module.Utility.Log("XRay activado con AntiLag.")
end

-- Combat
local killauraEnabled = false
local handleKillEnabled = false
local aimbotEnabled = false

module.Combat.Killaura = function(range, disable)
    local function removeCircle()
        local char = localPlayer.Character
        if char then
            local old1 = (context.Camera and context.Camera:FindFirstChild("KillauraCircleGui"))
            if old1 then old1:Destroy() end
            local old2 = char:FindFirstChild("KillauraCircle")
            if old2 then old2:Destroy() end
        end
    end

    if disable then
        killauraEnabled = false
        context.Flags.Killaura = false
        removeCircle()
        return
    end

    local radius = tonumber(range) or 15
    killauraEnabled = true
    context.Flags.Killaura = true

    removeCircle()
    local char = localPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- Visual local (BillboardGui para no replicar Part)
    if root and context.Camera then
        local ui = Instance.new("BillboardGui")
        ui.Name = "KillauraCircleGui"
        ui.Adornee = root
        ui.Size = UDim2.new(0, radius*2, 0, radius*2)
        ui.AlwaysOnTop = true
        ui.LightInfluence = 0
        ui.Parent = context.Camera

        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(1,0,1,0)
        circle.BackgroundColor3 = Color3.fromRGB(255,60,60)
        circle.BackgroundTransparency = 0.4
        circle.BorderSizePixel = 0
        circle.Parent = ui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1,0) -- círculo
        corner.Parent = circle
    end

    task.spawn(function()
        while killauraEnabled do
            local myChar = localPlayer.Character
            local tool = myChar and myChar:FindFirstChildOfClass("Tool")
            if tool then
                local targets = module.Utility.GetNearbyPlayers(radius)
                for _, info in ipairs(targets) do
                    -- Solo uso de Tool real
                    pcall(function() tool:Activate() end)
                end
            end
            task.wait(0.5)
        end
    end)
end

module.Combat.HandleKill = function(range, disable)
    if disable then
        handleKillEnabled = false
        context.Flags.HandleKill = false
        return
    end

    local radius = tonumber(range) or 15
    handleKillEnabled = true
    context.Flags.HandleKill = true

    task.spawn(function()
        while handleKillEnabled do
            local myChar = localPlayer.Character
            local tool = myChar and myChar:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                local targets = module.Utility.GetNearbyPlayers(radius)
                for _, info in ipairs(targets) do
                    -- Solo automatiza contacto con arma real
                    pcall(function() tool:Activate() end)
                end
            end
            task.wait(0.7)
        end
    end)
end

module.Combat.Aimbot = function(range, disable)
    if disable then
        aimbotEnabled = false
        context.Flags.Aimbot = false
        return
    end

    local camera = context.Camera
    local radius = tonumber(range) or 150
    aimbotEnabled = true
    context.Flags.Aimbot = true

    task.spawn(function()
        while aimbotEnabled do
            local myChar = localPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            camera = context.Camera
            if myChar and myRoot and camera then
                local nearestRoot
                local nearestDist = math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= localPlayer and p.Character and not module.Utility.SameTeam(localPlayer, p) then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        local root = p.Character:FindFirstChild("HumanoidRootPart")
                        local head = p.Character:FindFirstChild("Head")
                        if hum and root and hum.Health > 0 then
                            local d = module.Utility.Dist(myRoot, root)
                            if d < nearestDist and d <= radius then
                                nearestDist = d
                                nearestRoot = head or root
                            end
                        end
                    end
                end
                if nearestRoot then
                    local camPos = camera.CFrame.Position
                    local look = CFrame.new(camPos, nearestRoot.Position)
                    camera.CFrame = camera.CFrame:Lerp(look, 0.20)
                end
            end
            RunService.RenderStepped:Wait()
        end
    end)
end

-- Aliases planos
function module.Fly(arg, disable) return module.Movement.Fly(arg, disable) end
function module.Noclip(disable) return module.Movement.Noclip(disable) end
function module.WalkSpeed(value) return module.Movement.WalkSpeed(value) end
function module.InfiniteJump(enable) return module.Movement.InfiniteJump(enable) end
function module.ESP(disable) return module.Visual.ESP(disable) end
function module.XRay(value, disable) return module.Visual.XRay(value, disable) end
function module.Killaura(...) if module.Combat.Killaura then return module.Combat.Killaura(...) else module.Utility.Warn("Killaura no implementada") end end
function module.HandleKill(...) if module.Combat.HandleKill then return module.Combat.HandleKill(...) else module.Utility.Warn("HandleKill no implementada") end end
function module.Aimbot(...) if module.Combat.Aimbot then return module.Combat.Aimbot(...) else module.Utility.Warn("Aimbot no implementada") end end

-- Limpieza
function module._Internal.CleanupAll()
    context.Flags.Flying = false
    context.Flags.InfiniteJump = false
    context.Flags.Noclip = false
    context.Flags.ESPEnabled = false
    context.Flags.XRayEnabled = false
    context.Flags.Killaura = false
    context.Flags.HandleKill = false
    context.Flags.Aimbot = false

    for name, conn in pairs(context.Connections) do
        pcall(function() conn:Disconnect() end)
        context.Connections[name] = nil
    end

    for part, data in pairs(xrayCache) do
        if part and part.Parent then
            part.Transparency = data.Transparency
            part.Material = data.Material
            part.Color = data.Color
        end
    end
    table.clear(xrayCache)

    -- Restaurar valores por defecto seguros
    local hum = module.Utility.GetHumanoid(context.LocalPlayer)
    if hum then
        pcall(function()
            hum.WalkSpeed = module.Settings.Movement.DefaultWalkSpeed
            hum.JumpPower = context._Default.JumpPower
            hum.HipHeight = context._Default.HipHeight
        end)
    end

    -- limpiar visual de killaura local
    if context.Camera then
        local oldUI = context.Camera:FindFirstChild("KillauraCircleGui")
        if oldUI then oldUI:Destroy() end
    end

    module.Utility.Log("CleanupAll ejecutado.")
end

-- Capa extra de seguridad: watchdog de integridad básica
-- Si otro script intenta reemplazar nuestro módulo en getgenv, lo restauramos.
task.spawn(function()
    while true do
        task.wait(5)
        if gv.FloopaHub.ModuleContainer ~= module then
            gv.FloopaHub.ModuleContainer = module
            module.Utility.Warn("Watchdog: módulo restaurado en getgenv.")
        end
    end
end)

gv.FloopaHub.ModuleContainer = module
return module
