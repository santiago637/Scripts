-- MainLocalScript
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Importar módulo
local Commands = loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/ModuleScriptContainer.lua"))()

-- Función para ejecutar comandos
local function executeCommand(text)
    local args = string.split(text, " ")
    local cmd = args[1] and args[1]:lower()
    local arg = args[2]

    if cmd == "fly" then
        Commands.Fly(arg, false)
    elseif cmd == "unfly" then
        Commands.Fly(nil, true)
    elseif cmd == "noclip" then
        Commands.Noclip(false)
    elseif cmd == "unnoclip" then
        Commands.Noclip(true)
    elseif cmd == "walkspeed" or cmd == "speed" then
        Commands.WalkSpeed(arg)
    elseif cmd == "unwalkspeed" then
        Commands.WalkSpeed(16)
    elseif cmd == "esp" then
        Commands.ESP(false)
    elseif cmd == "unesp" then
        Commands.ESP(true)
    elseif cmd == "xray" then
        Commands.XRay(arg, false)
    elseif cmd == "unxray" then
        Commands.XRay(nil, true)
    elseif cmd == "killaura" then
        Commands.Killaura(arg, false)
    elseif cmd == "unkillaura" then
        Commands.Killaura(nil, true)
    elseif cmd == "handlekill" then
        Commands.HandleKill(arg, false)
    elseif cmd == "unhandlekill" then
        Commands.HandleKill(nil, true)
    elseif cmd == "aimbot" then
        Commands.Aimbot(arg, false)
    elseif cmd == "unaimbot" then
        Commands.Aimbot(nil, true)
    else
        warn("Comando no reconocido:", text)
    end
end

-- Exponer función para que la GUI la use
return {
    ExecuteCommand = executeCommand
}
