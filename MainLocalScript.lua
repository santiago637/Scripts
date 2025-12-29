local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local Commands = loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/ModuleScriptContainer.lua"))()

local function safeCall(func, ...)
    if typeof(func) == "function" then
        local ok, err = pcall(func, ...)
        if not ok then
            warn("[FloopaHub] Error ejecutando comando:", err)
        end
    else
        warn("[FloopaHub] Comando no implementado en el módulo.")
    end
end

local aliases = {
    ["fly"] = "fly",
    ["unfly"] = "unfly",

    ["noclip"] = "noclip",
    ["unnoclip"] = "unnoclip",

    ["walkspeed"] = "walkspeed",
    ["speed"] = "walkspeed",
    ["ws"] = "walkspeed",

    ["unwalkspeed"] = "unwalkspeed",

    ["esp"] = "esp",
    ["unesp"] = "unesp",

    ["xray"] = "xray",
    ["unxray"] = "unxray",

    ["killaura"] = "killaura",
    ["ka"] = "killaura",
    ["unkillaura"] = "unkillaura",

    ["handlekill"] = "handlekill",
    ["hkill"] = "handlekill",
    ["unhandlekill"] = "unhandlekill",

    ["aimbot"] = "aimbot",
    ["aim"] = "aimbot",
    ["unaimbot"] = "unaimbot",

    ["infinitejump"] = "infinitejump",
    ["infjump"] = "infinitejump",
    ["uninfinitejump"] = "uninfinitejump"
}

local function executeCommand(text)
    local args = string.split(text, " ")
    local rawCmd = args[1] and args[1]:lower()
    local cmd = aliases[rawCmd] or rawCmd
    local arg = args[2]

    if cmd == "fly" then
        safeCall(Commands.Fly, arg, false)

    elseif cmd == "unfly" then
        safeCall(Commands.Fly, nil, true)

    elseif cmd == "noclip" then
        safeCall(Commands.Noclip, false)

    elseif cmd == "unnoclip" then
        safeCall(Commands.Noclip, true)

    elseif cmd == "walkspeed" then
        safeCall(Commands.WalkSpeed, arg)

    elseif cmd == "unwalkspeed" then
        safeCall(Commands.WalkSpeed, 16)

    elseif cmd == "esp" then
        safeCall(Commands.ESP, false)

    elseif cmd == "unesp" then
        safeCall(Commands.ESP, true)

    elseif cmd == "xray" then
        safeCall(Commands.XRay, arg, false)

    elseif cmd == "unxray" then
        safeCall(Commands.XRay, nil, true)

    elseif cmd == "killaura" then
        safeCall(Commands.Killaura, arg, false)

    elseif cmd == "unkillaura" then
        safeCall(Commands.Killaura, nil, true)

    elseif cmd == "handlekill" then
        safeCall(Commands.HandleKill, arg, false)

    elseif cmd == "unhandlekill" then
        safeCall(Commands.HandleKill, nil, true)

    elseif cmd == "aimbot" then
        safeCall(Commands.Aimbot, arg, false)

    elseif cmd == "unaimbot" then
        safeCall(Commands.Aimbot, nil, true)

    elseif cmd == "infinitejump" then
        safeCall(Commands.InfiniteJump, true)

    elseif cmd == "uninfinitejump" then
        safeCall(Commands.InfiniteJump, false)

    else
        warn("[FloopaHub] Comando no reconocido:", text)
    end
end

return {
    ExecuteCommand = executeCommand
}
