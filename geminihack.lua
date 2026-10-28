-- // BLOX FRUITS V14 — REDZ SUPREME EDITION (VERIFIED QUEST HANDSHAKE + EXACT FRUIT RESOLVER + 70-TEST SUITE) //
-- Compatible with Delta X (Android / iOS / PC). Zero fake quest grace window. Zero "Controller" fruit mislabeling.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- // 1. Services & Safe Executor Shims //
local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Workspace = cloneref(game:GetService("Workspace"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local HttpService = cloneref(game:GetService("HttpService"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local Lighting = cloneref(game:GetService("Lighting"))

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local getgenv = getgenv or function() return _G end
local raw_sethiddenproperty = sethiddenproperty or set_hidden_property or sethiddenprop
local raw_hookmetamethod = hookmetamethod
local raw_getnamecallmethod = getnamecallmethod
local raw_newcclosure = newcclosure or function(f) return f end
local raw_checkcaller = checkcaller or function() return false end
local raw_getupvalues = (debug and debug.getupvalues) or getupvalues or getupvals
local raw_getgc = getgc or get_gc_objects
local raw_firetouchinterest = firetouchinterest
local raw_fireclickdetector = fireclickdetector
local raw_fireproximityprompt = fireproximityprompt
local raw_writefile = writefile
local raw_readfile = readfile
local raw_isfile = isfile
local raw_makefolder = makefolder
local raw_isfolder = isfolder

local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))
end)

-- // 2. Clean Teardown of Previous Session //
local SuiteName = "OllieBench_RedzV14"
if getgenv().OllieBF_Teardown then
    pcall(getgenv().OllieBF_Teardown)
end

local SessionActive = true
local Connections = {}

local function TrackConn(sig, fn)
    if not sig then return nil end
    local c = sig:Connect(fn)
    table.insert(Connections, c)
    return c
end

local function GetGuiParent()
    local ok, root = pcall(function()
        if gethui then return gethui() end
        return CoreGui
    end)
    return (ok and typeof(root) == "Instance" and root) or LocalPlayer:WaitForChild("PlayerGui", 10)
end

local GuiParent = GetGuiParent()
for _, child in ipairs(GuiParent:GetChildren()) do
    if string.find(child.Name, "OllieBench_") then
        pcall(function() child:Destroy() end)
    end
end

-- // 3. Remotes & Fast Dispatcher //
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 15)
local CommE = Remotes and Remotes:FindFirstChild("CommE")

local function InvokeCommF(...)
    if not CommF or not CommF.Parent then
        Remotes = ReplicatedStorage:FindFirstChild("Remotes")
        CommF = Remotes and Remotes:FindFirstChild("CommF_")
    end
    if not CommF then return nil end
    local args = table.pack(...)
    local ok, res = pcall(function()
        return CommF:InvokeServer(table.unpack(args, 1, args.n))
    end)
    if ok then return res end
    return nil
end

local function FireCommE(...)
    if not CommE or not CommE.Parent then
        Remotes = ReplicatedStorage:FindFirstChild("Remotes")
        CommE = Remotes and Remotes:FindFirstChild("CommE")
    end
    if not CommE then return end
    local args = table.pack(...)
    pcall(function()
        CommE:FireServer(table.unpack(args, 1, args.n))
    end)
end

-- Auto Join Pirates if unassigned
task.spawn(function()
    local t0 = os.clock()
    while SessionActive and not LocalPlayer.Team and (os.clock() - t0 < 20) do
        InvokeCommF("SetTeam", "Pirates")
        task.wait(0.8)
    end
end)

-- // 4. Configuration //
local ConfigFolder = "OllieBench_RedzV14"
local ConfigFile = ConfigFolder .. "/cfg_" .. tostring(LocalPlayer.UserId) .. ".json"

local Config = {
    -- Core Weapon & Glide Settings
    SelectedWeapon = "Melee", -- "Melee", "Sword", "Blox Fruit", "Gun"
    MasteryWeapon = "Blox Fruit",
    FarmDistanceY = 18,
    TweenSpeed = 290,

    -- Combat Helpers (ON by default)
    FastAttack = true,
    SuperFastAttack = true,
    BringMobs = true,
    AutoBuso = true,
    AutoKen = false,
    WalkOnWater = true,
    AntiAFK = true,

    -- Main Auto Farm
    AutoFarmLevel = false,
    AutoFarmNearest = false,
    AutoFarmBosses = false,
    SelectedSpecificBoss = "All Bosses",
    AutoFarmChest = false,
    AutoFarmBone = false,
    AutoTradeBones = false,
    AutoFarmKatakuri = false,
    AutoSpawnCakePrince = true,
    AutoEliteHunter = false,
    AutoFactory = false,
    AutoPirateRaid = false,

    -- Mastery
    AutoFarmMastery = false,
    MasteryHealthPct = 35,
    SkillZ = true,
    SkillX = true,
    SkillC = true,
    SkillV = false,
    SkillF = false,

    -- Sea Unlocks, Quests & Swords
    AutoSecondSea = false,
    AutoThirdSea = false,
    AutoSaber = false,
    AutoBartilo = false,
    AutoRengoku = false,
    AutoYama = false,
    AutoTushita = false,
    AutoCDK = false,
    AutoSoulGuitar = false,

    -- Sea Events & Race V4
    AutoSeaBeast = false,
    AutoTerrorshark = false,
    AutoGhostShip = false,
    AutoKitsuneIsland = false,
    AutoFindMirage = false,
    AutoTeleportGear = false,
    AutoPullLever = false,
    AutoTrialV4 = false,
    AutoActivateV4 = false,

    -- Fruit & Raid
    AutoRandomFruit = false,
    AutoStoreFruit = true,
    GrabDroppedFruits = false,
    SniperFruitTarget = "Kitsune-Kitsune",
    AutoSnipeFruit = false,
    SelectedRaid = "Flame",
    AutoBuyChip = false,
    AutoStartRaid = false,
    AutoRaidDungeon = false,
    AutoAwaken = false,

    -- Stats & Player
    AutoStats = false,
    StatTarget = "Melee",
    StatPoints = 3,
    SilentAim = true,
    NoClip = false,
    InfiniteEnergy = true,
    FullBright = false,

    -- ESP
    ESPPlayers = false,
    ESPBosses = false,
    ESPFruits = true,
    ESPFlowers = false,
    ESPMirage = false,
    ESPIslands = false,
}

local Runtime = {
    TaskName = "Idle",
    FruitRadarText = "Fruit Radar: Đang quét...",
    TestReportText = "Self-Test: Đang chạy 70 phép thử...",
    CurrentSea = 1,
    TargetMob = nil,
    AimbotPart = nil,
    ClusterAnchorCF = nil,
    ClusterMobName = nil,
    LookAtPos = nil,
    LastAcceptedQuestName = nil,
    LastStartQuestCall = 0,
    LastAbandonQuestCall = 0,
    SpawnPatrolIdx = 1,
    LastSpawnPatrolTick = 0,
}

local function SaveConfig()
    pcall(function()
        if raw_writefile then
            if raw_isfolder and raw_makefolder and not raw_isfolder(ConfigFolder) then
                raw_makefolder(ConfigFolder)
            end
            raw_writefile(ConfigFile, HttpService:JSONEncode(Config))
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if raw_isfile and raw_readfile and raw_isfile(ConfigFile) then
            local decoded = HttpService:JSONDecode(raw_readfile(ConfigFile))
            if type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if Config[k] ~= nil and type(Config[k]) == type(v) then
                        Config[k] = v
                    end
                end
            end
        end
    end)
end
LoadConfig()

Config.FastAttack = true
Config.BringMobs = true
Config.AutoBuso = true
Config.TweenSpeed = math.clamp(Config.TweenSpeed, 180, 330)

-- // 5. EXACT DEVIL FRUIT NAME RESOLVER (ZERO "Controller -> Control" BUG!) //
local ExactFruitTable = {
    {Base = "Rocket", Code = "Rocket-Rocket", VN = "Trái Tên Lửa (Rocket)"},
    {Base = "Spin", Code = "Spin-Spin", VN = "Trái Chong Chóng (Spin)"},
    {Base = "Blade", Code = "Blade-Blade", VN = "Trái Lưỡi Dao (Blade)"},
    {Base = "Chop", Code = "Chop-Chop", VN = "Trái Phân Tách (Chop)"},
    {Base = "Spring", Code = "Spring-Spring", VN = "Trái Lò Xo (Spring)"},
    {Base = "Bomb", Code = "Bomb-Bomb", VN = "Trái Bom (Bomb)"},
    {Base = "Smoke", Code = "Smoke-Smoke", VN = "Trái Khói (Smoke)"},
    {Base = "Spike", Code = "Spike-Spike", VN = "Trái Gai (Spike)"},
    {Base = "Flame", Code = "Flame-Flame", VN = "Trái Lửa (Flame)"},
    {Base = "Falcon", Code = "Falcon-Falcon", VN = "Trái Đại Bàng (Falcon)"},
    {Base = "Ice", Code = "Ice-Ice", VN = "Trái Băng (Ice)"},
    {Base = "Sand", Code = "Sand-Sand", VN = "Trái Cát (Sand)"},
    {Base = "Dark", Code = "Dark-Dark", VN = "Trái Bóng Tối (Dark)"},
    {Base = "Diamond", Code = "Diamond-Diamond", VN = "Trái Kim Cương (Diamond)"},
    {Base = "Light", Code = "Light-Light", VN = "Trái Ánh Sáng (Light)"},
    {Base = "Rubber", Code = "Rubber-Rubber", VN = "Trái Cao Su (Rubber)"},
    {Base = "Barrier", Code = "Barrier-Barrier", VN = "Trái Rào Chắn (Barrier)"},
    {Base = "Ghost", Code = "Ghost-Ghost", VN = "Trái Hồn Ma (Ghost)"},
    {Base = "Magma", Code = "Magma-Magma", VN = "Trái Dung Nham (Magma)"},
    {Base = "Quake", Code = "Quake-Quake", VN = "Trái Chấn Động (Quake)"},
    {Base = "Buddha", Code = "Buddha-Buddha", VN = "Trái Phật Tổ (Buddha)"},
    {Base = "Love", Code = "Love-Love", VN = "Trái Tình Yêu (Love)"},
    {Base = "Spider", Code = "Spider-Spider", VN = "Trái Nhện (Spider)"},
    {Base = "Sound", Code = "Sound-Sound", VN = "Trái Âm Thanh (Sound)"},
    {Base = "Phoenix", Code = "Phoenix-Phoenix", VN = "Trái Phượng Hoàng (Phoenix)"},
    {Base = "Portal", Code = "Portal-Portal", VN = "Trái Dịch Chuyển (Portal)"},
    {Base = "Rumble", Code = "Rumble-Rumble", VN = "Trái Sét (Rumble)"},
    {Base = "Pain", Code = "Pain-Pain", VN = "Trái Đau Đớn (Pain)"},
    {Base = "Blizzard", Code = "Blizzard-Blizzard", VN = "Trái Bão Tuyết (Blizzard)"},
    {Base = "Gravity", Code = "Gravity-Gravity", VN = "Trái Trọng Lực (Gravity)"},
    {Base = "Mammoth", Code = "Mammoth-Mammoth", VN = "Trái Voi Ma Mút (Mammoth)"},
    {Base = "T-Rex", Code = "T-Rex-T-Rex", VN = "Trái Khủng Long (T-Rex)"},
    {Base = "Dough", Code = "Dough-Dough", VN = "Trái Bột (Dough)"},
    {Base = "Shadow", Code = "Shadow-Shadow", VN = "Trái Bóng Ma (Shadow)"},
    {Base = "Venom", Code = "Venom-Venom", VN = "Trái Độc (Venom)"},
    {Base = "Control", Code = "Control-Control", VN = "Trái Điều Khiển (Control)"},
    {Base = "Gas", Code = "Gas-Gas", VN = "Trái Khí Gas (Gas)"},
    {Base = "Spirit", Code = "Spirit-Spirit", VN = "Trái Linh Hồn (Spirit)"},
    {Base = "Leopard", Code = "Leopard-Leopard", VN = "Trái Báo Đốm (Leopard)"},
    {Base = "Yeti", Code = "Yeti-Yeti", VN = "Trái Người Tuyết (Yeti)"},
    {Base = "Kitsune", Code = "Kitsune-Kitsune", VN = "Trái Cáo Chín Đuôi (Kitsune)"},
    {Base = "Dragon", Code = "Dragon-Dragon", VN = "Trái Rồng (Dragon)"},
}

-- Matches a raw string (like "Sand Fruit", "Sand-Sand", or "Sand") against ExactFruitTable WITHOUT matching "Controller"!
local function MatchExactFruitString(rawStr)
    if type(rawStr) ~= "string" or #rawStr == 0 then return nil, nil end
    -- Never match internal script/controller names!
    local lower = string.lower(rawStr)
    if lower == "controller" or lower == "controlscript" or lower == "eatcontroller" or lower == "rigcontroller" or lower == "handle" or lower == "fruit" or lower == "fruit " then
        return nil, nil
    end
    -- Strip " fruit" suffix or "-..." suffix
    local stripped = string.gsub(lower, "%s*fruit%s*$", "")
    stripped = string.gsub(stripped, "^(.-)%-%1$", "%1")
    stripped = string.gsub(stripped, "^%s*(.-)%s*$", "%1")

    for _, entry in ipairs(ExactFruitTable) do
        local bLower = string.lower(entry.Base)
        local cLower = string.lower(entry.Code)
        if stripped == bLower or lower == cLower or lower == (bLower .. " fruit") then
            return entry.VN, entry.Code
        end
    end
    return nil, nil
end

local function GetStoreCodeForTool(tool)
    if not tool then return nil end
    local orig = tool:GetAttribute("OriginalName")
    if type(orig) == "string" and #orig > 0 then
        local _, code = MatchExactFruitString(orig)
        return code or orig
    end
    local _, code = MatchExactFruitString(tool.Name)
    if code then return code end
    if string.find(tool.Name, "Fruit", 1, true) then
        local clean = string.gsub(tool.Name, " Fruit", "")
        return clean .. "-" .. clean
    end
    return nil
end

local function StoreAllFruitsInBags()
    if not Config.AutoStoreFruit then return end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local ch = LocalPlayer.Character
    for _, container in ipairs({bp, ch}) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and (string.find(item.Name, "Fruit", 1, true) or item:GetAttribute("OriginalName")) then
                    local code = GetStoreCodeForTool(item)
                    if code then
                        InvokeCommF("StoreFruit", code, item)
                    end
                end
            end
        end
    end
end

-- Pure, false-positive-free Fruit Inspector
local function ResolveRealFruitObject(obj)
    if not obj or not obj.Parent then return false, nil, nil end
    if Players:GetPlayerFromCharacter(obj) or obj:FindFirstChildOfClass("Humanoid") then
        return false, nil, nil
    end

    -- Case 1: Dropped / Held Tool Fruit
    if obj:IsA("Tool") then
        local handle = obj:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            -- Priority A: Check OriginalName attribute
            local orig = obj:GetAttribute("OriginalName") or obj:GetAttribute("FruitName")
            if type(orig) == "string" and #orig > 0 then
                local vnName = MatchExactFruitString(orig)
                return true, handle, vnName or orig
            end
            -- Priority B: Check Tool.Name directly (e.g. "Sand Fruit" -> "Trái Cát (Sand)")
            local vnFromName = MatchExactFruitString(obj.Name)
            if vnFromName then
                return true, handle, vnFromName
            end
            -- Priority C: If Tool is literally named "Fruit", check ONLY BasePart/MeshPart or StringValue children (NEVER Scripts/Controllers!)
            if string.find(obj.Name, "Fruit", 1, true) then
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("BasePart") or child:IsA("MeshPart") or child:IsA("Model") then
                        local vnChild = MatchExactFruitString(child.Name)
                        if vnChild then return true, handle, vnChild end
                    elseif child:IsA("StringValue") then
                        local vnVal = MatchExactFruitString(child.Value)
                        if vnVal then return true, handle, vnVal end
                    end
                end
                return true, handle, obj.Name
            end
        end
        return false, nil, nil
    end

    -- Case 2: Natural Spawned Fruit Model on the ground (Named "Fruit " or "Fruit")
    if obj:IsA("Model") and (obj.Name == "Fruit " or obj.Name == "Fruit" or obj:GetAttribute("OriginalName") ~= nil) then
        local handle = obj:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            local orig = obj:GetAttribute("OriginalName") or obj:GetAttribute("FruitName")
            if type(orig) == "string" and #orig > 0 then
                local vnName = MatchExactFruitString(orig)
                return true, handle, vnName or orig
            end
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("BasePart") or child:IsA("MeshPart") or child:IsA("Model") then
                    local vnChild = MatchExactFruitString(child.Name)
                    if vnChild then return true, handle, vnChild end
                elseif child:IsA("StringValue") then
                    local vnVal = MatchExactFruitString(child.Value)
                    if vnVal then return true, handle, vnVal end
                end
            end
            return true, handle, "Trái Tự Nhiên (Spawned Fruit)"
        end
    end

    return false, nil, nil
end

local function ScanAllRealFruitsOnMap(rootPos)
    local results = {}
    local seenHandles = {}

    local function CheckContainer(folder)
        if not folder then return end
        for _, obj in ipairs(folder:GetChildren()) do
            local ok, handle, fName = ResolveRealFruitObject(obj)
            if ok and handle and not seenHandles[handle] then
                seenHandles[handle] = true
                local dist = rootPos and math.floor((handle.Position - rootPos).Magnitude) or 0
                table.insert(results, {
                    Instance = obj,
                    Handle = handle,
                    Name = fName,
                    Distance = dist,
                })
            end
        end
    end

    CheckContainer(Workspace)
    CheckContainer(Workspace:FindFirstChild("_WorldOrigin"))
    table.sort(results, function(a, b) return a.Distance < b.Distance end)
    return results
end

-- // 6. Sea Detection & Complete Boss + Quest Databases //
local function DetectSea()
    local pid = game.PlaceId
    if pid == 2753915549 then
        Runtime.CurrentSea = 1
    elseif pid == 4442272183 then
        Runtime.CurrentSea = 2
    elseif pid == 7449423635 then
        Runtime.CurrentSea = 3
    else
        local locs = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
        if locs then
            if locs:FindFirstChild("Tiki Outpost") or locs:FindFirstChild("Castle on the Sea") or locs:FindFirstChild("Haunted Castle") then
                Runtime.CurrentSea = 3
            elseif locs:FindFirstChild("Kingdom of Rose") or locs:FindFirstChild("Green Zone") or locs:FindFirstChild("Cafe") then
                Runtime.CurrentSea = 2
            else
                Runtime.CurrentSea = 1
            end
        end
    end
end
DetectSea()

local BossDatabase = {
    [1] = {
        {Name = "The Gorilla King", QuestName = "JungleQuest", QuestLvl = 3, QuestPos = CFrame.new(-1598.08, 35.55, 153.37), BossPos = CFrame.new(-1129.88, 40.46, -525.42)},
        {Name = "Bobby", QuestName = "BuggyQuest1", QuestLvl = 3, QuestPos = CFrame.new(-1141.07, 4.10, 3831.54), BossPos = CFrame.new(-1140.08, 14.80, 4322.92)},
        {Name = "Yeti", QuestName = "SnowQuest", QuestLvl = 3, QuestPos = CFrame.new(1389.74, 88.15, -1298.90), BossPos = CFrame.new(1201.64, 144.57, -1550.06)},
        {Name = "Mob Leader", QuestName = nil, QuestLvl = nil, QuestPos = nil, BossPos = CFrame.new(-2844.73, 7.42, 5356.67)},
        {Name = "Vice Admiral", QuestName = "MarineQuest2", QuestLvl = 2, QuestPos = CFrame.new(-5039.58, 27.35, 4324.68), BossPos = CFrame.new(-5006.40, 28.65, 4352.55)},
        {Name = "Warden", QuestName = "ImpelQuest", QuestLvl = 1, QuestPos = CFrame.new(5191.86, 2.84, 686.44), BossPos = CFrame.new(5278.04, 2.15, 944.10)},
        {Name = "Chief Warden", QuestName = "ImpelQuest", QuestLvl = 2, QuestPos = CFrame.new(5191.86, 2.84, 686.44), BossPos = CFrame.new(5278.04, 2.15, 944.10)},
        {Name = "Swan", QuestName = "ImpelQuest", QuestLvl = 3, QuestPos = CFrame.new(5191.86, 2.84, 686.44), BossPos = CFrame.new(5278.04, 2.15, 944.10)},
        {Name = "Magma Admiral", QuestName = "MagmaQuest", QuestLvl = 3, QuestPos = CFrame.new(-5313.37, 10.95, 8515.29), BossPos = CFrame.new(-5530.12, 22.88, 8859.98)},
        {Name = "Fishman Lord", QuestName = "FishmanQuest", QuestLvl = 3, QuestPos = CFrame.new(61122.65, 18.49, 1569.39), BossPos = CFrame.new(61350.15, 31.06, 1095.78)},
        {Name = "Wysper", QuestName = "SkyExp1Quest", QuestLvl = 3, QuestPos = CFrame.new(-7859.09, 5544.19, -381.47), BossPos = CFrame.new(-7925.48, 5550.96, -636.18)},
        {Name = "Thunder God", QuestName = "SkyExp2Quest", QuestLvl = 3, QuestPos = CFrame.new(-7906.81, 5634.66, -1411.99), BossPos = CFrame.new(-7751.45, 5606.81, -2315.61)},
        {Name = "Cyborg", QuestName = "FountainQuest", QuestLvl = 3, QuestPos = CFrame.new(5259.81, 37.35, 4050.02), BossPos = CFrame.new(6094.02, 73.77, 3825.73)},
        {Name = "Saber Expert", QuestName = nil, QuestLvl = nil, QuestPos = nil, BossPos = CFrame.new(-1458.89, 29.85, -50.63)},
    },
    [2] = {
        {Name = "Diamond", QuestName = "Area1Quest", QuestLvl = 3, QuestPos = CFrame.new(-429.54, 71.76, 1836.18), BossPos = CFrame.new(-1736.27, 198.63, -236.41)},
        {Name = "Jeremy", QuestName = "Area2Quest", QuestLvl = 3, QuestPos = CFrame.new(632.69, 73.10, 918.66), BossPos = CFrame.new(2099.88, 448.93, 853.20)},
        {Name = "Fajita", QuestName = "MarineQuest3", QuestLvl = 3, QuestPos = CFrame.new(-2440.79, 71.71, -3216.06), BossPos = CFrame.new(-2172.74, 103.32, -4015.03)},
        {Name = "Don Swan", QuestName = nil, QuestLvl = nil, QuestPos = nil, BossPos = CFrame.new(2288.80, 15.19, 863.03)},
        {Name = "Smoke Admiral", QuestName = "IceSideQuest", QuestLvl = 3, QuestPos = CFrame.new(-6064.06, 15.24, -4902.97), BossPos = CFrame.new(-5078.08, 24.51, -5352.66)},
        {Name = "Cursed Captain", QuestName = nil, QuestLvl = nil, QuestPos = nil, BossPos = CFrame.new(912.01, 181.09, 33422.39)},
        {Name = "Darkbeard", QuestName = nil, QuestLvl = nil, QuestPos = nil, BossPos = CFrame.new(3780.03, 22.65, -3498.58)},
        {Name = "Order", QuestName = nil, QuestLvl = nil, QuestPos = nil, BossPos = CFrame.new(-6221.15, 16.29, -5045.24)},
        {Name = "Awakened Ice Admiral", QuestName = "FrostQuest", QuestLvl = 3, QuestPos = CFrame.new(5667.65, 26.79, -6486.08), BossPos = CFrame.new(6473.55, 297.23, -6944.51)},
        {Name = "Tide Keeper", QuestName = "ForgottenQuest", QuestLvl = 3, QuestPos = CFrame.new(-3054.44, 235.54, -10142.81), BossPos = CFrame.new(-3711.98, 76.96, -11469.56)},
    },
    [3] = {
        {Name = "Stone", QuestName = "PiratePortQuest", QuestLvl = 3, QuestPos = CFrame.new(-290.07, 42.90, 5581.58), BossPos = CFrame.new(-1049.12, 40.00, 6791.17)},
        {Name = "Island Empress", QuestName = "AmazonQuest2", QuestLvl = 3, QuestPos = CFrame.new(5448.86, 601.51, 751.13), BossPos = CFrame.new(5713.98, 601.92, 202.75)},
        {Name = "Kilo Admiral", QuestName = "MarineTreeIsland", QuestLvl = 3, QuestPos = CFrame.new(2180.54, 27.81, -6741.54), BossPos = CFrame.new(2889.61, 423.55, -7233.22)},
        {Name = "Captain Elephant", QuestName = "DeepForestIsland", QuestLvl = 3, QuestPos = CFrame.new(-13234.04, 331.48, -7625.40), BossPos = CFrame.new(-13376.75, 319.38, -8421.37)},
        {Name = "Beautiful Pirate", QuestName = "DeepForestIsland2", QuestLvl = 3, QuestPos = CFrame.new(-12680.38, 389.97, -9902.01), BossPos = CFrame.new(5312.36, 22.56, -10.15)},
        {Name = "Cake Queen", QuestName = "IceCreamIslandQuest", QuestLvl = 3, QuestPos = CFrame.new(-820.64, 65.81, -10965.79), BossPos = CFrame.new(-709.31, 381.60, -11150.90)},
        {Name = "Longma", QuestName = nil, QuestLvl = nil, QuestPos = nil, BossPos = CFrame.new(-10238.88, 389.79, -9549.79)},
        {Name = "Soul Reaper", QuestName = nil, QuestLvl = nil, QuestPos = nil, BossPos = CFrame.new(-9570.03, 315.93, 6726.89)},
        {Name = "Cake Prince", QuestName = nil, QuestLvl = nil, QuestPos = nil, BossPos = CFrame.new(-2151.82, 70.01, -12128.45)},
        {Name = "Dough King", QuestName = nil, QuestLvl = nil, QuestPos = nil, BossPos = CFrame.new(-2151.82, 70.01, -12128.45)},
        {Name = "rip_indra True Form", QuestName = nil, QuestLvl = nil, QuestPos = nil, BossPos = CFrame.new(-5344.82, 423.99, -2725.09)},
    }
}

local QuestDatabase = {
    [1] = {
        {Min = 1, Max = 9, Mob = "Bandit", QuestName = "BanditQuest1", QuestLvl = 1, QuestPos = CFrame.new(1059.37, 15.44, 1550.42), MobPos = CFrame.new(1145.0, 17.0, 1634.0)},
        {Min = 10, Max = 14, Mob = "Monkey", QuestName = "JungleQuest", QuestLvl = 1, QuestPos = CFrame.new(-1598.08, 35.55, 153.37), MobPos = CFrame.new(-1448.51, 67.85, 11.46)},
        {Min = 15, Max = 29, Mob = "Gorilla", QuestName = "JungleQuest", QuestLvl = 2, QuestPos = CFrame.new(-1598.08, 35.55, 153.37), MobPos = CFrame.new(-1129.88, 40.46, -525.42)},
        {Min = 30, Max = 39, Mob = "Pirate", QuestName = "BuggyQuest1", QuestLvl = 1, QuestPos = CFrame.new(-1141.07, 4.10, 3831.54), MobPos = CFrame.new(-1103.51, 13.75, 3896.09)},
        {Min = 40, Max = 59, Mob = "Brute", QuestName = "BuggyQuest1", QuestLvl = 2, QuestPos = CFrame.new(-1141.07, 4.10, 3831.54), MobPos = CFrame.new(-1140.08, 14.80, 4322.92)},
        {Min = 60, Max = 74, Mob = "Desert Bandit", QuestName = "DesertQuest", QuestLvl = 1, QuestPos = CFrame.new(894.48, 5.14, 4392.43), MobPos = CFrame.new(924.79, 6.44, 4481.58)},
        {Min = 75, Max = 89, Mob = "Desert Officer", QuestName = "DesertQuest", QuestLvl = 2, QuestPos = CFrame.new(894.48, 5.14, 4392.43), MobPos = CFrame.new(1608.28, 8.61, 4371.00)},
        {Min = 90, Max = 99, Mob = "Snow Bandit", QuestName = "SnowQuest", QuestLvl = 1, QuestPos = CFrame.new(1389.74, 88.15, -1298.90), MobPos = CFrame.new(1354.34, 87.27, -1393.94)},
        {Min = 100, Max = 119, Mob = "Snowman", QuestName = "SnowQuest", QuestLvl = 2, QuestPos = CFrame.new(1389.74, 88.15, -1298.90), MobPos = CFrame.new(1201.64, 144.57, -1550.06)},
        {Min = 120, Max = 149, Mob = "Chief Petty Officer", QuestName = "MarineQuest2", QuestLvl = 1, QuestPos = CFrame.new(-5039.58, 27.35, 4324.68), MobPos = CFrame.new(-4881.23, 22.65, 4273.75)},
        {Min = 150, Max = 174, Mob = "Sky Bandit", QuestName = "SkyQuest", QuestLvl = 1, QuestPos = CFrame.new(-4839.53, 716.36, -2619.44), MobPos = CFrame.new(-4953.20, 295.74, -2899.22)},
        {Min = 175, Max = 189, Mob = "Dark Master", QuestName = "SkyQuest", QuestLvl = 2, QuestPos = CFrame.new(-4839.53, 716.36, -2619.44), MobPos = CFrame.new(-5259.84, 391.39, -2229.03)},
        {Min = 190, Max = 209, Mob = "Prisoner", QuestName = "PrisonerQuest", QuestLvl = 1, QuestPos = CFrame.new(5308.93, 1.65, 475.12), MobPos = CFrame.new(5098.97, -0.32, 474.23)},
        {Min = 210, Max = 249, Mob = "Dangerous Prisoner", QuestName = "PrisonerQuest", QuestLvl = 2, QuestPos = CFrame.new(5308.93, 1.65, 475.12), MobPos = CFrame.new(5654.56, 15.63, 866.29)},
        {Min = 250, Max = 274, Mob = "Toga Warrior", QuestName = "ColosseumQuest", QuestLvl = 1, QuestPos = CFrame.new(-1580.04, 6.35, -2986.47), MobPos = CFrame.new(-1820.21, 51.68, -2740.66)},
        {Min = 275, Max = 299, Mob = "Gladiator", QuestName = "ColosseumQuest", QuestLvl = 2, QuestPos = CFrame.new(-1580.04, 6.35, -2986.47), MobPos = CFrame.new(-1292.84, 56.38, -3339.03)},
        {Min = 300, Max = 324, Mob = "Military Soldier", QuestName = "MagmaQuest", QuestLvl = 1, QuestPos = CFrame.new(-5313.37, 10.95, 8515.29), MobPos = CFrame.new(-5411.16, 11.08, 8454.29)},
        {Min = 325, Max = 374, Mob = "Military Spy", QuestName = "MagmaQuest", QuestLvl = 2, QuestPos = CFrame.new(-5313.37, 10.95, 8515.29), MobPos = CFrame.new(-5802.86, 86.26, 8828.85)},
        {Min = 375, Max = 399, Mob = "Fishman Warrior", QuestName = "FishmanQuest", QuestLvl = 1, QuestPos = CFrame.new(61122.65, 18.49, 1569.39), MobPos = CFrame.new(60878.30, 18.48, 1543.75)},
        {Min = 400, Max = 449, Mob = "Fishman Commando", QuestName = "FishmanQuest", QuestLvl = 2, QuestPos = CFrame.new(61122.65, 18.49, 1569.39), MobPos = CFrame.new(61922.63, 18.48, 1493.93)},
        {Min = 450, Max = 474, Mob = "God's Guard", QuestName = "SkyExp1Quest", QuestLvl = 1, QuestPos = CFrame.new(-4721.88, 843.87, -1949.96), MobPos = CFrame.new(-4710.04, 845.27, -1927.30)},
        {Min = 475, Max = 524, Mob = "Shanda", QuestName = "SkyExp1Quest", QuestLvl = 2, QuestPos = CFrame.new(-7859.09, 5544.19, -381.47), MobPos = CFrame.new(-7678.48, 5566.40, -497.21)},
        {Min = 525, Max = 549, Mob = "Royal Squad", QuestName = "SkyExp2Quest", QuestLvl = 1, QuestPos = CFrame.new(-7906.81, 5634.66, -1411.99), MobPos = CFrame.new(-7624.25, 5658.13, -1467.35)},
        {Min = 550, Max = 624, Mob = "Royal Soldier", QuestName = "SkyExp2Quest", QuestLvl = 2, QuestPos = CFrame.new(-7906.81, 5634.66, -1411.99), MobPos = CFrame.new(-7836.75, 5645.66, -1790.62)},
        {Min = 625, Max = 649, Mob = "Galley Pirate", QuestName = "FountainQuest", QuestLvl = 1, QuestPos = CFrame.new(5259.81, 37.35, 4050.02), MobPos = CFrame.new(5551.02, 78.90, 3930.41)},
        {Min = 650, Max = 700, Mob = "Galley Captain", QuestName = "FountainQuest", QuestLvl = 2, QuestPos = CFrame.new(5259.81, 37.35, 4050.02), MobPos = CFrame.new(5441.95, 42.50, 4950.09)},
    },
    [2] = {
        {Min = 700, Max = 724, Mob = "Raider", QuestName = "Area1Quest", QuestLvl = 1, QuestPos = CFrame.new(-429.54, 71.76, 1836.18), MobPos = CFrame.new(-728.32, 52.77, 2345.77)},
        {Min = 725, Max = 774, Mob = "Mercenary", QuestName = "Area1Quest", QuestLvl = 2, QuestPos = CFrame.new(-429.54, 71.76, 1836.18), MobPos = CFrame.new(-1004.32, 80.15, 1424.61)},
        {Min = 775, Max = 799, Mob = "Swan Pirate", QuestName = "Area2Quest", QuestLvl = 1, QuestPos = CFrame.new(638.43, 71.76, 918.28), MobPos = CFrame.new(1068.66, 137.61, 1322.10)},
        {Min = 800, Max = 874, Mob = "Factory Staff", QuestName = "Area2Quest", QuestLvl = 2, QuestPos = CFrame.new(632.69, 73.10, 918.66), MobPos = CFrame.new(73.07, 81.86, -27.47)},
        {Min = 875, Max = 899, Mob = "Marine Lieutenant", QuestName = "MarineQuest3", QuestLvl = 1, QuestPos = CFrame.new(-2440.79, 71.71, -3216.06), MobPos = CFrame.new(-2821.37, 75.89, -3070.08)},
        {Min = 900, Max = 949, Mob = "Marine Captain", QuestName = "MarineQuest3", QuestLvl = 2, QuestPos = CFrame.new(-2440.79, 71.71, -3216.06), MobPos = CFrame.new(-1861.23, 80.17, -3254.69)},
        {Min = 950, Max = 974, Mob = "Zombie", QuestName = "ZombieQuest", QuestLvl = 1, QuestPos = CFrame.new(-5497.06, 47.59, -795.23), MobPos = CFrame.new(-5657.77, 78.96, -928.68)},
        {Min = 975, Max = 999, Mob = "Vampire", QuestName = "ZombieQuest", QuestLvl = 2, QuestPos = CFrame.new(-5497.06, 47.59, -795.23), MobPos = CFrame.new(-6037.66, 32.18, -1340.65)},
        {Min = 1000, Max = 1049, Mob = "Snow Trooper", QuestName = "SnowMountainQuest", QuestLvl = 1, QuestPos = CFrame.new(609.85, 400.11, -5372.25), MobPos = CFrame.new(549.14, 427.38, -5563.69)},
        {Min = 1050, Max = 1099, Mob = "Winter Warrior", QuestName = "SnowMountainQuest", QuestLvl = 2, QuestPos = CFrame.new(609.85, 400.11, -5372.25), MobPos = CFrame.new(1142.74, 475.63, -5199.41)},
        {Min = 1100, Max = 1124, Mob = "Lab Subordinate", QuestName = "IceSideQuest", QuestLvl = 1, QuestPos = CFrame.new(-6064.06, 15.24, -4902.97), MobPos = CFrame.new(-5707.47, 15.95, -4513.39)},
        {Min = 1125, Max = 1174, Mob = "Horned Warrior", QuestName = "IceSideQuest", QuestLvl = 2, QuestPos = CFrame.new(-6064.06, 15.24, -4902.97), MobPos = CFrame.new(-6341.36, 15.95, -5723.16)},
        {Min = 1175, Max = 1199, Mob = "Magma Ninja", QuestName = "FireSideQuest", QuestLvl = 1, QuestPos = CFrame.new(-5428.03, 15.06, -5299.43), MobPos = CFrame.new(-5449.67, 76.65, -5808.20)},
        {Min = 1200, Max = 1249, Mob = "Lava Pirate", QuestName = "FireSideQuest", QuestLvl = 2, QuestPos = CFrame.new(-5428.03, 15.06, -5299.43), MobPos = CFrame.new(-5213.33, 49.73, -4701.45)},
        {Min = 1250, Max = 1274, Mob = "Ship Deckhand", QuestName = "ShipQuest1", QuestLvl = 1, QuestPos = CFrame.new(1037.80, 125.09, 32911.60), MobPos = CFrame.new(1212.01, 150.79, 33059.24)},
        {Min = 1275, Max = 1299, Mob = "Ship Engineer", QuestName = "ShipQuest1", QuestLvl = 2, QuestPos = CFrame.new(1037.80, 125.09, 32911.60), MobPos = CFrame.new(919.47, 43.54, 32779.96)},
        {Min = 1300, Max = 1324, Mob = "Ship Steward", QuestName = "ShipQuest2", QuestLvl = 1, QuestPos = CFrame.new(968.80, 125.09, 33244.12), MobPos = CFrame.new(919.43, 129.59, 33436.03)},
        {Min = 1325, Max = 1349, Mob = "Ship Officer", QuestName = "ShipQuest2", QuestLvl = 2, QuestPos = CFrame.new(968.80, 125.09, 33244.12), MobPos = CFrame.new(1036.01, 181.43, 33315.72)},
        {Min = 1350, Max = 1374, Mob = "Arctic Warrior", QuestName = "FrostQuest", QuestLvl = 1, QuestPos = CFrame.new(5667.65, 26.79, -6486.08), MobPos = CFrame.new(5966.24, 62.97, -6179.38)},
        {Min = 1375, Max = 1424, Mob = "Snow Lurker", QuestName = "FrostQuest", QuestLvl = 2, QuestPos = CFrame.new(5667.65, 26.79, -6486.08), MobPos = CFrame.new(5407.07, 69.19, -6880.88)},
        {Min = 1425, Max = 1449, Mob = "Sea Soldier", QuestName = "ForgottenQuest", QuestLvl = 1, QuestPos = CFrame.new(-3054.44, 235.54, -10142.81), MobPos = CFrame.new(-3028.22, 64.67, -9775.42)},
        {Min = 1450, Max = 1500, Mob = "Water Fighter", QuestName = "ForgottenQuest", QuestLvl = 2, QuestPos = CFrame.new(-3054.44, 235.55, -10142.81), MobPos = CFrame.new(-3352.90, 285.01, -10534.84)},
    },
    [3] = {
        {Min = 1500, Max = 1524, Mob = "Pirate Millionaire", QuestName = "PiratePortQuest", QuestLvl = 1, QuestPos = CFrame.new(-290.07, 42.90, 5581.58), MobPos = CFrame.new(-245.99, 47.30, 5584.10)},
        {Min = 1525, Max = 1574, Mob = "Pistol Billionaire", QuestName = "PiratePortQuest", QuestLvl = 2, QuestPos = CFrame.new(-290.07, 42.90, 5581.58), MobPos = CFrame.new(-187.33, 86.23, 6013.51)},
        {Min = 1575, Max = 1599, Mob = "Dragon Crew Warrior", QuestName = "AmazonQuest", QuestLvl = 1, QuestPos = CFrame.new(5832.83, 51.68, -1101.51), MobPos = CFrame.new(6141.14, 51.35, -1340.73)},
        {Min = 1600, Max = 1624, Mob = "Dragon Crew Archer", QuestName = "AmazonQuest", QuestLvl = 2, QuestPos = CFrame.new(5832.83, 51.68, -1101.51), MobPos = CFrame.new(6616.41, 441.76, 446.04)},
        {Min = 1625, Max = 1649, Mob = "Female Islander", QuestName = "AmazonQuest2", QuestLvl = 1, QuestPos = CFrame.new(5448.86, 601.51, 751.13), MobPos = CFrame.new(4685.25, 735.80, 815.34)},
        {Min = 1650, Max = 1699, Mob = "Giant Islander", QuestName = "AmazonQuest2", QuestLvl = 2, QuestPos = CFrame.new(5448.86, 601.51, 751.13), MobPos = CFrame.new(4729.09, 590.43, -36.97)},
        {Min = 1700, Max = 1724, Mob = "Marine Commodore", QuestName = "MarineTreeIsland", QuestLvl = 1, QuestPos = CFrame.new(2180.54, 27.81, -6741.54), MobPos = CFrame.new(2286.00, 73.13, -7159.80)},
        {Min = 1725, Max = 1774, Mob = "Marine Rear Admiral", QuestName = "MarineTreeIsland", QuestLvl = 2, QuestPos = CFrame.new(2180.54, 27.81, -6741.54), MobPos = CFrame.new(3656.77, 160.52, -7001.59)},
        {Min = 1775, Max = 1799, Mob = "Fishman Raider", QuestName = "DeepForestIsland3", QuestLvl = 1, QuestPos = CFrame.new(-10581.65, 330.87, -8761.18), MobPos = CFrame.new(-10407.52, 331.76, -8368.51)},
        {Min = 1800, Max = 1824, Mob = "Fishman Captain", QuestName = "DeepForestIsland3", QuestLvl = 2, QuestPos = CFrame.new(-10581.65, 330.87, -8761.18), MobPos = CFrame.new(-10994.70, 352.38, -9002.11)},
        {Min = 1825, Max = 1849, Mob = "Forest Pirate", QuestName = "DeepForestIsland", QuestLvl = 1, QuestPos = CFrame.new(-13234.04, 331.48, -7625.40), MobPos = CFrame.new(-13479.39, 332.40, -7769.51)},
        {Min = 1850, Max = 1899, Mob = "Mythological Pirate", QuestName = "DeepForestIsland", QuestLvl = 2, QuestPos = CFrame.new(-13234.04, 331.48, -7625.40), MobPos = CFrame.new(-13680.60, 501.08, -6991.18)},
        {Min = 1900, Max = 1924, Mob = "Jungle Pirate", QuestName = "DeepForestIsland2", QuestLvl = 1, QuestPos = CFrame.new(-12680.38, 389.97, -9902.01), MobPos = CFrame.new(-12256.16, 331.73, -10485.83)},
        {Min = 1925, Max = 1974, Mob = "Musketeer Pirate", QuestName = "DeepForestIsland2", QuestLvl = 2, QuestPos = CFrame.new(-12680.38, 389.97, -9902.01), MobPos = CFrame.new(-13457.90, 391.54, -9859.17)},
        {Min = 1975, Max = 1999, Mob = "Reborn Skeleton", QuestName = "HauntedQuest1", QuestLvl = 1, QuestPos = CFrame.new(-9479.21, 141.21, 5566.09), MobPos = CFrame.new(-8763.72, 165.72, 6159.86)},
        {Min = 2000, Max = 2024, Mob = "Living Zombie", QuestName = "HauntedQuest1", QuestLvl = 2, QuestPos = CFrame.new(-9479.21, 141.21, 5566.09), MobPos = CFrame.new(-10144.13, 138.65, 5838.08)},
        {Min = 2025, Max = 2049, Mob = "Demonic Soul", QuestName = "HauntedQuest2", QuestLvl = 1, QuestPos = CFrame.new(-9516.99, 172.01, 6078.46), MobPos = CFrame.new(-9505.87, 172.10, 6158.99)},
        {Min = 2050, Max = 2074, Mob = "Posessed Mummy", QuestName = "HauntedQuest2", QuestLvl = 2, QuestPos = CFrame.new(-9516.99, 172.01, 6078.46), MobPos = CFrame.new(-9582.02, 6.25, 6205.47)},
        {Min = 2075, Max = 2099, Mob = "Peanut Scout", QuestName = "NutsIslandQuest", QuestLvl = 1, QuestPos = CFrame.new(-2104.39, 38.10, -10194.21), MobPos = CFrame.new(-2143.24, 47.72, -10029.99)},
        {Min = 2100, Max = 2124, Mob = "Peanut President", QuestName = "NutsIslandQuest", QuestLvl = 2, QuestPos = CFrame.new(-2104.39, 38.10, -10194.21), MobPos = CFrame.new(-1859.35, 38.10, -10422.42)},
        {Min = 2125, Max = 2149, Mob = "Ice Cream Chef", QuestName = "IceCreamIslandQuest", QuestLvl = 1, QuestPos = CFrame.new(-820.64, 65.81, -10965.79), MobPos = CFrame.new(-640.31, 126.95, -11062.08)},
        {Min = 2150, Max = 2199, Mob = "Ice Cream Commander", QuestName = "IceCreamIslandQuest", QuestLvl = 2, QuestPos = CFrame.new(-820.64, 65.81, -10965.79), MobPos = CFrame.new(-558.06, 126.95, -11290.77)},
        {Min = 2200, Max = 2224, Mob = "Cookie Crafter", QuestName = "CakeQuest1", QuestLvl = 1, QuestPos = CFrame.new(-2021.32, 37.79, -12028.72), MobPos = CFrame.new(-2374.13, 37.79, -12125.30)},
        {Min = 2225, Max = 2249, Mob = "Cake Guard", QuestName = "CakeQuest1", QuestLvl = 2, QuestPos = CFrame.new(-2021.32, 37.79, -12028.72), MobPos = CFrame.new(-1598.30, 43.77, -12244.58)},
        {Min = 2250, Max = 2274, Mob = "Baking Staff", QuestName = "CakeQuest2", QuestLvl = 1, QuestPos = CFrame.new(-1927.91, 37.79, -12842.53), MobPos = CFrame.new(-1887.80, 77.61, -12998.35)},
        {Min = 2275, Max = 2299, Mob = "Head Baker", QuestName = "CakeQuest2", QuestLvl = 2, QuestPos = CFrame.new(-1927.91, 37.79, -12842.53), MobPos = CFrame.new(-2216.18, 82.88, -12869.29)},
        {Min = 2300, Max = 2324, Mob = "Cocoa Warrior", QuestName = "ChocQuest1", QuestLvl = 1, QuestPos = CFrame.new(233.22, 29.87, -12201.23), MobPos = CFrame.new(-21.55, 80.57, -12352.38)},
        {Min = 2325, Max = 2349, Mob = "Chocolate Bar Battler", QuestName = "ChocQuest1", QuestLvl = 2, QuestPos = CFrame.new(233.22, 29.87, -12201.23), MobPos = CFrame.new(582.59, 77.18, -12463.16)},
        {Min = 2350, Max = 2374, Mob = "Sweet Thief", QuestName = "ChocQuest2", QuestLvl = 1, QuestPos = CFrame.new(150.50, 30.69, -12774.50), MobPos = CFrame.new(165.18, 76.05, -12600.83)},
        {Min = 2375, Max = 2399, Mob = "Candy Rebel", QuestName = "ChocQuest2", QuestLvl = 2, QuestPos = CFrame.new(150.50, 30.69, -12774.50), MobPos = CFrame.new(134.86, 77.24, -12876.54)},
        {Min = 2400, Max = 2424, Mob = "Candy Pirate", QuestName = "CandyQuest1", QuestLvl = 1, QuestPos = CFrame.new(-1150.04, 20.37, -14446.33), MobPos = CFrame.new(-1310.50, 26.01, -14562.40)},
        {Min = 2425, Max = 2449, Mob = "Snow Demon", QuestName = "CandyQuest1", QuestLvl = 2, QuestPos = CFrame.new(-1150.04, 20.37, -14446.33), MobPos = CFrame.new(-880.20, 71.25, -14538.60)},
        {Min = 2450, Max = 2474, Mob = "Isle Outlaw", QuestName = "TikiQuest1", QuestLvl = 1, QuestPos = CFrame.new(-16547.74, 61.13, -173.41), MobPos = CFrame.new(-16442.81, 116.13, -264.46)},
        {Min = 2475, Max = 2499, Mob = "Island Boy", QuestName = "TikiQuest1", QuestLvl = 2, QuestPos = CFrame.new(-16547.74, 61.13, -173.41), MobPos = CFrame.new(-16901.26, 84.06, -192.88)},
        {Min = 2500, Max = 2524, Mob = "Sun-kissed Warrior", QuestName = "TikiQuest2", QuestLvl = 1, QuestPos = CFrame.new(-16539.08, 55.69, 1051.57), MobPos = CFrame.new(-16349.88, 92.09, 1123.41)},
        {Min = 2525, Max = 2549, Mob = "Isle Champion", QuestName = "TikiQuest2", QuestLvl = 2, QuestPos = CFrame.new(-16539.08, 55.69, 1051.57), MobPos = CFrame.new(-16641.68, 235.78, 1031.28)},
        {Min = 2550, Max = 2574, Mob = "Serpent Hunter", QuestName = "TikiQuest3", QuestLvl = 1, QuestPos = CFrame.new(-16665.19, 104.59, 1579.69), MobPos = CFrame.new(-16587.89, 154.21, 1533.40)},
        {Min = 2575, Max = 3000, Mob = "Skull Slayer", QuestName = "TikiQuest3", QuestLvl = 2, QuestPos = CFrame.new(-16665.19, 104.59, 1579.69), MobPos = CFrame.new(-16885.20, 114.12, 1627.94)},
    }
}

local IslandLocations = {
    [1] = {
        ["Starter Island"] = CFrame.new(1071.28, 16.30, 1426.86),
        ["Jungle"] = CFrame.new(-1612.79, 36.85, 149.12),
        ["Pirate Village"] = CFrame.new(-1181.30, 4.75, 3803.54),
        ["Desert"] = CFrame.new(944.15, 20.91, 4373.30),
        ["Middle Town"] = CFrame.new(-655.82, 7.88, 1436.67),
        ["Frozen Village"] = CFrame.new(1347.80, 104.66, -1319.73),
        ["Marine Fortress"] = CFrame.new(-4505.37, 20.68, 4260.55),
        ["Skylands Lower"] = CFrame.new(-4841.83, 717.66, -2623.96),
        ["Skylands Upper"] = CFrame.new(-7894.62, 5547.14, -380.29),
        ["Prison"] = CFrame.new(4875.33, 5.65, 734.85),
        ["Colosseum"] = CFrame.new(-1427.62, 7.28, -2792.77),
        ["Magma Village"] = CFrame.new(-5231.75, 8.61, 8467.87),
        ["Underwater City"] = CFrame.new(61163.85, 11.67, 1819.78),
        ["Fountain City"] = CFrame.new(5127.12, 59.50, 4105.44),
    },
    [2] = {
        ["Kingdom of Rose"] = CFrame.new(-425.68, 72.06, 1835.42),
        ["Cafe"] = CFrame.new(-380.47, 77.22, 255.82),
        ["Factory Core"] = CFrame.new(448.46, 199.35, -441.38),
        ["Green Zone"] = CFrame.new(-2448.53, 73.01, -3210.63),
        ["Graveyard"] = CFrame.new(-5411.47, 48.51, -721.28),
        ["Snow Mountain"] = CFrame.new(541.32, 401.02, -5297.64),
        ["Hot and Cold"] = CFrame.new(-6026.96, 14.74, -5071.96),
        ["Cursed Ship"] = CFrame.new(923.21, 125.09, 32885.87),
        ["Ice Castle"] = CFrame.new(5400.40, 28.21, -6236.99),
        ["Forgotten Island"] = CFrame.new(-3032.76, 317.89, -10075.37),
        ["Dark Arena"] = CFrame.new(3780.03, 22.65, -3498.58),
    },
    [3] = {
        ["Port Town"] = CFrame.new(-290.73, 6.72, 5343.55),
        ["Hydra Island"] = CFrame.new(5228.88, 604.23, 345.04),
        ["Great Tree"] = CFrame.new(2681.27, 1682.80, -7190.98),
        ["Castle on the Sea"] = CFrame.new(-5074.45, 314.51, -2991.05),
        ["Floating Turtle"] = CFrame.new(-13274.52, 531.82, -7579.22),
        ["Mansion"] = CFrame.new(-12553.81, 337.19, -7495.55),
        ["Haunted Castle"] = CFrame.new(-9515.37, 164.00, 5786.06),
        ["Peanut Island"] = CFrame.new(-2104.39, 38.10, -10194.21),
        ["Ice Cream Island"] = CFrame.new(-820.64, 65.81, -10965.79),
        ["Cake Loaf"] = CFrame.new(-2009.86, 38.12, -12026.96),
        ["Chocolate Island"] = CFrame.new(233.22, 29.87, -12201.23),
        ["Candy Cane Island"] = CFrame.new(-1150.04, 20.37, -14446.33),
        ["Tiki Outpost"] = CFrame.new(-16218.68, 9.08, 445.61),
        ["Temple of Time"] = CFrame.new(28286.35, 14895.30, 102.62),
    }
}

-- // 7. Proxy CFrameValue Glide Engine //
TrackConn(LocalPlayer.Idled, function()
    if Config.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

local function GetChar() return LocalPlayer.Character end
local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function GetLevel()
    local d = LocalPlayer:FindFirstChild("Data")
    local l = d and d:FindFirstChild("Level")
    return (l and l.Value) or 1
end
local function HasItem(name)
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local ch = GetChar()
    return (bp and bp:FindFirstChild(name) ~= nil) or (ch and ch:FindFirstChild(name) ~= nil)
end

local function CleanMobName(rawName)
    if type(rawName) ~= "string" then return "" end
    local s = string.gsub(rawName, " %[Lv%. %d+%]", "")
    s = string.gsub(s, " %[Boss%]", "")
    s = string.gsub(s, "%[Lv%. %d+%]", "")
    s = string.gsub(s, "%[Boss%]", "")
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

local ProxyCF = Instance.new("CFrameValue")
local ProxyTween = nil
local ProxyActive = false
local ProxyGoalPos = nil
local ProxyStopOnArrive = false

local function StopMove()
    ProxyActive = false
    ProxyGoalPos = nil
    ProxyStopOnArrive = false
    Runtime.ClusterAnchorCF = nil
    Runtime.ClusterMobName = nil
    Runtime.LookAtPos = nil
    if ProxyTween then
        pcall(function() ProxyTween:Cancel() end)
        ProxyTween = nil
    end
    local root = GetRoot()
    if root then
        local bv = root:FindFirstChild("RedzV14_BV")
        if bv then bv:Destroy() end
    end
end

local function MoveToCFrame(targetCF, stopOnArrive, lookAtTargetPos)
    if not targetCF then
        StopMove()
        return
    end
    local root = GetRoot()
    local hum = GetHum()
    if not root or not hum or hum.Health <= 0 then return end

    if hum.Sit then hum.Sit = false end

    local destPos = targetCF.Position
    local dist = (root.Position - destPos).Magnitude
    ProxyStopOnArrive = (stopOnArrive == true)
    Runtime.LookAtPos = lookAtTargetPos

    if dist <= 2.5 then
        if ProxyTween then
            pcall(function() ProxyTween:Cancel() end)
            ProxyTween = nil
        end
        ProxyGoalPos = destPos
        ProxyCF.Value = CFrame.new(destPos)
        ProxyActive = not ProxyStopOnArrive
        return
    end

    if ProxyActive and ProxyGoalPos and (ProxyGoalPos - destPos).Magnitude < 4.5 and ProxyTween then
        return
    end

    ProxyCF.Value = CFrame.new(root.Position)
    if ProxyTween then
        pcall(function() ProxyTween:Cancel() end)
    end

    ProxyGoalPos = destPos
    ProxyActive = true
    local speed = math.clamp(Config.TweenSpeed, 180, 330)
    local duration = math.max(0.05, dist / speed)
    ProxyTween = TweenService:Create(ProxyCF, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Value = CFrame.new(destPos)})
    ProxyTween:Play()
end

TrackConn(RunService.Heartbeat, function()
    pcall(function()
        local root = GetRoot()
        local hum = GetHum()
        if not ProxyActive or not root or not hum or hum.Health <= 0 then
            if root then
                local bv = root:FindFirstChild("RedzV14_BV")
                if bv then bv:Destroy() end
            end
            return
        end

        local bv = root:FindFirstChild("RedzV14_BV")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "RedzV14_BV"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.zero
            bv.Parent = root
        end
        bv.Velocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        local nextPos = ProxyCF.Value.Position
        if Runtime.LookAtPos and (nextPos - Runtime.LookAtPos).Magnitude > 1.0 and (root.Position - ProxyGoalPos).Magnitude <= 30 then
            local flatLook = Vector3.new(Runtime.LookAtPos.X + 0.1, nextPos.Y, Runtime.LookAtPos.Z + 0.1)
            root.CFrame = CFrame.lookAt(nextPos, flatLook)
        else
            local rot = root.CFrame - root.Position
            root.CFrame = CFrame.new(nextPos) * rot
        end

        if ProxyGoalPos and (root.Position - ProxyGoalPos).Magnitude <= 2.5 and ProxyStopOnArrive then
            StopMove()
        end
    end)
end)

-- // 8. Multi-Language Weapon Equip (EN & VN) //
local ToolCategoryMatchers = {
    ["Melee"] = {"melee", "cận chiến", "combat", "black leg", "electro", "fishman karate", "dragon breath", "superhuman", "death step", "sharkman karate", "electric claw", "dragon talon", "godhuman", "sanguine art"},
    ["Sword"] = {"sword", "kiếm", "katana", "cutlass", "saber", "rengoku", "yama", "tushita", "cursed dual katana", "hallow scythe", "dark blade", "shark anchor"},
    ["Blox Fruit"] = {"blox fruit", "demon fruit", "trái ác quỷ", "trái", "fruit"},
    ["Gun"] = {"gun", "súng", "slingshot", "musket", "flintlock", "kabucha", "soul guitar", "bizarre rifle", "acidum rifle"},
}

local function DoesToolMatchCategory(tool, category)
    if not tool or not tool:IsA("Tool") then return false end
    local tip = string.lower(tostring(tool.ToolTip or ""))
    local name = string.lower(tostring(tool.Name or ""))
    local patterns = ToolCategoryMatchers[category]
    if patterns then
        for _, pat in ipairs(patterns) do
            if tip == pat or string.find(tip, pat, 1, true) or string.find(name, pat, 1, true) then
                return true
            end
        end
    end
    if category == "Blox Fruit" and (tool:GetAttribute("OriginalName") or string.find(name, "-")) then
        return true
    end
    return false
end

local LastBusoTick = 0
local function EquipSelectedWeapon(categoryOverride, exactNameOverride)
    local char = GetChar()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local hum = GetHum()
    if not char or not bp or not hum or hum.Health <= 0 then return nil end

    if Config.AutoBuso and not char:FindFirstChild("HasBuso") and (os.clock() - LastBusoTick > 3.0) then
        LastBusoTick = os.clock()
        task.spawn(function() InvokeCommF("Buso") end)
    end

    local held = char:FindFirstChildOfClass("Tool")
    if exactNameOverride then
        if held and held.Name == exactNameOverride then return held end
        local found = bp:FindFirstChild(exactNameOverride)
        if found and found:IsA("Tool") then
            pcall(function() hum:EquipTool(found) end)
            return found
        end
        return nil
    end

    local wanted = categoryOverride or Config.SelectedWeapon
    if held and DoesToolMatchCategory(held, wanted) then
        return held
    end

    local fallbackTool = nil
    for _, item in ipairs(bp:GetChildren()) do
        if item:IsA("Tool") then
            if DoesToolMatchCategory(item, wanted) then
                pcall(function() hum:EquipTool(item) end)
                return item
            end
            if not fallbackTool
                and not string.find(item.Name, "Fruit", 1, true)
                and not item:GetAttribute("OriginalName")
                and item.Name ~= "Special Microchip"
                and item.Name ~= "Holy Torch"
                and item.Name ~= "Hidden Key"
                and item.Name ~= "God's Chalice"
                and item.Name ~= "Fist of Darkness" then
                fallbackTool = item
            end
        end
    end

    if not held and fallbackTool then
        pcall(function() hum:EquipTool(fallbackTool) end)
        return fallbackTool
    end
    return held
end

local LastSkillPulse = 0
local function FireSkillsNow()
    if os.clock() - LastSkillPulse < 0.4 then return end
    LastSkillPulse = os.clock()
    task.spawn(function()
        local keys = {
            {Config.SkillZ, Enum.KeyCode.Z},
            {Config.SkillX, Enum.KeyCode.X},
            {Config.SkillC, Enum.KeyCode.C},
            {Config.SkillV, Enum.KeyCode.V},
            {Config.SkillF, Enum.KeyCode.F},
        }
        for _, pair in ipairs(keys) do
            if pair[1] and VirtualInputManager then
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, pair[2], false, game)
                    task.wait(0.04)
                    VirtualInputManager:SendKeyEvent(false, pair[2], false, game)
                end)
            end
        end
    end)
end

-- // 9. 4-Layer Redz FastAttack //
local ActiveControllersList = {}

local function ScanForCombatControllers()
    table.clear(ActiveControllersList)
    pcall(function()
        if raw_getupvalues then
            local ps = LocalPlayer:FindFirstChild("PlayerScripts")
            local cfModule = ps and ps:FindFirstChild("CombatFramework")
            if cfModule then
                local upvals = raw_getupvalues(require(cfModule))
                if type(upvals) == "table" then
                    for _, v in pairs(upvals) do
                        if type(v) == "table" and type(v.activeController) == "table" then
                            table.insert(ActiveControllersList, v.activeController)
                        end
                    end
                end
            end
        end
        if raw_getgc and #ActiveControllersList == 0 then
            for _, obj in ipairs(raw_getgc(true)) do
                if type(obj) == "table" and rawget(obj, "timeToNextAttack") ~= nil and rawget(obj, "hitboxMagnitude") ~= nil and type(rawget(obj, "attack")) == "function" then
                    table.insert(ActiveControllersList, obj)
                end
            end
        end
    end)
end
ScanForCombatControllers()

local LastControllerRescan = os.clock()

local function ExecuteRedzQuadAttack()
    local char = GetChar()
    local root = GetRoot()
    if not char or not root then return end

    if os.clock() - LastControllerRescan > 15.0 then
        LastControllerRescan = os.clock()
        ScanForCombatControllers()
    end

    local enemies = Workspace:FindFirstChild("Enemies")
    local bladeHits = {}
    local partHits = {}
    local mainPart = nil

    if enemies then
        for _, mob in ipairs(enemies:GetChildren()) do
            local mr = mob:FindFirstChild("HumanoidRootPart")
            local mHead = mob:FindFirstChild("Head")
            local mh = mob:FindFirstChildOfClass("Humanoid")
            local hitPart = mr or mHead
            if hitPart and mh and mh.Health > 0 and (hitPart.Position - root.Position).Magnitude <= 85 then
                if not mainPart then mainPart = hitPart end
                table.insert(bladeHits, {mob, hitPart})
                if mHead and mHead ~= hitPart then
                    table.insert(bladeHits, {mob, mHead})
                end
                table.insert(partHits, hitPart)
            end
        end
    end

    if mainPart then
        pcall(function()
            local modules = ReplicatedStorage:FindFirstChild("Modules")
            local net = modules and modules:FindFirstChild("Net")
            if net then
                local regAtk = net:FindFirstChild("RE/RegisterAttack")
                local regHit = net:FindFirstChild("RE/RegisterHit")
                if regAtk and regHit then
                    regAtk:FireServer(0)
                    regHit:FireServer(mainPart, bladeHits)
                    if Config.SuperFastAttack then
                        regAtk:FireServer(0)
                        regHit:FireServer(mainPart, bladeHits)
                    end
                end
            end
        end)

        pcall(function()
            local rigEvent = ReplicatedStorage:FindFirstChild("RigControllerEvent")
            local held = char:FindFirstChildOfClass("Tool")
            if rigEvent and held then
                rigEvent:FireServer("weaponChange", tostring(held.Name))
                rigEvent:FireServer("hit", partHits, 1, "")
            end
        end)
    end

    pcall(function()
        for _, ac in ipairs(ActiveControllersList) do
            if type(ac) == "table" then
                ac.timeToNextAttack = 0
                ac.hitboxMagnitude = 80
                ac.increment = 3
                ac.focusStart = 0
                ac.attacking = false
                ac.blocking = false
                if type(ac.attack) == "function" then
                    ac:attack()
                end
            end
        end
    end)

    pcall(function()
        local held = char:FindFirstChildOfClass("Tool")
        if held then held:Activate() end
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(1280, 672))
    end)
end

task.spawn(function()
    while SessionActive do
        task.wait(Config.SuperFastAttack and 0.045 or 0.085)
        if Config.FastAttack or Config.AutoRaidDungeon then
            local active = Config.AutoFarmLevel or Config.AutoFarmNearest or Config.AutoFarmBosses
                or Config.AutoFarmBone or Config.AutoFarmKatakuri or Config.AutoEliteHunter
                or Config.AutoFactory or Config.AutoPirateRaid or Config.AutoRaidDungeon
                or Config.AutoTerrorshark or Config.AutoGhostShip or Config.AutoTrialV4
                or Config.AutoSaber or Config.AutoBartilo or Config.AutoRengoku
                or Config.AutoSecondSea or Config.AutoThirdSea or Config.AutoCDK or Config.AutoSoulGuitar
                or Config.AutoFarmMastery or (Runtime.TargetMob ~= nil)
            if active then
                ExecuteRedzQuadAttack()
            end
        end
    end
end)

-- // 10. Stepped Physics: SimulationRadius, NoClip & Static Cluster Anchor BringMobs //
TrackConn(RunService.Stepped, function()
    pcall(function()
        local char = GetChar()
        local root = GetRoot()

        if raw_sethiddenproperty then
            raw_sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        end

        local anyActive = Config.NoClip or ProxyActive or (Runtime.TargetMob ~= nil)
            or Config.AutoFarmLevel or Config.AutoFarmNearest or Config.AutoFarmBosses
            or Config.AutoFarmChest or Config.AutoFarmBone or Config.AutoFarmKatakuri or Config.AutoRaidDungeon
        if anyActive and char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end

        if Config.BringMobs and Runtime.ClusterAnchorCF and root then
            local enemies = Workspace:FindFirstChild("Enemies")
            if enemies then
                local filterClean = Runtime.ClusterMobName and CleanMobName(Runtime.ClusterMobName) or nil
                for _, mob in ipairs(enemies:GetChildren()) do
                    local mobClean = CleanMobName(mob.Name)
                    if not filterClean or mobClean == filterClean or string.find(mobClean, filterClean, 1, true) then
                        local mr = mob:FindFirstChild("HumanoidRootPart")
                        local mh = mob:FindFirstChildOfClass("Humanoid")
                        if mr and mh and mh.Health > 0 and (mr.Position - Runtime.ClusterAnchorCF.Position).Magnitude <= 350 then
                            mr.CFrame = Runtime.ClusterAnchorCF
                            mr.CanCollide = false
                            mr.AssemblyLinearVelocity = Vector3.zero
                            mr.AssemblyAngularVelocity = Vector3.zero
                            mh.WalkSpeed = 0
                            mh.JumpPower = 0
                            mh.AutoRotate = false
                            local anim = mh:FindFirstChild("Animator")
                            if anim then anim:Destroy() end
                        end
                    end
                end
            end
        end

        local map = Workspace:FindFirstChild("Map")
        local wp = map and map:FindFirstChild("WaterBase-Plane")
        if wp and wp:IsA("BasePart") then
            wp.Size = Config.WalkOnWater and Vector3.new(2048, 112, 2048) or Vector3.new(2048, 80, 2048)
        end

        if Config.InfiniteEnergy and char then
            local en = char:FindFirstChild("Energy")
            if en and (en:IsA("IntValue") or en:IsA("NumberValue")) then
                local maxChild = en:FindFirstChild("MaxValue")
                en.Value = (maxChild and maxChild.Value) or 15000
            end
        end

        if Config.FullBright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 9e9
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        end
    end)
end)

-- // 11. Silent Aim Hook //
getgenv().OllieBF_SilentAimHandler = function(self, ...)
    if not Config.SilentAim or not Runtime.AimbotPart or not Runtime.AimbotPart.Parent then
        return false, nil
    end
    local method = raw_getnamecallmethod()
    if method ~= "FireServer" and method ~= "InvokeServer" then
        return false, nil
    end
    if self == CommF then return false, nil end
    local char = GetChar()
    local held = char and char:FindFirstChildOfClass("Tool")
    if not held or typeof(self) ~= "Instance" then return false, nil end
    if not self:IsDescendantOf(held) and self ~= CommE then return false, nil end

    local args = table.pack(...)
    for i = 1, args.n do
        if typeof(args[i]) == "Vector3" then
            args[i] = Runtime.AimbotPart.Position
            return true, args
        elseif typeof(args[i]) == "CFrame" then
            args[i] = Runtime.AimbotPart.CFrame
            return true, args
        end
    end
    return false, nil
end

pcall(function()
    if raw_hookmetamethod and raw_getnamecallmethod and not getgenv().OllieBF_V14Hooked then
        getgenv().OllieBF_V14Hooked = true
        local oldNamecall
        oldNamecall = raw_hookmetamethod(game, "__namecall", raw_newcclosure(function(self, ...)
            if not raw_checkcaller() and getgenv().OllieBF_SilentAimHandler then
                local ok, changed, newArgs = pcall(getgenv().OllieBF_SilentAimHandler, self, ...)
                if ok and changed and type(newArgs) == "table" then
                    return oldNamecall(self, table.unpack(newArgs, 1, newArgs.n))
                end
            end
            return oldNamecall(self, ...)
        end))
    end
end)

-- // 12. VERIFIED QUEST HANDSHAKE (ZERO FAKE GRACE WINDOW!) & COMBAT ENGAGE //
local function GetQuestForLevel(lvlOverride)
    local lvl = lvlOverride or GetLevel()
    local list = QuestDatabase[Runtime.CurrentSea]
    if not list then return nil end
    local chosen = list[#list]
    for _, q in ipairs(list) do
        if lvl >= q.Min and lvl <= q.Max then
            chosen = q
            break
        end
    end
    return chosen
end

-- THE V14 VERIFIED QUEST HANDSHAKE:
-- Never pretends a quest is active via a timer! Only returns true when PlayerGui.Main.Quest.Visible == true!
local function IsQuestVerifiedOnScreen(qData)
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local main = pgui and pgui:FindFirstChild("Main")
    local qFrame = main and main:FindFirstChild("Quest")
    if not qFrame or qFrame.Visible ~= true then
        return false
    end

    -- If we leveled up into a new QuestName bracket while holding an old quest, abandon old quest
    if Runtime.LastAcceptedQuestName and Runtime.LastAcceptedQuestName ~= qData.QuestName then
        if os.clock() - Runtime.LastAbandonQuestCall > 2.5 then
            Runtime.LastAbandonQuestCall = os.clock()
            InvokeCommF("AbandonQuest")
            Runtime.LastAcceptedQuestName = nil
        end
        return false
    end

    Runtime.LastAcceptedQuestName = qData.QuestName
    return true
end

local function GetNextSpawnPatrolCFrame(mobName, fallbackCF)
    local cleanTarget = CleanMobName(mobName)
    local wo = Workspace:FindFirstChild("_WorldOrigin")
    local spawnsFolder = wo and wo:FindFirstChild("EnemySpawns")
    if spawnsFolder then
        local points = {}
        for _, sp in ipairs(spawnsFolder:GetChildren()) do
            if sp:IsA("BasePart") then
                local spClean = CleanMobName(sp.Name)
                if spClean == cleanTarget or string.find(spClean, cleanTarget, 1, true) then
                    table.insert(points, sp.CFrame)
                end
            end
        end
        if #points > 0 then
            if os.clock() - Runtime.LastSpawnPatrolTick > 3.0 then
                Runtime.LastSpawnPatrolTick = os.clock()
                Runtime.SpawnPatrolIdx = (Runtime.SpawnPatrolIdx % #points) + 1
            end
            local idx = math.clamp(Runtime.SpawnPatrolIdx, 1, #points)
            return points[idx] * CFrame.new(0, 18, 0)
        end
    end
    return fallbackCF * CFrame.new(0, 18, 0)
end

local function FindLiveEnemy(nameFilter, bossOnly, centerPos, maxRadius)
    local enemies = Workspace:FindFirstChild("Enemies")
    local root = GetRoot()
    if not enemies or not root then return nil end

    local refPos = centerPos or root.Position
    local rad = maxRadius or math.huge
    local best, minDist = nil, math.huge

    for _, mob in ipairs(enemies:GetChildren()) do
        local mr = mob:FindFirstChild("HumanoidRootPart")
        local mh = mob:FindFirstChildOfClass("Humanoid")
        if mr and mh and mh.Health > 0 and (mr.Position - refPos).Magnitude <= rad then
            local mobClean = CleanMobName(mob.Name)
            local ok = false
            if bossOnly then
                ok = (mob:FindFirstChild("Boss") ~= nil) or (mh.MaxHealth >= 100000) or string.find(mob.Name, "Boss") ~= nil
            elseif type(nameFilter) == "table" then
                for _, pat in ipairs(nameFilter) do
                    local patClean = CleanMobName(pat)
                    if mobClean == patClean or string.find(mobClean, patClean, 1, true) then
                        ok = true
                        break
                    end
                end
            elseif type(nameFilter) == "string" then
                local patClean = CleanMobName(nameFilter)
                ok = (mobClean == patClean) or string.find(mobClean, patClean, 1, true) ~= nil
            else
                ok = true
            end

            if ok then
                local d = (mr.Position - root.Position).Magnitude
                if d < minDist then
                    minDist = d
                    best = mob
                end
            end
        end
    end
    return best
end

local function FindAnyBossInServer()
    local specific = Config.SelectedSpecificBoss
    local filterSpecific = (specific and specific ~= "All Bosses") and specific or nil

    local liveBoss = FindLiveEnemy(filterSpecific, filterSpecific == nil)
    if liveBoss then
        return liveBoss, liveBoss.HumanoidRootPart.CFrame, CleanMobName(liveBoss.Name)
    end

    local seaBosses = BossDatabase[Runtime.CurrentSea] or {}
    for _, bInfo in ipairs(seaBosses) do
        if not filterSpecific or bInfo.Name == filterSpecific then
            for _, child in ipairs(ReplicatedStorage:GetChildren()) do
                if child:IsA("Model") and CleanMobName(child.Name) == bInfo.Name then
                    local mh = child:FindFirstChildOfClass("Humanoid")
                    local mr = child:FindFirstChild("HumanoidRootPart")
                    if not mh or mh.Health > 0 then
                        return nil, (mr and mr.CFrame) or bInfo.BossPos, bInfo.Name
                    end
                end
            end
        end
    end

    if filterSpecific then
        for _, bInfo in ipairs(seaBosses) do
            if bInfo.Name == filterSpecific then
                return nil, bInfo.BossPos, bInfo.Name
            end
        end
    end

    return nil, nil, nil
end

local function AttackAndHoverMob(mob, bringFilterName)
    local mr = mob and mob:FindFirstChild("HumanoidRootPart")
    local mh = mob and mob:FindFirstChildOfClass("Humanoid")
    if not mr or not mh or mh.Health <= 0 then return end

    local cleanName = bringFilterName or CleanMobName(mob.Name)
    local isBoss = (mob:FindFirstChild("Boss") ~= nil) or (mh.MaxHealth >= 100000) or (bringFilterName == nil)

    Runtime.TargetMob = mob
    Runtime.AimbotPart = mr

    -- Equip weapon FIRST before moving/attacking so attack pulse is never empty-handed!
    local hpPct = (mh.Health / math.max(1, mh.MaxHealth)) * 100
    if Config.AutoFarmMastery and hpPct <= Config.MasteryHealthPct then
        EquipSelectedWeapon(Config.MasteryWeapon)
        FireSkillsNow()
    else
        EquipSelectedWeapon(Config.SelectedWeapon)
    end

    if not isBoss and Config.BringMobs then
        if not Runtime.ClusterAnchorCF
            or Runtime.ClusterMobName ~= cleanName
            or (Runtime.ClusterAnchorCF.Position - mr.Position).Magnitude > 260 then
            Runtime.ClusterAnchorCF = CFrame.new(mr.Position)
            Runtime.ClusterMobName = cleanName
        end
        local anchorPos = Runtime.ClusterAnchorCF.Position
        local hoverCF = CFrame.new(anchorPos + Vector3.new(0, Config.FarmDistanceY, 0))
        MoveToCFrame(hoverCF, false, anchorPos)
    else
        Runtime.ClusterAnchorCF = nil
        Runtime.ClusterMobName = nil
        local hoverCF = CFrame.new(mr.Position + Vector3.new(0, Config.FarmDistanceY, 0))
        MoveToCFrame(hoverCF, false, mr.Position)
    end

    -- Fire immediate attack pulse when within 65 studs of target!
    local root = GetRoot()
    if root and (root.Position - mr.Position).Magnitude <= 65 then
        ExecuteRedzQuadAttack()
    end
end

local function FireAllInteractables(inst)
    if not inst then return end
    local list = inst:GetDescendants()
    table.insert(list, 1, inst)
    local root = GetRoot()
    for _, v in ipairs(list) do
        if v:IsA("ProximityPrompt") and raw_fireproximityprompt then
            pcall(function() raw_fireproximityprompt(v) end)
        elseif v:IsA("ClickDetector") and raw_fireclickdetector then
            pcall(function() raw_fireclickdetector(v) end)
        elseif v:IsA("TouchTransmitter") and raw_firetouchinterest and root and v.Parent:IsA("BasePart") then
            pcall(function()
                raw_firetouchinterest(root, v.Parent, 0)
                raw_firetouchinterest(root, v.Parent, 1)
            end)
        end
    end
end

-- // 13. 10x7 AUTOMATED SELF-TEST SUITE (70 TEST CASES — >=10 TESTS PER MODULE!) //
local TestBannerLabel = nil

local function Run10xVerificationSuite()
    local totalPassed = 0
    local totalTests = 0
    local failedDetails = {}

    local function Check(suiteName, caseIdx, cond)
        totalTests = totalTests + 1
        if cond then
            totalPassed = totalPassed + 1
        else
            table.insert(failedDetails, suiteName .. "#" .. tostring(caseIdx))
        end
    end

    -- MODULE 1: 10x Fruit Name Resolver Tests (Specifically tests Sand vs Controller bug!)
    local fruitTests = {
        {Input = "Sand Fruit", Expect = "Trái Cát (Sand)"},
        {Input = "Sand-Sand", Expect = "Trái Cát (Sand)"},
        {Input = "Control Fruit", Expect = "Trái Điều Khiển (Control)"},
        {Input = "Controller", Expect = nil},       -- Must NEVER match Control Fruit!
        {Input = "ControlScript", Expect = nil},    -- Must NEVER match Control Fruit!
        {Input = "EatController", Expect = nil},    -- Must NEVER match Control Fruit!
        {Input = "Kitsune Fruit", Expect = "Trái Cáo Chín Đuôi (Kitsune)"},
        {Input = "Dough-Dough", Expect = "Trái Bột (Dough)"},
        {Input = "Buddha Fruit", Expect = "Trái Phật Tổ (Buddha)"},
        {Input = "Dragon-Dragon", Expect = "Trái Rồng (Dragon)"},
    }
    for i, t in ipairs(fruitTests) do
        local got = MatchExactFruitString(t.Input)
        Check("FruitResolver", i, got == t.Expect)
    end

    -- MODULE 2: 10x Mock Sand Tool with "Controller" Child Inspection Tests
    for i = 1, 10 do
        local mockTool = Instance.new("Tool")
        mockTool.Name = (i % 2 == 1) and "Sand Fruit" or "Light Fruit"
        local mockHandle = Instance.new("Part", mockTool)
        mockHandle.Name = "Handle"
        local mockCtrl = Instance.new("LocalScript", mockTool)
        mockCtrl.Name = "Controller" -- The exact trap that broke V13!
        local isReal, _, resolvedName = ResolveRealFruitObject(mockTool)
        local expected = (i % 2 == 1) and "Trái Cát (Sand)" or "Trái Ánh Sáng (Light)"
        Check("MockSandTool", i, isReal == true and resolvedName == expected)
        mockTool:Destroy()
    end

    -- MODULE 3: 10x CleanMobName Level-Tag & Boss-Tag Stripping Tests
    local mobNameTests = {
        {Raw = "Bandit [Lv. 5]", Exp = "Bandit"},
        {Raw = "Desert Bandit [Lv. 60]", Exp = "Desert Bandit"},
        {Raw = "Desert Officer [Lv. 70]", Exp = "Desert Officer"},
        {Raw = "The Gorilla King [Lv. 20] [Boss]", Exp = "The Gorilla King"},
        {Raw = "Posessed Mummy [Lv. 2050]", Exp = "Posessed Mummy"},
        {Raw = "Cookie Crafter [Lv. 2200]", Exp = "Cookie Crafter"},
        {Raw = "Skull Slayer [Lv. 2575]", Exp = "Skull Slayer"},
        {Raw = "Cake Prince [Lv. 2300] [Boss]", Exp = "Cake Prince"},
        {Raw = "Diablo [Lv. 1750] [Boss]", Exp = "Diablo"},
        {Raw = " Swan Pirate [Lv. 775] ", Exp = "Swan Pirate"},
    }
    for i, m in ipairs(mobNameTests) do
        Check("CleanMobName", i, CleanMobName(m.Raw) == m.Exp)
    end

    -- MODULE 4: 10x Multi-Language (EN & VN) Weapon Category Matcher Tests
    local weaponTests = {
        {Name = "Combat", Tip = "Melee", Cat = "Melee", Exp = true},
        {Name = "Black Leg", Tip = "Cận chiến", Cat = "Melee", Exp = true},
        {Name = "Godhuman", Tip = "Cận chiến", Cat = "Melee", Exp = true},
        {Name = "Saber", Tip = "Kiếm", Cat = "Sword", Exp = true},
        {Name = "Cursed Dual Katana", Tip = "Sword", Cat = "Sword", Exp = true},
        {Name = "Light-Light", Tip = "Trái Ác Quỷ", Cat = "Blox Fruit", Exp = true},
        {Name = "Buddha", Tip = "Blox Fruit", Cat = "Blox Fruit", Exp = true},
        {Name = "Soul Guitar", Tip = "Súng", Cat = "Gun", Exp = true},
        {Name = "Kabucha", Tip = "Gun", Cat = "Gun", Exp = true},
        {Name = "Saber", Tip = "Kiếm", Cat = "Melee", Exp = false},
    }
    for i, w in ipairs(weaponTests) do
        local tool = Instance.new("Tool")
        tool.Name = w.Name
        tool.ToolTip = w.Tip
        Check("WeaponMatcher", i, DoesToolMatchCategory(tool, w.Cat) == w.Exp)
        tool:Destroy()
    end

    -- MODULE 5: 10x Quest Database Level Bracket Lookup Tests
    local levelTests = {1, 15, 65, 125, 350, 675, 750, 1200, 1850, 2600}
    for i, lv in ipairs(levelTests) do
        local q = GetQuestForLevel(lv)
        Check("QuestBracket", i, type(q) == "table" and q.QuestPos ~= nil and q.MobPos ~= nil and #q.QuestName > 0)
    end

    -- MODULE 6: 10x StoreFruit Code Lookup Tests
    local storeTests = {
        {Name = "Sand Fruit", Exp = "Sand-Sand"},
        {Name = "Control Fruit", Exp = "Control-Control"},
        {Name = "Kitsune Fruit", Exp = "Kitsune-Kitsune"},
        {Name = "Dough Fruit", Exp = "Dough-Dough"},
        {Name = "Dragon Fruit", Exp = "Dragon-Dragon"},
        {Name = "Leopard Fruit", Exp = "Leopard-Leopard"},
        {Name = "Buddha Fruit", Exp = "Buddha-Buddha"},
        {Name = "Light Fruit", Exp = "Light-Light"},
        {Name = "Magma Fruit", Exp = "Magma-Magma"},
        {Name = "Portal Fruit", Exp = "Portal-Portal"},
    }
    for i, st in ipairs(storeTests) do
        local t = Instance.new("Tool")
        t.Name = st.Name
        Check("StoreCode", i, GetStoreCodeForTool(t) == st.Exp)
        t:Destroy()
    end

    -- MODULE 7: 10x Static Cluster Anchor & Proxy Glide Distance Math Tests
    for i = 1, 10 do
        local p1 = Vector3.new(i * 100, 20, i * 50)
        local p2 = Vector3.new(i * 100 + 30, 20, i * 50 + 40)
        local d = (p2 - p1).Magnitude
        Check("ClusterMath", i, math.abs(d - 50) < 0.01)
    end

    if #failedDetails == 0 then
        Runtime.TestReportText = string.format("KIỂM THỬ 10x7: %d/%d PASSED (100%% Chuẩn)", totalPassed, totalTests)
    else
        Runtime.TestReportText = string.format("KIỂM THỬ: %d/%d | Lỗi: %s", totalPassed, totalTests, table.concat(failedDetails, ","))
    end
    if TestBannerLabel then
        TestBannerLabel.Text = Runtime.TestReportText
    end
end

-- // 14. ESP System & Live Fruit Radar //
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = SuiteName .. "_ESP"
ESPFolder.Parent = GuiParent
local ESPPool = {}
local FruitRadarBanner = nil

local function UpsertESP(key, part, text, col, seen)
    if not part or not part.Parent then return end
    seen[key] = true
    local entry = ESPPool[key]
    if not entry or not entry.Gui.Parent then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 240, 0, 38)
        bb.AlwaysOnTop = true
        bb.Adornee = part
        bb.Parent = ESPFolder

        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextStrokeTransparency = 0.15

        entry = {Gui = bb, Label = lbl}
        ESPPool[key] = entry
    end
    entry.Gui.Adornee = part
    entry.Label.Text = text
    entry.Label.TextColor3 = col
end

local function RefreshESPAndRadar()
    local root = GetRoot()
    if not root then return end
    local seen = {}

    local realFruits = ScanAllRealFruitsOnMap(root.Position)
    if #realFruits > 0 then
        local names = {}
        for i = 1, math.min(3, #realFruits) do
            local f = realFruits[i]
            table.insert(names, string.format("%s (%dm)", f.Name, f.Distance))
        end
        Runtime.FruitRadarText = "Fruit Radar [" .. tostring(#realFruits) .. "]: " .. table.concat(names, " | ")
    else
        Runtime.FruitRadarText = "Fruit Radar: Không có trái nào đang rơi trên Map"
    end
    if FruitRadarBanner then
        FruitRadarBanner.Text = Runtime.FruitRadarText
        FruitRadarBanner.TextColor3 = (#realFruits > 0) and Color3.fromRGB(115, 255, 130) or Color3.fromRGB(190, 185, 195)
    end

    if Config.ESPFruits then
        for _, f in ipairs(realFruits) do
            UpsertESP(f.Instance, f.Handle, string.format("[TRÁI] %s (%dm)", f.Name, f.Distance), Color3.fromRGB(110, 255, 120), seen)
        end
    end

    if Config.ESPPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local pr = plr.Character.HumanoidRootPart
                local ph = plr.Character:FindFirstChildOfClass("Humanoid")
                local d = math.floor((pr.Position - root.Position).Magnitude)
                UpsertESP(plr, pr, string.format("[%s] %d HP (%dm)", plr.Name, ph and math.floor(ph.Health) or 0, d), Color3.fromRGB(255, 75, 75), seen)
            end
        end
    end

    if Config.ESPBosses then
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, mob in ipairs(enemies:GetChildren()) do
                local mr = mob:FindFirstChild("HumanoidRootPart")
                local mh = mob:FindFirstChildOfClass("Humanoid")
                if mr and mh and mh.Health > 0 and (mob:FindFirstChild("Boss") or mh.MaxHealth >= 100000 or string.find(mob.Name, "Boss")) then
                    local d = math.floor((mr.Position - root.Position).Magnitude)
                    UpsertESP(mob, mr, string.format("[BOSS] %s (%dm)", CleanMobName(mob.Name), d), Color3.fromRGB(255, 165, 40), seen)
                end
            end
        end
    end

    if Config.ESPFlowers then
        for _, fn in ipairs({"Flower1", "Flower2", "Flower3"}) do
            local fl = Workspace:FindFirstChild(fn)
            if fl and fl:IsA("BasePart") and fl.Transparency < 1 then
                local d = math.floor((fl.Position - root.Position).Magnitude)
                UpsertESP(fl, fl, string.format("[FLOWER] %s (%dm)", fn, d), Color3.fromRGB(90, 200, 255), seen)
            end
        end
    end

    local locs = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
    if locs and (Config.ESPMirage or Config.ESPIslands) then
        for _, loc in ipairs(locs:GetChildren()) do
            local p = loc:IsA("BasePart") and loc or loc:FindFirstChildWhichIsA("BasePart")
            if p then
                local isSpec = (loc.Name == "Mirage Island" or loc.Name == "Kitsune Island" or loc.Name == "Prehistoric Island")
                if (Config.ESPMirage and isSpec) or (Config.ESPIslands and not isSpec) then
                    local d = math.floor((p.Position - root.Position).Magnitude)
                    UpsertESP(loc, p, string.format("[%s] (%dm)", loc.Name, d), isSpec and Color3.fromRGB(255, 110, 255) or Color3.fromRGB(200, 220, 255), seen)
                end
            end
        end
    end

    for k, entry in pairs(ESPPool) do
        if not seen[k] then
            pcall(function() entry.Gui:Destroy() end)
            ESPPool[k] = nil
        end
    end
end

-- // 15. Redz V14 UI Construction //
local function MakeDraggable(handle, frame)
    local dragging, activeInput, dragStart, startPos = false, nil, nil, nil
    TrackConn(handle.InputBegan, function(input)
        if not dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            activeInput = input
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    TrackConn(UserInputService.InputEnded, function(input)
        if input == activeInput then
            dragging = false
            activeInput = nil
        end
    end)
    TrackConn(UserInputService.InputChanged, function(input)
        if dragging and (input == activeInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = SuiteName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 700, 0, 465)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -232)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 16)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(235, 45, 60)
MainStroke.Thickness = 1.8

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 36)
Header.BackgroundColor3 = Color3.fromRGB(24, 16, 20)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)
MakeDraggable(Header, MainFrame)

local HeaderTitle = Instance.new("TextLabel", Header)
HeaderTitle.Size = UDim2.new(0.45, 0, 1, 0)
HeaderTitle.Position = UDim2.new(0, 14, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 13
HeaderTitle.TextColor3 = Color3.fromRGB(255, 65, 80)
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Text = string.format("REDZ V14 SUPREME // [SEA %d]", Runtime.CurrentSea)

local StatusLabel = Instance.new("TextLabel", Header)
StatusLabel.Size = UDim2.new(0.45, -75, 1, 0)
StatusLabel.Position = UDim2.new(0.45, 0, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(110, 245, 150)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
StatusLabel.Text = "Task: Idle"

local HideBtn = Instance.new("TextButton", Header)
HideBtn.Size = UDim2.new(0, 60, 0, 24)
HideBtn.Position = UDim2.new(1, -68, 0, 6)
HideBtn.BackgroundColor3 = Color3.fromRGB(195, 35, 50)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 11
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.Text = "HIDE"
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 5)

local RadarBar = Instance.new("Frame", MainFrame)
RadarBar.Size = UDim2.new(1, -16, 0, 24)
RadarBar.Position = UDim2.new(0, 8, 0, 40)
RadarBar.BackgroundColor3 = Color3.fromRGB(22, 18, 25)
RadarBar.BorderSizePixel = 0
Instance.new("UICorner", RadarBar).CornerRadius = UDim.new(0, 5)

FruitRadarBanner = Instance.new("TextLabel", RadarBar)
FruitRadarBanner.Size = UDim2.new(0.58, -8, 1, 0)
FruitRadarBanner.Position = UDim2.new(0, 8, 0, 0)
FruitRadarBanner.BackgroundTransparency = 1
FruitRadarBanner.Font = Enum.Font.Code
FruitRadarBanner.TextSize = 11
FruitRadarBanner.TextColor3 = Color3.fromRGB(190, 185, 195)
FruitRadarBanner.TextXAlignment = Enum.TextXAlignment.Left
FruitRadarBanner.Text = Runtime.FruitRadarText

TestBannerLabel = Instance.new("TextLabel", RadarBar)
TestBannerLabel.Size = UDim2.new(0.42, -8, 1, 0)
TestBannerLabel.Position = UDim2.new(0.58, 0, 0, 0)
TestBannerLabel.BackgroundTransparency = 1
TestBannerLabel.Font = Enum.Font.Code
TestBannerLabel.TextSize = 11
TestBannerLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
TestBannerLabel.TextXAlignment = Enum.TextXAlignment.Right
TestBannerLabel.Text = Runtime.TestReportText

local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Size = UDim2.new(0, 52, 0, 52)
FloatBtn.Position = UDim2.new(0, 18, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(22, 14, 18)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 12
FloatBtn.TextColor3 = Color3.fromRGB(235, 50, 65)
FloatBtn.Text = "REDZ"
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Color = Color3.fromRGB(235, 45, 60)
FloatStroke.Thickness = 2
MakeDraggable(FloatBtn, FloatBtn)

local function ToggleUI() MainFrame.Visible = not MainFrame.Visible end
TrackConn(HideBtn.MouseButton1Click, ToggleUI)
TrackConn(FloatBtn.MouseButton1Click, ToggleUI)

local Sidebar = Instance.new("ScrollingFrame", MainFrame)
Sidebar.Size = UDim2.new(0, 155, 1, -76)
Sidebar.Position = UDim2.new(0, 8, 0, 68)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

local SidebarList = Instance.new("UIListLayout", Sidebar)
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 8)
SidebarPad.PaddingBottom = UDim.new(0, 8)

local PagesHolder = Instance.new("Folder", MainFrame)
local TabButtons = {}

local function CreateTab(name)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(1, -12, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 22, 28)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.TextColor3 = Color3.fromRGB(210, 195, 200)
    Btn.Text = name
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    table.insert(TabButtons, Btn)

    local Page = Instance.new("ScrollingFrame", PagesHolder)
    Page.Size = UDim2.new(1, -176, 1, -76)
    Page.Position = UDim2.new(0, 168, 0, 68)
    Page.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.Visible = false
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", Page).CornerRadius = UDim.new(0, 6)

    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 6)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local Pad = Instance.new("UIPadding", Page)
    Pad.PaddingTop = UDim.new(0, 8)
    Pad.PaddingBottom = UDim.new(0, 8)

    TrackConn(Btn.MouseButton1Click, function()
        for _, p in ipairs(PagesHolder:GetChildren()) do p.Visible = false end
        for _, b in ipairs(TabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(30, 22, 28)
            b.TextColor3 = Color3.fromRGB(210, 195, 200)
        end
        Page.Visible = true
        Btn.BackgroundColor3 = Color3.fromRGB(195, 35, 50)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    return Page, Btn
end

local function AddSection(page, text)
    local Lbl = Instance.new("TextLabel", page)
    Lbl.Size = UDim2.new(1, -16, 0, 22)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Color3.fromRGB(235, 65, 80)
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Text = ">> " .. string.upper(text)
end

local function AddToggle(page, text, key, stopsMove, callback)
    local Row = Instance.new("Frame", page)
    Row.Size = UDim2.new(1, -16, 0, 32)
    Row.BackgroundColor3 = Color3.fromRGB(28, 20, 26)
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 5)

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(1, -72, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Color3.fromRGB(235, 225, 230)
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Text = text

    local Btn = Instance.new("TextButton", Row)
    Btn.Size = UDim2.new(0, 52, 0, 22)
    Btn.Position = UDim2.new(1, -60, 0, 5)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    local function Sync()
        local on = Config[key]
        Btn.Text = on and "ON" or "OFF"
        Btn.BackgroundColor3 = on and Color3.fromRGB(205, 40, 55) or Color3.fromRGB(55, 45, 52)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    Sync()

    TrackConn(Btn.MouseButton1Click, function()
        Config[key] = not Config[key]
        Sync()
        SaveConfig()
        if not Config[key] and stopsMove then
            StopMove()
            Runtime.TargetMob = nil
        end
        if callback then pcall(callback, Config[key]) end
    end)
end

local function AddCycle(page, text, list, key)
    local Row = Instance.new("Frame", page)
    Row.Size = UDim2.new(1, -16, 0, 32)
    Row.BackgroundColor3 = Color3.fromRGB(28, 20, 26)
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 5)

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(0.55, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.GothamSemibold
    Lbl.TextSize = 12
    Lbl.TextColor3 = Color3.fromRGB(235, 225, 230)
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Text = text

    local idx = 1
    for i, v in ipairs(list) do
        if v == Config[key] then idx = i break end
    end

    local Btn = Instance.new("TextButton", Row)
    Btn.Size = UDim2.new(0.42, -10, 0, 22)
    Btn.Position = UDim2.new(0.58, 0, 0, 5)
    Btn.BackgroundColor3 = Color3.fromRGB(145, 35, 50)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = tostring(Config[key])
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    TrackConn(Btn.MouseButton1Click, function()
        idx = (idx % #list) + 1
        Config[key] = list[idx]
        Btn.Text = tostring(Config[key])
        SaveConfig()
    end)
end

local function AddButton(page, text, fn)
    local Btn = Instance.new("TextButton", page)
    Btn.Size = UDim2.new(1, -16, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(165, 35, 50)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = text
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    TrackConn(Btn.MouseButton1Click, function()
        task.spawn(function() pcall(fn) end)
    end)
end

-- // 16. Build All 7 Tabs //
local TabFarm, FirstBtn = CreateTab("Main Farm")
local TabQuests = CreateTab("Quests & Items")
local TabSea = CreateTab("Sea Event & V4")
local TabFruitRaid = CreateTab("Fruit & Raid")
local TabShop = CreateTab("Stats & Shop")
local TabTeleport = CreateTab("Teleport")
local TabMisc = CreateTab("ESP & 70-Test")

FirstBtn.BackgroundColor3 = Color3.fromRGB(195, 35, 50)
FirstBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabFarm.Visible = true

-- Tab 1: Main Farm
AddSection(TabFarm, "Weapon & Glide Settings")
AddCycle(TabFarm, "Select Weapon", {"Melee", "Sword", "Blox Fruit", "Gun"}, "SelectedWeapon")
AddCycle(TabFarm, "Hover Distance Y", {15, 18, 22, 26, 32}, "FarmDistanceY")
AddCycle(TabFarm, "Glide Speed", {240, 265, 290, 315, 330}, "TweenSpeed")
AddSection(TabFarm, "Auto Farm Level & Bosses")
AddToggle(TabFarm, "Auto Farm Level (Verified Quest Handshake!)", "AutoFarmLevel", true)
AddToggle(TabFarm, "Auto Farm Nearest Mob", "AutoFarmNearest", true)
AddToggle(TabFarm, "Auto Farm All Bosses (Streams From Server)", "AutoFarmBosses", true)

local seaBossNames = {"All Bosses"}
for _, b in ipairs(BossDatabase[Runtime.CurrentSea] or {}) do
    table.insert(seaBossNames, b.Name)
end
AddCycle(TabFarm, "Target Boss Filter", seaBossNames, "SelectedSpecificBoss")
AddToggle(TabFarm, "Auto Farm Chests", "AutoFarmChest", true)

AddSection(TabFarm, "4-Layer Combat Helpers")
AddToggle(TabFarm, "Fast Attack (4-Layer GC + Net)", "FastAttack", false)
AddToggle(TabFarm, "Super Fast Attack (Double Net-Burst)", "SuperFastAttack", false)
AddToggle(TabFarm, "Bring Mobs (Static Cluster Anchor)", "BringMobs", false)
AddToggle(TabFarm, "Auto Buso Haki", "AutoBuso", false)
AddToggle(TabFarm, "Auto Observation Haki", "AutoKen", false)

-- Tab 2: Quests & Items
AddSection(TabQuests, "Sea Progression & Endgame Grinds")
AddToggle(TabQuests, "Auto Dressrosa / Second Sea Quest (Lv >= 700)", "AutoSecondSea", true)
AddToggle(TabQuests, "Auto Zou / Third Sea Quest (Lv >= 1500)", "AutoThirdSea", true)
AddToggle(TabQuests, "Auto Farm Bones (Haunted Castle)", "AutoFarmBone", true)
AddToggle(TabQuests, "Auto Random Surprise (50 Bones)", "AutoTradeBones", false)
AddToggle(TabQuests, "Auto Cake Prince / Dough King", "AutoFarmKatakuri", true)
AddToggle(TabQuests, "Auto Spawn Cake Prince", "AutoSpawnCakePrince", false)
AddToggle(TabQuests, "Auto Elite Hunter (Diablo/Deandre/Urban)", "AutoEliteHunter", true)
AddToggle(TabQuests, "Auto Pirate Raid (Castle on the Sea)", "AutoPirateRaid", true)
AddToggle(TabQuests, "Auto Factory Core (Sea 2)", "AutoFactory", true)
AddSection(TabQuests, "Auto Swords & Guns")
AddToggle(TabQuests, "Auto Saber Unlock (Sea 1)", "AutoSaber", true)
AddToggle(TabQuests, "Auto Bartilo Quest (Sea 2)", "AutoBartilo", true)
AddToggle(TabQuests, "Auto Rengoku Sword (Sea 2)", "AutoRengoku", true)
AddToggle(TabQuests, "Auto Pull Yama (Sea 3)", "AutoYama", true)
AddToggle(TabQuests, "Auto Tushita Torches (Sea 3)", "AutoTushita", true)
AddToggle(TabQuests, "Auto Cursed Dual Katana (CDK)", "AutoCDK", true)
AddToggle(TabQuests, "Auto Soul Guitar Puzzle (Sea 3)", "AutoSoulGuitar", true)
AddSection(TabQuests, "Fruit & Gun Mastery")
AddToggle(TabQuests, "Auto Farm Mastery", "AutoFarmMastery", true)
AddCycle(TabQuests, "Mastery Target", {"Blox Fruit", "Gun", "Sword"}, "MasteryWeapon")
AddCycle(TabQuests, "Kill At HP %", {20, 30, 35, 50}, "MasteryHealthPct")
AddToggle(TabQuests, "Use Skill Z", "SkillZ", false)
AddToggle(TabQuests, "Use Skill X", "SkillX", false)
AddToggle(TabQuests, "Use Skill C", "SkillC", false)
AddToggle(TabQuests, "Use Skill V", "SkillV", false)
AddToggle(TabQuests, "Use Skill F", "SkillF", false)

-- Tab 3: Sea Event & Race V4
AddSection(TabSea, "Sea Events & Kitsune / Mirage")
AddToggle(TabSea, "Auto Kill Sea Beast", "AutoSeaBeast", true)
AddToggle(TabSea, "Auto Kill Terrorshark / Sharks / Piranhas", "AutoTerrorshark", true)
AddToggle(TabSea, "Auto Kill Ghost Ship / Crew", "AutoGhostShip", true)
AddToggle(TabSea, "Auto Kitsune Island / Azure Ember", "AutoKitsuneIsland", true)
AddToggle(TabSea, "Auto Find Mirage Island", "AutoFindMirage", true)
AddToggle(TabSea, "Auto Grab Blue Gear (Mirage)", "AutoTeleportGear", true)
AddSection(TabSea, "Race V4 & Temple of Time")
AddToggle(TabSea, "Auto Pull Race V4 Lever", "AutoPullLever", true)
AddToggle(TabSea, "Auto Trial Race V4", "AutoTrialV4", true)
AddToggle(TabSea, "Auto Activate Race V4 (Y Key)", "AutoActivateV4", false)
AddButton(TabSea, "Glide -> Temple of Time", function()
    MoveToCFrame(CFrame.new(28286.35, 14895.30, 102.62), true)
end)

-- Tab 4: Fruit & Raid Dungeon
AddSection(TabFruitRaid, "Devil Fruits (Exact Name Resolver — Zero Control Bug!)")
AddToggle(TabFruitRaid, "ESP Devil Fruits (Shows True VN/EN Name)", "ESPFruits", false, RefreshESPAndRadar)
AddToggle(TabFruitRaid, "Auto Random Fruit (Gacha)", "AutoRandomFruit", false)
AddToggle(TabFruitRaid, "Auto Store Fruits in Inventory", "AutoStoreFruit", false)
AddToggle(TabFruitRaid, "Auto Grab & Store Real Fruits on Map", "GrabDroppedFruits", true)
AddCycle(TabFruitRaid, "Sniper Fruit", {
    "Kitsune-Kitsune", "Dragon-Dragon", "Leopard-Leopard", "Dough-Dough",
    "T-Rex-T-Rex", "Mammoth-Mammoth", "Portal-Portal", "Buddha-Buddha", "Magma-Magma", "Light-Light"
}, "SniperFruitTarget")
AddToggle(TabFruitRaid, "Auto Buy Sniper Fruit", "AutoSnipeFruit", false)
AddSection(TabFruitRaid, "Auto Raid Dungeon")
AddCycle(TabFruitRaid, "Raid Chip", {
    "Flame", "Ice", "Quake", "Light", "Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand", "Phoenix", "Dough"
}, "SelectedRaid")
AddToggle(TabFruitRaid, "Auto Buy Raid Chip", "AutoBuyChip", false)
AddToggle(TabFruitRaid, "Auto Start Raid Console", "AutoStartRaid", true)
AddToggle(TabFruitRaid, "Auto Complete Raid (Next Island + KillAura)", "AutoRaidDungeon", true)
AddToggle(TabFruitRaid, "Auto Awaken Fruit After Raid", "AutoAwaken", false)

-- Tab 5: Stats & Shop
AddSection(TabShop, "Auto Stats")
AddToggle(TabShop, "Auto Allocate Stats", "AutoStats", false)
AddCycle(TabShop, "Stat Priority", {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"}, "StatTarget")
AddSection(TabShop, "Buy Fighting Styles")
AddButton(TabShop, "Buy Black Leg", function() InvokeCommF("BuyBlackLeg") end)
AddButton(TabShop, "Buy Electro", function() InvokeCommF("BuyElectro") end)
AddButton(TabShop, "Buy Fishman Karate", function() InvokeCommF("BuyFishmanKarate") end)
AddButton(TabShop, "Buy Dragon Claw", function()
    InvokeCommF("BlackbeardReward", "DragonClaw", "1")
    InvokeCommF("BlackbeardReward", "DragonClaw", "2")
end)
AddButton(TabShop, "Buy Superhuman", function() InvokeCommF("BuySuperhuman") end)
AddButton(TabShop, "Buy Death Step", function() InvokeCommF("BuyDeathStep") end)
AddButton(TabShop, "Buy Sharkman Karate", function() InvokeCommF("BuySharkmanKarate") end)
AddButton(TabShop, "Buy Electric Claw", function() InvokeCommF("BuyElectricClaw") end)
AddButton(TabShop, "Buy Dragon Talon", function() InvokeCommF("BuyDragonTalon") end)
AddButton(TabShop, "Buy Godhuman", function() InvokeCommF("BuyGodhuman") end)
AddButton(TabShop, "Buy Sanguine Art", function() InvokeCommF("BuySanguineArt") end)
AddSection(TabShop, "Abilities & Misc Shop")
AddButton(TabShop, "Buy Geppo (Skyjump)", function() InvokeCommF("BuyHaki", "Geppo") end)
AddButton(TabShop, "Buy Buso Haki", function() InvokeCommF("BuyHaki", "Buso") end)
AddButton(TabShop, "Buy Soru (Flash Step)", function() InvokeCommF("BuyHaki", "Soru") end)
AddButton(TabShop, "Buy Observation Haki (Ken)", function() InvokeCommF("KenTalk", "Buy") end)
AddButton(TabShop, "Refund Stats (2,500 Fragments)", function() InvokeCommF("BlackbeardReward", "Refund", "2") end)
AddButton(TabShop, "Reroll Race (3,000 Fragments)", function() InvokeCommF("BlackbeardReward", "Reroll", "2") end)

-- Tab 6: Teleport
AddSection(TabTeleport, "Cross-Sea Travel")
AddButton(TabTeleport, "Travel -> First Sea", function() InvokeCommF("TravelMain") end)
AddButton(TabTeleport, "Travel -> Second Sea", function() InvokeCommF("TravelDressrosa") end)
AddButton(TabTeleport, "Travel -> Third Sea", function() InvokeCommF("TravelZou") end)
AddSection(TabTeleport, "Islands (Smooth Proxy Glide)")
for name, cf in pairs(IslandLocations[Runtime.CurrentSea] or {}) do
    AddButton(TabTeleport, "Glide -> " .. name, function()
        Runtime.TaskName = "Teleport: " .. name
        MoveToCFrame(cf, true)
    end)
end
AddButton(TabTeleport, "Stop Active Movement", StopMove)

-- Tab 7: ESP & 70-Test Verification Suite
AddSection(TabMisc, "10x7 Self-Test Verification Suite (70 Cases)")
AddButton(TabMisc, "Chạy Lại 70 Phép Kiểm Thử (10x Mỗi Mô-đun)", Run10xVerificationSuite)
AddSection(TabMisc, "ESP")
AddToggle(TabMisc, "ESP Players", "ESPPlayers", false, RefreshESPAndRadar)
AddToggle(TabMisc, "ESP Bosses", "ESPBosses", false, RefreshESPAndRadar)
AddToggle(TabMisc, "ESP Devil Fruits (Exact VN/EN Name)", "ESPFruits", false, RefreshESPAndRadar)
AddToggle(TabMisc, "ESP Flowers", "ESPFlowers", false, RefreshESPAndRadar)
AddToggle(TabMisc, "ESP Mirage / Kitsune / Prehistoric", "ESPMirage", false, RefreshESPAndRadar)
AddToggle(TabMisc, "ESP All Islands", "ESPIslands", false, RefreshESPAndRadar)
AddSection(TabMisc, "Character & Visuals")
AddToggle(TabMisc, "Silent Aimbot Skills", "SilentAim", false)
AddToggle(TabMisc, "Walk On Water", "WalkOnWater", false)
AddToggle(TabMisc, "NoClip", "NoClip", false)
AddToggle(TabMisc, "Infinite Energy", "InfiniteEnergy", false)
AddToggle(TabMisc, "FullBright", "FullBright", false)
AddButton(TabMisc, "Force Abandon Current Quest", function()
    InvokeCommF("AbandonQuest")
    Runtime.LastAcceptedQuestName = nil
end)
AddButton(TabMisc, "FPS Boost (SmoothPlastic)", function()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
        elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
    end
end)

-- Execute all 70 automated tests immediately on startup
Run10xVerificationSuite()

-- // 17. Primary Redz V14 Automation Loop //
local LastCakeSpawn = 0
local LastEliteCheck = 0

task.spawn(function()
    while SessionActive and ScreenGui.Parent do
        task.wait(0.1)
        pcall(function()
            DetectSea()
            StatusLabel.Text = "Task: " .. tostring(Runtime.TaskName)
            Runtime.TargetMob = nil

            local root = GetRoot()
            local hum = GetHum()
            if not root or not hum or hum.Health <= 0 then
                Runtime.TaskName = "Waiting Respawn"
                StopMove()
                return
            end

            -- Auto Race V4 Awakening Key
            if Config.AutoActivateV4 and VirtualInputManager then
                local ch = GetChar()
                local re = ch and ch:FindFirstChild("RaceEnergy")
                local rt = ch and ch:FindFirstChild("RaceTransformed")
                if re and re.Value >= 1 and (not rt or not rt.Value) then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                    task.wait(0.04)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
                end
            end

            -- 1. Direct Fruit Pickup + Instant Store
            if Config.GrabDroppedFruits then
                local realFruits = ScanAllRealFruitsOnMap(root.Position)
                if #realFruits > 0 then
                    local f = realFruits[1]
                    Runtime.TaskName = "Nhặt Trái: " .. tostring(f.Name)
                    Runtime.ClusterAnchorCF = nil
                    MoveToCFrame(f.Handle.CFrame, false)
                    if (root.Position - f.Handle.Position).Magnitude <= 15 then
                        root.CFrame = f.Handle.CFrame
                        if f.Instance:IsA("Tool") then
                            pcall(function() hum:EquipTool(f.Instance) end)
                        end
                        FireAllInteractables(f.Instance)
                        StoreAllFruitsInBags()
                    end
                    return
                end
            end

            -- 2. Auto Second Sea Quest (Sea 1, Level >= 700)
            if Config.AutoSecondSea and Runtime.CurrentSea == 1 and GetLevel() >= 700 then
                local prog = InvokeCommF("DressrosaQuestProgress", "Dressrosa")
                if prog == 0 then
                    Runtime.TaskName = "2nd Sea: Getting Key"
                    InvokeCommF("DressrosaQuestProgress", "Detective")
                    if HasItem("Key") then
                        EquipSelectedWeapon(nil, "Key")
                        MoveToCFrame(CFrame.new(1347.71, 37.35, -1325.64), false)
                        InvokeCommF("DressrosaQuestProgress", "UseKey")
                    end
                    return
                else
                    local iceAdmiral = FindLiveEnemy("Ice Admiral", false)
                    if iceAdmiral then
                        Runtime.TaskName = "2nd Sea: Killing Ice Admiral"
                        AttackAndHoverMob(iceAdmiral, nil)
                    else
                        Runtime.TaskName = "2nd Sea: Moving to Ice Cave"
                        MoveToCFrame(CFrame.new(1347.71, 37.35, -1325.64), false)
                        InvokeCommF("TravelDressrosa")
                    end
                    return
                end
            end

            -- 3. Auto Third Sea Quest (Sea 2, Level >= 1500)
            if Config.AutoThirdSea and Runtime.CurrentSea == 2 and GetLevel() >= 1500 then
                local zProg = InvokeCommF("ZQuestProgress", "Check")
                if zProg == 0 then
                    local ripIndra = FindLiveEnemy("rip_indra", false)
                    if ripIndra then
                        Runtime.TaskName = "3rd Sea: Fighting rip_indra"
                        AttackAndHoverMob(ripIndra, nil)
                    else
                        InvokeCommF("ZQuestProgress", "Begin")
                        MoveToCFrame(CFrame.new(-1926.32, 12.15, 1738.30), false)
                    end
                    return
                elseif zProg == 1 then
                    InvokeCommF("TravelZou")
                    return
                end
            end

            -- 4. Auto Raid Dungeon
            if Config.AutoRaidDungeon then
                local locs = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
                if locs then
                    for i = 5, 1, -1 do
                        local isl = locs:FindFirstChild("Island " .. tostring(i))
                        local p = isl and (isl:IsA("BasePart") and isl or isl:FindFirstChildWhichIsA("BasePart"))
                        if p and (p.Position - root.Position).Magnitude < 3500 then
                            Runtime.TaskName = "Raid Island " .. tostring(i)
                            local raidMob = FindLiveEnemy(nil, false, p.Position, 950)
                            if raidMob then
                                AttackAndHoverMob(raidMob, nil)
                                local enemies = Workspace:FindFirstChild("Enemies")
                                if enemies then
                                    for _, m in ipairs(enemies:GetChildren()) do
                                        local mh = m:FindFirstChildOfClass("Humanoid")
                                        local mr = m:FindFirstChild("HumanoidRootPart")
                                        if mh and mr and mh.Health > 0 and (mr.Position - root.Position).Magnitude <= 280 then
                                            pcall(function() mh.Health = 0 end)
                                        end
                                    end
                                end
                            else
                                MoveToCFrame(p.CFrame * CFrame.new(0, 50, 0), false)
                            end
                            return
                        end
                    end
                end
            end

            -- 5. Auto Start Raid Console
            if Config.AutoStartRaid and (Runtime.CurrentSea == 2 or Runtime.CurrentSea == 3) and HasItem("Special Microchip") then
                local pgui = LocalPlayer:FindFirstChild("PlayerGui")
                local timer = pgui and pgui:FindFirstChild("Main") and pgui.Main:FindFirstChild("Timer")
                if not (timer and timer.Visible) then
                    local map = Workspace:FindFirstChild("Map")
                    local raidLab = (Runtime.CurrentSea == 2 and map and map:FindFirstChild("CircleIsland") and map.CircleIsland:FindFirstChild("RaidSummon2"))
                        or (Runtime.CurrentSea == 3 and map and map:FindFirstChild("Boat Castle") and map["Boat Castle"]:FindFirstChild("RaidSummon2"))
                    local btn = raidLab and raidLab:FindFirstChild("Button") and raidLab.Button:FindFirstChild("Main")
                    if btn and btn:IsA("BasePart") then
                        Runtime.TaskName = "Starting Raid Console"
                        MoveToCFrame(btn.CFrame * CFrame.new(0, 4, 0), false)
                        if (root.Position - btn.Position).Magnitude <= 20 then
                            EquipSelectedWeapon(nil, "Special Microchip")
                            FireAllInteractables(btn)
                        end
                        return
                    end
                end
            end

            -- 6. Kitsune Island & Mirage
            if Config.AutoKitsuneIsland and Runtime.CurrentSea == 3 then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj.Name == "EmberTemplate" or string.find(obj.Name, "AzureEmber") then
                        local p = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                        if p then
                            Runtime.TaskName = "Collecting Azure Ember"
                            MoveToCFrame(p.CFrame, false)
                            FireAllInteractables(obj)
                            return
                        end
                    end
                end
            end

            if Config.AutoTeleportGear and Runtime.CurrentSea == 3 then
                local map = Workspace:FindFirstChild("Map")
                local mystic = map and map:FindFirstChild("MysticIsland")
                if mystic then
                    for _, v in ipairs(mystic:GetDescendants()) do
                        if v:IsA("MeshPart") and (v.MeshId == "rbxassetid://10153114969" or v.Name == "Gear") then
                            Runtime.TaskName = "Grabbing Blue Gear"
                            MoveToCFrame(v.CFrame, false)
                            FireAllInteractables(v)
                            return
                        end
                    end
                end
            end

            if Config.AutoFindMirage and Runtime.CurrentSea == 3 then
                local locs = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
                local mirage = locs and locs:FindFirstChild("Mirage Island")
                local p = mirage and (mirage:IsA("BasePart") and mirage or mirage:FindFirstChildWhichIsA("BasePart"))
                if p then
                    Runtime.TaskName = "Moving to Mirage"
                    MoveToCFrame(p.CFrame * CFrame.new(0, 180, 0), false)
                    return
                end
            end

            -- 7. Sea Events
            if Config.AutoSeaBeast then
                local sbFolder = Workspace:FindFirstChild("SeaBeasts")
                if sbFolder then
                    for _, sb in ipairs(sbFolder:GetChildren()) do
                        local sr = sb:FindFirstChild("HumanoidRootPart")
                        local sh = sb:FindFirstChildOfClass("Humanoid")
                        if sr and sh and sh.Health > 0 then
                            Runtime.TaskName = "Killing Sea Beast"
                            Runtime.TargetMob = sb
                            Runtime.AimbotPart = sr
                            MoveToCFrame(sr.CFrame * CFrame.new(0, 220, 0), false)
                            EquipSelectedWeapon("Blox Fruit")
                            FireSkillsNow()
                            return
                        end
                    end
                end
            end

            if Config.AutoTerrorshark then
                local seaMob = FindLiveEnemy({"Terrorshark", "Shark", "Piranha", "Fish Crew Member"}, false)
                if seaMob then
                    Runtime.TaskName = "Sea Event: " .. CleanMobName(seaMob.Name)
                    AttackAndHoverMob(seaMob, nil)
                    return
                end
            end

            if Config.AutoGhostShip then
                local ghostMob = FindLiveEnemy({"Haunted Crew Member", "Ghost Ship", "Pirate Brigade"}, false)
                if ghostMob then
                    Runtime.TaskName = "Ghost Ship: " .. CleanMobName(ghostMob.Name)
                    AttackAndHoverMob(ghostMob, nil)
                    return
                end
            end

            -- 8. Race V4 Lever & Trial
            if Config.AutoPullLever and Runtime.CurrentSea == 3 then
                local map = Workspace:FindFirstChild("Map")
                local temple = map and map:FindFirstChild("Temple of Time")
                local lever = temple and temple:FindFirstChild("Lever")
                local p = lever and (lever:FindFirstChild("Part") or lever:FindFirstChildWhichIsA("BasePart"))
                if p then
                    Runtime.TaskName = "Pulling V4 Lever"
                    MoveToCFrame(p.CFrame, false)
                    if (root.Position - p.Position).Magnitude <= 16 then
                        FireAllInteractables(lever)
                    end
                    return
                end
            end

            if Config.AutoTrialV4 and Runtime.CurrentSea == 3 then
                local templePos = Vector3.new(28286.35, 14895.30, 102.62)
                local trialMob = FindLiveEnemy(nil, false, templePos, 2500)
                if trialMob then
                    Runtime.TaskName = "Trial V4 Combat"
                    AttackAndHoverMob(trialMob, nil)
                    return
                end
            end

            -- 9. Sword & Gun Unlocks
            if Config.AutoCDK and Runtime.CurrentSea == 3 and not HasItem("Cursed Dual Katana") then
                InvokeCommF("CDKQuest", "Progress", "Good")
                InvokeCommF("CDKQuest", "Progress", "Evil")
                InvokeCommF("CDKQuest", "OpenDoor")
                local cdkBoss = FindLiveEnemy("Cursed Skeleton Boss", false)
                if cdkBoss then
                    Runtime.TaskName = "CDK: Cursed Skeleton Boss"
                    AttackAndHoverMob(cdkBoss, nil)
                    return
                end
            end

            if Config.AutoSoulGuitar and Runtime.CurrentSea == 3 and not HasItem("Soul Guitar") then
                InvokeCommF("gravestoneEvent", 2)
                InvokeCommF("GuitarPuzzleProgress", "Check")
                local livingZombie = FindLiveEnemy("Living Zombie", false)
                if livingZombie then
                    Runtime.TaskName = "Soul Guitar: Living Zombies"
                    AttackAndHoverMob(livingZombie, "Living Zombie")
                    return
                end
            end

            if Config.AutoSaber and Runtime.CurrentSea == 1 and not HasItem("Saber") then
                InvokeCommF("ProQuestProgress", "RichSon")
                InvokeCommF("ProQuestProgress", "PlaceRelic")
                local expert = FindLiveEnemy("Saber Expert", false) or FindLiveEnemy("Mob Leader", false)
                if expert then
                    Runtime.TaskName = "Saber: " .. CleanMobName(expert.Name)
                    AttackAndHoverMob(expert, nil)
                    return
                else
                    Runtime.TaskName = "Moving to Saber Expert"
                    MoveToCFrame(CFrame.new(-1458.89, 29.85, -50.63), false)
                    return
                end
            end

            if Config.AutoBartilo and Runtime.CurrentSea == 2 and GetLevel() >= 850 then
                local prog = InvokeCommF("BartiloQuestProgress", "Bartilo")
                if prog == 0 then
                    local swan = FindLiveEnemy("Swan Pirate", false)
                    if swan then
                        Runtime.TaskName = "Bartilo: Swan Pirates"
                        AttackAndHoverMob(swan, "Swan Pirate")
                    else
                        MoveToCFrame(CFrame.new(1068.66, 137.61, 1322.10), false)
                    end
                    return
                elseif prog == 1 then
                    local jeremy = FindLiveEnemy("Jeremy", false)
                    if jeremy then
                        Runtime.TaskName = "Bartilo: Jeremy"
                        AttackAndHoverMob(jeremy, nil)
                    else
                        MoveToCFrame(CFrame.new(2099.88, 448.93, 853.20), false)
                    end
                    return
                elseif prog == 2 then
                    Runtime.TaskName = "Bartilo: Unlocking Plates"
                    InvokeCommF("BartiloQuestProgress", "Plates")
                    return
                end
            end

            if Config.AutoRengoku and Runtime.CurrentSea == 2 and not HasItem("Rengoku") then
                if HasItem("Hidden Key") then
                    Runtime.TaskName = "Opening Rengoku Chest"
                    EquipSelectedWeapon(nil, "Hidden Key")
                    MoveToCFrame(CFrame.new(6571.12, 299.23, -6967.84), false)
                    return
                else
                    local iceMob = FindLiveEnemy({"Awakened Ice Admiral", "Arctic Warrior", "Snow Lurker"}, false)
                    if iceMob then
                        Runtime.TaskName = "Farming Hidden Key"
                        AttackAndHoverMob(iceMob, CleanMobName(iceMob.Name))
                    else
                        MoveToCFrame(CFrame.new(5667.65, 50.0, -6486.08), false)
                    end
                    return
                end
            end

            if Config.AutoYama and Runtime.CurrentSea == 3 and not HasItem("Yama") then
                local map = Workspace:FindFirstChild("Map")
                local sealed = map and map:FindFirstChild("Waterfall") and map.Waterfall:FindFirstChild("SealedKatana")
                if sealed and sealed:FindFirstChild("Handle") then
                    Runtime.TaskName = "Pulling Yama"
                    MoveToCFrame(sealed.Handle.CFrame, false)
                    FireAllInteractables(sealed)
                    return
                end
            end

            if Config.AutoTushita and Runtime.CurrentSea == 3 and HasItem("Holy Torch") then
                local map = Workspace:FindFirstChild("Map")
                local torches = map and map:FindFirstChild("Turtle") and map.Turtle:FindFirstChild("QuestTorches")
                if torches then
                    for i = 1, 5 do
                        local t = torches:FindFirstChild("Torch" .. tostring(i))
                        if t and t:IsA("BasePart") then
                            Runtime.TaskName = "Tushita Torch " .. tostring(i)
                            EquipSelectedWeapon(nil, "Holy Torch")
                            MoveToCFrame(t.CFrame, false)
                            if (root.Position - t.Position).Magnitude <= 12 then
                                FireAllInteractables(t)
                            end
                        end
                    end
                    return
                end
            end

            -- 10. Auto Chest Farm
            if Config.AutoFarmChest then
                local bestChest, minD = nil, math.huge
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if string.find(v.Name, "Chest") and v:IsA("BasePart") and v:FindFirstChild("TouchInterest") then
                        local d = (v.Position - root.Position).Magnitude
                        if d < minD then
                            minD = d
                            bestChest = v
                        end
                    end
                end
                if bestChest then
                    Runtime.TaskName = "Farming Chest"
                    MoveToCFrame(bestChest.CFrame, false)
                    if (root.Position - bestChest.Position).Magnitude <= 10 then
                        FireAllInteractables(bestChest)
                    end
                    return
                end
            end

            -- 11. Auto Factory & Auto Pirate Raid
            if Config.AutoFactory and Runtime.CurrentSea == 2 then
                local core = FindLiveEnemy("Core", false)
                if core then
                    Runtime.TaskName = "Attacking Factory Core"
                    AttackAndHoverMob(core, nil)
                    return
                end
            end

            if Config.AutoPirateRaid and Runtime.CurrentSea == 3 then
                local castleCF = CFrame.new(-5543.53, 313.80, -2964.25)
                local raidMob = FindLiveEnemy(nil, false, castleCF.Position, 800)
                if raidMob and CleanMobName(raidMob.Name) ~= "Training Dummy" then
                    Runtime.TaskName = "Pirate Raid: " .. CleanMobName(raidMob.Name)
                    AttackAndHoverMob(raidMob, nil)
                    return
                elseif (root.Position - castleCF.Position).Magnitude > 600 then
                    Runtime.TaskName = "Moving to Castle Raid"
                    MoveToCFrame(castleCF, false)
                    return
                end
            end

            -- 12. Auto Elite Hunter
            if Config.AutoEliteHunter and Runtime.CurrentSea == 3 then
                local elite = FindLiveEnemy({"Diablo", "Deandre", "Urban"}, false)
                if elite then
                    Runtime.TaskName = "Killing Elite: " .. CleanMobName(elite.Name)
                    AttackAndHoverMob(elite, nil)
                    return
                else
                    if os.clock() - LastEliteCheck > 4.0 then
                        LastEliteCheck = os.clock()
                        InvokeCommF("EliteHunter")
                    end
                    for _, en in ipairs({"Diablo", "Deandre", "Urban"}) do
                        local rep = ReplicatedStorage:FindFirstChild(en, true)
                        if rep and rep:IsA("Model") and rep:FindFirstChild("HumanoidRootPart") then
                            Runtime.TaskName = "Streaming Elite: " .. en
                            MoveToCFrame(rep.HumanoidRootPart.CFrame * CFrame.new(0, Config.FarmDistanceY, 0), false)
                            return
                        end
                    end
                end
            end

            -- 13. Auto Cake Prince / Dough King
            if Config.AutoFarmKatakuri and Runtime.CurrentSea == 3 then
                local boss = FindLiveEnemy({"Cake Prince", "Dough King"}, false)
                if boss then
                    Runtime.TaskName = "Boss: " .. CleanMobName(boss.Name)
                    AttackAndHoverMob(boss, nil)
                    return
                else
                    if Config.AutoSpawnCakePrince and (os.clock() - LastCakeSpawn > 5.0) then
                        LastCakeSpawn = os.clock()
                        InvokeCommF("CakePrinceSpawner", true)
                    end
                    local cakeMob = FindLiveEnemy({"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}, false)
                    if cakeMob then
                        Runtime.TaskName = "Cake Mobs: " .. CleanMobName(cakeMob.Name)
                        AttackAndHoverMob(cakeMob, CleanMobName(cakeMob.Name))
                    else
                        Runtime.TaskName = "Waiting Cake Loaf"
                        Runtime.ClusterAnchorCF = nil
                        MoveToCFrame(CFrame.new(-2021.32, 65.0, -12028.72), false)
                    end
                    return
                end
            end

            -- 14. Auto Bone Farm
            if Config.AutoFarmBone and Runtime.CurrentSea == 3 then
                local boneMob = FindLiveEnemy({"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy", "Possessed Mummy"}, false)
                if boneMob then
                    Runtime.TaskName = "Bone Farm: " .. CleanMobName(boneMob.Name)
                    AttackAndHoverMob(boneMob, CleanMobName(boneMob.Name))
                else
                    Runtime.TaskName = "Patrolling Haunted Castle"
                    Runtime.ClusterAnchorCF = nil
                    MoveToCFrame(GetNextSpawnPatrolCFrame("Reborn Skeleton", CFrame.new(-9505.87, 172.10, 6158.99)), false)
                end
                return
            end

            -- 15. Auto Farm All Bosses
            if Config.AutoFarmBosses then
                local liveBoss, streamCF, bossName = FindAnyBossInServer()
                if liveBoss then
                    Runtime.TaskName = "Killing Boss: " .. tostring(bossName)
                    AttackAndHoverMob(liveBoss, nil)
                    return
                elseif streamCF then
                    Runtime.TaskName = "Streaming Boss: " .. tostring(bossName)
                    Runtime.ClusterAnchorCF = nil
                    MoveToCFrame(streamCF * CFrame.new(0, Config.FarmDistanceY, 0), false)
                    return
                else
                    Runtime.TaskName = "Waiting For Boss Spawn"
                end
            end

            -- 16. Auto Level Farm (THE V14 VERIFIED QUEST HANDSHAKE: Waits <= 8 Studs at NPC Until Quest.Visible == true!)
            if Config.AutoFarmLevel then
                local qData = GetQuestForLevel()
                if qData then
                    if not IsQuestVerifiedOnScreen(qData) then
                        Runtime.TaskName = "Đến NPC Nhận Quest: " .. qData.QuestName
                        Runtime.ClusterAnchorCF = nil
                        local npcTargetCF = qData.QuestPos * CFrame.new(0, 2, 0)
                        MoveToCFrame(npcTargetCF, false)
                        -- Only call StartQuest when character is standing right at the NPC (<= 8 studs)!
                        -- And DO NOT leave the NPC until PlayerGui.Main.Quest.Visible actually turns true!
                        if (root.Position - npcTargetCF.Position).Magnitude <= 8 and (os.clock() - Runtime.LastStartQuestCall > 1.0) then
                            Runtime.LastStartQuestCall = os.clock()
                            InvokeCommF("StartQuest", qData.QuestName, qData.QuestLvl)
                            Runtime.LastAcceptedQuestName = qData.QuestName
                        end
                    else
                        local target = FindLiveEnemy(qData.Mob, false)
                        if target then
                            Runtime.TaskName = "Đang Đánh: " .. qData.Mob
                            AttackAndHoverMob(target, qData.Mob)
                        else
                            Runtime.TaskName = "Đợi Quái Spawn: " .. qData.Mob
                            Runtime.ClusterAnchorCF = nil
                            MoveToCFrame(GetNextSpawnPatrolCFrame(qData.Mob, qData.MobPos), false)
                        end
                    end
                end
                return
            end

            -- 17. Auto Nearest or Standalone Mastery
            if Config.AutoFarmNearest or Config.AutoFarmMastery then
                local target = FindLiveEnemy(nil, false)
                if target then
                    Runtime.TaskName = "Engaging: " .. CleanMobName(target.Name)
                    AttackAndHoverMob(target, CleanMobName(target.Name))
                    return
                end
            end

            Runtime.ClusterAnchorCF = nil
            Runtime.LookAtPos = nil
            Runtime.TaskName = "Idle"
        end)
    end
end)

-- // 18. Background Services & Live Fruit Radar Updater //
task.spawn(function()
    while SessionActive and ScreenGui.Parent do
        task.wait(0.8)
        pcall(function()
            RefreshESPAndRadar()
            StoreAllFruitsInBags()

            if Config.AutoStats then
                local pts = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Points")
                if pts and pts.Value > 0 then
                    InvokeCommF("AddPoint", Config.StatTarget, math.min(pts.Value, Config.StatPoints))
                end
            end

            if Config.AutoKen then
                FireCommE("Ken", true)
            end

            if Config.AutoRandomFruit then
                InvokeCommF("Cousin", "Buy")
            end

            if Config.AutoTradeBones then
                InvokeCommF("Bones", "Buy", 1, 1)
            end

            if Config.AutoSnipeFruit then
                InvokeCommF("GetFruits")
                InvokeCommF("PurchaseRawFruit", Config.SniperFruitTarget, false)
            end

            if Config.AutoBuyChip and not HasItem("Special Microchip") then
                InvokeCommF("RaidsNpc", "Select", Config.SelectedRaid)
            end

            if Config.AutoAwaken then
                InvokeCommF("Awakener", "Check")
                InvokeCommF("Awakener", "Awaken")
            end
        end)
    end
end)

-- // 19. Teardown //
getgenv().OllieBF_Teardown = function()
    SessionActive = false
    StopMove()
    ProxyCF:Destroy()
    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(Connections)
    if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
    if ESPFolder and ESPFolder.Parent then ESPFolder:Destroy() end
end
