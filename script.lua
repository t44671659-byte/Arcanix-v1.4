-- ============================================================
-- ⚡ ARCANIX v17.2 (FULL UNCOMPRESSED)
-- ============================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ============================================================
-- СОСТОЯНИЕ
-- ============================================================
local State = {
    ESP_Enabled = false,
    ESP_Nicknames = false,
    ESP_TeamCheck = false,
    ESP_Color = Color3.fromRGB(255, 0, 0),
    ESP_MaxDistance = 1000,
    
    Aim_Enabled = false,
    Aim_Mode = "ShiftLock",
    Aim_FOV = 150,
    Aim_Smooth = 50,
    Aim_WallCheck = true,
    CurrentTarget = nil,
    
    Fly_Enabled = false,
    Fly_Speed = 50,
    
    TouchFling_Enabled = false,
    AntiFling_Enabled = false,
    
    FPS_Boost = false,
}

local FillColors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 150, 255),
    Color3.fromRGB(255, 0, 255),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(255, 255, 255)
}
local currentColorIndex = 1

local TP = { Phase = "Idle", TargetPart = nil, Timer = 0 }

-- ============================================================
-- ХЕЛПЕРЫ UI
-- ============================================================
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(200, 200, 210)
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function isTeammate(plr)
    if not State.ESP_TeamCheck then return false end
    if not plr or not lp then return false end
    if not plr.Team or not lp.Team then return false end
    return plr.Team == lp.Team
end

-- ============================================================
-- FOV КРУГ
-- ============================================================
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "FovGui"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 1
fovGui.Parent = CoreGui

local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
fovCircle.Size = UDim2.new(0, State.Aim_FOV * 2, 0, State.Aim_FOV * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = fovGui
corner(fovCircle, 9999)

local fovStroke = stroke(fovCircle, Color3.fromRGB(80, 150, 255), 1.5)
fovStroke.Transparency = 0.3

-- ============================================================
-- ГЛАВНЫЙ GUI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "ArcanixLight"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = CoreGui

-- КНОПКА С ОРЛОМ
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -30)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = ""
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = gui
corner(toggleBtn, 12)
stroke(toggleBtn, Color3.fromRGB(80, 150, 255), 1.5)

local eagleImg = Instance.new("ImageLabel")
eagleImg.Size = UDim2.new(1, -10, 1, -18)
eagleImg.Position = UDim2.new(0, 5, 0, 5)
eagleImg.BackgroundTransparency = 1
eagleImg.ScaleType = Enum.ScaleType.Fit
eagleImg.Image = "rbxassetid://51226825"
eagleImg.Parent = toggleBtn

local btnText = Instance.new("TextLabel")
btnText.Size = UDim2.new(1, 0, 0, 14)
btnText.Position = UDim2.new(0, 0, 1, -16)
btnText.BackgroundTransparency = 1
btnText.Text = "ARCANIX"
btnText.TextColor3 = Color3.fromRGB(40, 40, 50)
btnText.TextSize = 12
btnText.Font = Enum.Font.Arcade
btnText.Parent = toggleBtn

local window = Instance.new("CanvasGroup")
window.Size = UDim2.new(0, 400, 0, 340)
window.Position = UDim2.new(0.5, -200, 0.5, -170)
window.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
window.GroupTransparency = 1
window.Visible = false
window.Parent = gui
corner(window, 16)
stroke(window, Color3.fromRGB(220, 225, 240), 1.5)

local uiScale = Instance.new("UIScale")
uiScale.Scale = 0.8
uiScale.Parent = window

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = window

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 16, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ ARCANIX"
titleLabel.TextColor3 = Color3.fromRGB(40, 40, 50)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.Arcade
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -36, 0.5, -13)
closeBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
closeBtn.Text = "X"
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(100, 100, 110)
closeBtn.Font = Enum.Font.Arcade
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
corner(closeBtn, 8)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -24, 0, 36)
tabBar.Position = UDim2.new(0, 12, 0, 42)
tabBar.BackgroundColor3 = Color3.fromRGB(240, 242, 248)
tabBar.Parent = window
corner(tabBar, 10)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -24, 1, -90)
contentHolder.Position = UDim2.new(0, 12, 0, 84)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = window

local tabs = {}
local function makeTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 110, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(120, 120, 130)
    btn.TextSize = 14
    btn.Font = Enum.Font.Arcade
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn.Parent = tabBar
    corner(btn, 8)

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 150, 255)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Visible = false
    scrollFrame.Parent = contentHolder

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame

    tabs[name] = { button = btn, frame = scrollFrame }
    return scrollFrame
end

local espTab = makeTab("ESP", 1)
local aimTab = makeTab("AimBot", 2)
local miscTab = makeTab("Misc", 3)

local function switchTab(name)
    for tabName, data in pairs(tabs) do
        local active = (tabName == name)
        data.frame.Visible = active
        TweenService:Create(data.button, TweenInfo.new(0.2), { BackgroundColor3 = active and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(250, 250, 255) }):Play()
        TweenService:Create(data.button, TweenInfo.new(0.2), { TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 130) }):Play()
    end
end
for name, data in pairs(tabs) do
    data.button.MouseButton1Click:Connect(function() switchTab(name) end)
end
switchTab("ESP")

-- ============================================================
-- КОМПОНЕНТЫ UI
-- ============================================================
local function createToggle(parent, text, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -6, 0, 34)
    holder.BackgroundColor3 = Color3.fromRGB(242, 244, 250)
    holder.Parent = parent
    corner(holder, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(60, 60, 70)
    label.TextSize = 14
    label.Font = Enum.Font.Arcade
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 42, 0, 22)
    switch.Position = UDim2.new(1, -52, 0.5, -11)
    switch.BackgroundColor3 = Color3.fromRGB(200, 205, 215)
    switch.Parent = holder
    corner(switch, 11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switch
    corner(knob, 9)
    stroke(knob, Color3.fromRGB(180, 185, 195), 1)

    local isOn = default
    local function update(animate)
        local targetPos = isOn and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        local targetCol = isOn and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(200, 205, 215)
        if animate then
            TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quint), { Position = targetPos }):Play()
            TweenService:Create(switch, TweenInfo.new(0.25), { BackgroundColor3 = targetCol }):Play()
        else
            knob.Position = targetPos
            switch.BackgroundColor3 = targetCol
        end
    end
    update(false)

    local clicker = Instance.new("TextButton")
    clicker.Size = UDim2.new(1, 0, 1, 0)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    clicker.Parent = holder
    clicker.MouseButton1Click:Connect(function()
        isOn = not isOn
        update(true)
        if callback then callback(isOn) end
    end)
    return holder
end

local function createSlider(parent, text, minV, maxV, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -6, 0, 46)
    holder.BackgroundColor3 = Color3.fromRGB(242, 244, 250)
    holder.Parent = parent
    corner(holder, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 18)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(60, 60, 70)
    label.TextSize = 14
    label.Font = Enum.Font.Arcade
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 18)
    valueLabel.Position = UDim2.new(1, -70, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(80, 150, 255)
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.Arcade
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = holder

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 1, -14)
    track.BackgroundColor3 = Color3.fromRGB(210, 215, 225)
    track.Parent = holder
    corner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
    fill.Parent = track
    corner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = track
    corner(knob, 8)
    stroke(knob, Color3.fromRGB(80, 150, 255), 1.5)

    local value = default
    local dragging = false

    local function setFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(minV + (maxV - minV) * rel + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end

    local init = (default - minV) / (maxV - minV)
    fill.Size = UDim2.new(init, 0, 1, 0)
    knob.Position = UDim2.new(init, 0, 0.5, 0)

    local clicker = Instance.new("TextButton")
    clicker.Size = UDim2.new(1, -24, 0, 24)
    clicker.Position = UDim2.new(0, 12, 1, -24)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    clicker.Parent = holder
    
    clicker.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return holder
end

local function createAimModeSelector(parent)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -6, 0, 60)
    holder.BackgroundColor3 = Color3.fromRGB(242, 244, 250)
    holder.Parent = parent
    corner(holder, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 18)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = "Режим Аимбота:"
    label.TextColor3 = Color3.fromRGB(60, 60, 70)
    label.TextSize = 14
    label.Font = Enum.Font.Arcade
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local btnHolder = Instance.new("Frame")
    btnHolder.Size = UDim2.new(1, -24, 0, 24)
    btnHolder.Position = UDim2.new(0, 12, 0, 26)
    btnHolder.BackgroundTransparency = 1
    btnHolder.Parent = holder

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 4)
    layout.Parent = btnHolder

    local function makeModeBtn(name, mode)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 105, 1, 0)
        btn.BackgroundColor3 = State.Aim_Mode == mode and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(220, 225, 235)
        btn.Text = name
        btn.TextColor3 = State.Aim_Mode == mode and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 100, 110)
        btn.TextSize = 12
        btn.Font = Enum.Font.Arcade
        btn.Parent = btnHolder
        corner(btn, 6)
        
        btn.MouseButton1Click:Connect(function()
            State.Aim_Mode = mode
            for _, child in ipairs(btnHolder:GetChildren()) do
                if child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(220, 225, 235),
                        TextColor3 = Color3.fromRGB(100, 100, 110)
                    }):Play()
                end
            end
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(80, 150, 255),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end)
    end

    makeModeBtn("ShiftLock", "ShiftLock")
    makeModeBtn("RMB", "RMB")
    makeModeBtn("Всегда", "Always")
    return holder
end

local function createColorButton(parent)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 34)
    btn.BackgroundColor3 = State.ESP_Color
    btn.Text = "Цвет чамсов"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Arcade
    btn.TextSize = 14
    btn.Parent = parent
    corner(btn, 8)
    
    btn.MouseButton1Click:Connect(function()
        currentColorIndex = currentColorIndex % #FillColors + 1
        State.ESP_Color = FillColors[currentColorIndex]
        btn.BackgroundColor3 = State.ESP_Color
        local c = State.ESP_Color
        btn.TextColor3 = (c.R + c.G + c.B) > 1.5 and Color3.new(0,0,0) or Color3.new(1,1,1)
    end)
    return btn
end

-- ============================================================
-- ESP ЛОГИКА
-- ============================================================
local ActiveESP = {}

local function applyESP(plr)
    if plr == lp then return end
    local char = plr.Character
    if not char then return end

    if ActiveESP[plr] then
        if ActiveESP[plr].hl then ActiveESP[plr].hl:Destroy() end
        if ActiveESP[plr].bb then ActiveESP[plr].bb:Destroy() end
        ActiveESP[plr] = nil
    end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillColor = State.ESP_Color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = CoreGui 
    
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_Nick"
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = char:FindFirstChild("Head") or char
    bb.Parent = CoreGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.Arcade
    nameLabel.Parent = bb

    ActiveESP[plr] = { hl = highlight, bb = bb }
end

local function setupPlayer(plr)
    if plr == lp then return end
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if State.ESP_Enabled then applyESP(plr) end
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do setupPlayer(plr) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(plr)
    if ActiveESP[plr] then
        if ActiveESP[plr].hl then ActiveESP[plr].hl:Destroy() end
        if ActiveESP[plr].bb then ActiveESP[plr].bb:Destroy() end
        ActiveESP[plr] = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if not State.ESP_Enabled then
        for _, data in pairs(ActiveESP) do
            if data.hl then data.hl.Enabled = false end
            if data.bb then data.bb.Enabled = false end
        end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local data = ActiveESP[plr]
                
                if not data or not data.hl or data.hl.Adornee ~= char then
                    applyESP(plr)
                else
                    local dist = 999
                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        dist = (lp.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                    end
                    local sameTeam = isTeammate(plr)
        (plr)
                            local shouldShow = (dist <= State.ESP_MaxDistance) and not sameTeam
                            
                            data.hl.Enabled = shouldShow
                            data.hl.FillColor = State.ESP_Color
                            data.hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            
                            if data.bb then
                                data.bb.Enabled = shouldShow and State.ESP_Nicknames
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- FLY
-- ============================================================
local flyVel = nil
RunService.RenderStepped:Connect(function()
    if State.Fly_Enabled then
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = lp.Character.HumanoidRootPart
            if not flyVel then
                flyVel = Instance.new("BodyVelocity")
                flyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyVel.Velocity = Vector3.zero
                flyVel.Parent = hrp
            end
            
            local moveDir = Vector3.zero
            local camLook = camera.CFrame.LookVector
            local camRight = camera.CFrame.RightVector
            
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += camLook end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= camLook end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= camRight end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += camRight end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
            
            local hum = lp.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0.1 then
                local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                local flatRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
                local joystickX = hum.MoveDirection:Dot(flatRight)
                local joystickZ = hum.MoveDirection:Dot(flatLook)
                moveDir += (camLook * joystickZ) + (camRight * joystickX)
            end

            if moveDir.Magnitude > 0 then
                flyVel.Velocity = moveDir.Unit * State.Fly_Speed
            else
                flyVel.Velocity = Vector3.zero
            end
        end
    else
        if flyVel then
            flyVel:Destroy()
            flyVel = nil
        end
    end
end)

-- ============================================================
-- УНИВЕРСАЛЬНОЕ МЕНЮ ИГРОКОВ
-- ============================================================
local function createPlayerMenu(titleText, actionCallback)
    local menu = Instance.new("CanvasGroup")
    menu.Size = UDim2.new(0, 250, 0, 300)
    menu.Position = UDim2.new(0.5, -125, 0.5, -150)
    menu.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
    menu.GroupTransparency = 1
    menu.Visible = false
    menu.Parent = gui
    corner(menu, 12)
    stroke(menu, Color3.fromRGB(220, 225, 240), 1.5)

    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundTransparency = 1
    title.Parent = menu

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = titleText
    label.TextColor3 = Color3.fromRGB(40, 40, 50)
    label.TextSize = 14
    label.Font = Enum.Font.Arcade
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = title

    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 24, 0, 24)
    close.Position = UDim2.new(1, -30, 0.5, -12)
    close.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    close.Text = "X"
    close.TextSize = 14
    close.TextColor3 = Color3.fromRGB(100, 100, 110)
    close.Font = Enum.Font.Arcade
    close.AutoButtonColor = false
    close.Parent = title
    corner(close, 6)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -50)
    scroll.Position = UDim2.new(0, 10, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 150, 255)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = menu

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.Name
    layout.Parent = scroll

    local function refresh()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -6, 0, 34)
                btn.BackgroundColor3 = Color3.fromRGB(242, 244, 250)
                btn.Text = plr.Name
                btn.TextColor3 = Color3.fromRGB(60, 60, 70)
                btn.TextSize = 14
                btn.Font = Enum.Font.Arcade
                btn.AutoButtonColor = false
                btn.Parent = scroll
                corner(btn, 8)
                
                btn.MouseButton1Click:Connect(function()
                    actionCallback(plr)
                    menu.Visible = false
                    TweenService:Create(menu, TweenInfo.new(0.2), {GroupTransparency = 1}):Play()
                end)
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end

    close.MouseButton1Click:Connect(function()
        menu.Visible = false
        TweenService:Create(menu, TweenInfo.new(0.2), {GroupTransparency = 1}):Play()
    end)

    return menu, refresh
end

-- ============================================================
-- ТЕЛЕПОРТ
-- ============================================================
local function startSmoothTP(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if targetHRP then
        TP.TargetPart = targetHRP
        TP.Phase = "Glide"
        TP.Timer = tick()
    end
end

RunService.RenderStepped:Connect(function(dt)
    if TP.Phase == "Idle" or not TP.TargetPart or not lp.Character then return end
    local myHRP = lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP or not TP.TargetPart.Parent then TP.Phase = "Idle"; return end

    if TP.Phase == "Glide" then
        local dist = (TP.TargetPart.Position - myHRP.Position).Magnitude
        if dist < 4 then
            TP.Phase = "Lock"
            TP.Timer = tick()
        else
            local speed = math.clamp(dist * 0.5, 5, 25) 
            local goal = CFrame.new(TP.TargetPart.Position - TP.TargetPart.CFrame.LookVector * 3, TP.TargetPart.Position)
            myHRP.CFrame = myHRP.CFrame:Lerp(goal, dt * speed)
        end
    elseif TP.Phase == "Lock" then
        local goal = CFrame.new(TP.TargetPart.Position - TP.TargetPart.CFrame.LookVector * 3, TP.TargetPart.Position)
        myHRP.CFrame = myHRP.CFrame:Lerp(goal, dt * 15)
        if tick() - TP.Timer > 1.5 then
            TP.Phase = "Release"
            TP.Timer = tick()
        end
    elseif TP.Phase == "Release" then
        if tick() - TP.Timer > 0.5 then
            TP.Phase = "Idle"
            TP.TargetPart = nil
        end
    end
end)

-- ============================================================
-- РЕАЛЬНЫЙ ФЛИНГ (Spin Fling)
-- ============================================================
local function flingTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local myChar = lp.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myHRP or not targetHRP then return end
    
    local oldPos = myHRP.CFrame
    local spinAngle = 0
    
    local function spinStep()
        spinAngle = spinAngle + 1690
        local spinPos = Vector3.new(
            targetHRP.Position.X + math.cos(math.rad(spinAngle)) * 1,
            targetHRP.Position.Y,
            targetHRP.Position.Z + math.sin(math.rad(spinAngle)) * 1
        )
        myHRP.CFrame = CFrame.new(spinPos) * CFrame.Angles(0, math.rad(spinAngle), 0)
        myChar:SetPrimaryPartCFrame(CFrame.new(spinPos) * CFrame.Angles(0, math.rad(spinAngle), 0))
        myHRP.Velocity = Vector3.new(9e9, 9e9 * 15, 9e9)
        myHRP.RotVelocity = Vector3.new(0, 9e9, 0)
    end

    local bv = Instance.new("BodyVelocity")
    bv.Parent = myHRP
    bv.Velocity = Vector3.new(9e9, 9e9, 9e9)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    local startTime = tick()
    
    while tick() - startTime < 1.5 do
        if not targetHRP.Parent then break end
        spinStep()
        task.wait(0.01)
    end
    
    bv:Destroy()
    myHRP.CFrame = oldPos
    myChar:SetPrimaryPartCFrame(oldPos)
end

-- Создаем меню
local tpMenu, refreshTP = createPlayerMenu("ТЕЛЕПОРТ", startSmoothTP)
local flingMenu, refreshFling = createPlayerMenu("ФЛИНГ", flingTarget)

-- ============================================================
-- TOUCH FLING & ANTI-FLING
-- ============================================================
local touchConnection, antiFlingConnection = nil, nil

local function toggleTouchFling(enable)
    if enable then
        if not State.AntiFling_Enabled then
            State.AntiFling_Enabled = true
            toggleAntiFling(true)
        end
        if not touchConnection then
            touchConnection = lp.Character.HumanoidRootPart.Touched:Connect(function(hit)
                if not State.TouchFling_Enabled then return end
                local hitChar = hit:FindFirstAncestorOfClass("Model")
                if hitChar and hitChar ~= lp.Character and hitChar:FindFirstChild("Humanoid") then
                    local targetHRP = hitChar:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local bv = Instance.new("BodyVelocity")
                        bv.Velocity = Vector3.new(0, 500, 0)
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Parent = targetHRP
                        task.wait(0.1)
                        bv:Destroy()
                    end
                end
            end)
        end
    else
        if touchConnection then
            touchConnection:Disconnect()
            touchConnection = nil
        end
    end
end

function toggleAntiFling(enable)
    if enable then
        if not antiFlingConnection then
            antiFlingConnection = RunService.Stepped:Connect(function()
                if not State.AntiFling_Enabled then return end
                local char = lp.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    if hrp.Velocity.Magnitude > 1000 then
                        hrp.Velocity = Vector3.zero
                        hrp.RotVelocity = Vector3.zero
                    end
                end
            end)
        end
    else
        if antiFlingConnection then
            antiFlingConnection:Disconnect()
            antiFlingConnection = nil
        end
    end
end

-- ============================================================
-- AIMBOT ЛОГИКА
-- ============================================================
local isAiming = false
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if State.Aim_Enabled and State.Aim_Mode == "RMB" and input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = true
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false
    end
end)

local function hasLineOfSight(targetPart)
    if not State.Aim_WallCheck then return true end
    local origin = camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {lp.Character, camera}
    local rayResult = Workspace:Raycast(origin, direction, raycastParams)
    if not rayResult then return true end
    if rayResult.Instance:IsDescendantOf(targetPart.Parent) then return true end
    return false
end

local function isTargetValid(targetPart)
    if not targetPart or not targetPart.Parent then return false end
    local hum = targetPart.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end

local function getTarget()
    if State.CurrentTarget and isTargetValid(State.CurrentTarget) then
        if hasLineOfSight(State.CurrentTarget) then
            return State.CurrentTarget
        end
    end
    
    State.CurrentTarget = nil
    local closest, shortest = nil, State.Aim_FOV
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and not isTeammate(plr) then
            local char = plr.Character
            if char then
                local targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if targetPart and hum and hum.Health > 0 then
                    local pos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if d < shortest then
                            if hasLineOfSight(targetPart) then
                                shortest = d
                                closest = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    State.CurrentTarget = closest
    return State.CurrentTarget
end

RunService.RenderStepped:Connect(function(dt)
    if not State.Aim_Enabled then 
        State.CurrentTarget = nil
        return 
    end
    
    local active = false
    if State.Aim_Mode == "Always" then 
        active = true
    elseif State.Aim_Mode == "RMB" then 
        active = isAiming
    elseif State.Aim_Mode == "ShiftLock" then 
        active = (UIS.MouseBehavior == Enum.MouseBehavior.LockCenter) 
    end
    
    if not active then 
        State.CurrentTarget = nil
        return 
    end
    
    local target = getTarget()
    if target then
        local current = camera.CFrame
        local desired = CFrame.new(current.Position, target.Position)
        if State.Aim_Smooth >= 99 then
            camera.CFrame = desired
        else
            local smoothFactor = State.Aim_Smooth / 100
            local alpha = 1 - math.pow(1 - smoothFactor, dt * 60)
            camera.CFrame = current:Lerp(desired, alpha)
        end
    end
end)

-- ============================================================
-- НАПОЛНЕНИЕ ВКЛАДОК
-- ============================================================
createToggle(espTab, "Включить ESP", false, function(v) 
    State.ESP_Enabled = v 
    if not v then
        for _, data in pairs(ActiveESP) do
            if data.hl then data.hl.Enabled = false end
            if data.bb then data.bb.Enabled = false end
        end
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            applyESP(plr)
        end
    end
end)
createToggle(espTab, "Показывать Ники", false, function(v) State.ESP_Nicknames = v end)
createToggle(espTab, "Игнорировать союзников", false, function(v) State.ESP_TeamCheck = v end)
createColorButton(espTab)

createToggle(aimTab, "Включить AimBot", false, function(v)
    State.Aim_Enabled = v
    fovCircle.Visible = v
end)
createToggle(aimTab, "Wall-Check", true, function(v) State.Aim_WallCheck = v end)
createAimModeSelector(aimTab)
createSlider(aimTab, "FOV (Радиус)", 50, 400, 150, function(v)
    State.Aim_FOV = v
    fovCircle.Size = UDim2.new(0, v*2, 0, v*2)
end)
createSlider(aimTab, "Сила лока (100 = СНАП)", 1, 100, 50, function(v)
    State.Aim_Smooth = v
end)

local flySlider
local flyToggle = createToggle(miscTab, "Fly", false, function(v)
    State.Fly_Enabled = v
    if flySlider then flySlider.Visible = v end
end)
flySlider = createSlider(miscTab, "Скорость полета", 10, 200, 50, function(v) State.Fly_Speed = v end)
flySlider.Visible = false 

-- Кнопки открытия меню
local tpOpenBtn = Instance.new("TextButton")
tpOpenBtn.Size = UDim2.new(1, -6, 0, 34)
tpOpenBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
tpOpenBtn.Text = "МЕНЮ ТЕЛЕПОРТА"
tpOpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpOpenBtn.TextSize = 14
tpOpenBtn.Font = Enum.Font.Arcade
tpOpenBtn.Parent = miscTab
corner(tpOpenBtn, 8)
tpOpenBtn.MouseButton1Click:Connect(function()
    refreshTP()
    tpMenu.Visible = true
    TweenService:Create(tpMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {GroupTransparency = 0}):Play()
end)

local flingOpenBtn = Instance.new("TextButton")
flingOpenBtn.Size = UDim2.new(1, -6, 0, 34)
flingOpenBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
flingOpenBtn.Text = "МЕНЮ ФЛИНГА"
flingOpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flingOpenBtn.TextSize = 14
flingOpenBtn.Font = Enum.Font.Arcade
flingOpenBtn.Parent = miscTab
corner(flingOpenBtn, 8)
flingOpenBtn.MouseButton1Click:Connect(function()
    refreshFling()
    flingMenu.Visible = true
    TweenService:Create(flingMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {GroupTransparency = 0}):Play()
end)

createToggle(miscTab, "Touch Fling (Авто-Антифлинг)", false, function(v) 
    State.TouchFling_Enabled = v
    toggleTouchFling(v)
    if v then 
        refreshFling()
        flingMenu.Visible = true
        TweenService:Create(flingMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {GroupTransparency = 0}):Play()
    end
end)

createToggle(miscTab, "FPS Boost", false, function(v)
    if v then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        Lighting.Brightness = 2
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    else
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 10000
        Lighting.Brightness = 3
        Lighting.EnvironmentDiffuseScale = 0.5
        Lighting.EnvironmentSpecularScale = 0.5
    end
end)

-- ============================================================
-- ПЕРЕТАСКИВАНИЕ И АНИМАЦИЯ
-- ============================================================
local function makeDraggable(frame, dragTarget)
    local dragging, dragStart, startPos
    dragTarget.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(window, titleBar)
makeDraggable(toggleBtn, toggleBtn)
makeDraggable(tpMenu, tpMenu:
FindFirstChild("Frame"))
makeDraggable(flingMenu, flingMenu:FindFirstChild("Frame"))

local isOpen = false
local function openMenu()
    if isOpen then return end
    isOpen = true
    window.Visible = true
    window.GroupTransparency = 1
    uiScale.Scale = 0.8
    TweenService:Create(window, TweenInfo.new(0.4, Enum.EasingStyle.Quint), { GroupTransparency = 0 }):Play()
    TweenService:Create(uiScale, TweenInfo.new(0.4, Enum.EasingStyle.Back), { Scale = 1 }):Play()
end
local function closeMenu()
    if not isOpen then return end
    isOpen = false
    local t1 = TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { GroupTransparency = 1 })
    local t2 = TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Quint), { Scale = 0.8 })
    t1:Play(); t2:Play()
    t1.Completed:Connect(function() if not isOpen then window.Visible = false end end)
end
toggleBtn.MouseButton1Click:Connect(function() if isOpen then closeMenu() else openMenu() end end)
closeBtn.MouseButton1Click:Connect(closeMenu)

print("Arcanix v17.2 Full Uncompressed Loaded")
