local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Importar lógica de comandos
local Main = loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/MainLocalScript.lua"))()

----------------------------------------------------------------------
-- CREAR GUI PRINCIPAL
----------------------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "FloopaHubGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

----------------------------------------------------------------------
-- BOTÓN DE APERTURA
----------------------------------------------------------------------

local openButton = Instance.new("TextButton")
openButton.Name = "HubButton"
openButton.Size = isMobile and UDim2.new(0,120,0,50) or UDim2.new(0,100,0,40)
openButton.Position = isMobile and UDim2.new(1,-130,0,10) or UDim2.new(1,-110,0,10)
openButton.AnchorPoint = Vector2.new(1,0)
openButton.BackgroundColor3 = Color3.fromRGB(35,35,45)
openButton.Text = "Hub"
openButton.TextColor3 = Color3.fromRGB(255,255,255)
openButton.Font = Enum.Font.GothamBold
openButton.TextScaled = true
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0,12)

----------------------------------------------------------------------
-- FRAME PRINCIPAL
----------------------------------------------------------------------

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = isMobile and UDim2.new(0,300,0,350) or UDim2.new(0,260,0,300)
frame.AnchorPoint = Vector2.new(1,1)
frame.Position = UDim2.new(1,10,1,10)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

----------------------------------------------------------------------
-- HEADER
----------------------------------------------------------------------

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1,0,0,45)
header.BackgroundColor3 = Color3.fromRGB(0,90,180)
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)

local logo = Instance.new("ImageLabel")
logo.Name = "LogoImage"
logo.Size = UDim2.new(0,32,0,32)
logo.Position = UDim2.new(0,8,0.5,-16)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://117990734815106" -- tu asset
logo.Parent = header

local title = Instance.new("TextLabel")
title.Name = "TitleLabel"
title.Size = UDim2.new(1,-90,1,0)
title.Position = UDim2.new(0,45,0,0)
title.BackgroundTransparency = 1
title.Text = "Floopa Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0,24,0,24)
minimizeButton.Position = UDim2.new(1,-55,0.5,-12)
minimizeButton.BackgroundColor3 = Color3.fromRGB(25,70,70)
minimizeButton.Text = "_"
minimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextScaled = true
minimizeButton.Parent = header
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0,6)

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0,24,0,24)
closeButton.Position = UDim2.new(1,-25,0.5,-12)
closeButton.BackgroundColor3 = Color3.fromRGB(70,25,25)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.Parent = header
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0,6)

----------------------------------------------------------------------
-- TEXTBOX PARA COMANDOS
----------------------------------------------------------------------

local commandBox = Instance.new("TextBox")
commandBox.Name = "CommandBox"
commandBox.Size = UDim2.new(1,-20,0,40)
commandBox.Position = UDim2.new(0,10,0,55)
commandBox.BackgroundColor3 = Color3.fromRGB(25,25,40)
commandBox.Text = ""
commandBox.PlaceholderText = "Introducir comando"
commandBox.TextColor3 = Color3.fromRGB(180,180,200)
commandBox.PlaceholderColor3 = Color3.fromRGB(140,140,170)
commandBox.Font = Enum.Font.Gotham
commandBox.TextScaled = true
commandBox.ClearTextOnFocus = true
commandBox.Parent = frame
Instance.new("UICorner", commandBox).CornerRadius = UDim.new(0,10)

----------------------------------------------------------------------
-- NOTIFICACIONES
----------------------------------------------------------------------

local function showNotification(msg)
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(0,260,0,50)
    notif.Position = UDim2.new(1,-270,1,-120)
    notif.BackgroundColor3 = Color3.fromRGB(30,30,50)
    notif.Parent = gui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0,10)

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1,-30,1,0)
    txt.Position = UDim2.new(0,10,0,0)
    txt.BackgroundTransparency = 1
    txt.Text = msg
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = notif

    local x = Instance.new("TextButton")
    x.Size = UDim2.new(0,24,0,24)
    x.Position = UDim2.new(1,-28,0,4)
    x.BackgroundColor3 = Color3.fromRGB(70,25,25)
    x.Text = "X"
    x.TextColor3 = Color3.fromRGB(255,255,255)
    x.Font = Enum.Font.GothamBold
    x.TextScaled = true
    x.Parent = notif
    Instance.new("UICorner", x).CornerRadius = UDim.new(0,6)

    x.MouseButton1Click:Connect(function()
        notif:Destroy()
    end)

    task.delay(5,function()
        if notif and notif.Parent then
            notif:Destroy()
        end
    end)
end

----------------------------------------------------------------------
-- SCROLLFRAME + TOOLTIP
----------------------------------------------------------------------

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "CommandsScroll"
scrollFrame.Size = UDim2.new(1,-20,1,-110)
scrollFrame.Position = UDim2.new(0,10,0,100)
scrollFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
scrollFrame.ScrollBarThickness = isMobile and 12 or 8
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.Parent = frame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0,10)

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0,6)
padding.PaddingLeft = UDim.new(0,6)
padding.PaddingRight = UDim.new(0,6)
padding.Parent = scrollFrame

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

----------------------------------------------------------------------
-- LISTA DE COMANDOS (TODOS)
----------------------------------------------------------------------

local commandsInfo = {
    fly = "Permite volar.",
    unfly = "Desactiva el vuelo.",

    noclip = "Atravesar paredes.",
    unnoclip = "Desactiva noclip.",

    walkspeed = "Cambia velocidad.",
    unwalkspeed = "Velocidad normal.",

    esp = "Resalta jugadores.",
    unesp = "Desactiva ESP.",

    xray = "Transparencia paredes.",
    unxray = "Desactiva XRay.",

    infinitejump = "Salto infinito.",
    uninfinitejump = "Desactiva salto infinito.",

    killaura = "Ataca automáticamente.",
    unkillaura = "Desactiva Killaura.",

    handlekill = "Ataca con arma.",
    unhandlekill = "Desactiva HandleKill.",

    aimbot = "Apunta automático.",
    unaimbot = "Desactiva Aimbot."
}

local y = 0
for cmd,desc in pairs(commandsInfo) do
    local b = Instance.new("TextButton")
    b.Name = cmd.."Button"
    b.Size = UDim2.new(1,0,0,32)
    b.Position = UDim2.new(0,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(35,35,55)
    b.Text = cmd
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = scrollFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

    y = y + 36

    b.MouseButton1Click:Connect(function()
        local ok = pcall(function()
            Main.ExecuteCommand(cmd)
        end)
        if ok then
            showNotification("Comando ejecutado: "..cmd)
        else
            showNotification("Error al ejecutar: "..cmd)
        end
    end)

    b.MouseEnter:Connect(function()
        if not isMobile then
            local pos = UserInputService:GetMouseLocation()
            tooltip.Text = desc
            tooltip.Position = UDim2.new(0,pos.X+10,0,pos.Y-20)
            tooltip.Visible = true
        end
    end)

    b.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)

    if isMobile then
        b.TouchLongPress:Connect(function()
            tooltip.Text = desc
            tooltip.Position = UDim2.new(0.5,-110,0.8,-20)
            tooltip.Visible = true
            task.delay(2,function()
                tooltip.Visible = false
            end)
        end)
    end
end

scrollFrame.CanvasSize = UDim2.new(0,0,0,y)

----------------------------------------------------------------------
-- ANIMACIÓN ABRIR/CERRAR
----------------------------------------------------------------------

local hubOpen = false

local function toggleFrame(show)
    if show then
        frame.Visible = true
        TweenService:Create(
            frame,
            TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
            {Position = UDim2.new(1,-10,1,-10)}
        ):Play()
        hubOpen = true
    else
        local tween = TweenService:Create(
            frame,
            TweenInfo.new(0.35,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Position = UDim2.new(1,10,1,10)}
        )
        tween:Play()
        tween.Completed:Connect(function()
            frame.Visible = false
        end)
        hubOpen = false
    end
end

openButton.MouseButton1Click:Connect(function()
    toggleFrame(not hubOpen)
end)

minimizeButton.MouseButton1Click:Connect(function()
    toggleFrame(false)
end)

----------------------------------------------------------------------
-- CONFIRMACIÓN AL CERRAR
----------------------------------------------------------------------

closeButton.MouseButton1Click:Connect(function()
    local confirmFrame = Instance.new("Frame")
    confirmFrame.Name = "ConfirmFrame"
    confirmFrame.Size = UDim2.new(0,260,0,120)
    confirmFrame.Position = UDim2.new(0.5,0,0.5,0)
    confirmFrame.AnchorPoint = Vector2.new(0.5,0.5)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
    confirmFrame.Parent = gui
    Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0,10)

    local label = Instance.new("TextLabel")
    label.Name = "ConfirmLabel"
    label.Size = UDim2.new(1,-20,0.5,0)
    label.Position = UDim2.new(0,10,0,10)
    label.BackgroundTransparency = 1
    label.Text = "¿Seguro que quieres cerrar?"
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.Merriweather
    label.TextScaled = true
    label.Parent = confirmFrame

    local yesButton = Instance.new("TextButton")
    yesButton.Name = "YesButton"
    yesButton.Size = UDim2.new(0.4,0,0.25,0)
    yesButton.Position = UDim2.new(0.08,0,0.65,0)
    yesButton.BackgroundColor3 = Color3.fromRGB(60,20,20)
    yesButton.Text = "Sí"
    yesButton.TextColor3 = Color3.fromRGB(255,255,255)
    yesButton.Font = Enum.Font.GothamBold
    yesButton.TextScaled = true
    yesButton.Parent = confirmFrame
    Instance.new("UICorner", yesButton).CornerRadius = UDim.new(0,8)

    local noButton = Instance.new("TextButton")
    noButton.Name = "NoButton"
    noButton.Size = UDim2.new(0.4,0,0.25,0)
    noButton.Position = UDim2.new(0.52,0,0.65,0)
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

----------------------------------------------------------------------
-- COMANDOS MANUALES
----------------------------------------------------------------------

commandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and commandBox.Text ~= "" then
        local text = commandBox.Text
        local ok = pcall(function()
            Main.ExecuteCommand(text)
        end)
        if ok then
            showNotification("Comando ejecutado: "..text)
        else
            showNotification("Error al ejecutar: "..text)
        end
        commandBox.Text = ""
    end
end)

----------------------------------------------------------------------
-- ARRASTRE SUAVE
----------------------------------------------------------------------

local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        startPos = frame.Position
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - dragStart

                if i.UserInputType == Enum.UserInputType.Touch then
            delta = delta * 0.7
        end

        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y

        local cam = workspace.CurrentCamera.ViewportSize
        local fs = frame.AbsoluteSize
        local margin = 20

        newX = math.clamp(newX, margin, cam.X - fs.X - margin)
        newY = math.clamp(newY, margin, cam.Y - fs.Y - margin)

        frame.Position = UDim2.fromOffset(newX, newY)
    end
end)
