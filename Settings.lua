-- Floopa Hub - Settings integrado en HubButton
-- v5.0 - Configuración global avanzada, estable y sin interferir con otros paneles

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

-- Singleton y estado global
local gv = getgenv()
gv.FloopaHub = gv.FloopaHub or {}
gv.FloopaHub.Settings = gv.FloopaHub.Settings or {
    Notifications = true,
    ThemeColor = Color3.fromRGB(20, 20, 30),
    HeaderColor = Color3.fromRGB(0, 90, 180),
    AccentColor = Color3.fromRGB(35, 35, 55),
    StrokeColor = Color3.fromRGB(60, 60, 90),
    Transparency = 0,
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontSizeScale = 1.0,
    Layout = "BottomRight", -- preferencia del layout global (informativa, no mueve otros paneles)
    ButtonSize = UDim2.new(0, 120, 0, 40),
    InfoText = "Floopa Hub • Settings",
    Presets = {}, -- espacio para temas guardados
    Export = {},  -- espacio para exportar preferencias
}

if gv.FloopaHub.SettingsLoaded then
    -- Ya cargado; exponer funciones y salir
    gv.FloopaHub.ShowSettings = function()
        local gui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui") and Players.LocalPlayer.PlayerGui:FindFirstChild("FloopaHubGUI")
        if gui and gui:FindFirstChild("SettingsFrame") then
            gui.SettingsFrame.Visible = true
        end
    end
    return
end
gv.FloopaHub.SettingsLoaded = true

-- Notificación segura (controlada por Settings.Notifications)
local function notifySafe(title, text, duration)
    if not gv.FloopaHub.Settings.Notifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Info",
            Text = text or "",
            Duration = duration or 3
        })
    end)
end

-- Helpers de UI
local function applyCorner(inst, radius)
    if inst and inst:IsA("GuiObject") then
        local c = inst:FindFirstChildOfClass("UICorner")
        if not c then
            c = Instance.new("UICorner", inst)
        end
        c.CornerRadius = radius or UDim.new(0, 10)
    end
end

local function applyStroke(inst, color, thickness, transparency)
    if inst and inst:IsA("GuiObject") then
        local s = inst:FindFirstChildOfClass("UIStroke")
        if not s then
            s = Instance.new("UIStroke", inst)
        end
        s.Color = color or gv.FloopaHub.Settings.StrokeColor
        s.Thickness = thickness or 1
        s.Transparency = transparency or 0
    end
end

local function setTextStyle(label, bold, scaled)
    if not label or not label:IsA("TextLabel") then return end
    label.Font = bold and gv.FloopaHub.Settings.FontBold or gv.FloopaHub.Settings.Font
    label.TextScaled = scaled == true
end

local function setButtonStyle(btn)
    if not btn or not btn:IsA("TextButton") then return end
    btn.Font = gv.FloopaHub.Settings.FontBold
    btn.TextScaled = true
    btn.BackgroundColor3 = gv.FloopaHub.Settings.AccentColor
end

local function randomThemeColor()
    return Color3.fromRGB(math.random(40, 180), math.random(40, 180), math.random(40, 180))
end

local function clamp01(x) return math.clamp(x, 0, 1) end

-- GUI principal
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Asegurar FloopaHubGUI
local gui = playerGui:FindFirstChild("FloopaHubGUI")
if not gui then
    gui = Instance.new("ScreenGui")
    gui.Name = "FloopaHubGUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = false
    gui.Parent = playerGui
end

---------------------------------------------------------------------
-- SettingsFrame principal
---------------------------------------------------------------------
local frame = gui:FindFirstChild("SettingsFrame") or Instance.new("Frame")
frame.Name = "SettingsFrame"
frame.Size = UDim2.new(0, 360, 0, 520)
frame.Position = UDim2.new(0.5, -180, 0.5, -260)
frame.BackgroundColor3 = gv.FloopaHub.Settings.ThemeColor
frame.BackgroundTransparency = gv.FloopaHub.Settings.Transparency
frame.Visible = false
frame.Parent = gui
applyCorner(frame, UDim.new(0, 14))
applyStroke(frame, gv.FloopaHub.Settings.StrokeColor, 1, 0)

-- Header
local header = frame:FindFirstChild("Header") or Instance.new("Frame", frame)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = gv.FloopaHub.Settings.HeaderColor
applyCorner(header, UDim.new(0, 14))
applyStroke(header, Color3.fromRGB(40, 120, 220), 1, 0)

local title = header:FindFirstChild("Title") or Instance.new("TextLabel", header)
title.Name = "Title"
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = gv.FloopaHub.Settings.InfoText
title.TextColor3 = Color3.fromRGB(255, 255, 255)
setTextStyle(title, true, true)

local closeBtn = header:FindFirstChild("Close") or Instance.new("TextButton", header)
closeBtn.Name = "Close"
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setButtonStyle(closeBtn)
applyCorner(closeBtn, UDim.new(0, 8))
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Tabs container
local tabsBar = frame:FindFirstChild("TabsBar") or Instance.new("Frame", frame)
tabsBar.Name = "TabsBar"
tabsBar.Size = UDim2.new(1, -20, 0, 40)
tabsBar.Position = UDim2.new(0, 10, 0, 60)
tabsBar.BackgroundTransparency = 1

local tabsLayout = tabsBar:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout", tabsBar)
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.Padding = UDim.new(0, 8)

local function newTabButton(name, text)
    local b = tabsBar:FindFirstChild(name) or Instance.new("TextButton", tabsBar)
    b.Name = name
    b.Size = UDim2.new(0, 100, 1, 0)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(b)
    applyCorner(b, UDim.new(0, 8))
    return b
end

local tabGeneral = newTabButton("TabGeneral", "General")
local tabTheme   = newTabButton("TabTheme", "Tema")
local tabUI      = newTabButton("TabUI", "Interfaz")
local tabAdvanced= newTabButton("TabAdvanced", "Avanzado")
local tabAbout   = newTabButton("TabAbout", "Acerca de")

-- Pages container
local pages = frame:FindFirstChild("Pages") or Instance.new("Frame", frame)
pages.Name = "Pages"
pages.Size = UDim2.new(1, -20, 1, -120)
pages.Position = UDim2.new(0, 10, 0, 110)
pages.BackgroundTransparency = 1

local function newPage(name)
    local p = pages:FindFirstChild(name) or Instance.new("Frame", pages)
    p.Name = name
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    return p
end

local pageGeneral = newPage("PageGeneral")
local pageTheme   = newPage("PageTheme")
local pageUI      = newPage("PageUI")
local pageAdvanced= newPage("PageAdvanced")
local pageAbout   = newPage("PageAbout")

local function showPage(target)
    for _, child in ipairs(pages:GetChildren()) do
        if child:IsA("Frame") then child.Visible = (child == target) end
    end
end

-- Default page
showPage(pageGeneral)

-- Tab bindings
tabGeneral.MouseButton1Click:Connect(function() showPage(pageGeneral) end)
tabTheme.MouseButton1Click:Connect(function() showPage(pageTheme) end)
tabUI.MouseButton1Click:Connect(function() showPage(pageUI) end)
tabAdvanced.MouseButton1Click:Connect(function() showPage(pageAdvanced) end)
tabAbout.MouseButton1Click:Connect(function() showPage(pageAbout) end)

---------------------------------------------------------------------
-- Página: General
---------------------------------------------------------------------
do
    local y = 0

    -- Notificaciones ON/OFF
    local notifBtn = pageGeneral:FindFirstChild("NotifBtn") or Instance.new("TextButton", pageGeneral)
    notifBtn.Name = "NotifBtn"
    notifBtn.Size = UDim2.new(1, -20, 0, 40)
    notifBtn.Position = UDim2.new(0, 10, 0, y)
    notifBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(notifBtn)
    applyCorner(notifBtn, UDim.new(0, 10))
    local function refreshNotifText()
        notifBtn.Text = gv.FloopaHub.Settings.Notifications and "Notificaciones: ON" or "Notificaciones: OFF"
    end
    refreshNotifText()
    notifBtn.MouseButton1Click:Connect(function()
        gv.FloopaHub.Settings.Notifications = not gv.FloopaHub.Settings.Notifications
        refreshNotifText()
    end)
    y = y + 50

    -- Transparencia + / -
    local transpInfo = pageGeneral:FindFirstChild("TranspInfo") or Instance.new("TextLabel", pageGeneral)
    transpInfo.Name = "TranspInfo"
    transpInfo.Size = UDim2.new(1, -20, 0, 28)
    transpInfo.Position = UDim2.new(0, 10, 0, y)
    transpInfo.BackgroundTransparency = 1
    transpInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    transpInfo.TextXAlignment = Enum.TextXAlignment.Left
    setTextStyle(transpInfo, false, true)
    local function refreshTranspInfo()
        transpInfo.Text = string.format("Transparencia: %d%%", math.floor(clamp01(gv.FloopaHub.Settings.Transparency) * 100))
    end
    refreshTranspInfo()
    y = y + 32

    local transpRow = pageGeneral:FindFirstChild("TranspRow") or Instance.new("Frame", pageGeneral)
    transpRow.Name = "TranspRow"
    transpRow.Size = UDim2.new(1, -20, 0, 40)
    transpRow.Position = UDim2.new(0, 10, 0, y)
    transpRow.BackgroundTransparency = 1
    local minusBtn = transpRow:FindFirstChild("Minus") or Instance.new("TextButton", transpRow)
    minusBtn.Name = "Minus"
    minusBtn.Size = UDim2.new(0, 120, 1, 0)
    minusBtn.Position = UDim2.new(0, 0, 0, 0)
    minusBtn.Text = "- Transparencia"
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(minusBtn)
    applyCorner(minusBtn, UDim.new(0, 10))

    local plusBtn = transpRow:FindFirstChild("Plus") or Instance.new("TextButton", transpRow)
    plusBtn.Name = "Plus"
    plusBtn.Size = UDim2.new(0, 120, 1, 0)
    plusBtn.Position = UDim2.new(0, 130, 0, 0)
    plusBtn.Text = "+ Transparencia"
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(plusBtn)
    applyCorner(plusBtn, UDim.new(0, 10))

    minusBtn.MouseButton1Click:Connect(function()
        gv.FloopaHub.Settings.Transparency = clamp01(gv.FloopaHub.Settings.Transparency - 0.1)
        frame.BackgroundTransparency = gv.FloopaHub.Settings.Transparency
        refreshTranspInfo()
    end)
    plusBtn.MouseButton1Click:Connect(function()
        gv.FloopaHub.Settings.Transparency = clamp01(gv.FloopaHub.Settings.Transparency + 0.1)
        frame.BackgroundTransparency = gv.FloopaHub.Settings.Transparency
        refreshTranspInfo()
    end)
    y = y + 50

    -- Tamaño de fuente (escala)
    local fontRow = pageGeneral:FindFirstChild("FontRow") or Instance.new("Frame", pageGeneral)
    fontRow.Name = "FontRow"
    fontRow.Size = UDim2.new(1, -20, 0, 40)
    fontRow.Position = UDim2.new(0, 10, 0, y)
    fontRow.BackgroundTransparency = 1

    local fontDec = fontRow:FindFirstChild("FontDec") or Instance.new("TextButton", fontRow)
    fontDec.Name = "FontDec"
    fontDec.Size = UDim2.new(0, 120, 1, 0)
    fontDec.Position = UDim2.new(0, 0, 0, 0)
    fontDec.Text = "Fuente -"
    fontDec.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(fontDec)
    applyCorner(fontDec, UDim.new(0, 10))

    local fontInc = fontRow:FindFirstChild("FontInc") or Instance.new("TextButton", fontRow)
    fontInc.Name = "FontInc"
    fontInc.Size = UDim2.new(0, 120, 1, 0)
    fontInc.Position = UDim2.new(0, 130, 0, 0)
    fontInc.Text = "Fuente +"
    fontInc.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(fontInc)
    applyCorner(fontInc, UDim.new(0, 10))

    local fontInfo = pageGeneral:FindFirstChild("FontInfo") or Instance.new("TextLabel", pageGeneral)
    fontInfo.Name = "FontInfo"
    fontInfo.Size = UDim2.new(1, -20, 0, 26)
    fontInfo.Position = UDim2.new(0, 10, 0, y + 42)
    fontInfo.BackgroundTransparency = 1
    fontInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    fontInfo.TextXAlignment = Enum.TextXAlignment.Left
    setTextStyle(fontInfo, false, true)
    local function refreshFontInfo()
        fontInfo.Text = string.format("Escala de fuente: %.2f", gv.FloopaHub.Settings.FontSizeScale)
    end
    refreshFontInfo()

    fontDec.MouseButton1Click:Connect(function()
        gv.FloopaHub.Settings.FontSizeScale = math.max(0.8, gv.FloopaHub.Settings.FontSizeScale - 0.1)
        refreshFontInfo()
    end)
    fontInc.MouseButton1Click:Connect(function()
        gv.FloopaHub.Settings.FontSizeScale = math.min(1.4, gv.FloopaHub.Settings.FontSizeScale + 0.1)
        refreshFontInfo()
    end)
end

---------------------------------------------------------------------
-- Página: Tema
---------------------------------------------------------------------
do
    local y = 0

    local themeInfo = pageTheme:FindFirstChild("ThemeInfo") or Instance.new("TextLabel", pageTheme)
    themeInfo.Name = "ThemeInfo"
    themeInfo.Size = UDim2.new(1, -20, 0, 26)
    themeInfo.Position = UDim2.new(0, 10, 0, y)
    themeInfo.BackgroundTransparency = 1
    themeInfo.Text = "Colores del Hub (no afecta otros paneles)"
    themeInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeInfo.TextXAlignment = Enum.TextXAlignment.Left
    setTextStyle(themeInfo, false, true)
    y = y + 36

    -- Cambiar color tema
    local colorBtn = pageTheme:FindFirstChild("ColorBtn") or Instance.new("TextButton", pageTheme)
    colorBtn.Name = "ColorBtn"
    colorBtn.Size = UDim2.new(1, -20, 0, 40)
    colorBtn.Position = UDim2.new(0, 10, 0, y)
    colorBtn.Text = "Cambiar color del panel"
    colorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(colorBtn)
    applyCorner(colorBtn, UDim.new(0, 10))
    colorBtn.MouseButton1Click:Connect(function()
        local newColor = randomThemeColor()
        gv.FloopaHub.Settings.ThemeColor = newColor
        frame.BackgroundColor3 = newColor
    end)
    y = y + 50

    -- Cambiar color header
    local headerBtn = pageTheme:FindFirstChild("HeaderBtn") or Instance.new("TextButton", pageTheme)
    headerBtn.Name = "HeaderBtn"
    headerBtn.Size = UDim2.new(1, -20, 0, 40)
    headerBtn.Position = UDim2.new(0, 10, 0, y)
    headerBtn.Text = "Cambiar color del header"
    headerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(headerBtn)
    applyCorner(headerBtn, UDim.new(0, 10))
    headerBtn.MouseButton1Click:Connect(function()
        local newColor = randomThemeColor()
        gv.FloopaHub.Settings.HeaderColor = newColor
        header.BackgroundColor3 = newColor
    end)
    y = y + 50

    -- Cambiar color del acento
    local accentBtn = pageTheme:FindFirstChild("AccentBtn") or Instance.new("TextButton", pageTheme)
    accentBtn.Name = "AccentBtn"
    accentBtn.Size = UDim2.new(1, -20, 0, 40)
    accentBtn.Position = UDim2.new(0, 10, 0, y)
    accentBtn.Text = "Cambiar color de acento"
    accentBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(accentBtn)
    applyCorner(accentBtn, UDim.new(0, 10))
    accentBtn.MouseButton1Click:Connect(function()
        local newColor = randomThemeColor()
        gv.FloopaHub.Settings.AccentColor = newColor
        -- aplicar a botones visibles de settings
        for _, obj in ipairs(frame:GetDescendants()) do
            if obj:IsA("TextButton") and obj.Parent and obj.Parent:IsDescendantOf(frame) then
                obj.BackgroundColor3 = newColor
            end
        end
    end)
    y = y + 50

    -- Preset rápido (guardar)
    local savePresetBtn = pageTheme:FindFirstChild("SavePresetBtn") or Instance.new("TextButton", pageTheme)
    savePresetBtn.Name = "SavePresetBtn"
    savePresetBtn.Size = UDim2.new(1, -20, 0, 40)
    savePresetBtn.Position = UDim2.new(0, 10, 0, y)
    savePresetBtn.Text = "Guardar preset tema actual"
    savePresetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(savePresetBtn)
    applyCorner(savePresetBtn, UDim.new(0, 10))

    savePresetBtn.MouseButton1Click:Connect(function()
        local preset = {
            ThemeColor = gv.FloopaHub.Settings.ThemeColor,
            HeaderColor = gv.FloopaHub.Settings.HeaderColor,
            AccentColor = gv.FloopaHub.Settings.AccentColor,
        }
        table.insert(gv.FloopaHub.Settings.Presets, preset)
        notifySafe("Floopa Hub", "Preset guardado", 2)
    end)
    y = y + 50

    -- Aplicar primer preset guardado
    local applyPresetBtn = pageTheme:FindFirstChild("ApplyPresetBtn") or Instance.new("TextButton", pageTheme)
    applyPresetBtn.Name = "ApplyPresetBtn"
    applyPresetBtn.Size = UDim2.new(1, -20, 0, 40)
    applyPresetBtn.Position = UDim2.new(0, 10, 0, y)
    applyPresetBtn.Text = "Aplicar primer preset guardado"
    applyPresetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(applyPresetBtn)
    applyCorner(applyPresetBtn, UDim.new(0, 10))

    applyPresetBtn.MouseButton1Click:Connect(function()
        local preset = gv.FloopaHub.Settings.Presets and gv.FloopaHub.Settings.Presets[1]
        if preset then
            gv.FloopaHub.Settings.ThemeColor = preset.ThemeColor or gv.FloopaHub.Settings.ThemeColor
            gv.FloopaHub.Settings.HeaderColor = preset.HeaderColor or gv.FloopaHub.Settings.HeaderColor
            gv.FloopaHub.Settings.AccentColor = preset.AccentColor or gv.FloopaHub.Settings.AccentColor
            frame.BackgroundColor3 = gv.FloopaHub.Settings.ThemeColor
            header.BackgroundColor3 = gv.FloopaHub.Settings.HeaderColor
            for _, obj in ipairs(frame:GetDescendants()) do
                if obj:IsA("TextButton") then obj.BackgroundColor3 = gv.FloopaHub.Settings.AccentColor end
            end
        else
            notifySafe("Floopa Hub", "No hay presets guardados", 2)
        end
    end)
end

---------------------------------------------------------------------
-- Página: Interfaz (preferencias visuales del Settings)
---------------------------------------------------------------------
do
    local y = 0

    local uiInfo = pageUI:FindFirstChild("UIInfo") or Instance.new("TextLabel", pageUI)
    uiInfo.Name = "UIInfo"
    uiInfo.Size = UDim2.new(1, -20, 0, 26)
    uiInfo.Position = UDim2.new(0, 10, 0, y)
    uiInfo.BackgroundTransparency = 1
    uiInfo.Text = "Preferencias del panel de configuración"
    uiInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    uiInfo.TextXAlignment = Enum.TextXAlignment.Left
    setTextStyle(uiInfo, false, true)
    y = y + 36

    -- Layout (informativo: no mueve otros paneles del hub, solo recordar preferencia)
    local layoutBtn = pageUI:FindFirstChild("LayoutBtn") or Instance.new("TextButton", pageUI)
    layoutBtn.Name = "LayoutBtn"
    layoutBtn.Size = UDim2.new(1, -20, 0, 40)
    layoutBtn.Position = UDim2.new(0, 10, 0, y)
    layoutBtn.Text = "Layout preferido: "..tostring(gv.FloopaHub.Settings.Layout)
    layoutBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(layoutBtn)
    applyCorner(layoutBtn, UDim.new(0, 10))
    layoutBtn.MouseButton1Click:Connect(function()
        local options = {"BottomRight", "TopRight", "TopLeft", "BottomLeft", "Center"}
        local idx = table.find(options, gv.FloopaHub.Settings.Layout) or 1
        idx = idx % #options + 1
        gv.FloopaHub.Settings.Layout = options[idx]
        layoutBtn.Text = "Layout preferido: "..tostring(gv.FloopaHub.Settings.Layout)
    end)
    y = y + 50

    -- Tamaño del panel Settings
    local sizeRow = pageUI:FindFirstChild("SizeRow") or Instance.new("Frame", pageUI)
    sizeRow.Name = "SizeRow"
    sizeRow.Size = UDim2.new(1, -20, 0, 40)
    sizeRow.Position = UDim2.new(0, 10, 0, y)
    sizeRow.BackgroundTransparency = 1

    local sizeDec = sizeRow:FindFirstChild("SizeDec") or Instance.new("TextButton", sizeRow)
    sizeDec.Name = "SizeDec"
    sizeDec.Size = UDim2.new(0, 140, 1, 0)
    sizeDec.Position = UDim2.new(0, 0, 0, 0)
    sizeDec.Text = "Panel -"
    sizeDec.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(sizeDec); applyCorner(sizeDec, UDim.new(0, 10))

    local sizeInc = sizeRow:FindFirstChild("SizeInc") or Instance.new("TextButton", sizeRow)
    sizeInc.Name = "SizeInc"
    sizeInc.Size = UDim2.new(0, 140, 1, 0)
    sizeInc.Position = UDim2.new(0, 150, 0, 0)
    sizeInc.Text = "Panel +"
    sizeInc.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(sizeInc); applyCorner(sizeInc, UDim.new(0, 10))

    local function clampSize(w, h)
        return math.clamp(w, 280, 520), math.clamp(h, 420, 700)
    end

    sizeDec.MouseButton1Click:Connect(function()
        local w = frame.Size.X.Offset - 20
        local h = frame.Size.Y.Offset - 20
        w, h = clampSize(w, h)
        frame.Size = UDim2.new(0, w, 0, h)
    end)
    sizeInc.MouseButton1Click:Connect(function()
        local w = frame.Size.X.Offset + 20
        local h = frame.Size.Y.Offset + 20
        w, h = clampSize(w, h)
        frame.Size = UDim2.new(0, w, 0, h)
    end)
    y = y + 60

    -- Tamaño de botones (solo dentro del Settings)
    local btnSizeRow = pageUI:FindFirstChild("BtnSizeRow") or Instance.new("Frame", pageUI)
    btnSizeRow.Name = "BtnSizeRow"
    btnSizeRow.Size = UDim2.new(1, -20, 0, 40)
    btnSizeRow.Position = UDim2.new(0, 10, 0, y)
    btnSizeRow.BackgroundTransparency = 1

    local btnDec = btnSizeRow:FindFirstChild("BtnDec") or Instance.new("TextButton", btnSizeRow)
    btnDec.Name = "BtnDec"
    btnDec.Size = UDim2.new(0, 140, 1, 0)
    btnDec.Position = UDim2.new(0, 0, 0, 0)
    btnDec.Text = "Botones -"
    btnDec.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(btnDec); applyCorner(btnDec, UDim.new(0, 10))

    local btnInc = btnSizeRow:FindFirstChild("BtnInc") or Instance.new("TextButton", btnSizeRow)
    btnInc.Name = "BtnInc"
    btnInc.Size = UDim2.new(0, 140, 1, 0)
    btnInc.Position = UDim2.new(0, 150, 0, 0)
    btnInc.Text = "Botones +"
    btnInc.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(btnInc); applyCorner(btnInc, UDim.new(0, 10))

    local function updateButtonSizes()
        for _, obj in ipairs(frame:GetDescendants()) do
            if obj:IsA("TextButton") then
                local baseW = gv.FloopaHub.Settings.ButtonSize.X.Offset
                local baseH = gv.FloopaHub.Settings.ButtonSize.Y.Offset
                obj.Size = UDim2.new(0, baseW, 0, baseH)
            end
        end
    end
    btnDec.MouseButton1Click:Connect(function()
        local bw = math.max(80, gv.FloopaHub.Settings.ButtonSize.X.Offset - 10)
        local bh = math.max(32, gv.FloopaHub.Settings.ButtonSize.Y.Offset - 4)
        gv.FloopaHub.Settings.ButtonSize = UDim2.new(0, bw, 0, bh)
        updateButtonSizes()
    end)
    btnInc.MouseButton1Click:Connect(function()
        local bw = math.min(220, gv.FloopaHub.Settings.ButtonSize.X.Offset + 10)
        local bh = math.min(80, gv.FloopaHub.Settings.ButtonSize.Y.Offset + 4)
        gv.FloopaHub.Settings.ButtonSize = UDim2.new(0, bw, 0, bh)
        updateButtonSizes()
    end)
end

---------------------------------------------------------------------
-- Página: Avanzado (exportar/importar/reset)
---------------------------------------------------------------------
do
    local y = 0

    local advInfo = pageAdvanced:FindFirstChild("AdvInfo") or Instance.new("TextLabel", pageAdvanced)
    advInfo.Name = "AdvInfo"
    advInfo.Size = UDim2.new(1, -20, 0, 26)
    advInfo.Position = UDim2.new(0, 10, 0, y)
    advInfo.BackgroundTransparency = 1
    advInfo.Text = "Herramientas avanzadas de configuración"
    advInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    advInfo.TextXAlignment = Enum.TextXAlignment.Left
    setTextStyle(advInfo, false, true)
    y = y + 36

    -- Exportar a tabla interna
    local exportBtn = pageAdvanced:FindFirstChild("ExportBtn") or Instance.new("TextButton", pageAdvanced)
    exportBtn.Name = "ExportBtn"
    exportBtn.Size = UDim2.new(1, -20, 0, 40)
    exportBtn.Position = UDim2.new(0, 10, 0, y)
    exportBtn.Text = "Exportar preferencias (interno)"
    exportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(exportBtn)
    applyCorner(exportBtn, UDim.new(0, 10))
    exportBtn.MouseButton1Click:Connect(function()
        local copy = {
            Notifications = gv.FloopaHub.Settings.Notifications,
            ThemeColor   = gv.FloopaHub.Settings.ThemeColor,
            HeaderColor  = gv.FloopaHub.Settings.HeaderColor,
            AccentColor  = gv.FloopaHub.Settings.AccentColor,
            Transparency = gv.FloopaHub.Settings.Transparency,
            Font         = gv.FloopaHub.Settings.Font,
            FontBold     = gv.FloopaHub.Settings.FontBold,
            FontSizeScale= gv.FloopaHub.Settings.FontSizeScale,
            Layout       = gv.FloopaHub.Settings.Layout,
            ButtonSize   = gv.FloopaHub.Settings.ButtonSize,
            InfoText     = gv.FloopaHub.Settings.InfoText,
            Presets      = gv.FloopaHub.Settings.Presets,
        }
        gv.FloopaHub.Settings.Export = copy
        notifySafe("Floopa Hub", "Preferencias exportadas", 2)
    end)
    y = y + 50

    -- Importar desde tabla interna
    local importBtn = pageAdvanced:FindFirstChild("ImportBtn") or Instance.new("TextButton", pageAdvanced)
    importBtn.Name = "ImportBtn"
    importBtn.Size = UDim2.new(1, -20, 0, 40)
    importBtn.Position = UDim2.new(0, 10, 0, y)
    importBtn.Text = "Importar preferencias (interno)"
    importBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(importBtn)
    applyCorner(importBtn, UDim.new(0, 10))
    importBtn.MouseButton1Click:Connect(function()
        local data = gv.FloopaHub.Settings.Export
        if type(data) == "table" then
            for k, v in pairs(data) do
                gv.FloopaHub.Settings[k] = v
            end
            frame.BackgroundColor3 = gv.FloopaHub.Settings.ThemeColor
            header.BackgroundColor3 = gv.FloopaHub.Settings.HeaderColor
            frame.BackgroundTransparency = gv.FloopaHub.Settings.Transparency
            for _, obj in ipairs(frame:GetDescendants()) do
                if obj:IsA("TextButton") then obj.BackgroundColor3 = gv.FloopaHub.Settings.AccentColor end
            end
            notifySafe("Floopa Hub", "Preferencias importadas", 2)
        else
            notifySafe("Floopa Hub", "No hay datos exportados", 2)
        end
    end)
    y = y + 50

    -- Reset a valores por defecto
    local resetBtn = pageAdvanced:FindFirstChild("ResetBtn") or Instance.new("TextButton", pageAdvanced)
    resetBtn.Name = "ResetBtn"
    resetBtn.Size = UDim2.new(1, -20, 0, 40)
    resetBtn.Position = UDim2.new(0, 10, 0, y)
    resetBtn.Text = "Restaurar valores por defecto"
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setButtonStyle(resetBtn)
    resetBtn.BackgroundColor3 = Color3.fromRGB(55, 35, 35)
    applyCorner(resetBtn, UDim.new(0, 10))
    resetBtn.MouseButton1Click:Connect(function()
        gv.FloopaHub.Settings = {
            Notifications = true,
            ThemeColor = Color3.fromRGB(20, 20, 30),
            HeaderColor = Color3.fromRGB(0, 90, 180),
            AccentColor = Color3.fromRGB(35, 35, 55),
            StrokeColor = Color3.fromRGB(60, 60, 90),
            Transparency = 0,
            Font = Enum.Font.Gotham,
            FontBold = Enum.Font.GothamBold,
            FontSizeScale = 1.0,
            Layout = "BottomRight",
            ButtonSize = UDim2.new(0, 120, 0, 40),
            InfoText = "Floopa Hub • Settings",
            Presets = {},
            Export = {},
        }
        frame.BackgroundColor3 = gv.FloopaHub.Settings.ThemeColor
        header.BackgroundColor3 = gv.FloopaHub.Settings.HeaderColor
        frame.BackgroundTransparency = gv.FloopaHub.Settings.Transparency
        for _, obj in ipairs(frame:GetDescendants()) do
            if obj:IsA("TextButton") then obj.BackgroundColor3 = gv.FloopaHub.Settings.AccentColor end
        end
        notifySafe("Floopa Hub", "Preferencias restauradas", 2)
    end)
end

---------------------------------------------------------------------
-- Página: Acerca de (informativo)
---------------------------------------------------------------------
do
    local aboutText = pageAbout:FindFirstChild("AboutText") or Instance.new("TextLabel", pageAbout)
    aboutText.Name = "AboutText"
    aboutText.Size = UDim2.new(1, -20, 0, 100)
    aboutText.Position = UDim2.new(0, 10, 0, 0)
    aboutText.BackgroundTransparency = 1
    aboutText.TextColor3 = Color3.fromRGB(255, 255, 255)
    aboutText.TextWrapped = true
    aboutText.TextXAlignment = Enum.TextXAlignment.Left
    aboutText.TextYAlignment = Enum.TextYAlignment.Top
    setTextStyle(aboutText, false, true)
    aboutText.Text = "Floopa Hub Settings v5.0\n" ..
        "- Panel global de configuración del Hub.\n" ..
        "- No interfiere con otros paneles (ESP, XRay, etc.).\n" ..
        "- Ajusta tema, transparencia, tipografías y preferencias visuales.\n" ..
        "- Soporta exportar/importar presets y resetear valores.\n\n" ..
        "Santiago (Floopa_077) • Legend Status."

    local tipText = pageAbout:FindFirstChild("TipText") or Instance.new("TextLabel", pageAbout)
    tipText.Name = "TipText"
    tipText.Size = UDim2.new(1, -20, 0, 60)
    tipText.Position = UDim2.new(0, 10, 0, 120)
    tipText.BackgroundTransparency = 1
    tipText.TextColor3 = Color3.fromRGB(200, 200, 220)
    tipText.TextWrapped = true
    tipText.TextXAlignment = Enum.TextXAlignment.Left
    tipText.TextYAlignment = Enum.TextYAlignment.Top
    setTextStyle(tipText, false, true)
    tipText.Text = "Nota: las preferencias de layout son informativas. El posicionamiento real de otros paneles se maneja en sus propios scripts."
end

---------------------------------------------------------------------
-- Exponer funciones de utilidad para el HubButton
---------------------------------------------------------------------
gv.FloopaHub.SettingsFrame = frame

gv.FloopaHub.ShowSettings = function()
    frame.Visible = true
end

gv.FloopaHub.ToggleSettings = function()
    frame.Visible = not frame.Visible
end
-- Inicialización visual mínima (aplica estilos guardados)
do
    frame.BackgroundColor3 = gv.FloopaHub.Settings.ThemeColor
    header.BackgroundColor3 = gv.FloopaHub.Settings.HeaderColor
    frame.BackgroundTransparency = gv.FloopaHub.Settings.Transparency
    for _, obj in ipairs(frame:GetDescendants()) do
        if obj:IsA("TextButton") then
            obj.BackgroundColor3 = gv.FloopaHub.Settings.AccentColor
        end
    end
end

-- Exponer el frame y funciones de utilidad para el HubButton
gv.FloopaHub.SettingsFrame = frame

gv.FloopaHub.ShowSettings = function()
    frame.Visible = true
end

gv.FloopaHub.ToggleSettings = function()
    frame.Visible = not frame.Visible
end

print("[FloopaHub] Settings inicializado correctamente.")
