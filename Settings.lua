-- Floopa Hub - Settings.lua (Delta-ready)
-- v1.1 - Singleton + robust parenting + toggles seguros

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local gv = getgenv()
gv.FloopaHub = gv.FloopaHub or {}
gv.FloopaHub.Settings = gv.FloopaHub.Settings or { Notifications = true }

-- Protección: evitar doble carga
if gv.FloopaHub.SettingsLoaded then
    return
end
gv.FloopaHub.SettingsLoaded = true

local function notifySafe(title, text, duration)
    if not gv.FloopaHub.Settings.Notifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title or "Info", Text = text or "", Duration = duration or 3 })
    end)
end

-- Espera al PlayerGui
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Asegurar FloopaHubGUI
local gui = playerGui:FindFirstChild("FloopaHubGUI")
if not gui then
    gui = Instance.new("ScreenGui")
    gui.Name = "FloopaHubGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
end

-- Crear o reutilizar frame de settings
local frame = gui:FindFirstChild("SettingsFrame") or Instance.new("Frame")
frame.Name = "SettingsFrame"
frame.Size = UDim2.new(0, 260, 0, 210)
frame.Position = UDim2.new(0.5, -130, 0.5, -105)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.Visible = true
frame.Parent = gui
if not frame:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
end

-- Header
local header = frame:FindFirstChild("Header") or Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(0, 90, 180)
header.Parent = frame
if not header:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
end

local headerText = header:FindFirstChild("Title") or Instance.new("TextLabel")
headerText.Name = "Title"
headerText.Size = UDim2.new(1, -40, 1, 0)
headerText.Position = UDim2.new(0, 10, 0, 0)
headerText.BackgroundTransparency = 1
headerText.Text = "Configuración"
headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
headerText.Font = Enum.Font.GothamBold
headerText.TextScaled = true
headerText.Parent = header

-- Botón cerrar
local closeBtn = header:FindFirstChild("Close") or Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.Parent = header
if not closeBtn:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
end
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Toggle de notificaciones
local notifButton = frame:FindFirstChild("NotifButton") or Instance.new("TextButton")
notifButton.Name = "NotifButton"
notifButton.Size = UDim2.new(1, -20, 0, 40)
notifButton.Position = UDim2.new(0, 10, 0, 60)
notifButton.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
notifButton.TextColor3 = Color3.fromRGB(255, 255, 255)
notifButton.Font = Enum.Font.GothamBold
notifButton.TextScaled = true
notifButton.Parent = frame
if not notifButton:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", notifButton).CornerRadius = UDim.new(0, 10)
end

local function refreshNotifText()
    notifButton.Text = gv.FloopaHub.Settings.Notifications and "Notificaciones: ON" or "Notificaciones: OFF"
end
refreshNotifText()

notifButton.MouseButton1Click:Connect(function()
    gv.FloopaHub.Settings.Notifications = not gv.FloopaHub.Settings.Notifications
    refreshNotifText()
    notifySafe("Floopa Hub", gv.FloopaHub.Settings.Notifications and "Notificaciones activadas" or "Notificaciones desactivadas", 2)
end)

-- Cambiar color del hub (tema simple)
local colorButton = frame:FindFirstChild("ColorButton") or Instance.new("TextButton")
colorButton.Name = "ColorButton"
colorButton.Size = UDim2.new(1, -20, 0, 40)
colorButton.Position = UDim2.new(0, 10, 0, 110)
colorButton.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
colorButton.Text = "Cambiar color Hub"
colorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
colorButton.Font = Enum.Font.GothamBold
colorButton.TextScaled = true
colorButton.Parent = frame
if not colorButton:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", colorButton).CornerRadius = UDim.new(0, 10)
end

colorButton.MouseButton1Click:Connect(function()
    local newColor = Color3.fromRGB(math.random(40, 180), math.random(40, 180), math.random(40, 180))
    -- Aplica color a marcos principales
    for _, obj in pairs(gui:GetDescendants()) do
        if obj:IsA("Frame") and (obj.Name == "MainFrame" or obj.Name == "MainMenu" or obj.Name == "SettingsFrame" or obj.Name == "TPPanelFrame") then
            obj.BackgroundColor3 = newColor
        end
    end
    notifySafe("Floopa Hub", "Color aplicado al Hub", 2)
end)

notifySafe("Floopa Hub", "Settings abierto", 2)
