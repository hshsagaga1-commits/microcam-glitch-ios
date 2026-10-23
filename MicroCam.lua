-- MicroCam Glitch | Roblox Mobile
-- Tremor lateral perceptivel; botao ON/OFF.
-- O controlador de camera do jogo continua responsavel pelo touch.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui")

if _G.MicroGlitchCleanup then
    pcall(_G.MicroGlitchCleanup)
end

local enabled = false
local amplitude = math.rad(2)
local returnTime = 0.030
local restTime = 0.015
local elapsed = 0
local alive = true
local bindName = "MicroGlitchEffect"
local previousOffset = CFrame.identity

local gui = Instance.new("ScreenGui")
gui.Name = "MicroGlitchUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = playerGui

local button = Instance.new("ImageButton")
button.Name = "GlitchToggle"
button.Size = UDim2.fromOffset(26, 26)
button.Position = UDim2.new(0.78, 0, 0.65, 0)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
button.BackgroundTransparency = 0.35
button.ImageTransparency = 1
button.AutoButtonColor = true
button.Active = true
button.Parent = gui

local round = Instance.new("UICorner")
round.CornerRadius = UDim.new(1, 0)
round.Parent = button

-- Um unico ponto preto de 1 px; sem contorno externo.
local dot = Instance.new("Frame")
dot.Name = "PositionDot"
dot.Size = UDim2.fromOffset(3, 3)
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.fromScale(0.5, 0.5)
dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dot.BorderSizePixel = 0
dot.Active = false
dot.ZIndex = button.ZIndex + 1
dot.Parent = button

button.Activated:Connect(function()
    enabled = not enabled
    elapsed = 0
    button.BackgroundColor3 = enabled and Color3.fromRGB(25, 190, 105) or Color3.fromRGB(40, 40, 48)
end)

local function cleanup()
    alive = false
    enabled = false
    pcall(function() RunService:UnbindFromRenderStep(bindName) end)
    if gui.Parent then gui:Destroy() end
end

_G.MicroGlitchCleanup = cleanup

RunService:BindToRenderStep(bindName, Enum.RenderPriority.Last.Value + 100, function(dt)
    local camera = workspace.CurrentCamera
    if not camera then
        previousOffset = CFrame.identity
        return
    end

    -- Undo only our last frame's offset, then apply a fresh offset.
    if previousOffset ~= CFrame.identity then
        camera.CFrame = camera.CFrame * previousOffset:Inverse()
        previousOffset = CFrame.identity
    end

    if not enabled then return end
    -- Pulso unilateral: parte de um angulo grande a esquerda e volta ao centro muito rapido.
    -- Depois de um breve instante no centro, reinicia sem varrer para a direita.
    elapsed = (elapsed + dt) % (returnTime + restTime)
    local yaw
    if elapsed < returnTime then
        yaw = amplitude * (1 - elapsed / returnTime)
    else
        yaw = 0
    end
    local roll = 0
    previousOffset = CFrame.new() * CFrame.Angles(0, yaw, 0)
    camera.CFrame = camera.CFrame * previousOffset
end)

gui.Destroying:Connect(function()
    if alive then
        alive = false
        pcall(function() RunService:UnbindFromRenderStep(bindName) end)
    end
end)
