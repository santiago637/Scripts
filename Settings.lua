-- Settings.lua
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Crear frame principal
local frame = Instance.new("Frame")
frame.Name = "SettingsFrame"
frame.Size = UDim2.new(0,260,0,200)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.Position = UDim2.new(0.5,-130,0.5,-100)
frame.Visible = true
frame.Parent = playerGui:FindFirstChild("FloopaHubGUI")
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

-- Header
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1,0,0,40)
header.BackgroundColor3 = Color3.fromRGB(0,90,180)
header.Text = "Configuración"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.Font = Enum.Font.GothamBold
header.TextScaled = true
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)

-- Ejemplo: toggle de notificaciones
local notifButton = Instance.new("TextButton")
notifButton.Size = UDim2.new(1,-20,0,40)
notifButton.Position = UDim2.new(0,10,0,60)
notifButton.BackgroundColor3 = Color3.fromRGB(35,35,55)
notifButton.Text = "Toggle Notificaciones"
notifButton.TextColor3 = Color3.fromRGB(255,255,255)
notifButton.Font = Enum.Font.GothamBold
notifButton.TextScaled = true
notifButton.Parent = frame
Instance.new("UICorner", notifButton).CornerRadius = UDim.new(0,10)

local notifEnabled = true
notifButton.MouseButton1Click:Connect(function()
    notifEnabled = not notifEnabled
    notifButton.Text = notifEnabled and "Notificaciones: ON" or "Notificaciones: OFF"
end)

-- Ejemplo: cambiar color del hub
local colorButton = Instance.new("TextButton")
colorButton.Size = UDim2.new(1,-20,0,40)
colorButton.Position = UDim2.new(0,10,0,110)
colorButton.BackgroundColor3 = Color3.fromRGB(35,35,55)
colorButton.Text = "Cambiar color Hub"
colorButton.TextColor3 = Color3.fromRGB(255,255,255)
colorButton.Font = Enum.Font.GothamBold
colorButton.TextScaled = true
colorButton.Parent = frame
Instance.new("UICorner", colorButton).CornerRadius = UDim.new(0,10)

colorButton.MouseButton1Click:Connect(function()
    local gui = playerGui:FindFirstChild("FloopaHubGUI")
    if gui then
        for _,obj in pairs(gui:GetDescendants()) do
            if obj:IsA("Frame") then
                obj.BackgroundColor3 = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
            end
        end
    end
end)

