local function safeLoad(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and result then
        local fn, err = loadstring(result)
        if fn then
            local success, execErr = pcall(fn)
            if not success then
                warn("Error ejecutando script:", execErr)
            end
        else
            warn("Error compilando script:", err)
        end
    else
        warn("Error descargando script:", url)
    end
end

-- Invocar MainLocalScript (lógica de comandos)
safeLoad("https://raw.githubusercontent.com/santiago637/Scripts/main/MainLocalScript.lua")

-- Invocar GUILocalScript (interfaz gráfica)
safeLoad("https://raw.githubusercontent.com/santiago637/Scripts/main/GUILocalScript.lua")

