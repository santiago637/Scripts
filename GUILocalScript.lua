    local noButton = Instance.new("TextButton")
    noButton.Size = UDim2.new(0.4,0,0.3,0)
    noButton.Position = UDim2.new(0.5,0,0.6,0)
    noButton.BackgroundColor3 = Color3.fromRGB(20,60,20)
    noButton.Text = "Cancelar"
    noButton.TextColor3 = Color3.fromRGB(255,255,255)
    noButton.Font = Enum.Font.GothamBold
    noButton.TextScaled = true
    noButton.Parent = confirmFrame

    yesButton.MouseButton1Click:Connect(function()
        gui:Destroy() -- destruye todo el exploit/GUI
    end)

    noButton.MouseButton1Click:Connect(function()
        confirmFrame:Destroy() -- cierra la confirmación sin cerrar el hub
    end)
end)

-- Capturar comandos
commandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and commandBox.Text ~= "" then
        Main.ExecuteCommand(commandBox.Text)
        showFeedback("Comando ejecutado: "..commandBox.Text)
        commandBox.Text = "Introducir comandos"
    end
end)
