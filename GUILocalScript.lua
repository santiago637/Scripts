local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Detectar móvil/tablet
local screenSize = workspace.CurrentCamera.ViewportSize
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Importar MainLocalScript desde GitHub
local Main = loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/MainLocalScript.lua"))()

-- ScreenGui principal
local gui = Instance.new("ScreenGui")
gui.Name = "FloopaHubGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Botón Hub
local openButton = Instance.new("TextButton")
openButton.Name = "HubButton"
openButton.Size = isMobile and UDim2.new(0.18,0,0.1,0) or UDim2.new(0.12,0,0.08,0)
openButton.Position = isMobile and UDim2.new(0.02,0,0.85,0) or UDim2.new(0.02,0,0.5,0)
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
frame.Name = "MainFrame"
frame.Size = isMobile and UDim2.new(0.9,0,0.75,0) or UDim2.new(0.55,0,0.6,0)
frame.Position = isMobile and UDim2.new(0.05,0,1.1,0) or UDim2.new(0.225,0,1.1,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1,0,0.15,0)
header.BackgroundColor3 = Color3.fromRGB(0,90,180)
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)

-- Logo
local logo = Instance.new("ImageLabel")
logo.Name = "LogoImage"
logo.Size = UDim2.new(0,40,0,40)
logo.Position = UDim2.new(0,10,0.5,-20)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://109038108792734"
logo.Parent = header

-- Título
local title = Instance.new("TextLabel")
title.Name = "TitleLabel"
title.Size = UDim2.new(1,-120,1,0)
title.Position = UDim2.new(0,60,0,0)
title.BackgroundTransparency = 1
title.Text = "Floopa Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Botón Minimizar
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0,28,0,28)
minimizeButton.AnchorPoint = Vector2.new(1,0.5)
minimizeButton.Position = UDim2.new(1,-50,0.5,0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(25,70,70)
minimizeButton.Text = "_"
minimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextScaled = true
minimizeButton.Parent = header
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0,8)

-- Botón cerrar (X)
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0,28,0,28)
closeButton.AnchorPoint = Vector2.new(1,0.5)
closeButton.Position = UDim2.new(1,-10,0.5,0)
closeButton.BackgroundColor3 = Color3.fromRGB(70,25,25)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.Parent = header
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0,8)

-- TextBox para comandos manuales
local commandBox = Instance.new("TextBox")
commandBox.Name = "CommandBox"
commandBox.Size = UDim2.new(1,-20,0,36)
commandBox.Position = UDim2.new(0,10,0.2,0)
commandBox.BackgroundColor3 = Color3.fromRGB(25,25,40)
commandBox.Text = "Introducir comandos"
commandBox.TextColor3 = Color3.fromRGB(150,150,170)
commandBox.Font = Enum.Font.Gotham
commandBox.TextScaled = true
commandBox.Parent = frame
Instance.new("UICorner", commandBox).CornerRadius = UDim.new(0,10)

-- Notificación avanzada
local function showNotification(msg)
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(0.3,0,0.1,0)
    notif.Position = UDim2.new(0.65,0,0.05,0)
    notif.BackgroundColor3 = Color3.fromRGB(30,30,50)
    notif.Parent = gui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0,10)

    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1,-30,1,0)
    notifText.Position = UDim2.new(0,10,0,0)
    notifText.BackgroundTransparency = 1
    notifText.Text = msg
    notifText.TextColor3 = Color3.fromRGB(255,255,255)
    notifText.Font = Enum.Font.GothamBold
    notifText.TextScaled = true
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.Parent = notif

    local closeNotif = Instance.new("TextButton")
    closeNotif.Size = UDim2.new(0,24,0,24)
    closeNotif.Position = UDim2.new(1,-28,0,4)
    closeNotif.BackgroundColor3 = Color3.fromRGB(70,25,25)
    closeNotif.Text = "X"
    closeNotif.TextColor3 = Color3.fromRGB(255,255,255)
    closeNotif.Font = Enum.Font.GothamBold
    closeNotif.TextScaled = true
    closeNotif.Parent = notif
    Instance.new("UICorner", closeNotif).CornerRadius = UDim.new(0,6)

    closeNotif.MouseButton1Click:Connect(function()
        notif:Destroy()
    end)

    task.spawn(function()
        task.wait(5)
        if notif and notif.Parent then
            notif:Destroy()
        end
    end)
end

-- ScrollingFrame para comandos
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "CommandsScroll"
scrollFrame.Size = UDim2.new(1,-20,0.65,-60)
scrollFrame.Position = UDim2.new(0,10,0.3,0)
scrollFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
scrollFrame.ScrollBarThickness = isMobile and 12 or 8
scrollFrame.Parent = frame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0,10)

-- Tooltip
local tooltip = Instance.new("TextLabel")
tooltip.Name = "TooltipLabel"
tooltip.Size = UDim2.new(0,220,0,40)
tooltip.BackgroundColor3 = Color3.fromRGB(30,30,50)
tooltip.TextColor3 = Color3.fromRGB(255,255,255)
tooltip.Font = Enum.Font.Merriweather
tooltip.TextScaled = true
tooltip.Visible = false
tooltip.Parent = gui
Instance.new("UICorner", tooltip).CornerRadius = UDim.new(0,8)

-- Info de comandos
local commandsInfo = {
    ["fly"] = "Permite volar.",
    ["unfly"] = "Desactiva el vuelo.",
    ["noclip"] = "Atravesar paredes.",
    ["unnoclip"] = "Desactiva noclip.",
    ["walkspeed"] = "Cambia velocidad.",
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
    btn.Name = cmd.."Button"
    btn.Size = UDim2.new(1,0,0,32)
    btn.Position = UDim2.new(0,0,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,55)
    btn.Text = cmd
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Parent = scrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    yPos = yPos + 36

    btn.MouseButton1Click:Connect(function()
        local success = pcall(function()
            Main.ExecuteCommand(cmd)
        end)
        if success then
            showNotification("Comando ejecutado: "..cmd)
        else
            showNotification("Error al ejecutar: "..cmd)
        end
    end)

    -- Tooltip PC
    btn.MouseEnter:Connect(function()
        if not isMobile then
            tooltip.Text = desc
            local pos = UserInputService:GetMouseLocation()
            tooltip.Position = UDim2.new(0, pos.X + 10, 0, pos.Y - 20)
            tooltip.Visible = true
        end
    end)

    btn.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)

    -- Tooltip móvil (mantener presionado)
    if isMobile then
        btn.TouchLongPress:Connect(function()
            tooltip.Text = desc
            tooltip.Position = UDim2.new(0.5,-110,0.85,-20)
            tooltip.Visible = true
            task.wait(2)
            tooltip.Visible = false
        end)
    end
end

scrollFrame.CanvasSize = UDim2.new(0,0,0,yPos)

-- Animación abrir/cerrar
local hubOpen = false
local function toggleFrame(show)
    if show then
        frame.Visible = true
        local goal = {Position = isMobile and UDim2.new(0.05,0,0.12,0) or UDim2.new(0.225,0,0.225,0)}
        TweenService:Create(frame, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal):Play()
        hubOpen = true
    else
        local goal = {Position = isMobile and UDim2.new(0.05,0,1.1,0) or UDim2.new(0.225,0,1.1,0)}
        local tween = TweenService:Create(frame, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In),goal)
        tween:Play()
        tween.Completed:Connect(function()
            frame.Visible = false
        end)
        hubOpen = false
    end
end

-- Eventos de botones
openButton.MouseButton1Click:Connect(function()
    toggleFrame(not hubOpen)
end)

minimizeButton.MouseButton1Click:Connect(function()
    toggleFrame(false)
end)

closeButton.MouseButton1Click:Connect(function()
    local confirmFrame = Instance.new("Frame")
    confirmFrame.Name = "ConfirmFrame"
    confirmFrame.Size = UDim2.new(0.4,0,0.2,0)
    confirmFrame.Position = UDim2.new(0.3,0,0.4,0)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
    confirmFrame.Parent = gui
    Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0,10)

    local label = Instance.new("TextLabel")
    label.Name = "ConfirmLabel"
    label.Size = UDim2.new(1,0,0.5,0)
    label.BackgroundTransparency = 1
    label.Text = "¿Seguro que quieres cerrar?"
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.Merriweather
    label.TextScaled = true
    label.Parent = confirmFrame

    local yesButton = Instance.new("TextButton")
    yesButton.Name = "YesButton"
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
    noButton.Name = "NoButton"
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
        gui:Destroy()
    end)

    noButton.MouseButton1Click:Connect(function()
        confirmFrame:Destroy()
    end)
end)

-- Capturar comandos manuales
commandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and commandBox.Text ~= "" then
        local success = pcall(function()
            Main.ExecuteCommand(commandBox.Text)
        end)
        if success then
            showNotification("Comando ejecutado: "..commandBox.Text)
        else
            showNotification("Error al ejecutar: "..commandBox.Text)
        end
        commandBox.Text = "Introducir comandos"
    end
end)

-- Arrastre optimizado para PC + móvil
local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
