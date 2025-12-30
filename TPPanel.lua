local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Crear frame principal
local frame = Instance.new("Frame")
frame.Name = "TPPanelFrame"
frame.Size = UDim2.new(0,260,0,300)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.Position = UDim2.new(0.5,-130,0.5,-150)
frame.Visible = true
frame.Parent = playerGui:FindFirstChild("FloopaHubGUI")
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,14)

-- Header
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1,0,0,40)
header.BackgroundColor3 = Color3.fromRGB(0,90,180)
header.Text = "TP Panel"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.Font = Enum.Font.GothamBold
header.TextScaled = true
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0,14)

-- ScrollingFrame con lista de jugadores
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-20,1,-90)
scroll.Position = UDim2.new(0,10,0,50)
scroll.BackgroundColor3 = Color3.fromRGB(25,25,35)
scroll.ScrollBarThickness = 8
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.Parent = frame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0,10)

local y = 0
for _,plr in pairs(Players:GetPlayers()) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,32)
    b.Position = UDim2.new(0,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(35,35,55)
    b.Text = plr.Name
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextScaled = true
    b.Parent = scroll
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

    y = y + 36

    b.MouseButton1Click:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            localPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
        end
    end)
end
scroll.CanvasSize = UDim2.new(0,0,0,y)

-- Botón TP random
local tpRandom = Instance.new("TextButton")
tpRandom.Size = UDim2.new(1,-20,0,40)
tpRandom.Position = UDim2.new(0,10,1,-50)
tpRandom.BackgroundColor3 = Color3.fromRGB(35,35,55)
tpRandom.Text = "TP Random"
tpRandom.TextColor3 = Color3.fromRGB(255,255,255)
tpRandom.Font = Enum.Font.GothamBold
tpRandom.TextScaled = true
tpRandom.Parent = frame
Instance.new("UICorner", tpRandom).CornerRadius = UDim.new(0,10)

tpRandom.MouseButton1Click:Connect(function()
    local parts = workspace:GetDescendants()
    local candidates = {}
    for _,p in pairs(parts) do
        if p:IsA("BasePart") and p:IsDescendantOf(workspace) then
            table.insert(candidates,p)
        end
    end
    if #candidates > 0 and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rand = candidates[math.random(1,#candidates)]
        localPlayer.Character.HumanoidRootPart.CFrame = rand.CFrame + Vector3.new(0,5,0)
    end
end)
