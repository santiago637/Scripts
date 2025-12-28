local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
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
frame.Position = UDim2.new(0.275, 0, 1.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Thickness = 2
frameStroke.Color = Color3.fromRGB(0, 90, 200)
frameStroke.Parent = frame

local bgImage = Instance.new("ImageLabel")
bgImage.Name = "BackgroundImage"
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = "rbxassetid://81585308037319"
bgImage.ImageTransparency = 0.2
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 0
bgImage.Parent = frame

-- HEADER
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0.16, 0)
header.BackgroundColor3 = Color3.fromRGB(0, 85, 170)
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

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

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

-- CONTENIDO
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -20, 0.84, -20)
contentFrame.Position = UDim2.new(0, 10, 0.16, 10)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 1
contentFrame.Parent = frame

local uiList = Instance.new("UIListLayout")
uiList.FillDirection = Enum.FillDirection.Vertical
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 6)
uiList.Parent = contentFrame

-- TEXTBOX DE COMANDOS
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

local exCorner = Instance.new("UICorner")
exCorner.CornerRadius = UDim.new(0, 8)
exCorner.Parent = commandBox

local exStroke = Instance.new("UIStroke")
exStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
exStroke.Thickness = 1
exStroke.Color = Color3.fromRGB(0, 90, 200)
exStroke.Parent = commandBox

-- FEEDBACK LABEL MINIMALISTA
local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Name = "FeedbackLabel"
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
        task.wait(2)
        for i = 0, 1, 0.1 do
            feedbackLabel.TextTransparency = i
            task.wait(0.05)
        end
        feedbackLabel.Text = ""
    end)
end

-- PLACEHOLDER + COMANDOS
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

    local text = commandBox.Text
    if text == placeholder or text == "" then return end

    local args = string.split(text, " ")
    local cmd = args[1]:lower()
    local arg = args[2]

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

    elseif cmd == "walkspeed" or cmd == "speed" then
        Commands.WalkSpeed(arg)
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
        -- arg opcional (1–10) para ajustar transparencia
        Commands.XRay(arg, false)
        showFeedback("XRay activado")

    elseif cmd == "unxray" then
        Commands.XRay(nil, true)
        showFeedback("XRay desactivado")

    else
        print("Comando no reconocido:", text)
        showFeedback("Comando no reconocido")
    end

    commandBox.Text = placeholder
    commandBox.TextColor3 = Color3.fromRGB(150, 150, 170)
end)
