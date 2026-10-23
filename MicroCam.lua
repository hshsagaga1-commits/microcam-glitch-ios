-- MicroCam Glitch | Roblox Mobile
-- Botao circular ON/OFF + tremor horizontal perceptivel
-- Configuracao inicial: amplitude 3 graus, frequencia 22 Hz.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui")

-- Limpa execucao anterior, se houver.
if _G.MicroGlitchCleanup then
    pcall(_G.MicroGlitchCleanup)
end

local enabled = false
local amplitude = math.rad(3)
local frequency = 22
local phase = 0
local previousOffset = CFrame.identity
local alive = true
local bindName = "MicroGlitchEffect"

local gui = Instance.new("ScreenGui")
gui.Name = "MicroGlitchUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.Name = "GlitchToggle"
button.Size = UDim2.fromOffset(58, 58)
button.Position = UDim2.new(0.78, 0, 0.65, 0)
button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
button.Text = "TRT"
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 17
button.Font = Enum.Font.GothamBold
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
    button.BackgroundColor3 = enabled
        and Color3.fromRGB(25, 190, 105)
        or Color3.fromRGB(40, 40, 48)
    button.Text = enabled and "ON" or "GL"
end)

local function cleanup()
    alive = false
    enabled = false
    pcall(function()
        RunService:UnbindFromRenderStep(bindName)
    end)
    if gui.Parent then
        gui:Destroy()
    end
end

_G.MicroGlitchCleanup = cleanup

RunService:BindToRenderStep(
    bindName,
    Enum.RenderPriority.Camera.Value + 1,
    function(dt)
        local camera = workspace.CurrentCamera
        if not camera then return end

        -- Remove o offset aplicado no frame anterior.
        camera.CFrame = camera.CFrame * previousOffset:Inverse()
        previousOffset = CFrame.identity

        if not enabled then return end

        phase = (phase + dt * frequency * math.pi * 2) % (math.pi * 2)
        local yaw = math.sin(phase) * amplitude

        previousOffset = CFrame.Angles(0, yaw, 0)
        camera.CFrame = camera.CFrame * previousOffset
    end
)

gui.Destroying:Connect(function()
    if alive then
        alive = false
        pcall(function()
            RunService:UnbindFromRenderStep(bindName)
        end)
    end
end)
