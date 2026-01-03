-- Floopa Hub - MainLocalScript
-- v1.1: Correcciones estrictas (aliases, safeCall, safeLoad robusto)

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local gv = getgenv()
gv.FloopaHub = gv.FloopaHub or {}
if gv.FloopaHub.MainLocalLoaded then
    return gv.FloopaHub.MainLocal -- permite reutilizar sin duplicar
end
gv.FloopaHub.MainLocalLoaded = true

local function notifySafe(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=title or "Info", Text=text or "", Duration=duration or 3})
    end)
end

-- Cargar módulo de comandos con protección y fallback
local function safeHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and #res > 0 then return res end

    local function tryReq(fn)
        local ok2, r = pcall(fn, {Url = url, Method = "GET"})
        if ok2 and r then
            local body = r.Body or r.body
            if type(body) == "string" and #body > 0 then return body end
        end
    end

    if syn and syn.request then
        local body = tryReq(syn.request)
        if body then return body end
    end
    if http_request then
        local body = tryReq(http_request)
        if body then return body end
    end
    if request then
        local body = tryReq(request)
        if body then return body end
    end

    return nil
end

local function safeLoad(url)
    local res = safeHttpGet(url)
    if type(res) ~= "string" or #res == 0 then
        notifySafe("Floopa Hub", "No se pudo cargar módulo", 3)
        return {}
    end
    local fOk, loader = pcall(loadstring, res)
    if not fOk or typeof(loader) ~= "function" then
        notifySafe("Floopa Hub", "Módulo inválido", 3)
        return {}
    end
    local rOk, Commands = pcall(loader)
    if not rOk or type(Commands) ~= "table" then
        notifySafe("Floopa Hub", "Módulo no retorna tabla", 3)
        return {}
    end
    return Commands
end

local Commands = safeLoad("https://raw.githubusercontent.com/santiago637/Scripts/main/ModuleScriptContainer.lua")

-- safeCall que respeta retorno
local function safeCall(func, ...)
    if typeof(func) ~= "function" then
        notifySafe("Floopa Hub", "Comando no implementado", 2)
        return false
    end
    local ok, res = pcall(func, ...)
    if not ok then
        warn("[FloopaHub] Error ejecutando comando:", res)
        notifySafe("Floopa Hub", "Error: "..tostring(res), 2)
        return false
    end
    return res ~= false
end

-- Aliases corregidos
local aliases = {
    ["fly"]="fly", ["unfly"]="unfly",
    ["noclip"]="noclip", ["unnoclip"]="unnoclip",
    ["walkspeed"]="walkspeed", ["speed"]="walkspeed", ["ws"]="walkspeed",
    ["unwalkspeed"]="unwalkspeed",
    ["jumppower"]="jumppower", ["jp"]="jumppower", ["unjumppower"]="unjumppower",
    ["esp"]="esp", ["unesp"]="unesp",
    ["xray"]="xray", ["unxray"]="unxray",
    ["killaura"]="killaura", ["ka"]="killaura", ["unkillaura"]="unkillaura",
    ["handlekill"]="handlekill", ["hkill"]="handlekill", ["unhandlekill"]="unhandlekill",
    ["aimbot"]="aimbot", ["aim"]="aimbot", ["unaimbot"]="unaimbot",
    ["infinitejump"]="infinitejump", ["infjump"]="infinitejump", ["uninfinitejump"]="uninfinitejump"
}

-- Dispatcher de comandos
local function executeCommand(text)
    if typeof(text) ~= "string" or text == "" then
        notifySafe("Floopa Hub", "Comando vacío", 2)
        return false
    end

    local args = string.split(text, " ")
    local rawCmd = args[1] and args[1]:lower()
    local cmd = aliases[rawCmd] or rawCmd
    local arg = args[2]

    if cmd == "fly" then
        return safeCall(Commands.Fly, arg, false)
    elseif cmd == "unfly" then
        return safeCall(Commands.Fly, nil, true)
    elseif cmd == "noclip" then
        return safeCall(Commands.Noclip, false)
    elseif cmd == "unnoclip" then
        return safeCall(Commands.Noclip, true)
    elseif cmd == "walkspeed" then
        return safeCall(Commands.WalkSpeed, arg)
    elseif cmd == "unwalkspeed" then
        return safeCall(Commands.WalkSpeed, 16)
    elseif cmd == "jumppower" then
        return safeCall(Commands.JumpPower, arg, false)
    elseif cmd == "unjumppower" then
        return safeCall(Commands.JumpPower, nil, true)
    elseif cmd == "esp" then
        return safeCall(Commands.ESP, false)
    elseif cmd == "unesp" then
        return safeCall(Commands.ESP, true)
    elseif cmd == "xray" then
        return safeCall(Commands.XRay, arg, false)
    elseif cmd == "unxray" then
        return safeCall(Commands.XRay, nil, true)
    elseif cmd == "killaura" then
        return safeCall(Commands.Killaura, arg, false)
    elseif cmd == "unkillaura" then
        return safeCall(Commands.Killaura, nil, true)
    elseif cmd == "handlekill" then
        return safeCall(Commands.HandleKill, arg, false)
    elseif cmd == "unhandlekill" then
        return safeCall(Commands.HandleKill, nil, true)
    elseif cmd == "aimbot" then
        return safeCall(Commands.Aimbot, arg, false)
    elseif cmd == "unaimbot" then
        return safeCall(Commands.Aimbot, nil, true)
    elseif cmd == "infinitejump" then
        return safeCall(Commands.InfiniteJump, true)
    elseif cmd == "uninfinitejump" then
        return safeCall(Commands.InfiniteJump, false)
    else
        warn("[FloopaHub] Comando no reconocido:", text)
        notifySafe("Floopa Hub", "Comando desconocido: "..tostring(text), 2)
        return false
    end
end

local export = { ExecuteCommand = executeCommand }
gv.FloopaHub.MainLocal = export
return export
