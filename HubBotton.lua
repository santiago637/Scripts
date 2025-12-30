local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

-- Protección: evitar re-ejecución
local gv = getgenv()
gv.FloopaHub = gv.FloopaHub or {}
if gv.FloopaHub.HubButtonLoaded then
    StarterGui:SetCore("SendNotification", {Title="Floopa Hub", Text="HubButton ya estaba cargado", Duration=3})
    return
end
gv.FloopaHub.HubButtonLoaded = true
gv.FloopaHub.Version = "1.2"

local function notifySafe(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=title or "Info", Text=text or "", Duration=duration or 3})
    end)
end

-- Espera a que el juego cargue
if not game:IsLoaded() then
    pcall(game.Loaded.Wait, game.Loaded)
end

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Singleton de GUI
local gui = playerGui:FindFirstChild("FloopaHubGUI")
if not gui then
    gui = Instance.new("ScreenGui")
    gui.Name = "FloopaHubGUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = false
    gui.Parent = playerGui
end

-- Botón de apertura con debounce
local openButton = gui:FindFirstChild("HubButton") or Instance.new("TextButton")
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
if not openButton:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", openButton).CornerRadius = UDim.new(0,12)
end

-- Menú principal
local menuFrame = gui:FindFirstChild("MainMenu") or Instance.new("Frame")
menuFrame.Name = "MainMenu"
menuFrame.Size = isMobile and UDim2.new(0,380,0,420) or UDim2.new(0,340,0,380)
menuFrame.Position = UDim2.new(0.5,0,0.5,0)
menuFrame.AnchorPoint = Vector2.new(0.5,0.5)
menuFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
menuFrame.Visible = false
menuFrame.Parent = gui
if not menuFrame:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0,14)
end

-- Header
local header = menuFrame:FindFirstChild("Header") or Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1,0,0,50)
header.BackgroundColor3 = Color3.fromRGB(0,90,180)
header.Parent = menuFrame
if not header:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)
end

local logo = header:FindFirstChild("Logo") or Instance.new("ImageLabel")
logo.Name = "Logo"
logo.Size = UDim2.new(0,36,0,36)
logo.Position = UDim2.new(0,10,0.5,-18)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://117990734815106"
logo.Parent = header

local title = header:FindFirstChild("Title") or Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,50,0,0)
title.BackgroundTransparency = 1
title.Text = "Floopa Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local function createMenuButton(name, text, posY, callback)
    local b = menuFrame:FindFirstChild(name) or Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(1,-40,0,50)
    b.Position = UDim2.new(0,20,0,posY)
    b.BackgroundColor3 = Color3.fromRGB(35,35,55)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = menuFrame
    if not b:FindFirstChildOfClass("UICorner") then
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    end
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then
            notifySafe("Floopa Hub", "Error: "..tostring(err), 3)
        end
    end)
end

-- Capa de protección a carga externa
local function safeLoad(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok or type(res) ~= "string" or #res < 20 then
        notifySafe("Floopa Hub", "No se pudo cargar: "..url, 3)
        return function() end
    end
    local fOk, fn = pcall(loadstring, res)
    if not fOk or type(fn) ~= "function" then
        notifySafe("Floopa Hub", "Código inválido: "..url, 3)
        return function() end
    end
    return fn
end

-- 🔥 Integración avanzada con CommandsExecutor
createMenuButton("CommandsButton","Abrir Ejecutor de Comandos",130,function()
    local gui = playerGui:FindFirstChild("FloopaHubGUI")
    local executor = gv.FloopaHub.ExecutorFrame
    if executor and executor.Parent == gui then
        executor.Visible = not executor.Visible
        gv.FloopaHub.ExecutorVisible = executor.Visible
        notifySafe("Floopa Hub", executor.Visible and "CommandsExecutor abierto" or "CommandsExecutor oculto", 2)
    else
        safeLoad("https://raw.githubusercontent.com/santiago637/Scripts/main/CommandsExecutor.lua")()
    end
end)

-- TP Panel con toggle avanzado
createMenuButton("TPPanelButton","Abrir TP Panel",70,function()
    local gui = playerGui:FindFirstChild("FloopaHubGUI")
    local tpPanel = gv.FloopaHub.TPPanelFrame
    if tpPanel and tpPanel.Parent == gui then
        tpPanel.Visible = not tpPanel.Visible
        gv.FloopaHub.TPPanelVisible = tpPanel.Visible
        notifySafe("Floopa Hub", tpPanel.Visible and "TP Panel abierto" or "TP Panel oculto", 2)
    else
        safeLoad("https://raw.githubusercontent.com/santiago637/Scripts/main/TPPanel.lua")()
    end
end)

-- Settings con toggle avanzado
createMenuButton("SettingsButton","Configuración",190,function()
    local gui = playerGui:FindFirstChild("FloopaHubGUI")
    local settings = gv.FloopaHub.SettingsFrame
    if settings and settings.Parent == gui then
        settings.Visible = not settings.Visible
        gv.FloopaHub.SettingsVisible = settings.Visible
        notifySafe("Floopa Hub", settings.Visible and "Settings abierto" or "Settings oculto", 2)
    else
        safeLoad("https://raw.githubusercontent.com/santiago637/Scripts/main/Settings.lua")()
    end
end)

-- Toggle con debounce
local lastClick = 0
openButton.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastClick < 0.15 then return end
    lastClick = now
    menuFrame.Visible = not menuFrame.Visible
end)

notifySafe("Floopa Hub", "HubButton cargado (v"..gv.FloopaHub.Version..")", 2)
