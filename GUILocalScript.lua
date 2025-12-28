-- GUILocalScript final
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

-- Botón Hub (abrir/minimizar)
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0.12,0,0.08,0)
openButton.Position = UDim2.new(0.02,0,0.5,0)
openButton.AnchorPoint = Vector2.new(0,0.5)
openButton.BackgroundColor3 = Color3.fromRGB(35,35,45)
openButton.Text = "Hub"
openButton.TextColor3 = Color3.fromRGB(255,255,255)
openButton.Font = Enum.Font.GothamBold
openButton.TextScaled = true
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0,10)

-- Frame principal
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0.5,0,0.5,0)
frame.Position = UDim2.new(0.25,0,1.1,0) -- fuera de pantalla inicialmente
frame.BackgroundColor3 = Color3.fromRGB(15,15,25)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

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

-- Botón cerrar (X)
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

-- Lista de comandos
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

-- Botón Minimizar
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0,80,0,30)
minimizeButton.Position = UDim2.new(0,10,0.85,0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(40,40,60)
minimizeButton.Text = "Minimizar"
minimizeButton.TextColor3 = Color3.fromRGB(255,255,255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextScaled = true
minimizeButton.Parent = frame

-- Animación abrir/cerrar
local hubOpen = false
local function toggleFrame(show)
    if show then
        frame.Visible = true
        local goal = {Position = UDim2.new(0.25,0,0.25,0)}
        TweenService:Create(frame, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal):Play()
        hubOpen = true
    else
        local goal = {Position = UDim2.new(0.25,0,1.1,0)}
        local tween = TweenService:Create(frame, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In),goal)
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

    local noButton = Instance.new("TextButton")
    noButton.Size = UDim2.new(0.4,0,0.3,0)
    noButton.Position = UDim2.new(0.5,0,0.6,0)
    noButton.BackgroundColor3 = Color3.fromRGB(20,60,20)
    noButton.Text = "Cancelar"
    noButton.TextColor3 = Color3.fromRGB(255,255,255)
    noButton.Font = Enum.Font.GothamBold
    noButton.TextScaled = true
    noButton.Parent = confirmFrame

    yesButton.MouseButton1Click:Connect(function()
        gui:Destroy() -- destruye todo el exploit/GUI
    end)

    noButton.MouseButton1Click:Connect(function()
        confirmFrame:Destroy() -- cierra la confirmación sin cerrar el hub
    end)
end)

-- Capturar comandos
commandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and commandBox.Text ~= "" then
        Main.ExecuteCommand(commandBox.Text)
        showFeedback("Comando ejecutado: "..commandBox.Text)
        commandBox.Text = "Introducir comandos"
    end
end)
