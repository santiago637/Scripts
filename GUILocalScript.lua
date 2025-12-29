local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Main = loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/MainLocalScript.lua"))()

local gui = Instance.new("ScreenGui")
gui.Name = "FloopaHubGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- BOTÓN HUB (ABAJO DERECHA)
local openButton = Instance.new("TextButton")
openButton.Name = "HubButton"
openButton.Size = isMobile and UDim2.new(0,120,0,55) or UDim2.new(0,100,0,45)
openButton.Position = UDim2.new(1,-(isMobile and 130 or 110),1,-(isMobile and 70 or 60))
openButton.BackgroundColor3 = Color3.fromRGB(35,35,45)
openButton.Text = "Hub"
openButton.TextColor3 = Color3.fromRGB(255,255,255)
openButton.Font = Enum.Font.GothamBold
openButton.TextScaled = true
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0,12)

-- FRAME PRINCIPAL (CUADRADO, COMPACTO, ABAJO DERECHA)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = isMobile and UDim2.new(0,300,0,350) or UDim2.new(0,260,0,300)
frame.Position = UDim2.new(1,10,1,10) -- fuera de pantalla
frame.AnchorPoint = Vector2.new(1,1)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.Visible = false
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

-- HEADER
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
logo.Image = "rbxassetid://109038108792734"
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

-- BOTONES HEADER
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

-- TEXTBOX
local commandBox = Instance.new("TextBox")
commandBox.Name = "CommandBox"
commandBox.Size = UDim2.new(1,-20,0,40)
commandBox.Position = UDim2.new(0,10,0,55)
commandBox.BackgroundColor3 = Color3.fromRGB(25,25,40)
commandBox.Text = "Introducir comando"
commandBox.TextColor3 = Color3.fromRGB(180,180,200)
commandBox.Font = Enum.Font.Gotham
commandBox.TextScaled = true
commandBox.ClearTextOnFocus = true
commandBox.Parent = frame
Instance.new("UICorner", commandBox).CornerRadius = UDim.new(0,10)

-- NOTIFICACIONES
local function showNotification(msg)
    local notif = Instance.new("Frame")
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
        if notif then notif:Destroy() end
    end)
end

-- SCROLLFRAME
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "CommandsScroll"
scrollFrame.Size = UDim2.new(1,-20,1,-110)
scrollFrame.Position = UDim2.new(0,10,0,100)
scrollFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
scrollFrame.ScrollBarThickness = isMobile and 12 or 8
scrollFrame.Parent = frame
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0,10)

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0,6)
padding.PaddingLeft = UDim.new(0,6)
padding.PaddingRight = UDim.new(0,6)
padding.Parent = scrollFrame

-- TOOLTIP
local tooltip = Instance.new("TextLabel")
tooltip.Size = UDim2.new(0,200,0,40)
tooltip.BackgroundColor3 = Color3.fromRGB(30,30,50)
tooltip.TextColor3 = Color3.fromRGB(255,255,255)
tooltip.Font = Enum.Font.Merriweather
tooltip.TextScaled = true
tooltip.Visible = false
tooltip.Parent = gui
Instance.new("UICorner", tooltip).CornerRadius = UDim.new(0,8)

-- COMANDOS
local commandsInfo = {
    fly="Permite volar.",
    unfly="Desactiva el vuelo.",
    noclip="Atravesar paredes.",
    unnoclip="Desactiva noclip.",
    walkspeed="Cambia velocidad.",
    unwalkspeed="Velocidad normal.",
    esp="Resalta jugadores.",
    unesp="Desactiva ESP.",
    xray="Transparencia paredes.",
    unxray="Desactiva XRay.",
    killaura="Ataca automáticamente.",
    unkillaura="Desactiva Killaura.",
    handlekill="Ataca con arma.",
    unhandlekill="Desactiva HandleKill.",
    aimbot="Apunta automático.",
    unaimbot="Desactiva Aimbot."
}

local y = 0
for cmd,desc in pairs(commandsInfo) do
    local b = Instance.new("TextButton")
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
        showNotification(ok and ("Comando ejecutado: "..cmd) or ("Error: "..cmd))
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
end

scrollFrame.CanvasSize = UDim2.new(0,0,0,y)

-- ANIMACIÓN
local open = false
local function toggle()
    if open then
        TweenService:Create(frame,TweenInfo.new(0.35),{Position=UDim2.new(1,10,1,10)}):Play()
        task.delay(0.35,function() frame.Visible=false end)
    else
        frame.Visible=true
        TweenService:Create(frame,TweenInfo.new(0.35),{Position=UDim2.new(1,-10,1,-10)}):Play()
    end
    open = not open
end

openButton.MouseButton1Click:Connect(toggle)
minimizeButton.MouseButton1Click:Connect(toggle)
closeButton.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ARRASTRE SUAVE
local dragging=false
local dragStart
local startPos

header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragStart=i.Position
        startPos=frame.Position
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if dragging then
        local delta=i.Position-dragStart
        local newX=startPos.X.Offset+delta.X
        local newY=startPos.Y.Offset+delta.Y

        local cam=workspace.CurrentCamera.ViewportSize
        local fs=frame.AbsoluteSize
        local m=20

        newX=math.clamp(newX,m,cam.X-fs.X-m)
        newY=math.clamp(newY,m,cam.Y-fs.Y-m)

        frame.Position=UDim2.fromOffset(newX,newY)
    end
end)
