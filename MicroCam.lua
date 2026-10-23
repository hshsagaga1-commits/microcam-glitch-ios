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
local amplitude = math.rad(0.7)
local frequency = 90
local phase = 0
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
button.Size = UDim2.fromOffset(58, 58)
button.Position = UDim2.new(0.78, 0, 0.65, 0)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
button.AutoButtonColor = true
button.Active = true
button.Parent = gui

local round = Instance.new("UICorner")
round.CornerRadius = UDim.new(1, 0)
round.Parent = button

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(125, 125, 145)
outline.Thickness = 2
outline.Parent = button

button.Activated:Connect(function()
    enabled = not enabled
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
    phase = (phase + dt * frequency * math.pi * 2) % (math.pi * 2)

    -- Pulso muito rapido: esquerda -> reto, sem transicao suave.
    -- 90 ciclos/s; o movimento realmente exibido depende do FPS.
    local yaw = (math.sin(phase) >= 0) and -amplitude or 0
    local roll = 0
    previousOffset = CFrame.Angles(0, yaw, roll)
    camera.CFrame = camera.CFrame * previousOffset
end)

gui.Destroying:Connect(function()
    if alive then
        alive = false
        pcall(function() RunService:UnbindFromRenderStep(bindName) end)
    end
end)
