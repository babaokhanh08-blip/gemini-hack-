--[[
    ✦ ASTRA HUB | Blox Fruits | v5.0
    Discord: discord.gg/astrahub
]]--

if not game:IsLoaded() then game.Loaded:Wait() end

-- =============================================
-- [[ SERVICES ]]
-- =============================================
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local HttpService     = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui      = game:GetService("StarterGui")
local Workspace       = game:GetService("Workspace")
local CoreGui         = game:GetService("CoreGui")
local VirtualUser     = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")

-- =============================================
-- [[ LOCALS ]]
-- =============================================
local LP       = Players.LocalPlayer
local Camera   = Workspace.CurrentCamera
local Remotes  = ReplicatedStorage:WaitForChild("Remotes", 10)

local function getChar()   return LP.Character end
local function getHRP()    local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()    local c = getChar(); return c and c:FindFirstChildWhichIsA("Humanoid") end

-- =============================================
-- [[ GLOBAL STATE ]]
-- =============================================
_G.Astra = _G.Astra or {}
local S = _G.Astra   -- settings shorthand

-- Toggles
S.AutoFarm          = false
S.AutoQuest         = false
S.AutoStats         = false
S.AutoHaki          = false
S.AutoObservation   = false
S.AutoObsV2         = false
S.AutoAttack        = false
S.FastAttack        = false
S.BringMob          = false
S.Magnet            = false
S.KillAura          = false
S.Aimbot            = false
S.SilentAim         = false
S.AutoSkillSpam     = false
S.BringPlayer       = false
S.SpeedHack         = false
S.FlyEnabled        = false
S.InfiniteJump      = false
S.NoClip            = false
S.GodMode           = false
S.AntiKnockback     = false
S.InfiniteEnergy    = false
S.InfiniteStamina   = false
S.NoFallDamage      = false
S.WalkOnWater       = false
S.FruitSniper       = false
S.AutoCollectFruit  = false
S.AutoStoreFruit    = false
S.AutoEatFruit      = false
S.AutoBuyFruit      = false
S.NotifyRareFruit   = true
S.AutoSeaBeast      = false
S.AutoSummonSeaBeast= false
S.AutoRaid          = false
S.AutoStartRaid     = false
S.AutoBoss          = false
S.AutoEliteHunter   = false
S.AutoDoughKing     = false
S.AutoCakeEvent     = false
S.AutoMirrorFractal = false
S.AutoMaterialFarm  = false
S.AutoFullyAwakened = false
S.AntiAFK           = true
S.FPSBoost          = false
S.ChatSpammer       = false
S.KillSay           = false
S.ESPPlayer         = false
S.ESPPlayerName     = true
S.ESPPlayerDist     = true
S.ESPPlayerHP       = true
S.ESPPlayerTool     = false
S.ESPPlayerTracer   = false
S.ESPMob            = false
S.ESPMobName        = true
S.ESPMobDist        = true
S.ESPMobHP          = true
S.ESPMobTracer      = false
S.ESPFruit          = false
S.ESPFruitName      = true
S.ESPFruitDist      = true
S.ESPChest          = false
S.ESPChestDist      = true
S.ESPIsland         = false
S.ESPNPC            = false

-- Values
S.Speed             = 16
S.FlySpeed          = 80
S.TweenSpeed        = 0.4     -- seconds
S.FarmTarget        = "Nearest"
S.SelectedIsland    = "Marine Starter"
S.SelectedMonster   = ""
S.SelectedBoss      = "Bobby"
S.AutoFarmType      = "Level"
S.StatsType         = "BloxFruit"
S.RaidType          = "Darkbeard"
S.ESPMaxDist        = 2000
S.ESPTextSize       = 14
S.ToggleKey         = Enum.KeyCode.RightShift
S.ChatSpamMsg       = "Astra Hub | discord.gg/astrahub"
S.KillSayMsg        = "GG ez"

-- =============================================
-- [[ HELPERS ]]
-- =============================================
local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title,
            Text     = text,
            Duration = dur or 3,
        })
    end)
end

local function FireRemote(name, ...)
    if not Remotes then return end
    local r = Remotes:FindFirstChild(name)
    if r and r:IsA("RemoteEvent") then
        pcall(function() r:FireServer(...) end)
    end
end

local function InvokeRemote(name, ...)
    if not Remotes then return end
    local r = Remotes:FindFirstChild(name)
    if r and r:IsA("RemoteFunction") then
        local ok, res = pcall(function() return r:InvokeServer(...) end)
        if ok then return res end
    end
end

local function TweenTo(target, speed)
    local hrp = getHRP()
    if not hrp then return end
    speed = speed or S.TweenSpeed
    local tween = TweenService:Create(hrp, TweenInfo.new(speed, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(target)})
    tween:Play()
    tween.Completed:Wait()
end

-- =============================================
-- [[ UI THEME ]]
-- =============================================
local T = {
    BG        = Color3.fromRGB(13, 13, 18),
    Topbar    = Color3.fromRGB(18, 18, 26),
    TabBar    = Color3.fromRGB(16, 16, 22),
    TabActive = Color3.fromRGB(95, 55, 215),
    TabHover  = Color3.fromRGB(40, 35, 70),
    TabOff    = Color3.fromRGB(26, 26, 36),
    Section   = Color3.fromRGB(20, 20, 28),
    TogOn     = Color3.fromRGB(95, 55, 215),
    TogOff    = Color3.fromRGB(45, 45, 58),
    BtnBG     = Color3.fromRGB(75, 42, 170),
    BtnHov    = Color3.fromRGB(105, 62, 230),
    Slider    = Color3.fromRGB(95, 55, 215),
    Text      = Color3.fromRGB(218, 218, 232),
    Sub       = Color3.fromRGB(145, 145, 165),
    Accent    = Color3.fromRGB(125, 75, 255),
    Border    = Color3.fromRGB(40, 40, 55),
    Input     = Color3.fromRGB(22, 22, 32),
    White     = Color3.fromRGB(255, 255, 255),
    Red       = Color3.fromRGB(185, 50, 50),
}

local function UICorner(r, p)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = p
    return c
end

local function UIStroke(col, thick, p)
    local s = Instance.new("UIStroke")
    s.Color = col
    s.Thickness = thick or 1
    s.Parent = p
    return s
end

local function UIPad(t, b, l, r, p)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop    = UDim.new(0, t)
    pad.PaddingBottom = UDim.new(0, b or t)
    pad.PaddingLeft   = UDim.new(0, l or t)
    pad.PaddingRight  = UDim.new(0, r or l or t)
    pad.Parent = p
    return pad
end

local function UIList(dir, pad, p)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding       = UDim.new(0, pad or 4)
    l.Parent = p
    return l
end

-- =============================================
-- [[ UI LIBRARY ]]
-- =============================================
local AstraUI = {}
AstraUI.__index = AstraUI

function AstraUI.new()
    local self = setmetatable({}, AstraUI)

    -- Destroy existing instance
    if CoreGui:FindFirstChild("AstraHub") then CoreGui:FindFirstChild("AstraHub"):Destroy() end

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "AstraHub"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.DisplayOrder = 999

    -- Executor gui protection
    pcall(function()
        if syn then syn.protect_gui(self.ScreenGui)
        elseif protect_gui then protect_gui(self.ScreenGui) end
        self.ScreenGui.Parent = CoreGui
    end)
    if not self.ScreenGui.Parent then
        self.ScreenGui.Parent = LP:WaitForChild("PlayerGui")
    end

    -- ---- Main Frame ----
    local MF = Instance.new("Frame")
    MF.Name            = "MainFrame"
    MF.Size            = UDim2.new(0, 700, 0, 475)
    MF.Position        = UDim2.new(0.5, -350, 0.5, -237)
    MF.BackgroundColor3 = T.BG
    MF.BorderSizePixel = 0
    MF.Parent          = self.ScreenGui
    UICorner(10, MF)
    UIStroke(T.Border, 1, MF)
    self.MainFrame = MF

    -- ---- Topbar ----
    local TB = Instance.new("Frame")
    TB.Size             = UDim2.new(1, 0, 0, 40)
    TB.BackgroundColor3 = T.Topbar
    TB.BorderSizePixel  = 0
    TB.Parent           = MF
    UICorner(10, TB)
    -- Fix bottom-round on topbar
    local tbfix = Instance.new("Frame")
    tbfix.Size = UDim2.new(1, 0, 0.5, 0)
    tbfix.Position = UDim2.new(0, 0, 0.5, 0)
    tbfix.BackgroundColor3 = T.Topbar
    tbfix.BorderSizePixel = 0
    tbfix.Parent = TB

    -- Logo
    local logo = Instance.new("TextLabel")
    logo.Text = "✦ ASTRA HUB"
    logo.Size = UDim2.new(0, 160, 1, 0)
    logo.Position = UDim2.new(0, 14, 0, 0)
    logo.BackgroundTransparency = 1
    logo.TextColor3 = T.Accent
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 15
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = TB

    local sub = Instance.new("TextLabel")
    sub.Text = "Blox Fruits  |  v5.0"
    sub.Size = UDim2.new(0, 200, 1, 0)
    sub.Position = UDim2.new(0, 168, 0, 0)
    sub.BackgroundTransparency = 1
    sub.TextColor3 = T.Sub
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 11
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.Parent = TB

    -- Close / Min buttons
    local function makeTopBtn(icon, col, xOff)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 26, 0, 26)
        b.Position = UDim2.new(1, xOff, 0.5, -13)
        b.BackgroundColor3 = col
        b.TextColor3 = T.White
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.Text = icon
        b.BorderSizePixel = 0
        b.Parent = TB
        UICorner(5, b)
        return b
    end

    local closeBtn = makeTopBtn("✕", T.Red, -32)
    local minBtn   = makeTopBtn("─", T.TabOff, -62)

    closeBtn.MouseButton1Click:Connect(function() MF.Visible = false end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        self.TabBar.Visible   = not minimized
        self.Content.Visible  = not minimized
        MF.Size = minimized and UDim2.new(0, 700, 0, 40) or UDim2.new(0, 700, 0, 475)
    end)

    -- Drag
    local dragging, dragStart, startPos = false
    TB.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = MF.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dragStart
            MF.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- ---- Tab Sidebar ----
    local sidebar = Instance.new("Frame")
    sidebar.Size             = UDim2.new(0, 148, 1, -40)
    sidebar.Position         = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = T.TabBar
    sidebar.BorderSizePixel  = 0
    sidebar.Parent           = MF
    -- top-left already rounded via MF; fix right side
    local sbFix = Instance.new("Frame")
    sbFix.Size = UDim2.new(0, 8, 1, 0)
    sbFix.Position = UDim2.new(1, -8, 0, 0)
    sbFix.BackgroundColor3 = T.TabBar
    sbFix.BorderSizePixel = 0
    sbFix.Parent = sidebar
    local sbDiv = Instance.new("Frame")
    sbDiv.Size = UDim2.new(0, 1, 1, 0)
    sbDiv.Position = UDim2.new(1, -1, 0, 0)
    sbDiv.BackgroundColor3 = T.Border
    sbDiv.BorderSizePixel = 0
    sbDiv.Parent = sidebar
    UIList(Enum.FillDirection.Vertical, 2, sidebar)
    UIPad(8, 8, 6, 6, sidebar)
    self.TabBar = sidebar

    -- ---- Content Area ----
    local content = Instance.new("Frame")
    content.Size             = UDim2.new(1, -148, 1, -40)
    content.Position         = UDim2.new(0, 148, 0, 40)
    content.BackgroundTransparency = 1
    content.BorderSizePixel  = 0
    content.ClipsDescendants = true
    content.Parent           = MF
    self.Content = content

    -- Watermark strip
    local wm = Instance.new("TextLabel")
    wm.Text = "✦ ASTRA HUB  |  Blox Fruits  |  v5.0  |  discord.gg/astrahub"
    wm.Size = UDim2.new(0, 420, 0, 20)
    wm.Position = UDim2.new(1, -425, 0, 4)
    wm.BackgroundTransparency = 1
    wm.TextColor3 = T.Sub
    wm.Font = Enum.Font.Gotham
    wm.TextSize = 10
    wm.TextXAlignment = Enum.TextXAlignment.Right
    wm.Parent = TB

    self.Tabs    = {}
    self.TabBtns = {}

    return self
end

function AstraUI:Tab(name, icon)
    icon = icon or "•"
    -- Button
    local btn = Instance.new("TextButton")
    btn.Name            = name
    btn.Size            = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = T.TabOff
    btn.TextColor3      = T.Sub
    btn.Font            = Enum.Font.Gotham
    btn.TextSize        = 12
    btn.Text            = icon .. "  " .. name
    btn.TextXAlignment  = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent          = self.TabBar
    UICorner(6, btn)
    UIPad(0, 0, 10, 0, btn)

    local indicator = Instance.new("Frame")
    indicator.Size             = UDim2.new(0, 3, 0.55, 0)
    indicator.Position         = UDim2.new(0, 2, 0.225, 0)
    indicator.BackgroundColor3 = T.Accent
    indicator.BorderSizePixel  = 0
    indicator.Visible          = false
    indicator.Parent           = btn
    UICorner(2, indicator)

    -- Scroll frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name                = name .. "_Frame"
    scroll.Size                = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel     = 0
    scroll.ScrollBarThickness  = 3
    scroll.ScrollBarImageColor3 = T.Accent
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize          = UDim2.new(0, 0, 0, 0)
    scroll.Visible             = false
    scroll.Parent              = self.Content
    UIList(Enum.FillDirection.Vertical, 6, scroll)
    UIPad(10, 10, 12, 12, scroll)

    local tab = { Frame = scroll, Btn = btn, Indicator = indicator }
    self.Tabs[name] = tab
    table.insert(self.TabBtns, name)

    btn.MouseButton1Click:Connect(function() self:Select(name) end)
    btn.MouseEnter:Connect(function()
        if self.ActiveTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = T.TabHover}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if self.ActiveTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = T.TabOff}):Play()
        end
    end)

    if #self.TabBtns == 1 then self:Select(name) end
    return tab
end

function AstraUI:Select(name)
    for n, t in pairs(self.Tabs) do
        t.Frame.Visible = false
        t.Btn.BackgroundColor3 = T.TabOff
        t.Btn.TextColor3 = T.Sub
        t.Indicator.Visible = false
    end
    if self.Tabs[name] then
        self.Tabs[name].Frame.Visible = true
        self.Tabs[name].Btn.BackgroundColor3 = T.TabActive
        self.Tabs[name].Btn.TextColor3 = T.Text
        self.Tabs[name].Indicator.Visible = true
        self.ActiveTab = name
    end
end

-- Section header
function AstraUI:Section(tab, title)
    local sf = Instance.new("Frame")
    sf.Size             = UDim2.new(1, 0, 0, 0)
    sf.AutomaticSize    = Enum.AutomaticSize.Y
    sf.BackgroundColor3 = T.Section
    sf.BorderSizePixel  = 0
    sf.Parent           = tab.Frame
    UICorner(7, sf)
    UIStroke(T.Border, 1, sf)
    UIList(Enum.FillDirection.Vertical, 3, sf)
    UIPad(8, 8, 10, 10, sf)

    local hdr = Instance.new("TextLabel")
    hdr.Text = title:upper()
    hdr.Size = UDim2.new(1, 0, 0, 18)
    hdr.BackgroundTransparency = 1
    hdr.TextColor3 = T.Accent
    hdr.Font = Enum.Font.GothamBold
    hdr.TextSize = 10
    hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.Parent = sf

    local div = Instance.new("Frame")
    div.Size = UDim2.new(1, 0, 0, 1)
    div.BackgroundColor3 = T.Border
    div.BorderSizePixel = 0
    div.Parent = sf

    return sf
end

-- Toggle
function AstraUI:Toggle(parent, text, default, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(1, -48, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = T.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 40, 0, 21)
    bg.Position = UDim2.new(1, -40, 0.5, -10)
    bg.BackgroundColor3 = default and T.TogOn or T.TogOff
    bg.BorderSizePixel = 0
    bg.Parent = row
    UICorner(20, bg)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 15, 0, 15)
    knob.Position = default and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = T.White
    knob.BorderSizePixel = 0
    knob.Parent = bg
    UICorner(20, knob)

    local state = default or false
    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = row

    local function setState(v)
        state = v
        TweenService:Create(bg, TweenInfo.new(0.14), {BackgroundColor3 = state and T.TogOn or T.TogOff}):Play()
        TweenService:Create(knob, TweenInfo.new(0.14), {
            Position = state and UDim2.new(1,-18,0.5,-7) or UDim2.new(0,3,0.5,-7)
        }):Play()
        if cb then pcall(cb, state) end
    end

    hitbox.MouseButton1Click:Connect(function() setState(not state) end)

    return {Set = setState, Get = function() return state end}
end

-- Button
function AstraUI:Button(parent, text, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 27)
    btn.BackgroundColor3 = T.BtnBG
    btn.TextColor3 = T.Text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.Text = text
    btn.BorderSizePixel = 0
    btn.Parent = parent
    UICorner(6, btn)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = T.BtnHov}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = T.BtnBG}):Play()
    end)
    btn.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return btn
end

-- Slider
function AstraUI:Slider(parent, text, min, max, default, cb)
    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(1, 0, 0, 46)
    sf.BackgroundTransparency = 1
    sf.Parent = parent

    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1, 0, 0, 18)
    topRow.BackgroundTransparency = 1
    topRow.Parent = sf

    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(0.72, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = T.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = topRow

    local valLbl = Instance.new("TextLabel")
    valLbl.Text = tostring(default)
    valLbl.Size = UDim2.new(0.28, 0, 1, 0)
    valLbl.Position = UDim2.new(0.72, 0, 0, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3 = T.Accent
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = topRow

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 28)
    track.BackgroundColor3 = T.TogOff
    track.BorderSizePixel = 0
    track.Parent = sf
    UICorner(20, track)

    local pct = (default - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = T.Slider
    fill.BorderSizePixel = 0
    fill.Parent = track
    UICorner(20, fill)

    local nub = Instance.new("Frame")
    nub.Size = UDim2.new(0, 13, 0, 13)
    nub.Position = UDim2.new(pct, -6, 0.5, -6)
    nub.BackgroundColor3 = T.White
    nub.BorderSizePixel = 0
    nub.ZIndex = 3
    nub.Parent = track
    UICorner(20, nub)

    local value = default
    local active = false

    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        nub.Position = UDim2.new(rel, -6, 0.5, -6)
        valLbl.Text = tostring(value)
        if cb then pcall(cb, value) end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            active = true; update(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if active and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then active = false end
    end)

    return {Get = function() return value end}
end

-- Dropdown
function AstraUI:Dropdown(parent, text, opts, default, cb)
    local df = Instance.new("Frame")
    df.Size = UDim2.new(1, 0, 0, 28)
    df.BackgroundTransparency = 1
    df.Parent = parent
    df.ClipsDescendants = false

    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(0.44, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = T.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = df

    local selected = default or opts[1] or ""

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.54, 0, 1, 0)
    btn.Position = UDim2.new(0.46, 0, 0, 0)
    btn.BackgroundColor3 = T.Input
    btn.TextColor3 = T.Text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Text = selected .. "  ▾"
    btn.BorderSizePixel = 0
    btn.Parent = df
    UICorner(5, btn)
    UIStroke(T.Border, 1, btn)

    local list = Instance.new("Frame")
    list.Size = UDim2.new(0.54, 0, 0, math.min(#opts, 7) * 24 + 4)
    list.Position = UDim2.new(0.46, 0, 1, 2)
    list.BackgroundColor3 = T.Input
    list.BorderSizePixel = 0
    list.Visible = false
    list.ZIndex = 15
    list.Parent = df
    UICorner(5, list)
    UIStroke(T.Accent, 1, list)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = T.Accent
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ZIndex = 15
    scroll.Parent = list
    UIList(Enum.FillDirection.Vertical, 0, scroll)
    UIPad(2, 2, 2, 2, scroll)

    for _, opt in ipairs(opts) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, 0, 0, 23)
        ob.BackgroundColor3 = T.TabOff
        ob.TextColor3 = T.Text
        ob.Font = Enum.Font.Gotham
        ob.TextSize = 11
        ob.Text = opt
        ob.BorderSizePixel = 0
        ob.ZIndex = 16
        ob.Parent = scroll
        UICorner(4, ob)
        ob.MouseButton1Click:Connect(function()
            selected = opt
            btn.Text = opt .. "  ▾"
            list.Visible = false
            if cb then pcall(cb, opt) end
        end)
        ob.MouseEnter:Connect(function()
            TweenService:Create(ob, TweenInfo.new(0.08), {BackgroundColor3 = T.TabHover}):Play()
        end)
        ob.MouseLeave:Connect(function()
            TweenService:Create(ob, TweenInfo.new(0.08), {BackgroundColor3 = T.TabOff}):Play()
        end)
    end

    btn.MouseButton1Click:Connect(function() list.Visible = not list.Visible end)
    UserInputService.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 and list.Visible then
            -- close if clicking outside
            task.wait()
            if not btn:IsDescendantOf(game) then return end
            local mPos = UserInputService:GetMouseLocation()
            local listPos  = list.AbsolutePosition
            local listSize = list.AbsoluteSize
            if mPos.X < listPos.X or mPos.X > listPos.X + listSize.X or
               mPos.Y < listPos.Y or mPos.Y > listPos.Y + listSize.Y then
                list.Visible = false
            end
        end
    end)

    return {Get = function() return selected end, Set = function(v) selected = v; btn.Text = v.."  ▾" end}
end

-- Label
function AstraUI:Label(parent, text, col)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.Size = UDim2.new(1, 0, 0, 18)
    l.AutomaticSize = Enum.AutomaticSize.Y
    l.BackgroundTransparency = 1
    l.TextColor3 = col or T.Sub
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Parent = parent
    return l
end

-- Input
function AstraUI:Input(parent, label, placeholder, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Text = label
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = T.Text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.58, 0, 1, 0)
    box.Position = UDim2.new(0.42, 0, 0, 0)
    box.BackgroundColor3 = T.Input
    box.TextColor3 = T.Text
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = T.Sub
    box.Font = Enum.Font.Gotham
    box.TextSize = 11
    box.Text = ""
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Parent = row
    UICorner(5, box)
    UIStroke(T.Border, 1, box)

    box.FocusLost:Connect(function(enter) if enter and cb then pcall(cb, box.Text) end end)
    return box
end

-- =============================================
-- [[ BUILD UI ]]
-- =============================================
local UI = AstraUI.new()

-- Toggle key
UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == S.ToggleKey then
        UI.MainFrame.Visible = not UI.MainFrame.Visible
    end
end)

-- =============================================
-- [[ DATA TABLES ]]
-- =============================================
local Islands = {
    -- First Sea
    {n="Marine Starter",    p=Vector3.new(-1268,  6,  -104)},
    {n="Middle Town",       p=Vector3.new(290,   15,  1580)},
    {n="Jungle",            p=Vector3.new(-1795, 13,   206)},
    {n="Pirate Village",    p=Vector3.new(-2490,  8, -1500)},
    {n="Desert",            p=Vector3.new(938,   26,  4080)},
    {n="Snow Mountain",     p=Vector3.new(-2609,228,  3218)},
    {n="Marine Fortress",   p=Vector3.new(-4818,  8, -2247)},
    {n="Skylands",          p=Vector3.new(-4826,883, -1420)},
    {n="Prison",            p=Vector3.new(4718,   6, -3293)},
    {n="Colosseum",         p=Vector3.new(926,    7, -4319)},
    {n="Magma Village",     p=Vector3.new(-4889, 10,  4040)},
    {n="Upper Skylands",    p=Vector3.new(-5000,1032,-1420)},
    {n="Ice Castle",        p=Vector3.new(-2245,226,  3680)},
    {n="Fountain City",     p=Vector3.new(3600,   6,   900)},
    -- Second Sea
    {n="Kingdom of Rose",   p=Vector3.new(-188,   6, -3282)},
    {n="Green Zone",        p=Vector3.new(3055,  13, -4920)},
    {n="Graveyard",         p=Vector3.new(-3348,  6, -3800)},
    {n="Snow Island S2",    p=Vector3.new(1049,   6, -5200)},
    {n="Hot and Cold",      p=Vector3.new(-3500,  8, -5000)},
    {n="Cursed Ship",       p=Vector3.new(1550,   2, -3340)},
    {n="Ice Cream Island",  p=Vector3.new(2480,   6, -5400)},
    {n="Forgotten Island",  p=Vector3.new(-3760,  6, -5890)},
    {n="Dark Arena",        p=Vector3.new(1540,   2, -5520)},
    {n="Usoapp Island",     p=Vector3.new(-680,   6, -5750)},
    {n="Floating Turtle",   p=Vector3.new(4000,   6, -6500)},
    -- Third Sea
    {n="Port Town",         p=Vector3.new(-4900,  6,  1100)},
    {n="Hydra Island",      p=Vector3.new(-3800,  8,  6700)},
    {n="Great Tree",        p=Vector3.new(1600,   6,  5700)},
    {n="Floating Root",     p=Vector3.new(3500,   8,  5800)},
    {n="Castle on the Sea", p=Vector3.new(-800,   6,  8600)},
    {n="Icy Grid",          p=Vector3.new(5000,   6,  5000)},
    {n="Tidal Flat",        p=Vector3.new(-5500,  6,  5500)},
    {n="Sea of Treats",     p=Vector3.new(0,      6, 10500)},
}

local IslandNames = {}
for _, v in ipairs(Islands) do table.insert(IslandNames, v.n) end

local Bosses = {
    "Bobby","Yeti","Chief Petty Officer","Saber Expert","Magma Admiral",
    "Golden Boss","Jeremy","Greybeard","Wysper","Thunder God",
    "Cyborg","Dark Master","Cake Queen","Ice Admiral","Order",
    "Carbine","Longma","Rip_Indra","Soul Reaper","Captain Elephant",
    "Beautiful Pirate","Shanks","Kilo Admiral","Clown","Cake Prince Boss",
    "Dragon Crew Captain","Cursed Captain",
}

local Monsters = {
    "Bandit","Monkey","Gorilla","Pirate","Desert Bandit","Snow Bandit",
    "Toga Warrior","Arctic Warrior","Prison Guard","Gladiator",
    "Magma Ninja","Sky Castaway","Fishman","Fishman Lord",
    "Cocoa Warrior","Candy Rebel","Cake Guard","Ice Cream Marine",
    "Marine Recruit","Marine Soldier","Marine Lieutenant","Marine Captain",
    "Dragon","Sea Soldier","Reef Bandit","Carbine Soldier","Toad",
    "Forest Pirate","Diamond Sword Warrior","Mythological Pirate",
}

local RaidTypes = {"Darkbeard","Factory","Cake Prince","Dough King","Elite Hunter","Hydra","Mirror Fractal"}
local StatTypes = {"Melee","Defense","Sword","Gun","BloxFruit"}
local FarmModes = {"Nearest","Highest Level","Specific"}
local FarmTypes = {"Level","Mastery","Fruit","Bone","Cake","Material","Boss","Chest"}

-- Quest NPC positions (representative — adapt if game updates)
local QuestNPCs = {
    ["Marine Starter"]  = Vector3.new(-1255, 7,  -95),
    ["Middle Town"]     = Vector3.new(295,  16, 1612),
    ["Jungle"]          = Vector3.new(-1790,14,  200),
    ["Pirate Village"]  = Vector3.new(-2480, 9,-1495),
    ["Desert"]          = Vector3.new(945,  27, 4075),
    ["Snow Mountain"]   = Vector3.new(-2600,229,3210),
    ["Marine Fortress"] = Vector3.new(-4810, 9,-2240),
    ["Kingdom of Rose"] = Vector3.new(-182,  9,-3275),
    ["Port Town"]       = Vector3.new(-4892, 9, 1108),
    ["Hydra Island"]    = Vector3.new(-3790, 9, 6710),
}

-- =============================================
-- [[ TABS ]]
-- =============================================

-- ─────────── MAIN TAB ───────────
local mainTab = UI:Tab("Main", "⚔")
local secFarmType = UI:Section(mainTab, "Farm Settings")
UI:Dropdown(secFarmType, "Farm Type",  FarmTypes,  "Level", function(v) S.AutoFarmType  = v end)
UI:Dropdown(secFarmType, "Farm Mode",  FarmModes,  "Nearest", function(v) S.FarmTarget  = v end)
UI:Dropdown(secFarmType, "Monster",    Monsters,   Monsters[1], function(v) S.SelectedMonster = v end)
UI:Dropdown(secFarmType, "Island",     IslandNames,IslandNames[1], function(v) S.SelectedIsland = v end)

local secAutoFarm = UI:Section(mainTab, "Auto Farm")
UI:Toggle(secAutoFarm, "Auto Farm",        false, function(v) S.AutoFarm = v end)
UI:Toggle(secAutoFarm, "Auto Quest",       false, function(v) S.AutoQuest = v end)
UI:Toggle(secAutoFarm, "Auto Stats",       false, function(v) S.AutoStats = v end)
UI:Dropdown(secAutoFarm, "Stats Type", StatTypes, "BloxFruit", function(v) S.StatsType = v end)
UI:Toggle(secAutoFarm, "Fast Attack",      false, function(v) S.FastAttack = v end)
UI:Toggle(secAutoFarm, "Bring Mob",        false, function(v) S.BringMob   = v end)
UI:Toggle(secAutoFarm, "Magnet (Pull)",    false, function(v) S.Magnet     = v end)

local secHaki = UI:Section(mainTab, "Haki")
UI:Toggle(secHaki, "Auto Buso Haki",       false, function(v) S.AutoHaki        = v end)
UI:Toggle(secHaki, "Auto Observation",     false, function(v) S.AutoObservation  = v end)
UI:Toggle(secHaki, "Auto Observation V2",  false, function(v) S.AutoObsV2        = v end)
UI:Slider(mainTab.Frame, "Tween Speed (x10)", 1, 30, 4, function(v) S.TweenSpeed = v / 10 end)

-- ─────────── PLAYER TAB ───────────
local playerTab = UI:Tab("Player", "👤")

local secPvP = UI:Section(playerTab, "PvP")
UI:Toggle(secPvP, "Kill Aura",       false, function(v) S.KillAura    = v end)
UI:Toggle(secPvP, "Aimbot",          false, function(v) S.Aimbot      = v end)
UI:Toggle(secPvP, "Silent Aim",      false, function(v) S.SilentAim   = v end)
UI:Toggle(secPvP, "Auto Skill Spam", false, function(v) S.AutoSkillSpam = v end)
UI:Toggle(secPvP, "Bring Player",    false, function(v) S.BringPlayer  = v end)

local secESPPlayer = UI:Section(playerTab, "ESP Player")
UI:Toggle(secESPPlayer, "ESP Player",     false, function(v) S.ESPPlayer      = v end)
UI:Toggle(secESPPlayer, "Show Name",      true,  function(v) S.ESPPlayerName  = v end)
UI:Toggle(secESPPlayer, "Show Distance",  true,  function(v) S.ESPPlayerDist  = v end)
UI:Toggle(secESPPlayer, "Show Health",    true,  function(v) S.ESPPlayerHP    = v end)
UI:Toggle(secESPPlayer, "Show Tool",      false, function(v) S.ESPPlayerTool  = v end)
UI:Toggle(secESPPlayer, "Tracers",        false, function(v) S.ESPPlayerTracer = v end)

local secMove = UI:Section(playerTab, "Movement")
UI:Toggle(secMove, "Speed Hack",      false, function(v)
    S.SpeedHack = v
    if not v then pcall(function() LP.Character.Humanoid.WalkSpeed = 16 end) end
end)
UI:Slider(secMove, "Walk Speed", 16, 600, 16, function(v)
    S.Speed = v
    if S.SpeedHack then pcall(function() LP.Character.Humanoid.WalkSpeed = v end) end
end)
UI:Toggle(secMove, "Fly",             false, function(v) S.FlyEnabled    = v end)
UI:Slider(secMove, "Fly Speed", 20, 400, 80, function(v) S.FlySpeed = v end)
UI:Toggle(secMove, "Infinite Jump",   false, function(v) S.InfiniteJump  = v end)
UI:Toggle(secMove, "No Clip",         false, function(v) S.NoClip        = v end)

local secGod = UI:Section(playerTab, "Protection")
UI:Toggle(secGod, "God Mode",         false, function(v) S.GodMode       = v end)
UI:Toggle(secGod, "Anti Knockback",   false, function(v) S.AntiKnockback = v end)
UI:Toggle(secGod, "Infinite Energy",  false, function(v) S.InfiniteEnergy = v end)
UI:Toggle(secGod, "Infinite Stamina", false, function(v) S.InfiniteStamina = v end)
UI:Toggle(secGod, "No Fall Damage",   false, function(v) S.NoFallDamage  = v end)

-- ─────────── FRUIT TAB ───────────
local fruitTab = UI:Tab("Fruit", "🍎")

local secFruitFarm = UI:Section(fruitTab, "Fruit Farm")
UI:Toggle(secFruitFarm, "Fruit Sniper (Auto Grab)", false, function(v) S.FruitSniper    = v end)
UI:Toggle(secFruitFarm, "Auto Collect Fruit",        false, function(v) S.AutoCollectFruit = v end)
UI:Toggle(secFruitFarm, "Auto Store Fruit",          false, function(v) S.AutoStoreFruit  = v end)
UI:Toggle(secFruitFarm, "Auto Eat Fruit",            false, function(v) S.AutoEatFruit    = v end)
UI:Toggle(secFruitFarm, "Auto Buy Random Fruit",     false, function(v) S.AutoBuyFruit    = v end)
UI:Toggle(secFruitFarm, "Notify Rare Fruit",         true,  function(v) S.NotifyRareFruit = v end)

local secFruitESP = UI:Section(fruitTab, "Fruit ESP")
UI:Toggle(secFruitESP, "Fruit ESP",      false, function(v) S.ESPFruit     = v end)
UI:Toggle(secFruitESP, "Show Name",      true,  function(v) S.ESPFruitName = v end)
UI:Toggle(secFruitESP, "Show Distance",  true,  function(v) S.ESPFruitDist = v end)

local secFruitMgr = UI:Section(fruitTab, "Inventory")
UI:Button(secFruitMgr, "Auto Equip Best Fruit", function()
    pcall(function()
        for _, item in ipairs(LP.Backpack:GetChildren()) do
            if item:FindFirstChild("FruitName") or item.Name:find("Fruit") then
                FireRemote("EquipFruit", item)
                Notify("Astra Hub", "Equipped: " .. item.Name, 2)
                break
            end
        end
    end)
end)
UI:Button(secFruitMgr, "Store All Fruits", function()
    pcall(function()
        for _, item in ipairs(LP.Backpack:GetChildren()) do
            if item:FindFirstChild("FruitName") or item.Name:find("Fruit") then
                FireRemote("StoreFruit", item)
                FireRemote("StoreFruitInChest", item)
            end
        end
        Notify("Astra Hub", "All fruits stored", 2)
    end)
end)

-- ─────────── SEA / RAID TAB ───────────
local seaTab = UI:Tab("Sea/Raid", "🌊")

local secSea = UI:Section(seaTab, "Sea Beast")
UI:Toggle(secSea, "Auto Sea Beast Farm",    false, function(v) S.AutoSeaBeast      = v end)
UI:Toggle(secSea, "Auto Summon Sea Beast",  false, function(v) S.AutoSummonSeaBeast = v end)

local secRaid = UI:Section(seaTab, "Raid")
UI:Dropdown(secRaid, "Raid Type", RaidTypes, "Darkbeard", function(v) S.RaidType = v end)
UI:Toggle(secRaid, "Auto Raid",         false, function(v) S.AutoRaid      = v end)
UI:Toggle(secRaid, "Auto Start Raid",   false, function(v) S.AutoStartRaid = v end)

local secBoss = UI:Section(seaTab, "Boss Farm")
UI:Toggle(secBoss, "Auto Boss Farm",    false, function(v) S.AutoBoss        = v end)
UI:Toggle(secBoss, "Auto Elite Hunter", false, function(v) S.AutoEliteHunter = v end)
UI:Dropdown(secBoss, "Boss Target", Bosses, Bosses[1], function(v) S.SelectedBoss = v end)

local secEvent = UI:Section(seaTab, "Event / Special")
UI:Toggle(secEvent, "Auto Dough King",      false, function(v) S.AutoDoughKing    = v end)
UI:Toggle(secEvent, "Auto Cake Prince",     false, function(v) S.AutoCakeEvent    = v end)
UI:Toggle(secEvent, "Auto Mirror Fractal",  false, function(v) S.AutoMirrorFractal = v end)
UI:Toggle(secEvent, "Auto Material Farm",   false, function(v) S.AutoMaterialFarm  = v end)
UI:Toggle(secEvent, "Auto Fully Awakened",  false, function(v) S.AutoFullyAwakened  = v end)

-- ─────────── TELEPORT TAB ───────────
local tpTab = UI:Tab("Teleport", "🌀")

local secIslandTP = UI:Section(tpTab, "Island Teleport")
for _, isle in ipairs(Islands) do
    UI:Button(secIslandTP, isle.n, function()
        pcall(function()
            local hrp = getHRP()
            if hrp then hrp.CFrame = CFrame.new(isle.p + Vector3.new(0, 5, 0)) end
        end)
        Notify("Astra Hub", "→ " .. isle.n, 2)
    end)
end

local secPlayerTP = UI:Section(tpTab, "Player Teleport")
local pList = {"(refresh)"}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(pList, p.Name) end
end
local pDrop = UI:Dropdown(secPlayerTP, "Select Player", pList, pList[1], function() end)

UI:Button(secPlayerTP, "Refresh List", function()
    -- dropdown rebuilds on re-open; this notifies user
    Notify("Astra Hub", "Re-open dropdown to see updated list", 3)
end)
UI:Button(secPlayerTP, "Teleport to Player", function()
    local name = pDrop.Get()
    local target = Players:FindFirstChild(name)
    if target and target.Character then
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        if tHRP then
            pcall(function()
                local hrp = getHRP()
                if hrp then hrp.CFrame = tHRP.CFrame + Vector3.new(4, 0, 0) end
            end)
            Notify("Astra Hub", "→ " .. name, 2)
        end
    end
end)
UI:Button(secPlayerTP, "Bring Player Here", function()
    local name = pDrop.Get()
    local target = Players:FindFirstChild(name)
    if target and target.Character then
        local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
        local hrp  = getHRP()
        if tHRP and hrp then
            pcall(function() tHRP.CFrame = hrp.CFrame + Vector3.new(3, 0, 0) end)
        end
    end
end)

local secUtilTP = UI:Section(tpTab, "Server Utility")
UI:Button(secUtilTP, "Safe Zone", function()
    pcall(function()
        local hrp = getHRP()
        if hrp then hrp.CFrame = CFrame.new(290, 15, 1580) end
    end)
end)
UI:Button(secUtilTP, "Server Hop", function()
    pcall(function()
        local res = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(res)
        for _, srv in ipairs(data.data) do
            if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id)
                return
            end
        end
        Notify("Astra Hub", "No available servers found", 3)
    end)
end)
UI:Button(secUtilTP, "Low Player Server", function()
    pcall(function()
        local res = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(res)
        local best, low = nil, 999
        for _, srv in ipairs(data.data) do
            if srv.id ~= game.JobId and srv.playing < low then
                best, low = srv.id, srv.playing
            end
        end
        if best then TeleportService:TeleportToPlaceInstance(game.PlaceId, best) end
    end)
end)
UI:Slider(secUtilTP, "Tween Speed (x10)", 1, 30, 4, function(v) S.TweenSpeed = v / 10 end)

-- ─────────── MISC TAB ───────────
local miscTab = UI:Tab("Misc", "⚙")

local secUtil = UI:Section(miscTab, "Utility")
UI:Toggle(secUtil, "Anti AFK",            true,  function(v) S.AntiAFK        = v end)
UI:Toggle(secUtil, "FPS Booster",         false, function(v)
    S.FPSBoost = v
    pcall(function()
        settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Level08
    end)
end)
UI:Toggle(secUtil, "Walk on Water",       false, function(v) S.WalkOnWater     = v end)
UI:Toggle(secUtil, "Infinite Jump",       false, function(v) S.InfiniteJump    = v end)
UI:Toggle(secUtil, "No Fall Damage",      false, function(v) S.NoFallDamage    = v end)

local teamDrop = UI:Dropdown(secUtil, "Team", {"Pirates","Marines"}, "Pirates", function(v)
    pcall(function() FireRemote("SelectTeam", v) end)
end)

local codeBox = UI:Input(secUtil, "Redeem Code", "enter code...", nil)
UI:Button(secUtil, "Redeem Code", function()
    local code = codeBox.Text
    if code ~= "" then
        FireRemote("RedeemCode", code)
        Notify("Astra Hub", "Redeemed: " .. code, 3)
    end
end)

local secServer = UI:Section(miscTab, "Server")
UI:Button(secServer, "Rejoin", function()
    TeleportService:Teleport(game.PlaceId)
end)
UI:Button(secServer, "White Screen (2s)", function()
    local f = Instance.new("Frame", LP.PlayerGui)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Color3.new(1,1,1)
    f.BorderSizePixel = 0
    f.ZIndex = 999
    task.delay(2, function() pcall(function() f:Destroy() end) end)
end)
UI:Button(secServer, "Black Screen (2s)", function()
    local f = Instance.new("Frame", LP.PlayerGui)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Color3.new(0,0,0)
    f.BorderSizePixel = 0
    f.ZIndex = 999
    task.delay(2, function() pcall(function() f:Destroy() end) end)
end)

local secChat = UI:Section(miscTab, "Chat / Social")
UI:Toggle(secChat, "Chat Spammer",  false, function(v) S.ChatSpammer = v end)
local chatBox = UI:Input(secChat, "Spam Message", "Astra Hub | discord.gg/astrahub", function(v) S.ChatSpamMsg = v end)
UI:Toggle(secChat, "Kill Say",      false, function(v) S.KillSay     = v end)
local killSayBox = UI:Input(secChat, "Kill Say Msg", "GG ez", function(v) S.KillSayMsg = v end)

local secCfg = UI:Section(miscTab, "Config")
UI:Button(secCfg, "Save Config", function()
    pcall(function()
        writefile("AstraHub_Config.json", HttpService:JSONEncode(S))
        Notify("Astra Hub", "Config saved!", 2)
    end)
end)
UI:Button(secCfg, "Load Config", function()
    pcall(function()
        if isfile("AstraHub_Config.json") then
            local data = HttpService:JSONDecode(readfile("AstraHub_Config.json"))
            for k, v in pairs(data) do S[k] = v end
            Notify("Astra Hub", "Config loaded!", 2)
        else
            Notify("Astra Hub", "No config file found", 2)
        end
    end)
end)
UI:Button(secCfg, "Reset Config", function()
    pcall(function()
        if isfile("AstraHub_Config.json") then delfile("AstraHub_Config.json") end
        Notify("Astra Hub", "Config reset", 2)
    end)
end)

-- ─────────── ESP TAB ───────────
local espTab = UI:Tab("ESP", "👁")

local secESPMob = UI:Section(espTab, "Mob ESP")
UI:Toggle(secESPMob, "Mob ESP",         false, function(v) S.ESPMob      = v end)
UI:Toggle(secESPMob, "Show Name",       true,  function(v) S.ESPMobName  = v end)
UI:Toggle(secESPMob, "Show Distance",   true,  function(v) S.ESPMobDist  = v end)
UI:Toggle(secESPMob, "Show Health",     true,  function(v) S.ESPMobHP    = v end)
UI:Toggle(secESPMob, "Tracers",         false, function(v) S.ESPMobTracer = v end)

local secESPChest = UI:Section(espTab, "Chest ESP")
UI:Toggle(secESPChest, "Chest ESP",     false, function(v) S.ESPChest    = v end)
UI:Toggle(secESPChest, "Show Distance", true,  function(v) S.ESPChestDist = v end)

local secESPFruitT = UI:Section(espTab, "Fruit ESP")
UI:Toggle(secESPFruitT, "Fruit ESP",     false, function(v) S.ESPFruit    = v end)
UI:Toggle(secESPFruitT, "Show Name",     true,  function(v) S.ESPFruitName = v end)
UI:Toggle(secESPFruitT, "Show Distance", true,  function(v) S.ESPFruitDist = v end)

local secESPIsland = UI:Section(espTab, "Island ESP")
UI:Toggle(secESPIsland, "Island ESP",   false, function(v) S.ESPIsland   = v end)

local secESPNPC = UI:Section(espTab, "NPC ESP")
UI:Toggle(secESPNPC, "NPC ESP",         false, function(v) S.ESPNPC      = v end)

local secESPCfg = UI:Section(espTab, "ESP Config")
UI:Slider(secESPCfg, "Max Distance", 100, 5000, 2000, function(v) S.ESPMaxDist  = v end)
UI:Slider(secESPCfg, "Text Size",     8,    24,   14, function(v) S.ESPTextSize = v end)

-- ─────────── SETTINGS TAB ───────────
local settingsTab = UI:Tab("Settings", "🔧")

local secUI = UI:Section(settingsTab, "UI Settings")
local keyOpts = {"RightShift","Insert","Delete","Home","End","F1","F2","F3","F4","F5","Backquote"}
UI:Dropdown(secUI, "Toggle Key", keyOpts, "RightShift", function(v)
    S.ToggleKey = Enum.KeyCode[v]
    Notify("Astra Hub", "Toggle: " .. v, 2)
end)

local secPerf = UI:Section(settingsTab, "Performance")
UI:Toggle(secPerf, "Performance Mode", false, function(v)
    S.PerformanceMode = v
    pcall(function()
        settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Level05
    end)
end)
UI:Toggle(secPerf, "Auto Execute on Rejoin", false, function(v) S.AutoExecRejoin = v end)

local secCredits = UI:Section(settingsTab, "Credits")
UI:Label(secCredits, "✦ Astra Hub  |  Blox Fruits v5.0", T.Accent)
UI:Label(secCredits, "Discord: discord.gg/astrahub")
UI:Label(secCredits, "Build: 2024 • Coded for Roblox executors")
UI:Label(secCredits, "Synapse X  •  KRNL  •  Fluxus compatible")

-- =============================================
-- [[ ESP SYSTEM (Drawing) ]]
-- =============================================
local playerESP, mobESP, fruitESP, chestESP, islandESP = {}, {}, {}, {}, {}

local rareFruits = {
    "Dragon","Leopard","Spirit","Venom","Kitsune","Dough","Shadow",
    "Rumble","Buddha","String","Mammoth","T-Rex","Blizzard",
}

local function w2s(pos)
    local sp, vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), vis, sp.Z
end

local function hpColor(pct)  -- 0-100 → red-green
    return Color3.fromRGB(math.clamp(math.floor(255 * (1 - pct/100)), 0, 255),
                          math.clamp(math.floor(255 * pct/100),        0, 255), 30)
end

local function mkText(sz)
    local d = Drawing.new("Text")
    d.Outline     = true
    d.OutlineColor = Color3.fromRGB(0, 0, 0)
    d.Size        = sz or 14
    d.Font        = 2   -- Plex mono (executor-portable)
    d.Visible     = false
    d.Center      = true
    return d
end

local function mkLine()
    local d = Drawing.new("Line")
    d.Thickness = 1
    d.Visible   = false
    return d
end

local function hideESPTable(t)
    for _, pool in pairs(t) do
        if type(pool) == "table" then
            for _, d in pairs(pool) do
                if d.Remove then d.Visible = false end
            end
        end
    end
end

-- fruit notified cache (prevent spam)
local fruitNotified = {}

RunService.RenderStepped:Connect(function()
    local hrp  = getHRP()
    local hum  = getHum()
    if not hrp or not hum or hum.Health <= 0 then return end

    local cam    = Camera
    local maxD   = S.ESPMaxDist  or 2000
    local tSz    = S.ESPTextSize or 14
    local scSize = cam.ViewportSize

    -- ── PLAYER ESP ──
    if S.ESPPlayer then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl == LP then continue end
            local pChar = pl.Character
            local pHRP  = pChar and pChar:FindFirstChild("HumanoidRootPart")
            local pHum  = pChar and pChar:FindFirstChildWhichIsA("Humanoid")
            if not pHRP or not pHum then continue end

            local dist = (hrp.Position - pHRP.Position).Magnitude
            if dist > maxD then continue end

            local id = pl.UserId
            if not playerESP[id] then
                playerESP[id] = {
                    name   = mkText(tSz),
                    dist   = mkText(tSz - 2),
                    hp     = mkText(tSz - 2),
                    tracer = mkLine(),
                }
            end

            local e = playerESP[id]
            local sp, vis = w2s(pHRP.Position + Vector3.new(0, 3, 0))
            local yOff = 0

            if S.ESPPlayerName then
                e.name.Text     = pl.DisplayName
                e.name.Color    = Color3.fromRGB(255, 70, 70)
                e.name.Size     = tSz
                e.name.Position = Vector2.new(sp.X, sp.Y - yOff)
                e.name.Visible  = vis
                yOff = yOff + tSz + 2
            else e.name.Visible = false end

            if S.ESPPlayerDist then
                e.dist.Text     = math.floor(dist) .. "m"
                e.dist.Color    = Color3.fromRGB(190, 190, 190)
                e.dist.Size     = tSz - 2
                e.dist.Position = Vector2.new(sp.X, sp.Y - yOff)
                e.dist.Visible  = vis
                yOff = yOff + (tSz - 2) + 2
            else e.dist.Visible = false end

            if S.ESPPlayerHP then
                local pct = math.clamp(math.floor(pHum.Health / math.max(pHum.MaxHealth, 1) * 100), 0, 100)
                e.hp.Text     = pct .. "% HP"
                e.hp.Color    = hpColor(pct)
                e.hp.Size     = tSz - 2
                e.hp.Position = Vector2.new(sp.X, sp.Y - yOff)
                e.hp.Visible  = vis
            else e.hp.Visible = false end

            if S.ESPPlayerTracer then
                e.tracer.From    = Vector2.new(scSize.X * 0.5, scSize.Y)
                e.tracer.To      = sp
                e.tracer.Color   = Color3.fromRGB(255, 70, 70)
                e.tracer.Visible = vis
            else e.tracer.Visible = false end
        end
    else hideESPTable(playerESP) end

    -- ── MOB ESP ──
    if S.ESPMob then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not (obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj)) then continue end
            local oHRP = obj:FindFirstChild("HumanoidRootPart")
            local oHum = obj:FindFirstChildWhichIsA("Humanoid")
            if not oHRP or not oHum or oHum.Health <= 0 then continue end

            local dist = (hrp.Position - oHRP.Position).Magnitude
            if dist > math.min(maxD, 900) then continue end

            local id = obj:GetDebugId()
            if not mobESP[id] then
                mobESP[id] = {
                    name   = mkText(tSz - 2),
                    dist   = mkText(tSz - 3),
                    hp     = mkText(tSz - 3),
                    tracer = mkLine(),
                }
            end

            local e = mobESP[id]
            local sp, vis = w2s(oHRP.Position + Vector3.new(0, 3.5, 0))
            local yOff = 0

            if S.ESPMobName then
                e.name.Text     = obj.Name
                e.name.Color    = Color3.fromRGB(60, 230, 90)
                e.name.Size     = tSz - 2
                e.name.Position = Vector2.new(sp.X, sp.Y - yOff)
                e.name.Visible  = vis
                yOff = yOff + (tSz - 2) + 2
            else e.name.Visible = false end

            if S.ESPMobDist then
                e.dist.Text     = math.floor(dist) .. "m"
                e.dist.Color    = Color3.fromRGB(170, 170, 170)
                e.dist.Size     = tSz - 3
                e.dist.Position = Vector2.new(sp.X, sp.Y - yOff)
                e.dist.Visible  = vis
                yOff = yOff + (tSz - 3) + 2
            else e.dist.Visible = false end

            if S.ESPMobHP then
                local pct = math.clamp(math.floor(oHum.Health / math.max(oHum.MaxHealth, 1) * 100), 0, 100)
                e.hp.Text     = pct .. "%"
                e.hp.Color    = hpColor(pct)
                e.hp.Size     = tSz - 3
                e.hp.Position = Vector2.new(sp.X, sp.Y - yOff)
                e.hp.Visible  = vis
            else e.hp.Visible = false end

            if S.ESPMobTracer then
                e.tracer.From    = Vector2.new(scSize.X * 0.5, scSize.Y)
                e.tracer.To      = sp
                e.tracer.Color   = Color3.fromRGB(60, 230, 90)
                e.tracer.Visible = vis
            else e.tracer.Visible = false end
        end
    else hideESPTable(mobESP) end

    -- ── FRUIT ESP ──
    if S.ESPFruit then
        local function scanFruits(folder)
            if not folder then return end
            for _, fruit in ipairs(folder:GetChildren()) do
                local part = fruit:FindFirstChildWhichIsA("BasePart")
                if not part then continue end
                local dist = (hrp.Position - part.Position).Magnitude
                if dist > maxD then continue end

                local id = fruit:GetDebugId()
                if not fruitESP[id] then
                    fruitESP[id] = {
                        name = mkText(tSz),
                        dist = mkText(tSz - 2),
                    }
                end

                local e = fruitESP[id]
                local sp, vis = w2s(part.Position + Vector3.new(0, 2.5, 0))
                local yOff = 0

                if S.ESPFruitName then
                    e.name.Text     = "🍎 " .. fruit.Name
                    e.name.Color    = Color3.fromRGB(255, 215, 0)
                    e.name.Size     = tSz
                    e.name.Position = Vector2.new(sp.X, sp.Y - yOff)
                    e.name.Visible  = vis
                    yOff = yOff + tSz + 2
                else e.name.Visible = false end

                if S.ESPFruitDist then
                    e.dist.Text     = math.floor(dist) .. "m"
                    e.dist.Color    = Color3.fromRGB(200, 200, 200)
                    e.dist.Size     = tSz - 2
                    e.dist.Position = Vector2.new(sp.X, sp.Y - yOff)
                    e.dist.Visible  = vis
                else e.dist.Visible = false end

                -- Rare fruit notify
                if S.NotifyRareFruit and not fruitNotified[id] then
                    for _, rare in ipairs(rareFruits) do
                        if fruit.Name:find(rare) then
                            fruitNotified[id] = true
                            Notify("⚠ RARE FRUIT SPAWNED", fruit.Name .. " — " .. math.floor(dist) .. "m away!", 8)
                            break
                        end
                    end
                end
            end
        end

        pcall(function() scanFruits(Workspace:FindFirstChild("StoredFruits")) end)
        pcall(function() scanFruits(Workspace:FindFirstChild("Fruits")) end)
    else hideESPTable(fruitESP) end

    -- ── CHEST ESP ──
    if S.ESPChest then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not (obj:IsA("Model") and obj.Name:lower():find("chest")) then continue end
            local part = obj:FindFirstChildWhichIsA("BasePart")
            if not part then continue end
            local dist = (hrp.Position - part.Position).Magnitude
            if dist > maxD then continue end

            local id = obj:GetDebugId()
            if not chestESP[id] then
                chestESP[id] = {
                    name = mkText(tSz),
                    dist = mkText(tSz - 2),
                }
            end

            local e = chestESP[id]
            local sp, vis = w2s(part.Position + Vector3.new(0, 2, 0))

            e.name.Text     = "📦 Chest"
            e.name.Color    = Color3.fromRGB(100, 200, 255)
            e.name.Size     = tSz
            e.name.Position = Vector2.new(sp.X, sp.Y - 14)
            e.name.Visible  = vis

            if S.ESPChestDist then
                e.dist.Text     = math.floor(dist) .. "m"
                e.dist.Color    = Color3.fromRGB(190, 190, 190)
                e.dist.Size     = tSz - 2
                e.dist.Position = Vector2.new(sp.X, sp.Y)
                e.dist.Visible  = vis
            else e.dist.Visible = false end
        end
    else hideESPTable(chestESP) end

    -- ── ISLAND ESP ──
    if S.ESPIsland then
        for _, isle in ipairs(Islands) do
            local id = isle.n
            if not islandESP[id] then
                islandESP[id] = mkText(tSz)
            end
            local dist = (hrp.Position - isle.p).Magnitude
            if dist <= maxD * 2 then
                local sp, vis = w2s(isle.p + Vector3.new(0, 8, 0))
                islandESP[id].Text     = "◆ " .. isle.n .. " (" .. math.floor(dist) .. "m)"
                islandESP[id].Color    = Color3.fromRGB(180, 140, 255)
                islandESP[id].Size     = tSz - 1
                islandESP[id].Position = sp
                islandESP[id].Visible  = vis
            else
                islandESP[id].Visible = false
            end
        end
    else
        for _, d in pairs(islandESP) do
            if d.Remove then d.Visible = false end
        end
    end
end)

-- =============================================
-- [[ FLY SYSTEM ]]
-- =============================================
local bv, bg, flyConn
local flyActive = false

local function startFly()
    if flyActive then return end
    flyActive = true
    pcall(function()
        local char = LP.Character
        local hrp2 = char.HumanoidRootPart

        bv = Instance.new("BodyVelocity", hrp2)
        bv.Velocity  = Vector3.new(0, 0, 0)
        bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)

        bg = Instance.new("BodyGyro", hrp2)
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.P         = 1e4

        flyConn = RunService.RenderStepped:Connect(function()
            if not S.FlyEnabled then
                pcall(function() bv:Destroy() bg:Destroy() end)
                flyConn:Disconnect()
                flyActive = false
                return
            end
            pcall(function()
                local spd = S.FlySpeed or 80
                local cf  = Camera.CFrame
                local vel = Vector3.zero
                local UIS = UserInputService

                if UIS:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector * spd end
                if UIS:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector * spd end
                if UIS:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector * spd end
                if UIS:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector * spd end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then      vel = vel + Vector3.yAxis * spd end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.yAxis * spd end

                bv.Velocity = vel
                bg.CFrame   = cf
            end)
        end)
    end)
end

RunService.Heartbeat:Connect(function()
    if S.FlyEnabled and not flyActive then startFly() end
end)

-- =============================================
-- [[ MOVEMENT LOOPS ]]
-- =============================================

-- No clip
RunService.Stepped:Connect(function()
    if not S.NoClip then return end
    pcall(function()
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end)

-- Infinite jump
UserInputService.JumpRequest:Connect(function()
    if S.InfiniteJump then
        pcall(function() LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

-- Speed hack
RunService.Heartbeat:Connect(function()
    if not S.SpeedHack then return end
    pcall(function() LP.Character.Humanoid.WalkSpeed = S.Speed end)
end)

-- God mode
RunService.Heartbeat:Connect(function()
    if not S.GodMode then return end
    pcall(function()
        local hum = LP.Character and LP.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
    end)
end)

-- Anti knockback — destroy stray BodyVelocity instances
RunService.Heartbeat:Connect(function()
    if not S.AntiKnockback then return end
    pcall(function()
        local hrp2 = getHRP()
        if not hrp2 then return end
        for _, inst in ipairs(hrp2:GetChildren()) do
            if (inst:IsA("BodyVelocity") or inst:IsA("BodyForce")) and inst ~= bv then
                inst:Destroy()
            end
        end
    end)
end)

-- Infinite energy / stamina
RunService.Heartbeat:Connect(function()
    if not (S.InfiniteEnergy or S.InfiniteStamina) then return end
    pcall(function()
        local stats = LP.Character and LP.Character:FindFirstChild("Stats")
        if not stats then return end
        for _, v in ipairs(stats:GetChildren()) do
            if v:IsA("NumberValue") then
                local n = v.Name:lower()
                if S.InfiniteEnergy and (n:find("energy") or n:find("mana")) then
                    v.Value = 99999
                end
                if S.InfiniteStamina and n:find("stamina") then
                    v.Value = 99999
                end
            end
        end
    end)
end)

-- Walk on water
RunService.Stepped:Connect(function()
    if not S.WalkOnWater then return end
    pcall(function()
        for _, w in ipairs(Workspace:GetDescendants()) do
            if w:IsA("BasePart") and (w.Name == "Water" or w.Name:lower():find("ocean")) then
                w.CanCollide = true
            end
        end
    end)
end)

-- No fall damage
RunService.Heartbeat:Connect(function()
    if not S.NoFallDamage then return end
    pcall(function()
        local hum = getHum()
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end)
end)

-- Anti AFK
LP.Idled:Connect(function()
    if S.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
    end
end)

-- Kill Aura
RunService.Heartbeat:Connect(function()
    if not S.KillAura then return end
    pcall(function()
        local hrp2 = getHRP()
        if not hrp2 then return end
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl == LP then continue end
            local pHRP = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
            if pHRP and (hrp2.Position - pHRP.Position).Magnitude < 65 then
                FireRemote("UpdatePlayerActionPrimary")
                FireRemote("Punch")
            end
        end
    end)
end)

-- =============================================
-- [[ FARM SYSTEM ]]
-- =============================================

local function findNearestMob()
    local hrp2 = getHRP()
    if not hrp2 then return nil end

    local best, bestDist = nil, math.huge

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not (obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj)) then continue end
        local oHRP = obj:FindFirstChild("HumanoidRootPart")
        local oHum = obj:FindFirstChildWhichIsA("Humanoid")
        if not oHRP or not oHum or oHum.Health <= 0 then continue end

        local nameMatch = S.SelectedMonster == "" or
                          obj.Name:lower():find(S.SelectedMonster:lower()) ~= nil

        if not nameMatch then continue end

        local d = (hrp2.Position - oHRP.Position).Magnitude
        if d < bestDist then
            best, bestDist = obj, d
        end
    end

    return best
end

local function findBoss(bossName)
    bossName = bossName or S.SelectedBoss
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local hum = obj:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.Health > 0 and obj.Name:lower():find(bossName:lower()) then
                return obj
            end
        end
    end
    return nil
end

local function attackTarget(target)
    if not target then return end
    pcall(function()
        local tHRP = target:FindFirstChild("HumanoidRootPart")
        local tHum = target:FindFirstChildWhichIsA("Humanoid")
        if not tHRP or not tHum or tHum.Health <= 0 then return end

        local hrp2 = getHRP()
        if not hrp2 then return end

        -- Teleport adjacent
        hrp2.CFrame = CFrame.new(tHRP.Position + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))

        -- Bring mob to us if enabled
        if S.BringMob then
            tHRP.CFrame = CFrame.new(hrp2.Position + hrp2.CFrame.LookVector * 5)
        end

        -- Fire attack remotes
        local attackRemotes = {
            "UpdatePlayerActionPrimary", "Punch", "UpdatePlayerAction",
            "PlayerHit", "AttackRemote", "NormalAttack"
        }
        for _, rn in ipairs(attackRemotes) do FireRemote(rn, tHRP.Position) end

        -- Skills
        if S.AutoSkillSpam then
            for i = 1, 4 do FireRemote("UseSkill", i) end
        end

        if S.FastAttack then task.wait(0.02) else task.wait(0.08) end
    end)
end

local function takeQuest()
    local questPos = QuestNPCs[S.SelectedIsland]
    if not questPos then return end
    pcall(function()
        local hrp2 = getHRP()
        if not hrp2 then return end
        hrp2.CFrame = CFrame.new(questPos + Vector3.new(0, 3, 0))
        task.wait(0.6)

        -- Interact with any nearby quest NPCs
        for _, npc in ipairs(Workspace:GetDescendants()) do
            if npc:IsA("Model") then
                local nHRP = npc:FindFirstChild("HumanoidRootPart")
                if nHRP and (nHRP.Position - hrp2.Position).Magnitude < 25 then
                    if npc.Name:lower():find("quest") or npc.Name:lower():find("detective")
                       or npc.Name:lower():find("military") or npc.Name:lower():find("lord") then
                        FireRemote("GetQuest", npc)
                        FireRemote("TakeQuest", npc)
                        task.wait(0.3)
                    end
                end
            end
        end
    end)
end

local function doAutoStats()
    pcall(function()
        local statRemote = Remotes and (Remotes:FindFirstChild("BuyStat") or Remotes:FindFirstChild("IncreaseStat"))
        if statRemote then
            pcall(function() statRemote:FireServer(S.StatsType) end)
        end
        FireRemote("BuyStat", S.StatsType)
    end)
end

-- Main farm loop
task.spawn(function()
    while task.wait(0.12) do
        if not S.AutoFarm then continue end
        pcall(function()
            local hum2 = getHum()
            if not hum2 or hum2.Health <= 0 then return end

            -- Auto quest check
            if S.AutoQuest then
                local stats = LP.Character and LP.Character:FindFirstChild("Stats")
                local qc = stats and stats:FindFirstChild("QuestCount")
                if qc and qc.Value == 0 then
                    takeQuest()
                    task.wait(1.2)
                end
            end

            -- Auto stats
            if S.AutoStats then doAutoStats() end

            -- Find and attack mob
            local target = findNearestMob()
            if not target then return end

            local tHRP = target:FindFirstChild("HumanoidRootPart")
            local tHum = target:FindFirstChildWhichIsA("Humanoid")
            if not tHRP or not tHum or tHum.Health <= 0 then return end

            local hrp2 = getHRP()
            if not hrp2 then return end

            local dist = (hrp2.Position - tHRP.Position).Magnitude

            -- Magnet (pull mob to player)
            if S.Magnet then
                pcall(function() tHRP.CFrame = CFrame.new(hrp2.Position + hrp2.CFrame.LookVector * 4) end)
            end

            -- Tween to mob if far
            if dist > 7 then
                local tw = TweenService:Create(hrp2, TweenInfo.new(S.TweenSpeed, Enum.EasingStyle.Linear),
                    {CFrame = CFrame.new(tHRP.Position + Vector3.new(0, 2, 0))})
                tw:Play()
                if S.TweenSpeed > 0.15 then tw.Completed:Wait() end
            end

            attackTarget(target)

            -- Haki in-loop
            if S.AutoHaki       then FireRemote("Buso_Haki"); FireRemote("ActivateHaki","Buso") end
            if S.AutoObservation then FireRemote("Observation"); FireRemote("ActivateHaki","Ken") end
        end)
    end
end)

-- Haki standalone loop
task.spawn(function()
    while task.wait(1.2) do
        if S.AutoHaki        then FireRemote("Buso_Haki"); FireRemote("ActivateHaki","Buso") end
        if S.AutoObservation then FireRemote("Observation"); FireRemote("Ken_Haki"); FireRemote("ActivateHaki","Ken") end
        if S.AutoObsV2       then FireRemote("Observation_V2") end
    end
end)

-- Boss farm loop
task.spawn(function()
    while task.wait(0.2) do
        if not S.AutoBoss then continue end
        pcall(function()
            local boss = findBoss(S.SelectedBoss)
            if boss then attackTarget(boss) end
        end)
    end
end)

-- Sea beast loop
task.spawn(function()
    while task.wait(0.5) do
        if not S.AutoSeaBeast then continue end
        pcall(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and
                   (obj.Name:find("Sea") or obj.Name:find("SeaBeast") or obj.Name == "Sea Beast") then
                    local oHum = obj:FindFirstChildWhichIsA("Humanoid")
                    if oHum and oHum.Health > 0 then
                        attackTarget(obj)
                        break
                    end
                end
            end
            if S.AutoSummonSeaBeast then
                FireRemote("SpawnSeaBeast")
                FireRemote("SummonSeaBeast")
            end
        end)
    end
end)

-- Raid loop
task.spawn(function()
    while task.wait(0.5) do
        if not S.AutoRaid then continue end
        pcall(function()
            if S.AutoStartRaid then
                FireRemote("StartRaid", S.RaidType)
            end
            -- Attack raid mobs
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") then
                    local oHum = obj:FindFirstChildWhichIsA("Humanoid")
                    if oHum and oHum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                        attackTarget(obj)
                    end
                end
            end
        end)
    end
end)

-- Fruit sniper loop
task.spawn(function()
    while task.wait(0.15) do
        if not S.FruitSniper then continue end
        pcall(function()
            local function tryGrab(folder)
                if not folder then return end
                for _, fruit in ipairs(folder:GetChildren()) do
                    local part = fruit:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local hrp2 = getHRP()
                        if hrp2 then
                            hrp2.CFrame = CFrame.new(part.Position)
                            task.wait(0.06)
                            FireRemote("CollectFruit", fruit)
                            FireRemote("PickupFruit", fruit)
                        end
                    end
                end
            end
            tryGrab(Workspace:FindFirstChild("StoredFruits"))
            tryGrab(Workspace:FindFirstChild("Fruits"))
        end)
    end
end)

-- Auto collect fruit
task.spawn(function()
    while task.wait(0.3) do
        if not S.AutoCollectFruit then continue end
        pcall(function()
            local function tryCollect(folder)
                if not folder then return end
                local hrp2 = getHRP()
                if not hrp2 then return end
                for _, fruit in ipairs(folder:GetChildren()) do
                    local part = fruit:FindFirstChildWhichIsA("BasePart")
                    if part and (hrp2.Position - part.Position).Magnitude < 3000 then
                        hrp2.CFrame = CFrame.new(part.Position)
                        task.wait(0.08)
                        FireRemote("CollectFruit", fruit)
                        FireRemote("PickupFruit", fruit)
                    end
                end
            end
            tryCollect(Workspace:FindFirstChild("StoredFruits"))
            tryCollect(Workspace:FindFirstChild("Fruits"))
        end)
    end
end)

-- Auto store fruit
task.spawn(function()
    while task.wait(1.5) do
        if not S.AutoStoreFruit then continue end
        pcall(function()
            for _, item in ipairs(LP.Backpack:GetChildren()) do
                if item:FindFirstChild("FruitName") or item.Name:find("Fruit") then
                    FireRemote("StoreFruit", item)
                    FireRemote("StoreFruitInChest", item)
                end
            end
        end)
    end
end)

-- Auto eat fruit
task.spawn(function()
    while task.wait(2) do
        if not S.AutoEatFruit then continue end
        pcall(function()
            for _, item in ipairs(LP.Backpack:GetChildren()) do
                if item:FindFirstChild("FruitName") or item.Name:find("Fruit") then
                    FireRemote("EatFruit", item)
                    break
                end
            end
        end)
    end
end)

-- Auto buy fruit
task.spawn(function()
    while task.wait(3) do
        if not S.AutoBuyFruit then continue end
        pcall(function()
            FireRemote("BuyRandomFruit")
            FireRemote("BuyFruit", "Random")
        end)
    end
end)

-- Chat spammer
task.spawn(function()
    while task.wait(5) do
        if not S.ChatSpammer then continue end
        pcall(function()
            local msg = S.ChatSpamMsg ~= "" and S.ChatSpamMsg or "Astra Hub | discord.gg/astrahub"
            local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
            if chatRemote then
                chatRemote:FireServer(msg, "All")
            end
        end)
    end
end)

-- Kill say
Players.PlayerRemoving:Connect(function(pl)
    if not S.KillSay or pl == LP then return end
    pcall(function()
        local msg = S.KillSayMsg ~= "" and S.KillSayMsg or "GG ez"
        local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
        if chatRemote then chatRemote:FireServer(msg, "All") end
    end)
end)

-- =============================================
-- [[ CHARACTER RESPAWN ]]
-- =============================================
LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 5)
    char:WaitForChild("Humanoid", 5)
    -- Re-apply fly if it was on before death
    if S.FlyEnabled then flyActive = false end
end)

-- =============================================
-- [[ STARTUP ]]
-- =============================================
task.wait(0.8)
Notify("✦ Astra Hub", "v5.0 loaded! " .. S.ToggleKey.Name .. " to toggle UI.", 5)
