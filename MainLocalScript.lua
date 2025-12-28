local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- IMPORTAR EL MÓDULO DESDE GITHUB
local Commands = loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/ModuleScriptContainer.lua"))()

local gui = Instance.new("ScreenGui")
gui.Name = "FloopaHubMain"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- BOTÓN DE ABRIR
local openButton = Instance.new("ImageButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0.07, 0, 0.12, 0)
openButton.Position = UDim2.new(0.02, 0, 0.5, 0)
openButton.AnchorPoint = Vector2.new(0, 0.5)
openButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
openButton.BorderSizePixel = 0
openButton.Image = "rbxassetid://98416816221996"
openButton.Parent = gui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = openButton

local btnStroke = Instance.new("UIStroke")
btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
btnStroke.Thickness = 1.5
btnStroke.Color = Color3.fromRGB(0, 100, 200)
btnStroke.Parent = openButton

-- FRAME PRINCIPAL
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0.45, 0, 0.45, 0)
frame.Position = UDim2.new(0.275, 0, 1.1, 0) -- fuera de pantalla inicialmente
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Thickness = 2
frameStroke.Color = Color3.fromRGB(0, 90, 200)
frameStroke.Parent = frame

-- HEADER
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0.16, 0)
header.BackgroundColor3 = Color3.fromRGB(0, 85, 170)
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Floopa Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.ZIndex = 3
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.Position = UDim2.new(1, -10, 0.5, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.BorderSizePixel = 0
closeButton.ZIndex = 3
closeButton.Parent = header

-- CONTENIDO
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -20, 0.84, -20)
contentFrame.Position = UDim2.new(0, 10, 0.16, 10)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 1
contentFrame.Parent = frame

local commandBox = Instance.new("TextBox")
commandBox.Name = "CommandBox"
commandBox.Size = UDim2.new(1, 0, 0, 36)
commandBox.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
commandBox.Text = "Introducir comandos"
commandBox.TextColor3 = Color3.fromRGB(150, 150, 170)
commandBox.Font = Enum.Font.Gotham
commandBox.TextScaled = true
commandBox.BorderSizePixel = 0
commandBox.ZIndex = 2
commandBox.Parent = contentFrame

-- FEEDBACK
local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Size = UDim2.new(1, -20, 0, 24)
feedbackLabel.Position = UDim2.new(0, 10, 1, -30)
feedbackLabel.BackgroundTransparency = 1
feedbackLabel.Text = ""
feedbackLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
feedbackLabel.Font = Enum.Font.Merriweather
feedbackLabel.TextScaled = true
feedbackLabel.ZIndex = 5
feedbackLabel.Parent = frame

local function showFeedback(msg)
    feedbackLabel.Text = msg
    feedbackLabel.TextTransparency = 0
    task.spawn(function()
        for i = 0, 1, 0.05 do
            task.wait(0.05)
            feedbackLabel.TextTransparency = i
        end
        feedbackLabel.Text = ""
    end)
end

-- PLACEHOLDER
local placeholder = "Introducir comandos"

commandBox.Focused:Connect(function()
    if commandBox.Text == placeholder then
        commandBox.Text = ""
        commandBox.TextColor3 = Color3.fromRGB(230, 230, 255)
    end
end)

commandBox.FocusLost:Connect(function(enterPressed)
    if commandBox.Text == "" then
        commandBox.Text = placeholder
        commandBox.TextColor3 = Color3.fromRGB(150, 150, 170)
    end
    if not enterPressed then return end

    local args = string.split(commandBox.Text, " ")
    local cmd = args[1] and args[1]:lower()
    local arg = tonumber(args[2]) -- convertir a número si aplica

    if cmd == "fly" then
        Commands.Fly(arg, false)
        showFeedback("Fly activado")
    elseif cmd == "unfly" then
        Commands.Fly(nil, true)
        showFeedback("Fly desactivado")
    elseif cmd == "noclip" then
        Commands.Noclip(false)
        showFeedback("Noclip activado")
    elseif cmd == "unnoclip" then
        Commands.Noclip(true)
        showFeedback("Noclip desactivado")
    elseif cmd == "speed" or cmd == "walkspeed" then
        Commands.WalkSpeed(arg or 16)
        showFeedback("WalkSpeed ajustado")
    elseif cmd == "unwalkspeed" then
        Commands.WalkSpeed(16)
        showFeedback("WalkSpeed restaurado")
    elseif cmd == "esp" then
        Commands.ESP(false)
        showFeedback("ESP activado")
    elseif cmd == "unesp" then
        Commands.ESP(true)
        showFeedback("ESP desactivado")
    elseif cmd == "xray" then
        Commands.XRay(arg or 5, false)
        showFeedback("XRay activado")
    elseif cmd == "unxray" then
        Commands.XRay(nil, true)
        showFeedback("XRay desactivado")
    else
        showFeedback("Comando no reconocido")
    end

    commandBox.Text = placeholder
    commandBox.TextColor3 = Color3.fromRGB(150, 150, 170)
end)

-- ANIMACIONES DE APERTURA/CIERRE
local function toggleFrame(show)
    local goal = {}
    if show then
        goal.Position = UDim2.new(0.275, 0, 0.275, 0) -- posición visible en pantalla
    else
        goal.Position = UDim2.new(0.275, 0, 1.1, 0) -- fuera de pantalla
    end

    local tween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
    tween:Play()
end

-- EVENTOS DE BOTONES
openButton.MouseButton1Click:Connect(function()
    toggleFrame(true)
end)

closeButton.MouseButton1Click:Connect(function()
    toggleFrame(false)
end)
