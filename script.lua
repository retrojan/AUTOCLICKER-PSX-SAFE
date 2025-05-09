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
StartButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
StartButton.Text = "START"
StartButton.TextColor3 = Color3.new(1, 1, 1)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 14
Instance.new("UICorner", StartButton).CornerRadius = UDim.new(0, 6)

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

                -- Нажатие E
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)

                -- Клик по Yes
                local yesButton = findYesButton()
                if yesButton then
                    local x = yesButton.AbsolutePosition.X + yesButton.AbsoluteSize.X/2
                    local y = yesButton.AbsolutePosition.Y + yesButton.AbsoluteSize.Y/2
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
                end

                -- Клик по Collect
                findAndClickCollect()

                -- Нажатие Alt
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

-- Автоперезапуск humanoid при смене персонажа
player.CharacterAdded:Connect(function(character)
    humanoid = character:WaitForChildOfClass("Humanoid")
end)

-- Клавиша F6
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        StartButton:MouseButton1Click()
    end
end)
