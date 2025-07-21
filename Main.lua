local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local flyNoclip = true
local speed = 1

-- Create flying seat (not just a part)
local flyingSeat = Instance.new("Seat")
flyingSeat.Size = Vector3.new(2, 1, 2)
flyingSeat.Anchored = true
flyingSeat.CanCollide = false
flyingSeat.Transparency = 1
flyingSeat.Name = "FlyNoclipSeat"
flyingSeat.Parent = workspace

-- Notify player
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Anti-Cheat Test GUI",
        Text = "Fly-Noclip + Speed Slider loaded.",
        Duration = 5,
    })
end)

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyNoclipGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 120)
mainFrame.Position = UDim2.new(0.5, -125, 0.85, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -30, 0, 5)
minimizeButton.Text = "-"
minimizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
minimizeButton.TextColor3 = Color3.new(1,1,1)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 20
minimizeButton.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minimizeButton

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -35, 0.2, 0)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.Text = "Fly-Noclip Test"
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Fly-Noclip Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0.25, 0)
toggleButton.Position = UDim2.new(0, 10, 0.25, 0)
toggleButton.Text = "Fly-Noclip: ON"
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 16
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

toggleButton.MouseButton1Click:Connect(function()
    flyNoclip = not flyNoclip
    toggleButton.Text = "Fly-Noclip: " .. (flyNoclip and "ON" or "OFF")
    if not flyNoclip then
        -- On turning off, make sure player stands up and collisions back to normal
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Sit = false
            end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        flyingSeat.CFrame = CFrame.new(0, -500, 0) -- Move seat far away
    else
        -- Sit player again
        sitPlayer()
    end
end)

-- Speed Slider
local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0.2, 0)
sliderLabel.Position = UDim2.new(0, 0, 0.55, 0)
sliderLabel.Text = "Speed: 1"
sliderLabel.TextColor3 = Color3.new(1,1,1)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Font = Enum.Font.SourceSansBold
sliderLabel.TextSize = 18
sliderLabel.Parent = mainFrame

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(1, -20, 0.2, 0)
sliderButton.Position = UDim2.new(0, 10, 0.75, 0)
sliderButton.Text = "Drag to Change Speed"
sliderButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sliderButton.TextColor3 = Color3.new(1,1,1)
sliderButton.Font = Enum.Font.SourceSans
sliderButton.TextSize = 16
sliderButton.Parent = mainFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 8)
sliderCorner.Parent = sliderButton

local dragging = false

sliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

sliderButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mouseX = input.Position.X
        local absSizeX = sliderButton.AbsoluteSize.X
        local absPosX = sliderButton.AbsolutePosition.X
        local relative = math.clamp((mouseX - absPosX) / absSizeX, 0, 1)
        speed = math.floor(relative * 50) / 5 + 1 -- Range: 1 to 11
        sliderLabel.Text = "Speed: " .. string.format("%.1f", speed)
    end
end)

-- Minimize & Maximize logic
local minimized = false

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 50, 0, 25)
openButton.Position = UDim2.new(0.5, -25, 0.85, 0)
openButton.Text = "+"
openButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
openButton.TextColor3 = Color3.new(1,1,1)
openButton.Font = Enum.Font.SourceSansBold
openButton.TextSize = 20
openButton.Visible = false
openButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 8)
openCorner.Parent = openButton

minimizeButton.MouseButton1Click:Connect(function()
    minimized = true
    mainFrame.Visible = false
    openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
    minimized = false
    mainFrame.Visible = true
    openButton.Visible = false
end)

-- Sit player function
function sitPlayer()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    flyingSeat.CFrame = hrp.CFrame
    hrp.CFrame = flyingSeat.CFrame * CFrame.new(0, 3, 0) -- slightly above seat to avoid physics glitches
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Sit = true
end

-- Move flyingSeat and player in RenderStepped
RunService.RenderStepped:Connect(function(deltaTime)
    if flyNoclip then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local direction = Camera.CFrame.LookVector
                flyingSeat.CFrame = flyingSeat.CFrame + direction * speed * deltaTime * 10
                hrp.CFrame = flyingSeat.CFrame * CFrame.new(0, 3, 0)
            end
        end
    end
end)

-- Sit player on spawn
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    if flyNoclip then
        sitPlayer()
    end
end)

-- Initial setup
sitPlayer()
