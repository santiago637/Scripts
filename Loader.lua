-- Floopa Hub - Loader PRO
-- v2.0: bypass intermedio adaptado + red robusta + protección duplicados

local gv = getgenv()
gv.FloopaHub = gv.FloopaHub or {}
gv.FloopaHub.__loader_lock = gv.FloopaHub.__loader_lock or false
gv.FloopaHub.Version = "2.0"

if gv.FloopaHub.__loader_lock and not gv.FloopaHub.ForceReload then
    return
end
gv.FloopaHub.__loader_lock = true

-- Bypass intermedio adaptado al loader (Kick + remotes sospechosos + reversible)
do
    local mt = getrawmetatable(game)
    if mt then
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            local nameLower = (typeof(self) == "Instance" and (self.Name or "")):lower()

            -- Bloquear Kick directo
            if method == "Kick" then
                warn("[FloopaHub] Kick bloqueado.")
                return nil
            end

            -- Filtrar remotes sospechosos con whitelist
            if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" then
                local bad = nameLower:find("ban") or nameLower:find("report") or nameLower:find("anti") or nameLower:find("log")
                local whitelist = nameLower:find("antique") or nameLower:find("reportcard")
                if bad and not whitelist then
                    warn("[FloopaHub] Remote bloqueado durante carga: "..self.Name)
                    return nil
                end
            end

            return oldNamecall(self, unpack(args))
        end)

        setreadonly(mt, true)

        gv.FloopaHub.RestoreMetatable = function()
            local mt2 = getrawmetatable(game)
            setreadonly(mt2, false)
            mt2.__namecall = oldNamecall
            setreadonly(mt2, true)
            print("[FloopaHub] Metatable restaurado.")
        end

        print("[FloopaHub] Bypass intermedio activado (Kick + remotes en carga).")
    else
        warn("[FloopaHub] Metatable no disponible; bypass no aplicado.")
    end
end

-- Red robusta con fallbacks y reintentos
local function tryRequest(fn, url)
    local ok, r = pcall(fn, {Url = url, Method = "GET"})
    if ok and r then
        local body = r.Body or r.body
        if type(body) == "string" and #body > 0 then return body end
    end
end

local function httpGetAll(url, attempts)
    attempts = tonumber(attempts) or 3
    for i = 1, attempts do
        local ok, res = pcall(function() return game:HttpGet(url) end)
        if ok and type(res) == "string" and #res > 0 then return res end

        if syn and syn.request then
            local b = tryRequest(syn.request, url); if b then return b end
        end
        if http_request then
            local b = tryRequest(http_request, url); if b then return b end
        end
        if request then
            local b = tryRequest(request, url); if b then return b end
        end

        task.wait(0.25 + 0.1 * i)
    end
    return nil
end

-- Carga y ejecución segura
local function safeLoad(url, flagName)
    if not gv.FloopaHub.ForceReload and gv.FloopaHub[flagName] then
        print("[FloopaHub] "..flagName.." ya cargado; omitido.")
        return true
    end

    gv.FloopaHub.__loading_remote_guard = true
    local res = httpGetAll(url, 3)
    gv.FloopaHub.__loading_remote_guard = false

    if type(res) ~= "string" or #res == 0 then
        warn("[FloopaHub] No se pudo descargar: "..url)
        return false
    end

    local okLoader, fn = pcall(loadstring, res)
    if not okLoader or type(fn) ~= "function" then
        warn("[FloopaHub] Código inválido en: "..url)
        return false
    end

    local okRun, err = pcall(fn)
    if not okRun then
        warn("[FloopaHub] Error al ejecutar: "..tostring(err))
        return false
    end

    gv.FloopaHub[flagName] = true
    print("[FloopaHub] Cargado: "..flagName)
    return true
end

-- Orden de carga
safeLoad("https://raw.githubusercontent.com/santiago637/Scripts/main/MainLocalScript.lua", "MainLocalLoaded")
safeLoad("https://raw.githubusercontent.com/santiago637/Scripts/main/HubBotton.lua", "HubButtonLoaded")

-- Desbloquear re-ejecución
gv.FloopaHub.__loader_lock = false
print("[FloopaHub] Loader finalizado.")
