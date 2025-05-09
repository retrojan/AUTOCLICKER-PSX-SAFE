if not game:IsLoaded() then game.Loaded:Wait() end

-- Сервисы
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Создание простого GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleAutoClicker"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 120)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -60)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Text = "AUTO CLICKER"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Поле ввода задержки
local DelayLabel = Instance.new("TextLabel")
DelayLabel.Text = "Delay (seconds):"
DelayLabel.Size = UDim2.new(0.8, 0, 0, 20)
DelayLabel.Position = UDim2.new(0.1, 0, 0, 35)
DelayLabel.BackgroundTransparency = 1
DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.TextSize = 12
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = MainFrame

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.new(0.8, 0, 0, 25)
DelayBox.Position = UDim2.new(0.1, 0, 0, 55)
DelayBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
DelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayBox.Font = Enum.Font.Gotham
DelayBox.TextSize = 14
DelayBox.Text = "1"
DelayBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = DelayBox

-- Кнопка запуска
local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(0.8, 0, 0, 30)
StartButton.Position = UDim2.new(0.1, 0, 0, 85)
StartButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
StartButton.Text = "START"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 14
StartButton.Parent = MainFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = StartButton

-- Основная логика
local running = false
local function findYesButton()
    for _, element in ipairs(player.PlayerGui:GetDescendants()) do
        if (element:IsA("TextButton") or element:IsA("TextLabel")) and string.find(string.lower(element.Text), "yes") then
            return element
        end
    end
end

StartButton.MouseButton1Click:Connect(function()
    running = not running
    if running then
        StartButton.BackgroundColor3 = Color3.fromRGB(215, 0, 0)
        StartButton.Text = "STOP"
        local delay = tonumber(DelayBox.Text) or 1
        
        spawn(function()
            while running do
                -- Нажатие E
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                
                -- Клик по Yes
                local yesButton = findYesButton()
                if yesButton then
                    local centerX = yesButton.AbsolutePosition.X + yesButton.AbsoluteSize.X/2
                    local centerY = yesButton.AbsolutePosition.Y + yesButton.AbsoluteSize.Y/2
                    
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                end
                
                -- Нажатие Alt
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftAlt, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftAlt, false, game)
                
                task.wait(delay)
            end
        end)
    else
        StartButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        StartButton.Text = "START"
    end
end)
