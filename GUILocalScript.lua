local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Importar MainLocalScript desde GitHub
local Main = loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/MainLocalScript.lua"))()

-- Crear GUI principal
local gui = Instance.new("ScreenGui")
gui.Name = "FloopaHubGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Botón Hub (abrir/minimizar)
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0.12,0,0.08,0)
openButton.Position = UDim2.new(0.02,0,0.5,0)
openButton.AnchorPoint = Vector2.new(0,0.5)
openButton.BackgroundColor3 = Color3.fromRGB(35,35,45)
openButton.Text = "Hub"
openButton.TextColor3 = Color3.fromRGB(255,255,255)
openButton.Font = Enum.Font.GothamBold
openButton.TextScaled = true
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0,12)

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.5,0,0.5,0)
frame.Position = UDim2.new(0.25,0,1.1,0)
frame.BackgroundColor3 = Color3.fromRGB(15,15,25)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- Header (arrastrable)
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0.15,0)
header.BackgroundColor3 = Color3.fromRGB(0,85,170)
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-80,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "Floopa Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Botón Minimizar
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0,24,0,24)
minimizeButton.AnchorPoint = Vector2.new(1,0.5)
minimizeButton.Position = UDim2.new(1,-40,0.5,0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(20,60,60)
minimizeButton.Text = "_"
minimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextScaled = true
minimizeButton.Parent = header
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0,6)

-- Botón cerrar (X)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0,24,0,24)
closeButton.AnchorPoint = Vector2.new(1,0.5)
closeButton.Position = UDim2.new(1,-10,0.5,0)
closeButton.BackgroundColor3 = Color3.fromRGB(60,20,20)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.Parent = header
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0,6)

-- TextBox para comandos manuales
local commandBox = Instance.new("TextBox")
commandBox.Size = UDim2.new(1,-20,0,36)
commandBox.Position = UDim2.new(0,10,0.2,0)
commandBox.BackgroundColor3 = Color3.fromRGB(25,25,40)
commandBox.Text = "Introducir comandos"
commandBox.TextColor3 = Color3.fromRGB(150,150,170)
commandBox.Font = Enum.Font.Gotham
commandBox.TextScaled = true
commandBox.Parent = frame
Instance.new("UICorner", commandBox).CornerRadius = UDim.new(0,8)

-- Feedback label
local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Size = UDim2.new(1,-20,0,24)
feedbackLabel.Position = UDim2.new(0,10,1,-30)
feedbackLabel.BackgroundTransparency = 1
feedbackLabel.TextColor3 = Color3.fromRGB(0,255,140)
feedbackLabel.Font = Enum.Font.GothamBold
feedbackLabel.TextScaled = true
feedbackLabel.Text = ""
feedbackLabel.Parent = frame

local function showFeedback(msg)
    feedbackLabel.Text = msg
    feedbackLabel.TextTransparency = 0
    task.spawn(function()
        task.wait(2)
        for i=0,1,0.1 do
            feedbackLabel.TextTransparency = i
            task.wait(0.05)
        end
        feedbackLabel.Text = ""
    end)
end

-- Lista de comandos en ScrollingFrame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,-20,0.55,-60)
scrollFrame.Position = UDim2.new(0,10,0.35,0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = frame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0,8)

-- Tooltip
local tooltip = Instance.new("TextLabel")
tooltip.Size = UDim2.new(0,200,0,40)
tooltip.BackgroundColor3 = Color3.fromRGB(30,30,50)
tooltip.TextColor3 = Color3.fromRGB(255,255,255)
tooltip.Font = Enum.Font.Merriweather
tooltip.TextScaled = true
tooltip.Visible = false
tooltip.Parent = gui
Instance.new("UICorner", tooltip).CornerRadius = UDim.new(0,8)

local commandsInfo = {
    ["fly"] = "Permite volar (PC: WASD/QE, móvil: joystick + salto).",
    ["unfly"] = "Desactiva el vuelo.",
    ["noclip"] = "Atravesar paredes y objetos.",
    ["unnoclip"] = "Desactiva noclip.",
    ["walkspeed"] = "Cambia la velocidad de caminar.",
    ["unwalkspeed"] = "Restaura velocidad normal.",
    ["esp"] = "Resalta jugadores con color de equipo.",
    ["unesp"] = "Desactiva ESP.",
    ["xray"] = "Hace transparentes las paredes (1-10).",
    ["unxray"] = "Desactiva XRay.",
    ["killaura"] = "Ataca automáticamente a enemigos cercanos.",
    ["unkillaura"] = "Desactiva Killaura.",
    ["handlekill"] = "Usa el arma equipada para atacar.",
    ["unhandlekill"] = "Desactiva HandleKill.",
    ["aimbot"] = "Apunta automáticamente al enemigo más cercano.",
    ["unaimbot"] = "Desactiva Aimbot."
}

-- Crear botones de comandos
local yPos = 0
for cmd, desc in pairs(commandsInfo) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,40)
    btn.Position = UDim2.new(0,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(25,25,45)
    btn.Text = cmd
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Parent = scrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    yPos = yPos + 45

    btn.MouseButton1Click:Connect(function()
        Main.ExecuteCommand(cmd)
        showFeedback("Comando ejecutado: "..cmd)
    end)

btn.MouseEnter:Connect(function()
        tooltip.Text = desc
        tooltip.Position = UDim2.new(0, UserInputService:GetMouseLocation().X + 10, 0, UserInputService:GetMouseLocation().Y - 20)
        tooltip.Visible = true
    end)

    btn.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)
end

-- Animación abrir/cerrar
local hubOpen = false
local function toggleFrame(show)
    if show then
        frame.Visible = true
        local goal = {Position = UDim2.new(0.25,0,0.25,0)}
        TweenService:Create(frame, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal):Play()
        hubOpen = true
    else
        local goal = {Position = UDim2.new(0.25,0,1.1,0)}
        local tween = TweenService:Create(frame, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In),goal)
        tween:Play()
        tween.Completed:Connect(function()
            frame.Visible = false
        end)
        hubOpen = false
    end
end

-- Eventos
openButton.MouseButton1Click:Connect(function()
    if hubOpen then
        toggleFrame(false)
    else
        toggleFrame(true)
    end
end)

minimizeButton.MouseButton1Click:Connect(function()
    toggleFrame(false)
end)

closeButton.MouseButton1Click:Connect(function()
    -- Confirmación
    local confirmFrame = Instance.new("Frame")
    confirmFrame.Size = UDim2.new(0.4,0,0.2,0)
    confirmFrame.Position = UDim2.new(0.3,0,0.4,0)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
    confirmFrame.Parent = gui
    Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0,10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0.5,0)
    label.BackgroundTransparency = 1
    label.Text = "¿Seguro que quieres cerrar?"
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.Merriweather
    label.TextScaled = true
    label.Parent = confirmFrame

    local yesButton = Instance.new("TextButton")
    yesButton.Size = UDim2.new(0.4,0,0.3,0)
    yesButton.Position = UDim2.new(0.1,0,0.6,0)
    yesButton.BackgroundColor3 = Color3.fromRGB(60,20,20)
    yesButton.Text = "Sí"
    yesButton.TextColor3 = Color3.fromRGB(255,255,255)
    yesButton.Font = Enum.Font.GothamBold
    yesButton.TextScaled = true
    yesButton.Parent = confirmFrame
    Instance.new("UICorner", yesButton).CornerRadius = UDim.new(0,8)

    local noButton = Instance.new("TextButton")
    noButton.Size = UDim2.new(0.4,0,0.3,0)
    noButton.Position = UDim2.new(0.5,0,0.6,0)
    noButton.BackgroundColor3 = Color3.fromRGB(20,60,20)
    noButton.Text = "Cancelar"
    noButton.TextColor3 = Color3.fromRGB(255,255,255)
    noButton.Font = Enum.Font.GothamBold
    noButton.TextScaled = true
    noButton.Parent = confirmFrame
    Instance.new("UICorner", noButton).CornerRadius = UDim.new(0,8)

    yesButton.MouseButton1Click:Connect(function()
        gui:Destroy() -- destruye todo el exploit/GUI
    end)

    noButton.MouseButton1Click:Connect(function()
        confirmFrame:Destroy() -- cierra la confirmación sin cerrar el hub
    end)
end)

-- Capturar comandos manuales
commandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and commandBox.Text ~= "" then
        Main.ExecuteCommand(commandBox.Text)
        showFeedback("Comando ejecutado: "..commandBox.Text)
        commandBox.Text = "Introducir comandos"
    end
end)

-- Hacer el frame arrastrable desde el header
local dragging, dragInput, dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
