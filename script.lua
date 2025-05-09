-- Анти-дублирование с стильным уведомлением внизу
if getgenv().AutoClickerLoaded then
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 300, 0, 40)
    notif.Position = UDim2.new(0.5, -150, 1, -60)
    notif.AnchorPoint = Vector2.new(0.5, 1)
    notif.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    notif.BackgroundTransparency = 0.2
    notif.Text = "⚠️ Скрипт уже запущен!"
    notif.TextColor3 = Color3.new(1, 1, 1)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 16
    notif.TextStrokeTransparency = 0.8
    notif.Parent = game.CoreGui
    notif.ZIndex = 10

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notif

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 1
    stroke.Parent = notif

    task.delay(3, function()
        if notif and notif.Parent then
            notif:Destroy()
        end
    end)

    return
end
getgenv().AutoClickerLoaded = true


if not game:IsLoaded() then game.Loaded:Wait() end

-- Сервисы
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AutoClickerWithMovementCheck"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "AUTOCLICKER BY ReTrojan"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local DelayLabel = Instance.new("TextLabel", MainFrame)
DelayLabel.Text = "Delay (seconds):"
DelayLabel.Size = UDim2.new(0.8, 0, 0, 20)
DelayLabel.Position = UDim2.new(0.1, 0, 0, 35)
DelayLabel.BackgroundTransparency = 1
DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.TextSize = 12
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left

local DelayBox = Instance.new("TextBox", MainFrame)
DelayBox.Size = UDim2.new(0.8, 0, 0, 25)
DelayBox.Position = UDim2.new(0.1, 0, 0, 55)
DelayBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
DelayBox.TextColor3 = Color3.new(1, 1, 1)
DelayBox.Font = Enum.Font.Gotham
DelayBox.TextSize = 14
DelayBox.Text = "1"
Instance.new("UICorner", DelayBox).CornerRadius = UDim.new(0, 6)

local StartButton = Instance.new("TextButton", MainFrame)
StartButton.Size = UDim2.new(0.8, 0, 0, 30)
StartButton.Position = UDim2.new(0.1, 0, 0, 85)
StartButton.BackgroundTransparency = 1 -- делаем кнопку прозрачной
StartButton.Text = "START"
StartButton.TextColor3 = Color3.new(1, 1, 1)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 14
Instance.new("UICorner", StartButton).CornerRadius = UDim.new(0, 6)

-- Кнопка
local StartButton = Instance.new("TextButton", MainFrame)
StartButton.Size = UDim2.new(0.8, 0, 0, 30)
StartButton.Position = UDim2.new(0.1, 0, 0, 85)
StartButton.BackgroundTransparency = 1
StartButton.Text = "START"
StartButton.TextColor3 = Color3.new(1, 1, 1)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 14
StartButton.ZIndex = 3
Instance.new("UICorner", StartButton).CornerRadius = UDim.new(0, 6)

-- Градиентный фон
local GradientFrame = Instance.new("Frame")
GradientFrame.Size = UDim2.new(1, 0, 1, 0)
GradientFrame.Position = UDim2.new(0, 0, 0, 0)
GradientFrame.BackgroundColor3 = Color3.new(1, 1, 1)
GradientFrame.ZIndex = 1
GradientFrame.Parent = StartButton
Instance.new("UICorner", GradientFrame).CornerRadius = UDim.new(0, 6)

local Gradient = Instance.new("UIGradient", GradientFrame)
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 0, 255)), -- фиолетовый
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 102, 255))  -- синий
}

-- Затемнение при наведении
local HoverOverlay = Instance.new("Frame")
HoverOverlay.Size = UDim2.new(1, 0, 1, 0)
HoverOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
HoverOverlay.BackgroundTransparency = 1
HoverOverlay.ZIndex = 2
HoverOverlay.Parent = StartButton
Instance.new("UICorner", HoverOverlay).CornerRadius = UDim.new(0, 6)

-- Наведение мыши
StartButton.MouseEnter:Connect(function()
    HoverOverlay.BackgroundTransparency = 0.7  -- Сделано светлее
end)

StartButton.MouseLeave:Connect(function()
    HoverOverlay.BackgroundTransparency = 1
end)

-- Переменные
local running = false
local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
local movementConnection
local maxWorkTime = 120 -- макс. время работы автокликера
local autoRestartDelay = 5 -- время до автозапуска после остановки

-- Функции
local function isMoving()
    if not humanoid or not humanoid.Parent then
        humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        return false
    end
    return humanoid.MoveDirection.Magnitude > 0.1
end

local function findYesButton()
    for _, element in ipairs(player.PlayerGui:GetDescendants()) do
        if (element:IsA("TextButton") or element:IsA("TextLabel")) and string.find(string.lower(element.Text), "yes") then
            return element
        end
    end
end

local function findAndClickCollect()
    for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") and string.find(string.lower(gui.Text), "collect") then
            local x = gui.AbsolutePosition.X + gui.AbsoluteSize.X/2
            local y = gui.AbsolutePosition.Y + gui.AbsoluteSize.Y/2

            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
        end
    end
end

local function stopScript()
    if running then
        running = false
        getgenv().AutoClickerLoaded = false
        StartButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        StartButton.Text = "START"
        if movementConnection then
            movementConnection:Disconnect()
            movementConnection = nil
        end
        task.delay(autoRestartDelay, function()
            if not running then StartButton:MouseButton1Click() end
        end)
    end
end

-- Основная логика
StartButton.MouseButton1Click:Connect(function()
    running = not running
    if running then
        humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        StartButton.BackgroundColor3 = Color3.fromRGB(215, 0, 0)
        StartButton.Text = "STOP"
        local delay = tonumber(DelayBox.Text) or 1
        local startTime = tick()

        movementConnection = RunService.Heartbeat:Connect(function()
            if isMoving() then stopScript() end
        end)

        task.spawn(function()
            while running do
                if isMoving() then stopScript() break end
                if tick() - startTime >= maxWorkTime then stopScript() break end

                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

                local yesButton = findYesButton()
                if yesButton then
                    local x = yesButton.AbsolutePosition.X + yesButton.AbsoluteSize.X/2
                    local y = yesButton.AbsolutePosition.Y + yesButton.AbsoluteSize.Y/2
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
                end

                findAndClickCollect()

                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftAlt, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftAlt, false, game)

                task.wait(delay)
            end
        end)
    else
        stopScript()
    end
end)

-- Обновление humanoid при смене персонажа
player.CharacterAdded:Connect(function(character)
    humanoid = character:WaitForChildOfClass("Humanoid")
end)

-- Запуск по F6
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        StartButton:MouseButton1Click()
    end
end)
