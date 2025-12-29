local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- GUI principal
local gui = Instance.new("ScreenGui")
gui.Name = "FloopaHubGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Botón de apertura
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
-- MENU PRINCIPAL (más grande y centrado)
----------------------------------------------------------------------

local menuFrame = Instance.new("Frame")
menuFrame.Name = "MainMenu"
menuFrame.Size = isMobile and UDim2.new(0,380,0,420) or UDim2.new(0,340,0,380)
menuFrame.Position = UDim2.new(0.5,0,0.5,0)
menuFrame.AnchorPoint = Vector2.new(0.5,0.5)
menuFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
menuFrame.Visible = false
menuFrame.Parent = gui
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0,14)

-- Header con logo y título
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,50)
header.BackgroundColor3 = Color3.fromRGB(0,90,180)
header.Parent = menuFrame
Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0,36,0,36)
logo.Position = UDim2.new(0,10,0.5,-18)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://117990734815106"
logo.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,50,0,0)
title.BackgroundTransparency = 1
title.Text = "Floopa Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

----------------------------------------------------------------------
-- BOTONES DEL MENÚ
----------------------------------------------------------------------

local function createMenuButton(name, text, posY, callback)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = UDim2.new(1,-40,0,50)
    b.Position = UDim2.new(0,20,0,posY)
    b.BackgroundColor3 = Color3.fromRGB(35,35,55)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = menuFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

    b.MouseButton1Click:Connect(callback)
end

-- Botón: abrir TP Panel
createMenuButton("TPPanelButton","Abrir TP Panel",70,function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/TPPanel.lua"))()
end)

-- Botón: abrir ejecutor de comandos
createMenuButton("CommandsButton","Abrir Ejecutor de Comandos",130,function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/CommandsExecutor.lua"))()
end)

-- Botón: configuración
createMenuButton("SettingsButton","Configuración",190,function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/Settings.lua"))()
end)

----------------------------------------------------------------------
-- ABRIR/CERRAR MENÚ
----------------------------------------------------------------------

openButton.MouseButton1Click:Connect(function()
    menuFrame.Visible = not menuFrame.Visible
end)
