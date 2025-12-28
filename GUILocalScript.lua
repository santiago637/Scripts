-- GUILocalScript
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local Main = loadstring(game:HttpGet("https://raw.githubusercontent.com/santiago637/Scripts/main/MainLocalScript.lua"))()

-- Crear GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FloopaHubGUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Frame + TextBox
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.4,0,0.3,0)
frame.Position = UDim2.new(0.3,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(15,15,25)
frame.Parent = gui

local commandBox = Instance.new("TextBox")
commandBox.Size = UDim2.new(1,0,0,36)
commandBox.Text = "Introducir comandos"
commandBox.Font = Enum.Font.Gotham
commandBox.TextColor3 = Color3.fromRGB(150,150,170)
commandBox.Parent = frame

-- Feedback minimalista
local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Size = UDim2.new(1,0,0,20)
feedbackLabel.Position = UDim2.new(0,0,1,-20)
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

-- Capturar comandos
commandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and commandBox.Text ~= "" then
        Main.ExecuteCommand(commandBox.Text)
        showFeedback("Comando ejecutado: "..commandBox.Text)
        commandBox.Text = "Introducir comandos"
    end
end)
