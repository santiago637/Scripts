-- Floopa Hub - CommandsExecutor (GUI compacta inferior derecha)
-- v3.0 - Pro edition: bypass avanzado + UI pulida + integración con Hub

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local gv = getgenv()
gv.FloopaHub = gv.FloopaHub or {}
if gv.FloopaHub.CommandsExecutorLoaded then
    StarterGui:SetCore("SendNotification", {Title="Floopa Hub", Text="CommandsExecutor ya cargado", Duration=3})
    return
end
gv.FloopaHub.CommandsExecutorLoaded = true

local function notifySafe(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=title or "Info", Text=text or "", Duration=duration or 3})
    end)
end

-- 🔥 Bypass pro: múltiples capas
local function safeHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" then return res end

    local function tryReq(fn)
        local ok, r = pcall(fn, {Url=url, Method="GET"})
        if ok and r and r.Body then return r.Body end
    end

    if syn and syn.request then
        local body = tryReq(syn.request)
        if body then return body end
    end
    if http_request then
        local body = tryReq(http_request)
        if body then return body end
    end
    if request then
        local body = tryReq(request)
        if body then return body end
    end

    if readfile and isfile and isfile("MainLocalScript.lua") then
        local ok, data = pcall(readfile, "MainLocalScript.lua")
        if ok and type(data) == "string" then return data end
    end

    return ""
end

local function safeLoad(url)
    local res = safeHttpGet(url)
    if type(res) ~= "string" or #res < 50 then
        notifySafe("Floopa Hub", "No se pudo cargar: "..url, 3)
        return { ExecuteCommand = function() end }
    end
    local fOk, fn = pcall(loadstring, res)
    if not fOk or type(fn) ~= "function" then
        notifySafe("Floopa Hub", "Código inválido: "..url, 3)
        return { ExecuteCommand = function() end }
    end
    local ok, mod = pcall(fn)
    if not ok or type(mod) ~= "table" then
        return { ExecuteCommand = function() end }
    end
    return mod
end

local Main = safeLoad("https://raw.githubusercontent.com/santiago637/Scripts/main/MainLocalScript.lua")

-- Contexto GUI
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Asegurar ScreenGui
local gui = playerGui:FindFirstChild("FloopaHubGUI")
if not gui then
    gui = Instance.new("ScreenGui")
    gui.Name = "FloopaHubGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
end

-- Frame principal
local frame = gui:FindFirstChild("MainFrame") or Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = isMobile and UDim2.new(0,300,0,360) or UDim2.new(0,260,0,310)
frame.AnchorPoint = Vector2.new(0,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Parent = gui
if not frame:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)
end

gv.FloopaHub.ExecutorFrame = frame
gv.FloopaHub.ExecutorVisible = true

local function placeBottomRight(margin)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vs = cam.ViewportSize
    local fs = frame.AbsoluteSize
    frame.Position = UDim2.fromOffset(vs.X - fs.X - margin, vs.Y - fs.Y - margin)
end
placeBottomRight(10)
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if frame.Visible then placeBottomRight(10) end
end)

-- Header
local header = frame:FindFirstChild("Header") or Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1,0,0,45)
header.BackgroundColor3 = Color3.fromRGB(0,90,180)
header.Parent = frame
if not header:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)
end

local logo = header:FindFirstChild("LogoImage") or Instance.new("ImageLabel")
logo.Name = "LogoImage"
logo.Size = UDim2.new(0,32,0,32)
logo.Position = UDim2.new(0,8,0.5,-16)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://117990734815106"
logo.Parent = header

local title = header:FindFirstChild("TitleLabel") or Instance.new("TextLabel")
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

-- Botón cerrar
local closeBtn = header:FindFirstChild("CloseButton") or Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0.5,-15)
closeBtn.BackgroundColor3 = Color3.fromRGB(35,35,55)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.Parent = header
if not closeBtn:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)
end

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    gv.FloopaHub.ExecutorVisible = false
    notifySafe("Floopa Hub","CommandsExecutor oculto",2)
end)

-- Notificaciones locales
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
    txt.Text = tostring(msg)
    txt.TextColor3 = Color3.fromRGB(255,255,255)
    txt.Font = Enum.Font.GothamBold
    txt.TextScaled = true
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = notif

    task.delay(4,function()
        if notif and notif.Parent then notif:Destroy() end
    end)
end

-- TextBox comandos (corregido)
local commandBox = frame:FindFirstChild("CommandBox") or Instance.new("TextBox")
commandBox.Name = "CommandBox"
commandBox.Size = UDim2.new(1,-20,0,40)
commandBox.Position = UDim2.new(0,10,0,55)
commandBox.BackgroundColor3 = Color3.fromRGB(25,25,40)
commandBox.Text = ""  -- arranca vacío
commandBox.PlaceholderText = "Pon tu comando aquí"  -- hint visible
commandBox.TextColor3 = Color3.fromRGB(180,180,200)
commandBox.PlaceholderColor3 = Color3.fromRGB(140,140,170)
commandBox.Font = Enum.Font.Gotham
commandBox.TextScaled = true
commandBox.ClearTextOnFocus = true
commandBox.Parent = frame
if not commandBox:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", commandBox).CornerRadius = UDim.new(0,10)
end

-- Lista de comandos
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

local scrollFrame = frame:FindFirstChild("CommandsScroll") or Instance.new("ScrollingFrame")
scrollFrame.Name = "CommandsScroll"
scrollFrame.Size = UDim2.new(1,-20,1,-110)
scrollFrame.Position = UDim2.new(0,10,0,100)
scrollFrame.BackgroundColor3 = Color3.fromRGB(25,25,35)
scrollFrame.ScrollBarThickness = isMobile and 12 or 8
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.Parent = frame
if not scrollFrame:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0,10)
end

-- Crear botones ordenados alfabéticamente
local keys = {}
for cmd,_ in pairs(commandsInfo) do table.insert(keys, cmd) end
table.sort(keys)

local y = 0
for _,cmd in ipairs(keys) do
    local b = scrollFrame:FindFirstChild(cmd.."Button") or Instance.new("TextButton")
    b.Name = cmd.."Button"
    b.Size = UDim2.new(1,0,0,32)
    b.Position = UDim2.new(0,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(35,35,55)
    b.Text = cmd
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = scrollFrame
    if not b:FindFirstChildOfClass("UICorner") then
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    end

    y = y + 36

    b.MouseButton1Click:Connect(function()
        local ok = Main.ExecuteCommand and Main.ExecuteCommand(cmd)
        if ok then
            showNotification("Comando ejecutado: "..cmd)
        else
            showNotification("Error al ejecutar: "..cmd)
        end
    end)
end

scrollFrame.CanvasSize = UDim2.new(0,0,0,y)

-- Comandos manuales
commandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and commandBox.Text ~= "" then
        local text = commandBox.Text
        local ok = Main.ExecuteCommand and Main.ExecuteCommand(text)
        if ok then
            showNotification("Comando ejecutado: "..text)
        else
            showNotification("Error al ejecutar: "..text)
        end
        commandBox.Text = ""
    end
end)

-- Arrastre del frame (PC y móvil)
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

notifySafe("Floopa Hub", "CommandsExecutor listo", 2)
