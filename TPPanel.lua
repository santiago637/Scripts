-- Floopa Hub - TPPanel.lua (Delta-ready)
-- v1.2 - Singleton + lista dinámica + TP seguro + debounce

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local gv = getgenv()
gv.FloopaHub = gv.FloopaHub or {}

-- Protección: evitar doble carga del panel
if gv.FloopaHub.TPPanelLoaded then
    return
end
gv.FloopaHub.TPPanelLoaded = true

local function notifySafe(title, text, duration)
    if gv.FloopaHub.Settings and gv.FloopaHub.Settings.Notifications == false then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = title or "Info", Text = text or "", Duration = duration or 3 })
    end)
end

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

-- Frame principal
local frame = gui:FindFirstChild("TPPanelFrame") or Instance.new("Frame")
frame.Name = "TPPanelFrame"
frame.Size = UDim2.new(0, 280, 0, 340)
frame.Position = UDim2.new(0.5, -140, 0.5, -170)
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

local title = header:FindFirstChild("Title") or Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "TP Panel"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = header

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

-- ScrollingFrame con lista dinámica de jugadores
local scroll = frame:FindFirstChild("PlayersScroll") or Instance.new("ScrollingFrame")
scroll.Name = "PlayersScroll"
scroll.Size = UDim2.new(1, -20, 1, -90)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
scroll.ScrollBarThickness = 8
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = frame
if not scroll:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 10)
end

local function createPlayerButton(plr, y)
    local b = Instance.new("TextButton")
    b.Name = "TP_" .. plr.UserId
    b.Size = UDim2.new(1, 0, 0, 32)
    b.Position = UDim2.new(0, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    b.Text = plr.Name
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    b.MouseButton1Click:Connect(function()
        local myChar = localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local tChar = plr.Character
        local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
        if myRoot and tRoot then
            -- TP con offset para evitar colisión
            local targetCFrame = tRoot.CFrame * CFrame.new(2, 0, 0)
            myRoot.CFrame = targetCFrame
            notifySafe("Floopa Hub", "TP hacia " .. plr.Name, 2)
        else
            notifySafe("Floopa Hub", "No se puede TP: personaje/root no disponibles", 2)
        end
    end)
end

local function rebuildList()
    -- limpiar antiguos
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local y = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            createPlayerButton(plr, y)
            y = y + 36
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

rebuildList()

-- Actualizar lista en tiempo real
Players.PlayerAdded:Connect(function(plr)
    rebuildList()
end)
Players.PlayerRemoving:Connect(function(plr)
    rebuildList()
end)

-- Botón TP random (más seguro y eficiente)
local tpRandom = frame:FindFirstChild("TPRandom") or Instance.new("TextButton")
tpRandom.Name = "TPRandom"
tpRandom.Size = UDim2.new(1, -20, 0, 40)
tpRandom.Position = UDim2.new(0, 10, 1, -50)
tpRandom.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
tpRandom.Text = "TP Random"
tpRandom.TextColor3 = Color3.fromRGB(255, 255, 255)
tpRandom.Font = Enum.Font.GothamBold
tpRandom.TextScaled = true
tpRandom.Parent = frame
if not tpRandom:FindFirstChildOfClass("UICorner") then
    Instance.new("UICorner", tpRandom).CornerRadius = UDim.new(0, 10)
end

local lastTP = 0
tpRandom.MouseButton1Click:Connect(function()
    local now = tick()
    if now - lastTP < 0.25 then return end
    lastTP = now

    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        notifySafe("Floopa Hub", "No se puede TP: HumanoidRootPart no disponible", 2)
        return
    end

    -- Candidatos: partes ancladas y visibles del mapa (evita agarrar adornos del jugador)
    local candidates = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Anchored and obj.Transparency < 1 and not obj:IsDescendantOf(myChar) then
            table.insert(candidates, obj)
            if #candidates >= 500 then break end -- límite para performance
        end
    end

    if #candidates > 0 then
        local rand = candidates[math.random(1, #candidates)]
        myRoot.CFrame = rand.CFrame + Vector3.new(0, 5, 0)
        notifySafe("Floopa Hub", "TP Random hecho", 2)
    else
        notifySafe("Floopa Hub", "No hay candidatos para TP random", 2)
    end
end)

notifySafe("Floopa Hub", "TP Panel abierto", 2)
