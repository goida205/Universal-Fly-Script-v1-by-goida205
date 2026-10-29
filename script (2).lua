local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Переменные управления
local isFlying = false
local flySpeed = 50 -- Скорость по умолчанию (студов в секунду)
local currentVelocity = Vector3.new(0, 0, 0)

-- Создание графического интерфейса (GUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyMenuGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- Позволяет перетаскивать меню по экрану
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "FLY MENU"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

-- Кнопка Включения/Выключения
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.9, 0, 0, 35)
toggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.Text = "Fly: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

-- Поле ввода скорости
local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.9, 0, 0, 35)
speedInput.Position = UDim2.new(0.05, 0, 0.60, 0)
speedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedInput.Text = tostring(flySpeed)
speedInput.PlaceholderText = "Скорость (студы)..."
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.Font = Enum.Font.SourceSans
speedInput.TextSize = 14
speedInput.Parent = frame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = speedInput

-- Обновление ссылки на персонажа при респавне
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	rootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	if isFlying then
		isFlying = false
		toggleButton.Text = "Fly: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		humanoid.PlatformStand = false
	end
end)

-- Функция полета
local function getFlyDirection()
	local camera = workspace.CurrentCamera
	local moveDirection = Vector3.new(0, 0, 0)

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		moveDirection = moveDirection + camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		moveDirection = moveDirection - camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		moveDirection = moveDirection - camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		moveDirection = moveDirection + camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		moveDirection = moveDirection + Vector3.new(0, 1, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		moveDirection = moveDirection - Vector3.new(0, 1, 0)
	end

	return moveDirection
end

-- Цикл полета
RunService.RenderStepped:Connect(function()
	if isFlying and rootPart and humanoid then
		humanoid.PlatformStand = true -- Отключаем стандартную физику анимаций падения

		local direction = getFlyDirection()
		if direction.Magnitude > 0 then
			currentVelocity = direction.Unit * flySpeed
		else
			currentVelocity = Vector3.new(0, 0, 0)
		end

		rootPart.AssemblyLinearVelocity = currentVelocity
	end
end)

-- Логика кнопки включения
toggleButton.MouseButton1Click:Connect(function()
	isFlying = not isFlying
	if isFlying then
		toggleButton.Text = "Fly: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		toggleButton.Text = "Fly: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		if humanoid then
			humanoid.PlatformStand = false
		end
		if rootPart then
			rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		end
	end
end)

-- Логика изменения скорости
speedInput.FocusLost:Connect(function(enterPressed)
	local numericValue = tonumber(speedInput.Text)
	if numericValue and numericValue >= 0 then
		flySpeed = numericValue
	else
		speedInput.Text = tostring(flySpeed) -- Возврат старого значения при ошибке ввода
	end
end)
