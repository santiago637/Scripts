-- CommandsModule.lua (100% client-side)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local module = {}

local flying = false
local noclip = false
local flySpeed = 50
local espEnabled = false
local xrayEnabled = false

-- FLY con control direccional y Q/E
function module.Fly(arg, disable)
    local character = localPlayer.Character
    if not character then return end

    if disable then
        flying = false
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
        return
    end

    if arg then
        local num = tonumber(arg)
        if num then
            flySpeed = num * 10
        end
    end

    flying = true
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = true end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local moveDir = Vector3.new(0,0,0)
    local conn1, conn2

    conn1 = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then
            moveDir = moveDir + Vector3.new(0,0,-1)
        elseif input.KeyCode == Enum.KeyCode.S then
            moveDir = moveDir + Vector3.new(0,0,1)
        elseif input.KeyCode == Enum.KeyCode.A then
            moveDir = moveDir + Vector3.new(-1,0,0)
        elseif input.KeyCode == Enum.KeyCode.D then
            moveDir = moveDir + Vector3.new(1,0,0)
        elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Q then
            moveDir = moveDir + Vector3.new(0,1,0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.E then
            moveDir = moveDir + Vector3.new(0,-1,0)
        end
    end)

    conn2 = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W then
            moveDir = moveDir - Vector3.new(0,0,-1)
        elseif input.KeyCode == Enum.KeyCode.S then
            moveDir = moveDir - Vector3.new(0,0,1)
        elseif input.KeyCode == Enum.KeyCode.A then
            moveDir = moveDir - Vector3.new(-1,0,0)
        elseif input.KeyCode == Enum.KeyCode.D then
            moveDir = moveDir - Vector3.new(1,0,0)
        elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Q then
            moveDir = moveDir - Vector3.new(0,1,0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.E then
            moveDir = moveDir - Vector3.new(0,-1,0)
        end
    end)

    task.spawn(function()
        while flying do
            if root and moveDir.Magnitude > 0 then
                root.Velocity = moveDir.Unit * flySpeed
            end
            task.wait()
        end
        if humanoid then humanoid.PlatformStand = false end
        conn1:Disconnect()
        conn2:Disconnect()
    end)
end

-- NOCLIP con "unnoclip"
function module.Noclip(disable)
    local character = localPlayer.Character
    if not character then return end

    if disable then
        noclip = false
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        return
    end

    noclip = true
    task.spawn(function()
        while noclip and character.Parent do
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            task.wait()
        end
    end)
end

-- WALKSPEED (default = 3)
function module.WalkSpeed(value)
    local character = localPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local num = tonumber(value)
    if not num then num = 3 end

    humanoid.WalkSpeed = num
    print("WalkSpeed ajustado a:", num)
end

-- ESP (igual que antes)
function module.ESP(disable)
    if disable then
        espEnabled = false
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                if highlight then highlight:Destroy() end
                local gui = player.Character:FindFirstChild("ESPBillboard")
                if gui then gui:Destroy() end
            end
        end
        return
    end

    espEnabled = true
    task.spawn(function()
        while espEnabled do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

                    if not player.Character:FindFirstChild("ESPHighlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ESPHighlight"
                        hl.FillColor = Color3.fromRGB(255,0,0)
                        hl.OutlineColor = Color3.fromRGB(255,255,255)
                        hl.Parent = player.Character
                    end

                    if root and humanoid then
                        local bb = player.Character:FindFirstChild("ESPBillboard")
                        if not bb then
                            bb = Instance.new("BillboardGui")
                            bb.Name = "ESPBillboard"
                            bb.Size = UDim2.new(0,200,0,50)
                            bb.Adornee = root
                            bb.AlwaysOnTop = true
                            bb.Parent = player.Character

                            local text = Instance.new("TextLabel")
                            text.Size = UDim2.new(1,0,1,0)
                            text.BackgroundTransparency = 1
                            text.TextColor3 = Color3.fromRGB(255,255,255)
                            text.Font = Enum.Font.Merriweather
                            text.TextScaled = true
                            text.Parent = bb
                        end
                        local text = bb:FindFirstChildOfClass("TextLabel")
                        if text then
                            text.Text = player.Name .. " | HP: " .. math.floor(humanoid.Health)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- XRAY con transparencia ajustable (1-10)
function module.XRay(value, disable)
    if disable then
        xrayEnabled = false
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency > 0 then
                part.Transparency = 0
            end
        end
        return
    end

    local num = tonumber(value)
    local transparency = 0.7
    if num and num >= 1 and num <= 10 then
        transparency = num / 10
    end

    xrayEnabled = true
    task.spawn(function()
        while xrayEnabled do
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Parent ~= localPlayer.Character then
                    part.Transparency = transparency
                end
            end
            task.wait(1)
        end
    end)
end

return module
