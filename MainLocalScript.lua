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

-- Cargar módulo de comandos con protección
local function safeLoad(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok or type(res) ~= "string" or #res < 50 then
        notifySafe("Floopa Hub", "No se pudo cargar módulo", 3)
        return {}
    end
    local fOk, mod = pcall(loadstring, res)
    if not fOk then
        notifySafe("Floopa Hub", "Módulo inválido", 3)
        return {}
    end
    local rOk, Commands = pcall(mod)
    if not rOk or type(Commands) ~= "table" then
        notifySafe("Floopa Hub", "Módulo no retorna tabla", 3)
        return {}
    end
    return Commands
end

local Commands = safeLoad("https://raw.githubusercontent.com/santiago637/Scripts/main/ModuleScriptContainer.lua")

local function safeCall(func, ...)
    if typeof(func) ~= "function" then
        notifySafe("Floopa Hub", "Comando no implementado", 2)
        return false
    end
    local ok, err = pcall(func, ...)
    if not ok then
        warn("[FloopaHub] Error ejecutando comando:", err)
        notifySafe("Floopa Hub", "Error: "..tostring(err), 2)
        return false
    end
    return true
end

local aliases = {
    ["fly"]="fly", ["unfly"]="unfly",
    ["noclip"]="noclip", ["unnoclip"]="unnoclip",
    ["walkspeed"]="walkspeed", ["speed"]="walkspeed", ["ws"]="walkspeed",
    ["unwalkspeed"]="unwalkspeed",
    ["esp"]="esp", ["unesp"]="unesp",
    ["xray"]="xray", ["unxray"]="unxray",
    ["killaura"]="killaura", ["ka"]="killaura", ["unkillaura"]="unkillaura",
    ["handlekill"]="handlekill", ["hkill"]="handlekill", ["unhandlekill"]="unhandlekill",
    ["aimbot"]="aimbot", ["aim"]="aimbot", ["unaimbot"]="unaimbot",
    ["infinitejump"]="infinitejump", ["infjump"]="infinitejump", ["uninfinitejump"]="uninfinitejump"
}

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
