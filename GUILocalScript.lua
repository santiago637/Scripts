-- GUILocalScript mejorado
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Importar MainLocalScript desde GitHub
local Main = loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/MainLocalScript.lua"))()

-- Crear GUI principal
local gui = Instance.new("ScreenGui")
gui.Name = "FloopaHubGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Botón de abrir
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0.12,0,0.08,0) -- tamaño grande para móvil
openButton.Position = UDim2.new(0.02,0,0.5,0)
openButton.AnchorPoint = Vector2.new(0,0.5)
openButton.BackgroundColor3 = Color3.fromRGB(35,35,45)
openButton.Text = "Hub"
openButton.TextColor3 = Color3.fromRGB(255,255,255)
openButton.Font = Enum.Font.GothamBold
openButton.TextScaled = true
openButton.Parent = gui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0,10)
btnCorner.Parent = openButton

-- Frame principal
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0.5,0,0.5,0)
frame.Position = UDim2.new(0.25,0,1.1,0) -- fuera de pantalla inicialmente
frame.BackgroundColor3 = Color3.fromRGB(15,15,25)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0,10)
frameCorner.Parent = frame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0.15,0)
header.BackgroundColor3 = Color3.fromRGB(0,85,170)
header.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-40,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "Floopa Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0,24,0,24)
closeButton.AnchorPoint = Vector2.new(1,0.5)
closeButton.Position = UDim2.new(1,-10,0.5,0)
closeButton.BackgroundColor3 = Color3.fromRGB(15,15,25)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255,255,255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.Parent = header

-- TextBox para comandos
local commandBox = Instance.new("TextBox")
commandBox.Size = UDim2.new(1,-20,0,36)
commandBox.Position = UDim2.new(0,10,0.2,0)
commandBox.BackgroundColor3 = Color3.fromRGB(25,25,40)
commandBox.Text = "Introducir comandos"
commandBox.TextColor3 = Color3.fromRGB(150,150,170)
commandBox.Font = Enum.Font.Gotham
commandBox.TextScaled = true
commandBox.Parent = frame

-- Feedback
local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Size = UDim2.new(1,-20,0,24)
feedbackLabel.Position = UDim2.new(0,10,1,-30)
feedbackLabel.BackgroundTransparency = 1
feedbackLabel.TextColor3 = Color3.fromRGB(200,220,255)
feedbackLabel.Font = Enum.Font.Merriweather
feedbackLabel.TextScaled = true
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

-- Lista de comandos disponibles
local commandsList = Instance.new("TextLabel")
commandsList.Size = UDim2.new(1,-20,0.6,-60)
commandsList.Position = UDim2.new(0,10,0.35,0)
commandsList.BackgroundTransparency = 1
commandsList.TextColor3 = Color3.fromRGB(180,200,255)
commandsList.Font = Enum.Font.Merriweather
commandsList.TextScaled = true
commandsList.TextWrapped = true
commandsList.Text = [[
Comandos disponibles:
fly / unfly
noclip / unnoclip
walkspeed <num> / unwalkspeed
esp / unesp
xray <1-10> / unxray
killaura / unkillaura
handlekill / unhandlekill
aimbot / unaimbot
]]
commandsList.Parent = frame

-- Capturar comandos
commandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and commandBox.Text ~= "" then
        Main.ExecuteCommand(commandBox.Text)
        showFeedback("Comando ejecutado: "..commandBox.Text)
        commandBox.Text = "Introducir comandos"
    end
end)

-- Animación abrir/cerrar
local function toggleFrame(show)
    local goal = {}
    if show then
        goal.Position = UDim2.new(0.25,0,0.25,0)
    else
        goal.Position = UDim2.new(0.25,0,1.1,0)
    end
    TweenService:Create(frame, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal):Play()
end

openButton.MouseButton1Click:Connect(function()
    toggleFrame(true)
end)

closeButton.MouseButton1Click:Connect(function()
    toggleFrame(false)
end)
