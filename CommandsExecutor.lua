local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Importar lógica de comandos
local Main = loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/MainLocalScript.lua"))()

---------------------------------------------------------------------- 
-- FRAME PRINCIPAL
----------------------------------------------------------------------

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = isMobile and UDim2.new(0,300,0,350) or UDim2.new(0,260,0,300)
frame.AnchorPoint = Vector2.new(0,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Parent = playerGui:FindFirstChild("FloopaHubGUI")
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

local function placeBottomRight(margin)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vs = cam.ViewportSize
    local fs = frame.AbsoluteSize
    frame.Position = UDim2.fromOffset(vs.X - fs.X - margin, vs.Y - fs.Y - margin)
end

placeBottomRight(10)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if frame.Visible then
        placeBottomRight(10)
    end
end)

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
logo.Image = "rbxassetid://117990734815106"
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

---------------------------------------------------------------------- 
-- TEXTBOX PARA COMANDOS
----------------------------------------------------------------------

local commandBox = Instance.new("TextBox")
commandBox.Name = "CommandBox"
commandBox.Size = UDim2.new(1,-20,0,40)
commandBox.Position = UDim2.new(0,10,0,55)
commandBox.BackgroundColor3 = Color3.fromRGB(25,25,40)
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
    local gui = playerGui:FindFirstChild("FloopaHubGUI")
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

    task.delay(5,function()
        if notif and notif.Parent then
            notif:Destroy()
        end
    end)
end

---------------------------------------------------------------------- 
-- LISTA DE COMANDOS
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
end

scrollFrame.CanvasSize = UDim2.new(0,0,0,y)

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
-- ARRASTRE DEL FRAME
----------------------------------------------------------------------

local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        startPos = frame.AbsolutePosition
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

        local newX = startPos.X + delta.X
        local newY = startPos.Y + delta.Y

        local vs = workspace.CurrentCamera.ViewportSize
        local fs = frame.AbsoluteSize
        local margin = 20

        newX = math.clamp(newX, margin, vs.X - fs.X - margin)
        newY = math.clamp(newY, margin, vs.Y - fs.Y - margin)

        frame.Position = UDim2.fromOffset(newX, newY)
    end
end)
