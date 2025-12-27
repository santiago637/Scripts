local Commands = loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/ModuleScriptContainer.lua"))()

local placeholder = "Introducir comandos"

exampleButton.Text = placeholder
exampleButton.TextColor3 = Color3.fromRGB(150, 150, 170)

exampleButton.Focused:Connect(function()
    if exampleButton.Text == placeholder then
        exampleButton.Text = ""
        exampleButton.TextColor3 = Color3.fromRGB(230, 230, 255)
    end
end)

exampleButton.FocusLost:Connect(function(enterPressed)
    if exampleButton.Text == "" then
        exampleButton.Text = placeholder
        exampleButton.TextColor3 = Color3.fromRGB(150, 150, 170)
    end

    if not enterPressed then return end

    local text = exampleButton.Text
    if text == placeholder or text == "" then return end

    local args = string.split(text, " ")
    local cmd = args[1]:lower()
    local arg = args[2]

    -- FLY
    if cmd == "fly" then
        Commands.Fly(arg)

    -- NOCLIP
    elseif cmd == "noclip" then
        Commands.Noclip()

    -- WALKSPEED
    elseif cmd == "walkspeed" or cmd == "speed" then
        Commands.WalkSpeed(arg)

    else
        print("Comando no reconocido:", text)
    end

    exampleButton.Text = placeholder
    exampleButton.TextColor3 = Color3.fromRGB(150, 150, 170)
end)
