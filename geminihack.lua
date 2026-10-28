-- // BLOX FRUITS V6 (STATIC-AUDIT REMEDIATED ARCHITECTURE) //
-- Self-contained Luau build. Honest state reporting: [OK], [ATTEMPT], [WARN], [FAIL].

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- // 1. Services & Cloned References //
local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))
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

-- // 2. Granular Executor Capability Probe (Fixes #1, #85, #86) //
local getgenv = getgenv or function() return _G end
local raw_sethiddenproperty = sethiddenproperty or set_hidden_property or sethiddenprop
local raw_hookmetamethod = hookmetamethod
local raw_getnamecallmethod = getnamecallmethod
local raw_newcclosure = newcclosure or function(f) return f end
local raw_checkcaller = checkcaller
local raw_getupvalues = (debug and debug.getupvalues) or getupvalues or getupvals
local raw_setupvalue = (debug and debug.setupvalue) or setupvalue or setupval
local raw_getconstants = (debug and debug.getconstants) or getconstants or getconsts
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

local Capabilities = {
    HookMeta = type(raw_hookmetamethod) == "function" and type(raw_getnamecallmethod) == "function",
    CheckCaller = type(raw_checkcaller) == "function",
    Upvalues = type(raw_getupvalues) == "function" and type(raw_setupvalue) == "function",
    GetConsts = type(raw_getconstants) == "function",
    GetGC = type(raw_getgc) == "function",
    SimRadius = type(raw_sethiddenproperty) == "function",
    Touch = type(raw_firetouchinterest) == "function",
    Click = type(raw_fireclickdetector) == "function",
    Prompt = type(raw_fireproximityprompt) == "function",
    FileIO = type(raw_writefile) == "function" and type(raw_readfile) == "function" and type(raw_isfile) == "function",
    FolderIO = type(raw_makefolder) == "function" and type(raw_isfolder) == "function",
    VIM = VirtualInputManager ~= nil,
}

-- // 3. Prior Session Teardown & Validated GUI Root (Fixes #81, #82) //
local SuiteName = "OllieBench_BF_V6"
if getgenv().OllieBF_Teardown then
    pcall(getgenv().OllieBF_Teardown)
end

local SessionActive = true
local Connections = {}

local function TrackConn(signal, callback)
    if not signal then return nil end
    local conn = signal:Connect(callback)
    table.insert(Connections, conn)
    return conn
end

local function GetValidatedGuiParent()
    local cached = getgenv().OllieBF_GuiRoot
    if typeof(cached) == "Instance" and cached.Parent then
        local testOk = pcall(function()
            local f = Instance.new("Folder")
            f.Parent = cached
            f:Destroy()
        end)
        if testOk then return cached end
    end
    local ok, root = pcall(function()
        if gethui then return gethui() end
        return CoreGui
    end)
    local chosen = (ok and typeof(root) == "Instance" and root) or LocalPlayer:WaitForChild("PlayerGui", 10)
    getgenv().OllieBF_GuiRoot = chosen
    return chosen
end

local GuiParent = GetValidatedGuiParent()
for _, child in ipairs(GuiParent:GetChildren()) do
    if child.Name == SuiteName or child.Name == SuiteName .. "_ESP" then
        pcall(function() child:Destroy() end)
    end
end

-- // 4. Structured Logger, Cooldown Governor & Mutex Remote Dispatcher (Fixes #57-#60, #71, #80) //
local Runtime = {
    TaskName = "Idle",
    LastStatusTag = "READY",
    LastLog = "Initialized",
    LastLogTime = os.clock(),
    AimbotTargetPart = nil,
    MoveTargetCF = nil,
    MoveMode = "None", -- "OneShot" | "HoverLock"
    MoveOwner = nil,
    MoveGenerationId = 0,
    ArrivedMoveId = -1,
    ArrivedAtTarget = false,
    PortalPauseUntil = 0,
    CurrentSea = 1,
    KnownSea = false,
    MaxEnergySnapshot = 100,
    CollisionSnapshot = {},
    NoClipApplied = false,
    WaterPlaneSizeSnapshot = nil,
    WaterPlaneModified = false,
    ServerInventoryCache = {},
    LastInventorySync = 0,
}

local DefaultLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
}

-- Weak-keyed tables for NPC restoration & visited chests (Fixes #20, #21, #50)
local ModifiedNPCs = setmetatable({}, {__mode = "k"})
local VisitedChests = setmetatable({}, {__mode = "k"})
local OriginalUpvalues = {} -- Stores {fn, idx, oldVal} for GC patch restoration

local function SetLog(tag, msg)
    Runtime.LastStatusTag = tostring(tag or "INFO")
    Runtime.LastLog = tostring(msg or "")
    Runtime.LastLogTime = os.clock()
end

local CooldownTimestamps = {}
local function HasCooldownElapsed(key, interval)
    local now = os.clock()
    return (now - (CooldownTimestamps[key] or 0)) >= interval
end

local function CommitCooldown(key)
    CooldownTimestamps[key] = os.clock()
end

local function CheckAndCommitCooldown(key, interval)
    if HasCooldownElapsed(key, interval) then
        CommitCooldown(key)
        return true
    end
    return false
end

-- Branch Watchdog to prevent high-priority task starvation (Fixes #75-#79)
local BranchWatchdog = {} -- [branchKey] = {Start = clock, PenaltyUntil = clock}
local function IsBranchAllowed(branchKey, maxActiveSec, penaltySec)
    local now = os.clock()
    local entry = BranchWatchdog[branchKey]
    if not entry then
        BranchWatchdog[branchKey] = {Start = now, LastSeen = now, PenaltyUntil = 0}
        return true
    end
    if now < entry.PenaltyUntil then
        return false
    end
    if (now - entry.LastSeen) > 2.0 then
        -- Branch was inactive recently; reset continuous timer
        entry.Start = now
    end
    entry.LastSeen = now
    if (now - entry.Start) > (maxActiveSec or 12.0) then
        entry.PenaltyUntil = now + (penaltySec or 20.0)
        SetLog("WARN", branchKey .. " timed out -> penalty " .. tostring(penaltySec or 20) .. "s")
        return false
    end
    return true
end

local function ResetBranchWatchdog(branchKey)
    BranchWatchdog[branchKey] = nil
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 15)
local CommE = Remotes and Remotes:FindFirstChild("CommE")
local RemoteBusy = false

-- Fix #59 & #60: Inspect server response payload rather than assuming pcall ok == success
local function EvaluateCommFResult(res)
    if res == false or res == nil then
        return false, "Nil/False"
    end
    if type(res) == "string" then
        local lower = string.lower(res)
        if string.find(lower, "not ") or string.find(lower, "fail") or string.find(lower, "error")
            or string.find(lower, "locked") or string.find(lower, "already") or string.find(lower, "enough") then
            return false, res
        end
    end
    return true, res
end

local function InvokeCommF(actionTag, ...)
    if not CommF or not CommF.Parent then
        Remotes = ReplicatedStorage:FindFirstChild("Remotes")
        CommF = Remotes and Remotes:FindFirstChild("CommF_")
    end
    if not CommF then
        SetLog("FAIL", "CommF_ missing")
        return false, nil, false
    end

    -- Fix #80: Lightweight spin-wait mutex so background daemon and state machine don't collide
    local t0 = os.clock()
    while RemoteBusy and (os.clock() - t0) < 0.25 do
        task.wait(0.02)
    end
    RemoteBusy = true
    local args = table.pack(actionTag, ...)
    local callOk, res = pcall(function()
        return CommF:InvokeServer(table.unpack(args, 1, args.n))
    end)
    RemoteBusy = false

    if not callOk then
        SetLog("FAIL", "CommF Error [" .. tostring(actionTag) .. "]")
        return false, nil, false
    end
    local semanticOk, reason = EvaluateCommFResult(res)
    return true, res, semanticOk, reason
end

local function FireCommE(...)
    if not CommE or not CommE.Parent then
        Remotes = ReplicatedStorage:FindFirstChild("Remotes")
        CommE = Remotes and Remotes:FindFirstChild("CommE")
    end
    if not CommE then return false end
    local args = table.pack(...)
    local ok = pcall(function()
        CommE:FireServer(table.unpack(args, 1, args.n))
    end)
    return ok
end

-- // 5. Schema-Validated Config & Generic Numeric Clamping (Fixes #1, #23-#25, #62, #63) //
local ConfigFolder = "OllieBench_BF_V6"
local ConfigFile = Capabilities.FolderIO
    and (ConfigFolder .. "/config_" .. tostring(LocalPlayer.UserId) .. ".json")
    or ("OllieBench_BF_V6_cfg_" .. tostring(LocalPlayer.UserId) .. ".json")

local ValidEnums = {
    SelectedWeapon = {"Melee", "Sword", "Blox Fruit", "Gun"},
    MasteryTargetWeapon = {"Blox Fruit", "Gun"},
    StatTarget = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
    SniperFruitTarget = {
        "Kitsune-Kitsune", "Dragon-Dragon", "Leopard-Leopard", "Dough-Dough",
        "T-Rex-T-Rex", "Mammoth-Mammoth", "Portal-Portal", "Buddha-Buddha", "Magma-Magma", "Light-Light"
    },
    SelectedRaid = {
        "Flame", "Ice", "Quake", "Light", "Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand", "Phoenix", "Dough"
    },
}

local NumericBounds = {
    FarmOffsetY = {10, 80},
    TweenSpeed = {100, 350},
    MasteryHealthThreshold = {10, 90},
    StatBatch = {1, 100},
}

-- Fix #25: All active/world-modifying booleans default to FALSE on clean initialization
local Config = {
    AutoResumeSavedToggles = false,
    SelectedWeapon = "Melee",
    MasteryTargetWeapon = "Blox Fruit",
    FarmOffsetY = 28,
    TweenSpeed = 300,
    UsePortalTeleport = false,

    -- Core Farm
    AutoFarmLevel = false,
    AutoFarmNearest = false,
    AutoFarmChest = false,
    BringMobs = false,
    FastAttack = false,
    AutoBuso = false,
    AutoKen = false,

    -- Mastery, Bosses & Quests
    AutoFarmBosses = false,
    AutoFarmBone = false,
    AutoTradeBones = false,
    AutoFarmKatakuri = false,
    AutoSpawnCakePrince = false,
    AutoEliteHunter = false,
    AutoFactory = false,
    AutoPirateRaid = false,
    AutoSaber = false,
    AutoBartilo = false,
    AutoRengoku = false,
    AutoYama = false,
    AutoTushita = false,
    AutoFarmMastery = false,
    MasteryHealthThreshold = 35,
    UseSkillZ = true,
    UseSkillX = true,
    UseSkillC = true,
    UseSkillV = false,
    UseSkillF = false,

    -- Sea Events & Race V4
    AutoSeaBeast = false,
    AutoTerrorshark = false,
    AutoGhostShip = false,
    AutoFindMirage = false,
    AutoTeleportGear = false,
    AutoPullLever = false,
    AutoTrialV4 = false,
    AutoActivateV4 = false,

    -- Fruit & Raid
    AutoRandomFruit = false,
    AutoStoreFruit = false,
    GrabDroppedFruits = false,
    SniperFruitTarget = "Kitsune-Kitsune",
    AutoSnipeFruit = false,
    SelectedRaid = "Flame",
    AutoBuyChip = false,
    AutoStartRaid = false,
    KillAura = false,
    AutoNextIsland = false,
    AutoAwaken = false,

    -- Stats & Mods
    AutoStats = false,
    StatTarget = "Melee",
    StatBatch = 3,
    AimbotSkill = false,
    WalkOnWater = false,
    NoClip = false,
    InfiniteEnergy = false,
    InfiniteGeppo = false,
    NoDodgeCooldown = false,
    RemoveFog = false,
    FullBright = false,

    -- ESP
    ESPPlayers = false,
    ESPFruits = false,
    ESPChests = false,
    ESPFlowers = false,
    ESPMirage = false,
    ESPIslands = false,
}

local PassiveBooleanKeys = {
    AutoResumeSavedToggles = true,
    UseSkillZ = true,
    UseSkillX = true,
    UseSkillC = true,
    UseSkillV = true,
    UseSkillF = true,
}

local function IsValidEnum(key, val)
    local allowed = ValidEnums[key]
    if not allowed then return true end
    for _, v in ipairs(allowed) do
        if v == val then return true end
    end
    return false
end

local function SaveConfig()
    if not Capabilities.FileIO then
        SetLog("WARN", "FileIO unsupported")
        return false
    end
    local ok, err = pcall(function()
        if Capabilities.FolderIO and not raw_isfolder(ConfigFolder) then
            raw_makefolder(ConfigFolder)
        end
        raw_writefile(ConfigFile, HttpService:JSONEncode(Config))
    end)
    if not ok then
        SetLog("FAIL", "SaveConfig: " .. tostring(err))
        return false
    end
    return true
end

local function LoadConfig()
    if not Capabilities.FileIO then return false end
    local ok, decoded = pcall(function()
        if raw_isfile(ConfigFile) then
            return HttpService:JSONDecode(raw_readfile(ConfigFile))
        end
        return nil
    end)
    if ok and type(decoded) == "table" then
        local allowResume = (decoded.AutoResumeSavedToggles == true)
        for k, v in pairs(decoded) do
            if Config[k] ~= nil and type(Config[k]) == type(v) and IsValidEnum(k, v) then
                if type(v) == "number" and NumericBounds[k] then
                    v = math.clamp(v, NumericBounds[k][1], NumericBounds[k][2])
                end
                -- Fix #23 & #24: If AutoResume is false, reset ALL active boolean toggles to false
                if type(v) == "boolean" and not PassiveBooleanKeys[k] and not allowResume then
                    Config[k] = false
                else
                    Config[k] = v
                end
            end
        end
        SetLog("OK", "Config loaded (Resume=" .. tostring(allowResume) .. ")")
        return true
    end
    return false
end
LoadConfig()

-- // 6. Sea Detection & Databases (Fixes #9, #10) //
local MaxSupportedQuestLevel = 2650

local function DetectSeaOnce()
    local pid = game.PlaceId
    if pid == 2753915549 then
        Runtime.CurrentSea = 1
        Runtime.KnownSea = true
    elseif pid == 4442272183 then
        Runtime.CurrentSea = 2
        Runtime.KnownSea = true
    elseif pid == 7449423635 then
        Runtime.CurrentSea = 3
        Runtime.KnownSea = true
    else
        local locs = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
        if locs and locs:FindFirstChild("Tiki Outpost") then
            Runtime.CurrentSea = 3
            Runtime.KnownSea = true
        elseif locs and locs:FindFirstChild("Kingdom of Rose") then
            Runtime.CurrentSea = 2
            Runtime.KnownSea = true
        elseif locs and locs:FindFirstChild("Pirate Village") then
            Runtime.CurrentSea = 1
            Runtime.KnownSea = true
        end
    end
end
DetectSeaOnce()

local PortalNodes = {
    [1] = {
        CFrame.new(-4652.82, 872.58, -1754.02),
        CFrame.new(-7894.62, 5547.14, -380.29),
        CFrame.new(61163.85, 11.67, 1819.78),
        CFrame.new(3864.69, 6.74, -1926.21),
    },
    [2] = {
        CFrame.new(-286.99, 306.18, 597.75),
        CFrame.new(2284.91, 15.15, 905.48),
        CFrame.new(923.21, 125.09, 32885.87),
        CFrame.new(-6508.56, 89.03, -132.84),
    },
    [3] = {
        CFrame.new(-5074.45, 314.51, -2991.05),
        CFrame.new(-12553.81, 337.19, -7495.55),
        CFrame.new(5749.78, 610.45, -276.22),
        CFrame.new(28286.35, 14895.30, 102.62),
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
        {Min = 1450, Max = 1500, Mob = "Water Fighter", QuestName = "ForgottenQuest", QuestLvl = 2, QuestPos = CFrame.new(-3054.44, 235.54, -10142.81), MobPos = CFrame.new(-3352.90, 285.01, -10534.84)},
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
        {Min = 2575, Max = MaxSupportedQuestLevel, Mob = "Skull Slayer", QuestName = "TikiQuest3", QuestLvl = 2, QuestPos = CFrame.new(-16665.19, 104.59, 1579.69), MobPos = CFrame.new(-16885.20, 114.12, 1627.94)},
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

-- Known Fruit Tool Name -> StoreFruit ID Lookup (Fixes #26, #53, #54)
local FruitCodeMap = {
    ["Rocket Fruit"] = "Rocket-Rocket", ["Spin Fruit"] = "Spin-Spin", ["Blade Fruit"] = "Blade-Blade",
    ["Spring Fruit"] = "Spring-Spring", ["Bomb Fruit"] = "Bomb-Bomb", ["Smoke Fruit"] = "Smoke-Smoke",
    ["Spike Fruit"] = "Spike-Spike", ["Flame Fruit"] = "Flame-Flame", ["Falcon Fruit"] = "Falcon-Falcon",
    ["Ice Fruit"] = "Ice-Ice", ["Sand Fruit"] = "Sand-Sand", ["Dark Fruit"] = "Dark-Dark",
    ["Diamond Fruit"] = "Diamond-Diamond", ["Light Fruit"] = "Light-Light", ["Rubber Fruit"] = "Rubber-Rubber",
    ["Barrier Fruit"] = "Barrier-Barrier", ["Ghost Fruit"] = "Ghost-Ghost", ["Magma Fruit"] = "Magma-Magma",
    ["Quake Fruit"] = "Quake-Quake", ["Buddha Fruit"] = "Buddha-Buddha", ["Love Fruit"] = "Love-Love",
    ["Spider Fruit"] = "Spider-Spider", ["Sound Fruit"] = "Sound-Sound", ["Phoenix Fruit"] = "Phoenix-Phoenix",
    ["Portal Fruit"] = "Portal-Portal", ["Rumble Fruit"] = "Rumble-Rumble", ["Pain Fruit"] = "Pain-Pain",
    ["Blizzard Fruit"] = "Blizzard-Blizzard", ["Gravity Fruit"] = "Gravity-Gravity", ["Mammoth Fruit"] = "Mammoth-Mammoth",
    ["T-Rex Fruit"] = "T-Rex-T-Rex", ["Dough Fruit"] = "Dough-Dough", ["Shadow Fruit"] = "Shadow-Shadow",
    ["Venom Fruit"] = "Venom-Venom", ["Control Fruit"] = "Control-Control", ["Gas Fruit"] = "Gas-Gas",
    ["Spirit Fruit"] = "Spirit-Spirit", ["Leopard Fruit"] = "Leopard-Leopard", ["Yeti Fruit"] = "Yeti-Yeti",
    ["Kitsune Fruit"] = "Kitsune-Kitsune", ["Dragon Fruit"] = "Dragon-Dragon",
}

-- // 7. Character State, Inventory Sync, Lighting & NPC Restoration (Fixes #6-#8, #20-#22, #43) //
TrackConn(LocalPlayer.Idled, function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
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
local function GetReadyPlayerLevel()
    local d = LocalPlayer:FindFirstChild("Data")
    local l = d and d:FindFirstChild("Level")
    return l and l.Value or nil
end
local function GetPlayerStatPoints()
    local d = LocalPlayer:FindFirstChild("Data")
    local p = d and d:FindFirstChild("Points")
    return (p and p.Value) or 0
end
local function GetPlayerBeli()
    local d = LocalPlayer:FindFirstChild("Data")
    local b = d and d:FindFirstChild("Beli")
    return (b and b.Value) or 0
end

-- Fix #6 & #7: Compute authoritative Max Energy from Melee stat level + Energy object
local function GetAuthoritativeMaxEnergy(char)
    local computed = 100
    pcall(function()
        local stats = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Stats")
        local melee = stats and stats:FindFirstChild("Melee") and stats.Melee:FindFirstChild("Level")
        if melee and type(melee.Value) == "number" then
            computed = 100 + (melee.Value - 1) * 5
        end
    end)
    local en = char and char:FindFirstChild("Energy")
    if en then
        local maxChild = en:FindFirstChild("MaxValue")
        local attrMax = en:GetAttribute("MaxValue")
        if maxChild and type(maxChild.Value) == "number" then
            computed = math.max(computed, maxChild.Value)
        elseif type(attrMax) == "number" then
            computed = math.max(computed, attrMax)
        end
        if type(en.Value) == "number" and en.Value > computed then
            computed = en.Value
        end
    end
    Runtime.MaxEnergySnapshot = math.max(Runtime.MaxEnergySnapshot, computed)
    return Runtime.MaxEnergySnapshot
end

-- Fix #43: Check Backpack, Character, AND cached server getInventory
local function SyncServerInventory()
    if (os.clock() - Runtime.LastInventorySync) < 8.0 then return end
    Runtime.LastInventorySync = os.clock()
    local ok, inv = InvokeCommF("getInventory")
    if ok and type(inv) == "table" then
        local map = {}
        for _, entry in ipairs(inv) do
            if type(entry) == "table" and entry.Name then
                map[entry.Name] = entry.Count or 1
            end
        end
        Runtime.ServerInventoryCache = map
    end
end

local function HasItem(name, includeServerStorage)
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local ch = GetChar()
    if (bp and bp:FindFirstChild(name) ~= nil) or (ch and ch:FindFirstChild(name) ~= nil) then
        return true
    end
    if includeServerStorage then
        SyncServerInventory()
        if Runtime.ServerInventoryCache[name] and Runtime.ServerInventoryCache[name] > 0 then
            return true
        end
    end
    return false
end

-- Fix #22: Snapshot character collisions before NoClip mutates them; use standard R15/R6 defaults for late-added parts
local StandardCollideParts = {
    Head = true, Torso = true, UpperTorso = true, LowerTorso = true, HumanoidRootPart = true
}

local function SnapshotCharacterState(char)
    if not char then return end
    Runtime.CollisionSnapshot = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if not Runtime.NoClipApplied then
                Runtime.CollisionSnapshot[part] = part.CanCollide
            else
                Runtime.CollisionSnapshot[part] = (StandardCollideParts[part.Name] == true)
            end
        end
    end
    GetAuthoritativeMaxEnergy(char)
end

local function RestoreCharacterCollisions()
    for part, origCollide in pairs(Runtime.CollisionSnapshot) do
        if part and part.Parent then
            pcall(function() part.CanCollide = origCollide end)
        end
    end
    Runtime.NoClipApplied = false
end

-- Fix #20 & #21: Restore NPCs modified by BringNearbyMobs
local function RestoreModifiedNPCs()
    for mob, orig in pairs(ModifiedNPCs) do
        if mob and mob.Parent then
            pcall(function()
                local mr = mob:FindFirstChild("HumanoidRootPart")
                local mh = mob:FindFirstChildOfClass("Humanoid")
                if mr and orig.CanCollide ~= nil then mr.CanCollide = orig.CanCollide end
                if mh then
                    if orig.WalkSpeed then mh.WalkSpeed = orig.WalkSpeed end
                    if orig.JumpPower then mh.JumpPower = orig.JumpPower end
                end
            end)
        end
        ModifiedNPCs[mob] = nil
    end
end

local function RestoreWaterPlane()
    if not Runtime.WaterPlaneModified then return end
    local map = Workspace:FindFirstChild("Map")
    local wp = map and map:FindFirstChild("WaterBase-Plane")
    if wp and Runtime.WaterPlaneSizeSnapshot then
        pcall(function() wp.Size = Runtime.WaterPlaneSizeSnapshot end)
    end
    Runtime.WaterPlaneModified = false
end

-- Fix #8: Unified Lighting synchronizer prevents RemoveFog vs FullBright conflicts
local function SyncLightingState()
    pcall(function()
        if Config.FullBright then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 9e9
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = DefaultLighting.Ambient
            Lighting.OutdoorAmbient = DefaultLighting.OutdoorAmbient
            Lighting.Brightness = DefaultLighting.Brightness
            Lighting.ClockTime = DefaultLighting.ClockTime
            Lighting.GlobalShadows = DefaultLighting.GlobalShadows
            Lighting.FogEnd = Config.RemoveFog and 9e9 or DefaultLighting.FogEnd
        end
    end)
end

if GetChar() then SnapshotCharacterState(GetChar()) end
TrackConn(LocalPlayer.CharacterAdded, function(newChar)
    Runtime.MoveTargetCF = nil
    Runtime.AimbotTargetPart = nil
    Runtime.NoClipApplied = false
    task.wait(0.4)
    SnapshotCharacterState(newChar)
end)

-- // 8. Generation-Tracked Movement Engine (Fixes #69, #70, #71, #72, #73, #74) //
local function DestroyHoverBV()
    local root = GetRoot()
    if root then
        local bv = root:FindFirstChild("OllieV6_BV")
        if bv then bv:Destroy() end
    end
end

local function StopMovement(ownerFilter)
    if ownerFilter and Runtime.MoveOwner and Runtime.MoveOwner ~= ownerFilter then
        return
    end
    Runtime.MoveTargetCF = nil
    Runtime.MoveMode = "None"
    Runtime.MoveOwner = nil
    Runtime.ArrivedAtTarget = false
    DestroyHoverBV()
end

local function RequestMoveTo(targetCF, mode, ownerKey)
    if not targetCF then
        StopMovement(ownerKey)
        return Runtime.MoveGenerationId
    end

    local root = GetRoot()
    -- Fix #69, #70, #71: Only check & commit portal cooldown when distance > 3400 and a valid portal is closer
    if root and Config.UsePortalTeleport and HasCooldownElapsed("PortalRequest", 3.5) then
        local dist = (root.Position - targetCF.Position).Magnitude
        if dist > 3400 then
            local nodes = PortalNodes[Runtime.CurrentSea]
            if nodes then
                local bestNode, bestDist = nil, dist
                for _, nCF in ipairs(nodes) do
                    local d = (nCF.Position - targetCF.Position).Magnitude
                    if d + 600 < bestDist then
                        bestDist = d
                        bestNode = nCF
                    end
                end
                if bestNode then
                    CommitCooldown("PortalRequest")
                    Runtime.PortalPauseUntil = os.clock() + 0.35 -- Pause CFrame stepping while entrance replicates
                    InvokeCommF("requestEntrance", bestNode.Position)
                end
            end
        end
    end

    -- Fix #72: Only increment generation & reset arrival if destination shifted > 4 studs or mode/owner changed
    local prevCF = Runtime.MoveTargetCF
    local shifted = (not prevCF) or ((prevCF.Position - targetCF.Position).Magnitude > 4.0)
        or (Runtime.MoveMode ~= (mode or "HoverLock"))
        or (Runtime.MoveOwner ~= (ownerKey or "Generic"))

    Runtime.MoveTargetCF = targetCF
    Runtime.MoveMode = mode or "HoverLock"
    Runtime.MoveOwner = ownerKey or "Generic"

    if shifted then
        Runtime.MoveGenerationId = Runtime.MoveGenerationId + 1
        Runtime.ArrivedAtTarget = false
    end
    return Runtime.MoveGenerationId
end

TrackConn(RunService.Heartbeat, function(dt)
    pcall(function()
        if os.clock() < Runtime.PortalPauseUntil then return end
        local targetCF = Runtime.MoveTargetCF
        local root = GetRoot()
        local hum = GetHum()
        if not targetCF or not root or not hum or hum.Health <= 0 then
            DestroyHoverBV()
            return
        end

        if hum.Sit then hum.Sit = false end

        local bv = root:FindFirstChild("OllieV6_BV")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "OllieV6_BV"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.zero
            bv.Parent = root
        end
        bv.Velocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero

        local currentPos = root.Position
        local destPos = targetCF.Position
        local diff = destPos - currentPos
        local dist = diff.Magnitude

        -- Fix #73 & #74: Record exact ArrivedMoveId before clearing OneShot state
        if dist <= 3.5 then
            root.CFrame = CFrame.new(destPos) * targetCF.Rotation
            Runtime.ArrivedAtTarget = true
            Runtime.ArrivedMoveId = Runtime.MoveGenerationId
            if Runtime.MoveMode == "OneShot" then
                Runtime.MoveTargetCF = nil
                Runtime.MoveMode = "None"
                Runtime.MoveOwner = nil
                DestroyHoverBV()
            end
            return
        end

        local speed = math.clamp(Config.TweenSpeed, 100, 350)
        local stepDist = math.min(dist, speed * dt)
        local nextPos
        if dist > 260 and currentPos.Y < (destPos.Y - 80) then
            local climbY = math.min(destPos.Y, currentPos.Y + speed * 1.5 * dt)
            local horizDiff = Vector3.new(destPos.X - currentPos.X, 0, destPos.Z - currentPos.Z)
            local horizStep = horizDiff.Magnitude > 0.01 and (horizDiff.Unit * math.min(horizDiff.Magnitude, speed * 0.7 * dt)) or Vector3.zero
            nextPos = Vector3.new(currentPos.X + horizStep.X, climbY, currentPos.Z + horizStep.Z)
        else
            nextPos = currentPos + (diff.Unit * stepDist)
        end

        root.CFrame = CFrame.new(nextPos) * targetCF.Rotation
    end)
end)

-- // 9. Honest Interactable Trigger (Fix #2: Reports ATTEMPTED vs NO_API) //
local function TryTriggerInteractables(targetInstance)
    if not targetInstance then return false, "NIL_TARGET" end
    local list = targetInstance:GetDescendants()
    table.insert(list, 1, targetInstance)

    local myRoot = GetRoot()
    local attempted = false
    local foundAny = false

    for _, inst in ipairs(list) do
        if inst:IsA("ProximityPrompt") then
            foundAny = true
            if Capabilities.Prompt then
                local ok = pcall(function() raw_fireproximityprompt(inst) end)
                if ok then attempted = true end
            end
        elseif inst:IsA("ClickDetector") then
            foundAny = true
            if Capabilities.Click then
                local ok = pcall(function() raw_fireclickdetector(inst) end)
                if ok then attempted = true end
            end
        elseif inst:IsA("TouchTransmitter") and myRoot and inst.Parent and inst.Parent:IsA("BasePart") then
            foundAny = true
            if Capabilities.Touch then
                local ok = pcall(function()
                    raw_firetouchinterest(myRoot, inst.Parent, 0)
                    raw_firetouchinterest(myRoot, inst.Parent, 1)
                end)
                if ok then attempted = true end
            end
        end
    end

    if attempted then return true, "ATTEMPTED" end
    if foundAny then return false, "NO_EXECUTOR_API" end
    return false, "NO_INTERACTABLE_FOUND"
end

-- // 10. Non-Blocking Skill Caster, Weapon Equip & Scoped Attack (Fixes #16-#20) //
local function EquipWeapon(categoryOverride, exactNameOverride)
    local char = GetChar()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local hum = GetHum()
    if not char or not bp or not hum or hum.Health <= 0 then return nil end

    if Config.AutoBuso and not char:FindFirstChild("HasBuso") and CheckAndCommitCooldown("BusoToggle", 2.5) then
        InvokeCommF("Buso")
    end

    local held = char:FindFirstChildOfClass("Tool")
    if exactNameOverride then
        if held and held.Name == exactNameOverride then return held end
        local found = bp:FindFirstChild(exactNameOverride)
        if found and found:IsA("Tool") then
            pcall(function() hum:EquipTool(found) end)
            return char:FindFirstChild(exactNameOverride)
        end
        return nil
    end

    local wantedType = categoryOverride or Config.SelectedWeapon
    if held and held.ToolTip == wantedType then return held end
    for _, item in ipairs(bp:GetChildren()) do
        if item:IsA("Tool") and item.ToolTip == wantedType then
            pcall(function() hum:EquipTool(item) end)
            return char:FindFirstChild(item.Name)
        end
    end
    return held
end

local function IsSkillReadyOnUI(toolName, keyName)
    local ok, ready = pcall(function()
        local pgui = LocalPlayer:FindFirstChild("PlayerGui")
        local skills = pgui and pgui:FindFirstChild("Main") and pgui.Main:FindFirstChild("Skills")
        local toolFrame = skills and skills:FindFirstChild(toolName)
        local keyFrame = toolFrame and toolFrame:FindFirstChild(keyName)
        if not keyFrame then return true end
        local cdBar = keyFrame:FindFirstChild("Cooldown")
        if cdBar and cdBar:IsA("Frame") and cdBar.Size.X.Scale > 0.05 then
            return false
        end
        return true
    end)
    return (not ok) or ready
end

-- Fix #16 & #17: Non-blocking skill cast with equipped tool & UI cooldown verification
local SkillKeyList = {
    {Flag = "UseSkillZ", Key = Enum.KeyCode.Z, Name = "Z"},
    {Flag = "UseSkillX", Key = Enum.KeyCode.X, Name = "X"},
    {Flag = "UseSkillC", Key = Enum.KeyCode.C, Name = "C"},
    {Flag = "UseSkillV", Key = Enum.KeyCode.V, Name = "V"},
    {Flag = "UseSkillF", Key = Enum.KeyCode.F, Name = "F"},
}

local function TryCastNextAvailableSkill(expectedToolCategory)
    if not Capabilities.VIM then return false end
    local char = GetChar()
    local held = char and char:FindFirstChildOfClass("Tool")
    if not held or (expectedToolCategory and held.ToolTip ~= expectedToolCategory) then
        return false
    end
    if not CheckAndCommitCooldown("GlobalSkillPulse", 0.35) then
        return false
    end

    for _, sk in ipairs(SkillKeyList) do
        if Config[sk.Flag] and CheckAndCommitCooldown("SkillKey_" .. sk.Name, 1.2) then
            if IsSkillReadyOnUI(held.Name, sk.Name) then
                task.spawn(function()
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, sk.Key, false, game)
                        task.wait(0.05)
                        VirtualInputManager:SendKeyEvent(false, sk.Key, false, game)
                    end)
                end)
                return true
            end
        end
    end
    return false
end

local CombatController = nil
pcall(function()
    if Capabilities.Upvalues then
        local ps = LocalPlayer:WaitForChild("PlayerScripts", 5)
        local cfScript = ps and ps:FindFirstChild("CombatFramework")
        if cfScript then
            local upvals = raw_getupvalues(require(cfScript))
            if type(upvals) == "table" then
                for _, uv in pairs(upvals) do
                    if type(uv) == "table" and type(uv.activeController) == "table" then
                        CombatController = uv
                        break
                    end
                end
            end
        end
    end
end)

-- Fix #18 & #19: Target-scoped attack unless KillAura or BringMobs is active
local function ExecuteAttackPulse(primaryMob, radiusLimit)
    local char = GetChar()
    local root = GetRoot()
    if not char or not root then return false end
    local maxRadius = radiusLimit or 60
    local allowMultiHit = Config.KillAura or Config.BringMobs

    local netDispatched = false
    pcall(function()
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local net = modules and modules:FindFirstChild("Net")
        if net then
            local regAtk = net:FindFirstChild("RE/RegisterAttack")
            local regHit = net:FindFirstChild("RE/RegisterHit")
            if regAtk and regHit then
                local hitTargets = {}
                local mainPart = nil

                if primaryMob and primaryMob.Parent then
                    local mr = primaryMob:FindFirstChild("HumanoidRootPart")
                    local mh = primaryMob:FindFirstChildOfClass("Humanoid")
                    if mr and mh and mh.Health > 0 and (mr.Position - root.Position).Magnitude <= maxRadius then
                        mainPart = mr
                        table.insert(hitTargets, {primaryMob, mr})
                    end
                end

                if allowMultiHit then
                    local enemies = Workspace:FindFirstChild("Enemies")
                    if enemies then
                        for _, mob in ipairs(enemies:GetChildren()) do
                            if mob ~= primaryMob then
                                local mr = mob:FindFirstChild("HumanoidRootPart")
                                local mh = mob:FindFirstChildOfClass("Humanoid")
                                if mr and mh and mh.Health > 0 and (mr.Position - root.Position).Magnitude <= maxRadius then
                                    if not mainPart then mainPart = mr end
                                    table.insert(hitTargets, {mob, mr})
                                end
                            end
                        end
                    end
                end

                if mainPart then
                    regAtk:FireServer(0)
                    regHit:FireServer(mainPart, hitTargets)
                    netDispatched = true
                end
            end
        end
    end)

    pcall(function()
        if CombatController and type(CombatController.activeController) == "table" then
            local ac = CombatController.activeController
            ac.timeToNextAttack = 0
            ac.hitboxMagnitude = maxRadius
            if type(ac.attack) == "function" then ac:attack() end
        end
    end)

    if not netDispatched then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(1280, 672))
        end)
    end
    return netDispatched
end

-- Fix #20 & #21: Snapshot original NPC properties before modifying
local function BringNearbyMobs(mobNameFilter, centerCF)
    if not Config.BringMobs then return end
    if Capabilities.SimRadius then
        pcall(function() raw_sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
    end
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end

    for _, mob in ipairs(enemies:GetChildren()) do
        if not mobNameFilter or mob.Name == mobNameFilter then
            local mr = mob:FindFirstChild("HumanoidRootPart")
            local mh = mob:FindFirstChildOfClass("Humanoid")
            if mr and mh and mh.Health > 0 and (mr.Position - centerCF.Position).Magnitude <= 300 then
                if not ModifiedNPCs[mob] then
                    ModifiedNPCs[mob] = {
                        WalkSpeed = mh.WalkSpeed,
                        JumpPower = mh.JumpPower,
                        CanCollide = mr.CanCollide,
                    }
                end
                pcall(function()
                    mr.CFrame = centerCF
                    mr.CanCollide = false
                    mr.AssemblyLinearVelocity = Vector3.zero
                    mh.WalkSpeed = 0
                    mh.JumpPower = 0
                end)
            end
        end
    end
end

-- // 11. Strictly Scoped & Restorable Metamethod Hook (Fixes #3, #4, #83, #84) //
getgenv().OllieBF_HookEnabled = true
getgenv().OllieBF_NamecallHandler = function(self, ...)
    if not getgenv().OllieBF_HookEnabled then return false, nil end
    local aimActive = Config.AimbotSkill or Config.AutoFarmMastery or Config.AutoSeaBeast
    local targetPart = Runtime.AimbotTargetPart
    if not aimActive or not targetPart or not targetPart.Parent then
        return false, nil
    end

    local method = raw_getnamecallmethod()
    if method ~= "FireServer" and method ~= "InvokeServer" then
        return false, nil
    end

    -- Fix #3: Only intercept RemoteEvent inside the currently equipped Tool in LocalPlayer.Character
    local char = GetChar()
    local isEquippedToolRemote = (typeof(self) == "Instance"
        and self.Name == "RemoteEvent"
        and self.Parent
        and self.Parent:IsA("Tool")
        and char
        and self.Parent.Parent == char)

    if not isEquippedToolRemote then
        return false, nil
    end

    local args = table.pack(...)
    local modified = false
    for i = 1, args.n do
        local a = args[i]
        if typeof(a) == "Vector3" then
            args[i] = targetPart.Position
            modified = true
            break
        elseif typeof(a) == "CFrame" then
            args[i] = targetPart.CFrame
            modified = true
            break
        end
    end
    return modified, args
end

local function EnsureMetamethodHook()
    if not Capabilities.HookMeta then return end
    if getgenv().OllieBF_HookActive and getgenv().OllieBF_OriginalNamecall then return end
    pcall(function()
        local oldNamecall
        oldNamecall = raw_hookmetamethod(game, "__namecall", raw_newcclosure(function(self, ...)
            local isExploitCaller = Capabilities.CheckCaller and raw_checkcaller() or false
            if not isExploitCaller and getgenv().OllieBF_NamecallHandler then
                local ok, modified, packedArgs = pcall(getgenv().OllieBF_NamecallHandler, self, ...)
                if ok and modified and type(packedArgs) == "table" then
                    return oldNamecall(self, table.unpack(packedArgs, 1, packedArgs.n))
                end
            end
            return oldNamecall(self, ...)
        end))
        getgenv().OllieBF_OriginalNamecall = oldNamecall
        getgenv().OllieBF_HookActive = true
    end)
end
EnsureMetamethodHook()

-- // 12. Constant-Verified & Restorable GC Patcher (Fix #5) //
local function FunctionHasConstant(fn, targetStr)
    if not Capabilities.GetConsts then return true end
    local ok, consts = pcall(raw_getconstants, fn)
    if not ok or type(consts) ~= "table" then return false end
    for _, c in pairs(consts) do
        if type(c) == "string" and string.find(string.lower(c), string.lower(targetStr), 1, true) then
            return true
        end
    end
    return false
end

local function ApplyExperimentalGCPatch()
    if not Capabilities.GetGC or not Capabilities.Upvalues then return end
    if not Config.InfiniteGeppo and not Config.NoDodgeCooldown then return end
    pcall(function()
        for _, fn in ipairs(raw_getgc(false)) do
            if type(fn) == "function" then
                local envOk, env = pcall(getfenv, fn)
                local scr = envOk and env and rawget(env, "script")
                local scrName = typeof(scr) == "Instance" and scr.Name or nil
                if scrName == "Skyjump" and Config.InfiniteGeppo and FunctionHasConstant(fn, "Geppo") then
                    for idx, val in pairs(raw_getupvalues(fn)) do
                        if type(val) == "number" and math.floor(val) == val and val >= 1 and val <= 12 then
                            table.insert(OriginalUpvalues, {Fn = fn, Idx = idx, Val = val})
                            raw_setupvalue(fn, idx, 0)
                        end
                    end
                elseif scrName == "Dodge" and Config.NoDodgeCooldown and FunctionHasConstant(fn, "Dodge") then
                    for idx, val in pairs(raw_getupvalues(fn)) do
                        if type(val) == "number" and val > 0 and val <= 2.5 then
                            table.insert(OriginalUpvalues, {Fn = fn, Idx = idx, Val = val})
                            raw_setupvalue(fn, idx, 0)
                        end
                    end
                end
            end
        end
    end)
end

local function RestoreExperimentalGCPatch()
    if not Capabilities.Upvalues then return end
    for _, rec in ipairs(OriginalUpvalues) do
        pcall(function() raw_setupvalue(rec.Fn, rec.Idx, rec.Val) end)
    end
    table.clear(OriginalUpvalues)
end

-- // 13. Event-Indexed World Caches & Scoped Target Search (Fixes #46, #47, #51, #53) //
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = SuiteName .. "_ESP"
ESPFolder.Parent = GuiParent

local ESPPool = {}
local IndexedChests = setmetatable({}, {__mode = "k"})
local IndexedFlowers = setmetatable({}, {__mode = "k"})
local IndexedFruits = setmetatable({}, {__mode = "k"})
local IndexedReplicatedElites = setmetatable({}, {__mode = "k"})

local function IndexWorkspaceDescendant(inst)
    if inst:IsA("BasePart") then
        if string.find(inst.Name, "Chest") then
            IndexedChests[inst] = true
        elseif inst.Name == "Flower1" or inst.Name == "Flower2" or inst.Name == "Flower3" then
            IndexedFlowers[inst] = true
        end
    elseif (inst:IsA("Tool") or inst:IsA("Model")) and (string.find(inst.Name, "Fruit") or inst:GetAttribute("OriginalName")) then
        if not Players:GetPlayerFromCharacter(inst.Parent) then
            IndexedFruits[inst] = true
        end
    end
end

local function IndexReplicatedDescendant(inst)
    if inst:IsA("Model") and (inst.Name == "Diablo" or inst.Name == "Deandre" or inst.Name == "Urban") then
        IndexedReplicatedElites[inst] = true
    end
end

for _, d in ipairs(Workspace:GetDescendants()) do IndexWorkspaceDescendant(d) end
for _, d in ipairs(ReplicatedStorage:GetDescendants()) do IndexReplicatedDescendant(d) end

TrackConn(Workspace.DescendantAdded, IndexWorkspaceDescendant)
TrackConn(Workspace.DescendantRemoving, function(inst)
    IndexedChests[inst] = nil
    IndexedFlowers[inst] = nil
    IndexedFruits[inst] = nil
    if ESPPool[inst] then
        pcall(function() ESPPool[inst].Gui:Destroy() end)
        ESPPool[inst] = nil
    end
end)
TrackConn(ReplicatedStorage.DescendantAdded, IndexReplicatedDescendant)
TrackConn(ReplicatedStorage.DescendantRemoving, function(inst)
    IndexedReplicatedElites[inst] = nil
end)
-- Fix #53: Immediate cleanup when a player leaves
TrackConn(Players.PlayerRemoving, function(plr)
    if ESPPool[plr] then
        pcall(function() ESPPool[plr].Gui:Destroy() end)
        ESPPool[plr] = nil
    end
end)

local function GetInstancePivotPart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        return inst.PrimaryPart or inst:FindFirstChild("Handle") or inst:FindFirstChild("HumanoidRootPart") or inst:FindFirstChildWhichIsA("BasePart")
    end
    return inst:FindFirstChild("Handle") or inst:FindFirstChildWhichIsA("BasePart")
end

local KnownBossNames = {
    ["The Gorilla King"] = true, ["Bobby"] = true, ["Yeti"] = true, ["Mob Leader"] = true,
    ["Vice Admiral"] = true, ["Warden"] = true, ["Chief Warden"] = true, ["Swan"] = true,
    ["Magma Admiral"] = true, ["Fishman Lord"] = true, ["Wysper"] = true, ["Thunder God"] = true,
    ["Cyborg"] = true, ["Saber Expert"] = true, ["Diamond"] = true, ["Jeremy"] = true,
    ["Fajita"] = true, ["Don Swan"] = true, ["Smoke Admiral"] = true, ["Cursed Captain"] = true,
    ["Darkbeard"] = true, ["Order"] = true, ["Awakened Ice Admiral"] = true, ["Tide Keeper"] = true,
    ["Stone"] = true, ["Island Empress"] = true, ["Kilo Admiral"] = true, ["Captain Elephant"] = true,
    ["Beautiful Pirate"] = true, ["Longma"] = true, ["Cake Queen"] = true, ["Soul Reaper"] = true,
    ["Cake Prince"] = true, ["Dough King"] = true, ["rip_indra True Form"] = true,
}

local CurrentActiveMob = nil

local function FindEnemy(exactFilter, bossOnly, centerPos, maxRadius)
    local enemies = Workspace:FindFirstChild("Enemies")
    local root = GetRoot()
    if not enemies or not root then return nil end

    local refPos = centerPos or root.Position
    local radiusLimit = maxRadius or math.huge
    local bestMob, minDist = nil, math.huge

    for _, mob in ipairs(enemies:GetChildren()) do
        local mr = mob:FindFirstChild("HumanoidRootPart")
        local mh = mob:FindFirstChildOfClass("Humanoid")
        if mr and mh and mh.Health > 0 then
            if (mr.Position - refPos).Magnitude <= radiusLimit then
                local matched = false
                if bossOnly then
                    matched = KnownBossNames[mob.Name] == true or (mob:FindFirstChild("Boss") ~= nil) or string.find(mob.Name, "%[Boss%]") ~= nil
                elseif type(exactFilter) == "table" then
                    for _, exactName in ipairs(exactFilter) do
                        if mob.Name == exactName then matched = true break end
                    end
                elseif type(exactFilter) == "string" then
                    matched = (mob.Name == exactFilter)
                else
                    matched = true
                end

                if matched then
                    local d = (mr.Position - root.Position).Magnitude
                    if d < minDist then
                        minDist = d
                        bestMob = mob
                    end
                end
            end
        end
    end
    return bestMob
end

local function EngageMob(mob, clusterFilter, ownerKey)
    local mr = mob and mob:FindFirstChild("HumanoidRootPart")
    local mh = mob and mob:FindFirstChildOfClass("Humanoid")
    if not mr or not mh or mh.Health <= 0 then return end

    CurrentActiveMob = mob
    Runtime.AimbotTargetPart = mr
    RequestMoveTo(mr.CFrame * CFrame.new(0, Config.FarmOffsetY, 0), "HoverLock", ownerKey)
    if clusterFilter then BringNearbyMobs(clusterFilter, mr.CFrame) end

    local hpPct = (mh.Health / math.max(1, mh.MaxHealth)) * 100
    if Config.AutoFarmMastery and hpPct <= Config.MasteryHealthThreshold then
        EquipWeapon(Config.MasteryTargetWeapon)
        TryCastNextAvailableSkill(Config.MasteryTargetWeapon)
    else
        EquipWeapon(Config.SelectedWeapon)
    end
end

-- // 14. Diff-Pooled ESP Updater //
local function UpsertESP(keyInst, adorneePart, text, color, seenSet)
    if not adorneePart or not adorneePart.Parent then return end
    seenSet[keyInst] = true
    local entry = ESPPool[keyInst]
    if not entry or not entry.Gui.Parent then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 220, 0, 36)
        bb.AlwaysOnTop = true
        bb.Adornee = adorneePart
        bb.Parent = ESPFolder

        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 13
        lbl.TextStrokeTransparency = 0.15

        entry = {Gui = bb, Label = lbl}
        ESPPool[keyInst] = entry
    end
    entry.Gui.Adornee = adorneePart
    entry.Label.Text = text
    entry.Label.TextColor3 = color
end

local function RefreshESP()
    local root = GetRoot()
    if not root then return end
    local seen = {}

    if Config.ESPPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local pr = plr.Character:FindFirstChild("HumanoidRootPart")
                local ph = plr.Character:FindFirstChildOfClass("Humanoid")
                if pr then
                    local d = math.floor((pr.Position - root.Position).Magnitude)
                    UpsertESP(plr, pr, string.format("[PLR] %s | %d HP (%dm)", plr.Name, ph and math.floor(ph.Health) or 0, d), Color3.fromRGB(255, 85, 85), seen)
                end
            end
        end
    end

    if Config.ESPFruits then
        for obj in pairs(IndexedFruits) do
            if obj.Parent and not Players:GetPlayerFromCharacter(obj.Parent) then
                local part = GetInstancePivotPart(obj)
                if part then
                    local d = math.floor((part.Position - root.Position).Magnitude)
                    UpsertESP(obj, part, string.format("[FRUIT] %s (%dm)", obj.Name, d), Color3.fromRGB(115, 255, 115), seen)
                end
            end
        end
    end

    if Config.ESPFlowers then
        for fl in pairs(IndexedFlowers) do
            if fl.Parent and fl.Transparency < 1 then
                local d = math.floor((fl.Position - root.Position).Magnitude)
                UpsertESP(fl, fl, string.format("[FLOWER] %s (%dm)", fl.Name, d), Color3.fromRGB(100, 200, 255), seen)
            end
        end
    end

    if Config.ESPChests then
        for ch in pairs(IndexedChests) do
            if ch.Parent and ch:FindFirstChild("TouchInterest") then
                local d = math.floor((ch.Position - root.Position).Magnitude)
                if d <= 3000 then
                    UpsertESP(ch, ch, string.format("[%s] (%dm)", ch.Name, d), Color3.fromRGB(255, 215, 65), seen)
                end
            end
        end
    end

    local locs = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
    if locs and (Config.ESPMirage or Config.ESPIslands) then
        for _, loc in ipairs(locs:GetChildren()) do
            local part = GetInstancePivotPart(loc)
            if part then
                local isSpecial = (loc.Name == "Mirage Island" or loc.Name == "Kitsune Island" or loc.Name == "Prehistoric Island")
                if (Config.ESPMirage and isSpecial) or (Config.ESPIslands and not isSpecial) then
                    local d = math.floor((part.Position - root.Position).Magnitude)
                    local col = isSpecial and Color3.fromRGB(255, 130, 255) or Color3.fromRGB(180, 220, 250)
                    UpsertESP(loc, part, string.format("[LOC] %s (%dm)", loc.Name, d), col, seen)
                end
            end
        end
    end

    for keyInst, entry in pairs(ESPPool) do
        if not seen[keyInst] then
            pcall(function() entry.Gui:Destroy() end)
            ESPPool[keyInst] = nil
        end
    end
end

-- // 15. Zero-Leak Drag Controller & UI (Fixes #55, #56) //
local function MakeDraggable(handle, frame)
    local dragging = false
    local activeInput = nil
    local dragStart, startPos

    TrackConn(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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
MainFrame.Size = UDim2.new(0, 710, 0, 460)
MainFrame.Position = UDim2.new(0.5, -355, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(60, 190, 115)
MainStroke.Thickness = 1.6

local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 38)
Header.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Header.BorderSizePixel = 0
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)
MakeDraggable(Header, MainFrame)

local HeaderTitle = Instance.new("TextLabel", Header)
HeaderTitle.Size = UDim2.new(0.42, 0, 1, 0)
HeaderTitle.Position = UDim2.new(0, 12, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Font = Enum.Font.Code
HeaderTitle.TextSize = 13
HeaderTitle.TextColor3 = Color3.fromRGB(240, 240, 250)
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Text = string.format("BLOX FRUITS V6 [SEA %d]", Runtime.CurrentSea)

local StatusLabel = Instance.new("TextLabel", Header)
StatusLabel.Size = UDim2.new(0.48, -75, 1, 0)
StatusLabel.Position = UDim2.new(0.42, 0, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 11
StatusLabel.TextColor3 = Color3.fromRGB(90, 220, 140)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
StatusLabel.Text = "Idle | [READY] Initialized"

local HideBtn = Instance.new("TextButton", Header)
HideBtn.Size = UDim2.new(0, 62, 0, 24)
HideBtn.Position = UDim2.new(1, -70, 0, 7)
HideBtn.BackgroundColor3 = Color3.fromRGB(45, 140, 85)
HideBtn.Font = Enum.Font.Code
HideBtn.TextSize = 12
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.Text = "HIDE"
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 4)

local FloatBtn = Instance.new("TextButton", ScreenGui)
FloatBtn.Size = UDim2.new(0, 52, 0, 52)
FloatBtn.Position = UDim2.new(0, 18, 0.45, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
FloatBtn.Font = Enum.Font.Code
FloatBtn.TextSize = 12
FloatBtn.TextColor3 = Color3.fromRGB(60, 190, 115)
FloatBtn.Text = "V6 UI"
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Color = Color3.fromRGB(60, 190, 115)
FloatStroke.Thickness = 2
MakeDraggable(FloatBtn, FloatBtn)

local function ToggleUI() MainFrame.Visible = not MainFrame.Visible end
TrackConn(HideBtn.MouseButton1Click, ToggleUI)
TrackConn(FloatBtn.MouseButton1Click, ToggleUI)

local Sidebar = Instance.new("ScrollingFrame", MainFrame)
Sidebar.Size = UDim2.new(0, 155, 1, -48)
Sidebar.Position = UDim2.new(0, 8, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
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
    Btn.Size = UDim2.new(1, -12, 0, 30)
    Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    Btn.Font = Enum.Font.Code
    Btn.TextSize = 12
    Btn.TextColor3 = Color3.fromRGB(200, 200, 215)
    Btn.Text = name
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    table.insert(TabButtons, Btn)

    local Page = Instance.new("ScrollingFrame", PagesHolder)
    Page.Size = UDim2.new(1, -176, 1, -48)
    Page.Position = UDim2.new(0, 168, 0, 42)
    Page.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
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
            b.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
            b.TextColor3 = Color3.fromRGB(200, 200, 215)
        end
        Page.Visible = true
        Btn.BackgroundColor3 = Color3.fromRGB(50, 155, 95)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    return Page, Btn
end

local function AddSection(page, text)
    local Lbl = Instance.new("TextLabel", page)
    Lbl.Size = UDim2.new(1, -16, 0, 22)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.Code
    Lbl.TextSize = 12
    Lbl.TextColor3 = Color3.fromRGB(80, 210, 130)
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Text = "-- " .. string.upper(text) .. " --"
end

local function AddToggle(page, text, key, stopsMoveOnDisable, callback)
    local Row = Instance.new("Frame", page)
    Row.Size = UDim2.new(1, -16, 0, 32)
    Row.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 5)

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(1, -72, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.Code
    Lbl.TextSize = 12
    Lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Text = text

    local Btn = Instance.new("TextButton", Row)
    Btn.Size = UDim2.new(0, 52, 0, 22)
    Btn.Position = UDim2.new(1, -60, 0, 5)
    Btn.Font = Enum.Font.Code
    Btn.TextSize = 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    local function Sync()
        local on = Config[key]
        Btn.Text = on and "ON" or "OFF"
        Btn.BackgroundColor3 = on and Color3.fromRGB(50, 165, 100) or Color3.fromRGB(65, 65, 80)
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    Sync()

    TrackConn(Btn.MouseButton1Click, function()
        Config[key] = not Config[key]
        Sync()
        SaveConfig()
        if not Config[key] then
            ResetBranchWatchdog(key)
            if stopsMoveOnDisable then StopMovement(key) end
        end
        if callback then
            local ok, err = pcall(callback, Config[key])
            if not ok then SetLog("FAIL", key .. ": " .. tostring(err)) end
        end
    end)
end

local function AddCycle(page, text, list, key)
    local Row = Instance.new("Frame", page)
    Row.Size = UDim2.new(1, -16, 0, 32)
    Row.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 5)

    local Lbl = Instance.new("TextLabel", Row)
    Lbl.Size = UDim2.new(0.55, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Font = Enum.Font.Code
    Lbl.TextSize = 12
    Lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Text = text

    local idx = 1
    for i, v in ipairs(list) do
        if v == Config[key] then idx = i break end
    end

    local Btn = Instance.new("TextButton", Row)
    Btn.Size = UDim2.new(0.42, -10, 0, 22)
    Btn.Position = UDim2.new(0.58, 0, 0, 5)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 90, 150)
    Btn.Font = Enum.Font.Code
    Btn.TextSize = 12
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
    Btn.BackgroundColor3 = Color3.fromRGB(42, 95, 150)
    Btn.Font = Enum.Font.Code
    Btn.TextSize = 12
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Text = text
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
    TrackConn(Btn.MouseButton1Click, function()
        task.spawn(function()
            local ok, err = pcall(fn)
            if not ok then SetLog("FAIL", "Btn: " .. tostring(err)) end
        end)
    end)
end

-- // 16. Populate All 7 Tabs with Honest, Accurate Labels //
local TabFarm, FirstBtn = CreateTab("Auto Farm")
local TabMastery = CreateTab("Mastery & Quests")
local TabSeaEvents = CreateTab("Sea Events & V4")
local TabShop = CreateTab("Styles & Shop")
local TabFruitRaid = CreateTab("Fruit & Raid")
local TabTeleport = CreateTab("Teleports")
local TabESPMisc = CreateTab("ESP & Mods")

FirstBtn.BackgroundColor3 = Color3.fromRGB(50, 155, 95)
FirstBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabFarm.Visible = true

-- Tab 1: Auto Farm
AddSection(TabFarm, "Core Farming")
AddCycle(TabFarm, "Primary Weapon", ValidEnums.SelectedWeapon, "SelectedWeapon")
AddCycle(TabFarm, "Hover Offset Y", {18, 25, 28, 35, 45}, "FarmOffsetY")
AddCycle(TabFarm, "Move Speed", {200, 260, 300, 330}, "TweenSpeed")
AddToggle(TabFarm, "Use Instant Portal Nodes", "UsePortalTeleport", false)
AddToggle(TabFarm, "Auto Farm Level (Quest + Mob)", "AutoFarmLevel", true)
AddToggle(TabFarm, "Auto Farm Nearest Mob", "AutoFarmNearest", true)
AddToggle(TabFarm, "Auto Farm Chests (Beli/Touch Check)", "AutoFarmChest", true)
AddToggle(TabFarm, "Bring Mobs (Restores NPCs on Off)", "BringMobs", false, function(on)
    if not on then RestoreModifiedNPCs() end
end)
AddToggle(TabFarm, "Fast Attack (Net + Upvalue)", "FastAttack", false)
AddToggle(TabFarm, "Auto Buso Haki", "AutoBuso", false)
AddToggle(TabFarm, "Auto Observation Haki (Ken)", "AutoKen", false)

-- Tab 2: Mastery, Bosses & Quests
AddSection(TabMastery, "Standalone Mastery Engine")
AddToggle(TabMastery, "Auto Farm Mastery (Standalone/Assist)", "AutoFarmMastery", true)
AddCycle(TabMastery, "Mastery Weapon Type", ValidEnums.MasteryTargetWeapon, "MasteryTargetWeapon")
AddCycle(TabMastery, "Switch Weapon At Mob HP %", {20, 30, 35, 50}, "MasteryHealthThreshold")
AddToggle(TabMastery, "Cast Skill Z", "UseSkillZ", false)
AddToggle(TabMastery, "Cast Skill X", "UseSkillX", false)
AddToggle(TabMastery, "Cast Skill C", "UseSkillC", false)
AddToggle(TabMastery, "Cast Skill V", "UseSkillV", false)
AddToggle(TabMastery, "Cast Skill F", "UseSkillF", false)
AddSection(TabMastery, "Bosses & Sea Grinds")
AddToggle(TabMastery, "Auto Farm All Spawned Bosses", "AutoFarmBosses", true)
AddToggle(TabMastery, "Auto Farm Bones (Haunted Castle)", "AutoFarmBone", true)
AddToggle(TabMastery, "Auto Trade 50 Bones (Checks Bone Count)", "AutoTradeBones", false)
AddToggle(TabMastery, "Auto Farm Cake Prince / Dough King", "AutoFarmKatakuri", true)
AddToggle(TabMastery, "Auto Open Cake Prince Portal", "AutoSpawnCakePrince", false)
AddToggle(TabMastery, "Auto Elite Hunter (Event-Cached)", "AutoEliteHunter", true)
AddToggle(TabMastery, "Auto Attack Factory Core (When Open)", "AutoFactory", true)
AddToggle(TabMastery, "Auto Pirate Raid (Castle Mobs)", "AutoPirateRaid", true)
AddSection(TabMastery, "Sword & Quest Assistants")
AddToggle(TabMastery, "Auto Saber Boss Assist (Relic + Expert)", "AutoSaber", true)
AddToggle(TabMastery, "Auto Bartilo Assist (Swan/Jeremy/Plates)", "AutoBartilo", true)
AddToggle(TabMastery, "Auto Rengoku (Key Farm + Chest Touch)", "AutoRengoku", true)
AddToggle(TabMastery, "Auto Pull Yama (Checks >= 30 Elite Kills)", "AutoYama", true)
AddToggle(TabMastery, "Auto Light Tushita Torches (Requires Torch)", "AutoTushita", true)

-- Tab 3: Sea Events & Race V4
AddSection(TabSeaEvents, "Sea Events & Mirage")
AddToggle(TabSeaEvents, "Auto Hunt Sea Beasts", "AutoSeaBeast", true)
AddToggle(TabSeaEvents, "Auto Hunt Terrorshark / Sharks", "AutoTerrorshark", true)
AddToggle(TabSeaEvents, "Auto Hunt Ghost Ship / Haunted Crew", "AutoGhostShip", true)
AddToggle(TabSeaEvents, "Auto Move To Mirage Marker", "AutoFindMirage", true)
AddToggle(TabSeaEvents, "Auto Move & Touch Blue Gear", "AutoTeleportGear", true)
AddSection(TabSeaEvents, "Race V4 & Temple of Time")
AddToggle(TabSeaEvents, "Auto Move & Attempt V4 Lever", "AutoPullLever", true)
AddToggle(TabSeaEvents, "Auto Trial V4 Combat Assist (Temple Radius)", "AutoTrialV4", true)
AddToggle(TabSeaEvents, "Auto Activate Race V4 (Checks RaceEnergy)", "AutoActivateV4", false)
AddButton(TabSeaEvents, "Move -> Temple of Time", function()
    Runtime.TaskName = "Teleport: Temple of Time"
    RequestMoveTo(CFrame.new(28286.35, 14895.30, 102.62), "OneShot", "ManualTeleport")
end)
AddButton(TabSeaEvents, "Move & Attempt V4 Lever (GenID Tracked)", function()
    local map = Workspace:FindFirstChild("Map")
    local temple = map and map:FindFirstChild("Temple of Time")
    local lever = temple and temple:FindFirstChild("Lever")
    local part = lever and GetInstancePivotPart(lever)
    if not part then
        SetLog("WARN", "V4 Lever not streamed in Workspace")
        return
    end
    Runtime.TaskName = "Moving to V4 Lever"
    local genId = RequestMoveTo(part.CFrame, "OneShot", "ManualLever")
    local t0 = os.clock()
    while Runtime.ArrivedMoveId ~= genId and Runtime.MoveOwner == "ManualLever" and (os.clock() - t0 < 25) do
        task.wait(0.1)
    end
    if GetRoot() and (GetRoot().Position - part.Position).Magnitude <= 18 then
        local ok, status = TryTriggerInteractables(lever)
        SetLog(ok and "ATTEMPT" or "WARN", "V4 Lever: " .. status)
    end
end)

-- Tab 4: Styles & Shop (Fixes #59, #60, #61)
AddSection(TabShop, "Auto Stats (Clamped & Point-Checked)")
AddToggle(TabShop, "Auto Allocate Stat Points", "AutoStats", false)
AddCycle(TabShop, "Target Stat", ValidEnums.StatTarget, "StatTarget")
AddCycle(TabShop, "Points Per Tick", {1, 3, 10, 25}, "StatBatch")
AddSection(TabShop, "Fighting Styles (Evaluates Server Response)")
local function PurchaseWithEvaluatedLog(label, ...)
    local callOk, res, semanticOk, reason = InvokeCommF(...)
    if callOk and semanticOk then
        SetLog("OK", label .. ": " .. tostring(res))
    else
        SetLog("FAIL", label .. ": " .. tostring(reason or res or "Call failed"))
    end
end
AddButton(TabShop, "Buy Black Leg", function() PurchaseWithEvaluatedLog("BlackLeg", "BuyBlackLeg") end)
AddButton(TabShop, "Buy Electro", function() PurchaseWithEvaluatedLog("Electro", "BuyElectro") end)
AddButton(TabShop, "Buy Fishman Karate", function() PurchaseWithEvaluatedLog("FishmanKarate", "BuyFishmanKarate") end)
AddButton(TabShop, "Buy Dragon Breath", function()
    local ok1, res1, sem1, r1 = InvokeCommF("BlackbeardReward", "DragonClaw", "1")
    local ok2, res2, sem2, r2 = InvokeCommF("BlackbeardReward", "DragonClaw", "2")
    if (ok1 and sem1) or (ok2 and sem2) then
        SetLog("OK", "DragonClaw: " .. tostring(res2 or res1))
    else
        SetLog("FAIL", "DragonClaw: " .. tostring(r2 or r1 or "Failed"))
    end
end)
AddButton(TabShop, "Buy Superhuman", function() PurchaseWithEvaluatedLog("Superhuman", "BuySuperhuman") end)
AddButton(TabShop, "Buy Death Step", function() PurchaseWithEvaluatedLog("DeathStep", "BuyDeathStep") end)
AddButton(TabShop, "Buy Sharkman Karate", function() PurchaseWithEvaluatedLog("SharkmanKarate", "BuySharkmanKarate") end)
AddButton(TabShop, "Buy Electric Claw", function() PurchaseWithEvaluatedLog("ElectricClaw", "BuyElectricClaw") end)
AddButton(TabShop, "Buy Dragon Talon", function() PurchaseWithEvaluatedLog("DragonTalon", "BuyDragonTalon") end)
AddButton(TabShop, "Buy Godhuman", function() PurchaseWithEvaluatedLog("Godhuman", "BuyGodhuman") end)
AddButton(TabShop, "Buy Sanguine Art", function() PurchaseWithEvaluatedLog("SanguineArt", "BuySanguineArt") end)
AddSection(TabShop, "Abilities & Resets")
AddButton(TabShop, "Buy Geppo (Skyjump)", function() PurchaseWithEvaluatedLog("Geppo", "BuyHaki", "Geppo") end)
AddButton(TabShop, "Buy Buso Haki", function() PurchaseWithEvaluatedLog("Buso", "BuyHaki", "Buso") end)
AddButton(TabShop, "Buy Soru (Flash Step)", function() PurchaseWithEvaluatedLog("Soru", "BuyHaki", "Soru") end)
AddButton(TabShop, "Buy Ken Haki (Instinct)", function() PurchaseWithEvaluatedLog("Ken", "KenTalk", "Buy") end)
AddButton(TabShop, "Refund Stats (2,500 Fragments)", function() PurchaseWithEvaluatedLog("Refund", "BlackbeardReward", "Refund", "2") end)
AddButton(TabShop, "Reroll Race (3,000 Fragments)", function() PurchaseWithEvaluatedLog("Reroll", "BlackbeardReward", "Reroll", "2") end)

-- Tab 5: Fruit & Raid
AddSection(TabFruitRaid, "Devil Fruits")
AddToggle(TabFruitRaid, "Auto Random Fruit (Cousin Gacha)", "AutoRandomFruit", false)
AddToggle(TabFruitRaid, "Auto Store Fruits (Lookup + Parent Check)", "AutoStoreFruit", false)
AddToggle(TabFruitRaid, "Teleport & Grab Dropped Fruits", "GrabDroppedFruits", true)
AddCycle(TabFruitRaid, "Dealer Sniper Target", ValidEnums.SniperFruitTarget, "SniperFruitTarget")
AddToggle(TabFruitRaid, "Auto Buy Sniper Target (Beli Delta Check)", "AutoSnipeFruit", false)
AddSection(TabFruitRaid, "Raids & Awakening")
AddCycle(TabFruitRaid, "Select Raid Chip", ValidEnums.SelectedRaid, "SelectedRaid")
AddToggle(TabFruitRaid, "Auto Buy Raid Chip (Polls Microchip)", "AutoBuyChip", false)
AddToggle(TabFruitRaid, "Auto Start Raid (Console Click)", "AutoStartRaid", true)
AddToggle(TabFruitRaid, "Radius Attack Aura (RE/RegisterHit)", "KillAura", false)
AddToggle(TabFruitRaid, "Auto Next Raid Island", "AutoNextIsland", true)
AddToggle(TabFruitRaid, "Auto Awaken Fruit (Room Proximity Checked)", "AutoAwaken", false)

-- Tab 6: Teleports
AddSection(TabTeleport, "Cross-Sea Travel")
AddButton(TabTeleport, "Travel -> First Sea", function() InvokeCommF("TravelMain") end)
AddButton(TabTeleport, "Travel -> Second Sea", function() InvokeCommF("TravelDressrosa") end)
AddButton(TabTeleport, "Travel -> Third Sea", function() InvokeCommF("TravelZou") end)
AddSection(TabTeleport, "Current Sea Islands (OneShot Move)")
for name, cf in pairs(IslandLocations[Runtime.CurrentSea] or {}) do
    AddButton(TabTeleport, "Move -> " .. name, function()
        Runtime.TaskName = "Teleport: " .. name
        RequestMoveTo(cf, "OneShot", "ManualTeleport")
    end)
end
AddButton(TabTeleport, "Stop Active Movement", function() StopMovement(nil) end)

-- Tab 7: ESP, Mods & Full 10-Capability Diagnostics (Fix #85)
AddSection(TabESPMisc, "Executor API Presence (Static Check)")
local DiagLabel = Instance.new("TextLabel", TabESPMisc)
DiagLabel.Size = UDim2.new(1, -16, 0, 44)
DiagLabel.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
DiagLabel.Font = Enum.Font.Code
DiagLabel.TextSize = 11
DiagLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
DiagLabel.TextWrapped = true
DiagLabel.Text = string.format(
    "Hook:%s | Caller:%s | GC:%s | Upval:%s | SimRad:%s | VIM:%s | Click:%s | Prompt:%s | Touch:%s | File:%s/%s",
    tostring(Capabilities.HookMeta), tostring(Capabilities.CheckCaller), tostring(Capabilities.GetGC),
    tostring(Capabilities.Upvalues), tostring(Capabilities.SimRadius), tostring(Capabilities.VIM),
    tostring(Capabilities.Click), tostring(Capabilities.Prompt), tostring(Capabilities.Touch),
    tostring(Capabilities.FileIO), tostring(Capabilities.FolderIO)
)
Instance.new("UICorner", DiagLabel).CornerRadius = UDim.new(0, 5)

AddSection(TabESPMisc, "Diff-Pooled Visual ESP")
AddToggle(TabESPMisc, "ESP Players", "ESPPlayers", false, RefreshESP)
AddToggle(TabESPMisc, "ESP Devil Fruits (Event Indexed)", "ESPFruits", false, RefreshESP)
AddToggle(TabESPMisc, "ESP Chests (Event Indexed)", "ESPChests", false, RefreshESP)
AddToggle(TabESPMisc, "ESP Flowers (Event Indexed)", "ESPFlowers", false, RefreshESP)
AddToggle(TabESPMisc, "ESP Mirage / Kitsune / Prehistoric", "ESPMirage", false, RefreshESP)
AddToggle(TabESPMisc, "ESP All World Islands", "ESPIslands", false, RefreshESP)

AddSection(TabESPMisc, "Combat & Reversible World Mods")
AddToggle(TabESPMisc, "Auto Resume Saved Toggles On Load", "AutoResumeSavedToggles", false)
AddToggle(TabESPMisc, "Silent Aimbot Skills (Equipped Tool Only)", "AimbotSkill", false)
AddToggle(TabESPMisc, "NoClip (Restores Collisions)", "NoClip", false, function(on)
    if not on then RestoreCharacterCollisions() end
end)
AddToggle(TabESPMisc, "Walk On Water Plane (Restores Size)", "WalkOnWater", false, function(on)
    if not on then RestoreWaterPlane() end
end)
AddToggle(TabESPMisc, "Infinite Energy (Client Stamina Value)", "InfiniteEnergy", false)
AddToggle(TabESPMisc, "Experimental Infinite Geppo (GC Upvalue)", "InfiniteGeppo", false, function(on)
    if on then ApplyExperimentalGCPatch() else RestoreExperimentalGCPatch() end
end)
AddToggle(TabESPMisc, "Experimental No Dodge CD (GC Upvalue)", "NoDodgeCooldown", false, function(on)
    if on then ApplyExperimentalGCPatch() else RestoreExperimentalGCPatch() end
end)
AddToggle(TabESPMisc, "Remove Fog (Unified Lighting Sync)", "RemoveFog", false, SyncLightingState)
AddToggle(TabESPMisc, "FullBright (Unified Lighting Sync)", "FullBright", false, SyncLightingState)

-- // 17. Stepped Physics & State Loop //
TrackConn(RunService.Stepped, function()
    pcall(function()
        local elapsed = math.floor(os.clock() - Runtime.LastLogTime)
        StatusLabel.Text = string.format("%s | [%s %ds] %s", Runtime.TaskName, Runtime.LastStatusTag, elapsed, Runtime.LastLog)

        local farmingMoveActive = (Runtime.MoveTargetCF ~= nil)
        local char = GetChar()

        if Config.NoClip or farmingMoveActive then
            if char then
                Runtime.NoClipApplied = true
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if Runtime.CollisionSnapshot[part] == nil then
                            Runtime.CollisionSnapshot[part] = (StandardCollideParts[part.Name] == true)
                        end
                        if part.CanCollide then part.CanCollide = false end
                    end
                end
            end
        elseif Runtime.NoClipApplied then
            RestoreCharacterCollisions()
        end

        local map = Workspace:FindFirstChild("Map")
        local wp = map and map:FindFirstChild("WaterBase-Plane")
        if wp and wp:IsA("BasePart") then
            if not Runtime.WaterPlaneSizeSnapshot then
                Runtime.WaterPlaneSizeSnapshot = wp.Size
            end
            if Config.WalkOnWater then
                wp.Size = Vector3.new(Runtime.WaterPlaneSizeSnapshot.X, 112, Runtime.WaterPlaneSizeSnapshot.Z)
                Runtime.WaterPlaneModified = true
            elseif Runtime.WaterPlaneModified then
                RestoreWaterPlane()
            end
        end

        if Config.InfiniteEnergy and char then
            local en = char:FindFirstChild("Energy")
            if en and (en:IsA("IntValue") or en:IsA("NumberValue")) then
                en.Value = GetAuthoritativeMaxEnergy(char)
            end
        end

        if Config.FullBright or Config.RemoveFog then
            SyncLightingState()
        end
    end)
end)

-- // 18. Fast Attack Scheduler //
task.spawn(function()
    while SessionActive and ScreenGui.Parent do
        task.wait(0.08)
        if Config.FastAttack or Config.KillAura then
            local anyCombat = Config.KillAura or Config.AutoFarmLevel or Config.AutoFarmNearest
                or Config.AutoFarmBosses or Config.AutoFarmBone or Config.AutoFarmKatakuri
                or Config.AutoEliteHunter or Config.AutoFactory or Config.AutoPirateRaid
                or Config.AutoSeaBeast or Config.AutoTerrorshark or Config.AutoGhostShip
                or Config.AutoTrialV4 or Config.AutoSaber or Config.AutoBartilo
                or Config.AutoRengoku or Config.AutoYama or Config.AutoTushita or Config.AutoFarmMastery
            if anyCombat then
                ExecuteAttackPulse(CurrentActiveMob, Config.KillAura and 120 or 60)
            end
        end
    end
end)

-- // 19. Quest State Helpers (Fix #9: Explicit MaxSupportedQuestLevel Warning) //
local function GetQuestBracket(level)
    local list = QuestDatabase[Runtime.CurrentSea]
    if not list then return nil end
    if level > MaxSupportedQuestLevel then
        if HasCooldownElapsed("MaxLevelWarn", 30.0) then
            CommitCooldown("MaxLevelWarn")
            SetLog("WARN", "Level " .. tostring(level) .. " > DB Max (" .. tostring(MaxSupportedQuestLevel) .. "); using top quest")
        end
        return list[#list]
    end
    for _, q in ipairs(list) do
        if level >= q.Min and level <= q.Max then
            return q
        end
    end
    return list[1]
end

local function CheckQuestUIMatch(expectedMobName)
    local pgui = LocalPlayer:FindFirstChild("PlayerGui")
    local main = pgui and pgui:FindFirstChild("Main")
    local qFrame = main and main:FindFirstChild("Quest")
    if not qFrame or not qFrame.Visible then return false end

    local title = qFrame:FindFirstChild("Container")
        and qFrame.Container:FindFirstChild("QuestTitle")
        and qFrame.Container.QuestTitle:FindFirstChild("Title")
    if title and string.find(string.lower(title.Text), string.lower(expectedMobName), 1, true) then
        return true
    end
    if CheckAndCommitCooldown("AbandonQuest", 2.0) then
        InvokeCommF("AbandonQuest")
        SetLog("INFO", "Abandoned mismatched quest")
    end
    return false
end

-- // 20. Primary State Machine Loop //
task.spawn(function()
    while SessionActive and ScreenGui.Parent do
        task.wait(0.12)
        pcall(function()
            if not Runtime.KnownSea then DetectSeaOnce() end

            -- Fix #67 & #68: Clear AimbotTargetPart & CurrentActiveMob at the start of every tick
            Runtime.AimbotTargetPart = nil
            CurrentActiveMob = nil

            local root = GetRoot()
            local hum = GetHum()
            if not root or not hum or hum.Health <= 0 then
                Runtime.TaskName = "Waiting Respawn"
                return
            end

            -- Fix #64 & #65: Require RaceEnergy and RaceTransformed instances to exist before pressing Y
            if Config.AutoActivateV4 and CheckAndCommitCooldown("ActivateV4Key", 2.5) then
                local ch = GetChar()
                local raceEnergy = ch and ch:FindFirstChild("RaceEnergy")
                local raceTransformed = ch and ch:FindFirstChild("RaceTransformed")
                if raceEnergy and raceEnergy.Value >= 1 and raceTransformed and raceTransformed.Value == false then
                    if Capabilities.VIM then
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Y, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Y, false, game)
                        end)
                        SetLog("ATTEMPT", "Pressed Y for Race V4")
                    end
                end
            end

            -- 1. Grab Dropped Devil Fruits (Watchdog Protected)
            if Config.GrabDroppedFruits and IsBranchAllowed("GrabDroppedFruits", 12.0, 20.0) then
                for obj in pairs(IndexedFruits) do
                    if obj.Parent and not Players:GetPlayerFromCharacter(obj.Parent) then
                        local part = GetInstancePivotPart(obj)
                        if part then
                            Runtime.TaskName = "Grabbing " .. obj.Name
                            RequestMoveTo(part.CFrame, "OneShot", "GrabDroppedFruits")
                            if (root.Position - part.Position).Magnitude <= 15 and CheckAndCommitCooldown("GrabFruitTouch", 0.8) then
                                TryTriggerInteractables(obj)
                            end
                            return
                        end
                    end
                end
                ResetBranchWatchdog("GrabDroppedFruits")
            end

            -- 2. Auto Start Raid (Watchdog Protected)
            if Config.AutoStartRaid and (Runtime.CurrentSea == 2 or Runtime.CurrentSea == 3) and HasItem("Special Microchip", false) then
                local raidTimer = LocalPlayer:FindFirstChild("PlayerGui")
                    and LocalPlayer.PlayerGui:FindFirstChild("Main")
                    and LocalPlayer.PlayerGui.Main:FindFirstChild("Timer")
                if not (raidTimer and raidTimer.Visible) and IsBranchAllowed("AutoStartRaid", 12.0, 20.0) then
                    local map = Workspace:FindFirstChild("Map")
                    local raidLab = (Runtime.CurrentSea == 2 and map and map:FindFirstChild("CircleIsland") and map.CircleIsland:FindFirstChild("RaidSummon2"))
                        or (Runtime.CurrentSea == 3 and map and map:FindFirstChild("Boat Castle") and map["Boat Castle"]:FindFirstChild("RaidSummon2"))
                    local button = raidLab and raidLab:FindFirstChild("Button") and raidLab.Button:FindFirstChild("Main")
                    if button and button:IsA("BasePart") then
                        Runtime.TaskName = "Raid Console"
                        RequestMoveTo(button.CFrame * CFrame.new(0, 4, 0), "HoverLock", "AutoStartRaid")
                        if (root.Position - button.Position).Magnitude <= 18 and CheckAndCommitCooldown("StartRaidClick", 2.5) then
                            EquipWeapon(nil, "Special Microchip")
                            local ok, st = TryTriggerInteractables(button)
                            SetLog(ok and "ATTEMPT" or "WARN", "Raid Console: " .. st)
                        end
                        return
                    end
                else
                    ResetBranchWatchdog("AutoStartRaid")
                end
            end

            -- 3. Auto Next Raid Island
            if Config.AutoNextIsland then
                local locs = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
                if locs then
                    for i = 5, 1, -1 do
                        local isl = locs:FindFirstChild("Island " .. tostring(i))
                        local part = isl and GetInstancePivotPart(isl)
                        if part and (part.Position - root.Position).Magnitude < 3500 then
                            Runtime.TaskName = "Raid Island " .. tostring(i)
                            local raidMob = FindEnemy(nil, false, part.Position, 900)
                            if raidMob then
                                EngageMob(raidMob, nil, "AutoNextIsland")
                            else
                                RequestMoveTo(part.CFrame * CFrame.new(0, 50, 0), "HoverLock", "AutoNextIsland")
                            end
                            return
                        end
                    end
                end
            end

            -- 4. Auto Pull Lever & Auto Trial V4 Combat Assist (Fixes #11, #12, #66, #78, #79)
            if Config.AutoPullLever and Runtime.CurrentSea == 3 and IsBranchAllowed("AutoPullLever", 15.0, 25.0) then
                local map = Workspace:FindFirstChild("Map")
                local temple = map and map:FindFirstChild("Temple of Time")
                local lever = temple and temple:FindFirstChild("Lever")
                local part = lever and GetInstancePivotPart(lever)
                if part then
                    Runtime.TaskName = "Moving to V4 Lever"
                    RequestMoveTo(part.CFrame, "OneShot", "AutoPullLever")
                    if (part.Position - root.Position).Magnitude <= 16 and CheckAndCommitCooldown("PullV4Lever", 2.5) then
                        local ok, st = TryTriggerInteractables(lever)
                        SetLog(ok and "ATTEMPT" or "WARN", "V4 Lever: " .. st)
                    end
                    return
                else
                    Runtime.TaskName = "Streaming Temple of Time"
                    RequestMoveTo(CFrame.new(28286.35, 14895.30, 102.62), "HoverLock", "AutoPullLever")
                    return
                end
            end

            if Config.AutoTrialV4 and Runtime.CurrentSea == 3 then
                local templeCenter = Vector3.new(28286.35, 14895.30, 102.62)
                local trialMob = FindEnemy(nil, false, templeCenter, 2500)
                if trialMob then
                    Runtime.TaskName = "Trial V4 Combat Assist"
                    EngageMob(trialMob, nil, "AutoTrialV4")
                    return
                end
            end

            -- 5. Mirage Blue Gear & Mirage Marker (Watchdog Protected)
            if Config.AutoTeleportGear and Runtime.CurrentSea == 3 and IsBranchAllowed("AutoTeleportGear", 12.0, 20.0) then
                local map = Workspace:FindFirstChild("Map")
                local mystic = map and map:FindFirstChild("MysticIsland")
                if mystic then
                    for _, v in ipairs(mystic:GetDescendants()) do
                        if v:IsA("MeshPart") and (v.MeshId == "rbxassetid://10153114969" or v.Name == "Gear") then
                            Runtime.TaskName = "Blue Gear"
                            RequestMoveTo(v.CFrame, "OneShot", "AutoTeleportGear")
                            if (root.Position - v.Position).Magnitude <= 15 and CheckAndCommitCooldown("TouchGear", 1.5) then
                                local ok, st = TryTriggerInteractables(v)
                                SetLog(ok and "ATTEMPT" or "WARN", "Blue Gear: " .. st)
                            end
                            return
                        end
                    end
                end
            end

            if Config.AutoFindMirage and Runtime.CurrentSea == 3 and IsBranchAllowed("AutoFindMirage", 15.0, 20.0) then
                local locs = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
                local mirage = locs and locs:FindFirstChild("Mirage Island")
                local part = mirage and GetInstancePivotPart(mirage)
                if part then
                    Runtime.TaskName = "Mirage Marker"
                    RequestMoveTo(part.CFrame * CFrame.new(0, 180, 0), "HoverLock", "AutoFindMirage")
                    return
                end
            end

            -- 6. Sea Events: Sea Beasts, Terrorshark, Ghost Ship
            if Config.AutoSeaBeast then
                local sbFolder = Workspace:FindFirstChild("SeaBeasts")
                if sbFolder then
                    for _, sb in ipairs(sbFolder:GetChildren()) do
                        local sbRoot = sb:FindFirstChild("HumanoidRootPart")
                        local sbHum = sb:FindFirstChildOfClass("Humanoid")
                        if sbRoot and sbHum and sbHum.Health > 0 then
                            Runtime.TaskName = "Sea Beast"
                            CurrentActiveMob = sb
                            Runtime.AimbotTargetPart = sbRoot
                            RequestMoveTo(sbRoot.CFrame * CFrame.new(0, 210, 0), "HoverLock", "AutoSeaBeast")
                            EquipWeapon("Blox Fruit")
                            TryCastNextAvailableSkill("Blox Fruit")
                            return
                        end
                    end
                end
            end

            if Config.AutoTerrorshark then
                local seaMob = FindEnemy({"Terrorshark", "Shark", "Piranha", "Fish Crew Member"}, false)
                if seaMob then
                    Runtime.TaskName = "Sea Event: " .. seaMob.Name
                    EngageMob(seaMob, nil, "AutoTerrorshark")
                    return
                end
            end

            if Config.AutoGhostShip then
                local ghostMob = FindEnemy({"Haunted Crew Member", "Ghost Ship", "Pirate Brigade"}, false)
                if ghostMob then
                    Runtime.TaskName = "Ghost Ship: " .. ghostMob.Name
                    EngageMob(ghostMob, nil, "AutoGhostShip")
                    return
                end
            end

            -- 7. Sword & Quest Assistants (Fixes #34-#43)
            if Config.AutoSaber and Runtime.CurrentSea == 1 then
                if HasItem("Saber", true) then
                    SetLog("OK", "Saber detected in inventory")
                    Config.AutoSaber = false
                    StopMovement("AutoSaber")
                    return
                end
                local lvl = GetReadyPlayerLevel() or 0
                if lvl >= 200 then
                    if CheckAndCommitCooldown("SaberCheck", 4.0) then
                        InvokeCommF("ProQuestProgress", "RichSon")
                        InvokeCommF("ProQuestProgress", "PlaceRelic")
                    end
                    local expert = FindEnemy("Saber Expert", false)
                    local mobLeader = FindEnemy("Mob Leader", false)
                    if expert then
                        Runtime.TaskName = "Saber: Killing Expert"
                        EngageMob(expert, nil, "AutoSaber")
                        return
                    elseif mobLeader then
                        Runtime.TaskName = "Saber: Killing Mob Leader"
                        EngageMob(mobLeader, nil, "AutoSaber")
                        return
                    end
                end
            end

            if Config.AutoBartilo and Runtime.CurrentSea == 2 then
                local lvl = GetReadyPlayerLevel() or 0
                if lvl >= 850 then
                    local ok, prog = InvokeCommF("BartiloQuestProgress", "Bartilo")
                    if ok and prog == 3 then
                        SetLog("OK", "Bartilo Quest == 3 (Complete)")
                        Config.AutoBartilo = false
                        StopMovement("AutoBartilo")
                        return
                    elseif ok and prog == 0 then
                        local swan = FindEnemy("Swan Pirate", false)
                        if swan then
                            Runtime.TaskName = "Bartilo: Swan Pirates"
                            EngageMob(swan, "Swan Pirate", "AutoBartilo")
                        else
                            RequestMoveTo(CFrame.new(1068.66, 137.61, 1322.10), "HoverLock", "AutoBartilo")
                        end
                        return
                    elseif ok and prog == 1 then
                        local jeremy = FindEnemy("Jeremy", false)
                        if jeremy then
                            Runtime.TaskName = "Bartilo: Killing Jeremy"
                            EngageMob(jeremy, nil, "AutoBartilo")
                        else
                            RequestMoveTo(CFrame.new(2099.88, 448.93, 853.20), "HoverLock", "AutoBartilo")
                        end
                        return
                    elseif ok and prog == 2 then
                        Runtime.TaskName = "Bartilo: Plates Remote"
                        if CheckAndCommitCooldown("BartiloPlates", 2.5) then
                            InvokeCommF("BartiloQuestProgress", "Plates")
                        end
                        return
                    end
                end
            end

            -- Fix #38 & #39: Rengoku interacts with secret chest upon arrival
            if Config.AutoRengoku and Runtime.CurrentSea == 2 then
                if HasItem("Rengoku", true) then
                    SetLog("OK", "Rengoku detected in inventory")
                    Config.AutoRengoku = false
                    StopMovement("AutoRengoku")
                    return
                end
                if HasItem("Hidden Key", false) and IsBranchAllowed("RengokuChest", 12.0, 20.0) then
                    Runtime.TaskName = "Unlocking Rengoku Chest"
                    EquipWeapon(nil, "Hidden Key")
                    local chestPos = CFrame.new(6571.12, 299.23, -6967.84)
                    RequestMoveTo(chestPos, "OneShot", "AutoRengoku")
                    if (root.Position - chestPos.Position).Magnitude <= 12 and CheckAndCommitCooldown("RengokuInteract", 1.5) then
                        local map = Workspace:FindFirstChild("Map")
                        local iceCastle = map and map:FindFirstChild("IceCastle")
                        if iceCastle then
                            TryTriggerInteractables(iceCastle)
                        end
                    end
                    return
                else
                    local iceMob = FindEnemy({"Awakened Ice Admiral", "Arctic Warrior", "Snow Lurker"}, false)
                    if iceMob then
                        Runtime.TaskName = "Farming Hidden Key"
                        EngageMob(iceMob, iceMob.Name, "AutoRengoku")
                    else
                        RequestMoveTo(CFrame.new(5667.65, 50.0, -6486.08), "HoverLock", "AutoRengoku")
                    end
                    return
                end
            end

            -- Fix #34 & #35: Verify Elite Hunter progress >= 30 before attempting Yama
            if Config.AutoYama and Runtime.CurrentSea == 3 and IsBranchAllowed("AutoYama", 12.0, 20.0) then
                if HasItem("Yama", true) then
                    SetLog("OK", "Yama detected in inventory")
                    Config.AutoYama = false
                    StopMovement("AutoYama")
                    return
                end
                local ok, prog = InvokeCommF("EliteHunter", "Progress")
                local kills = tonumber(prog) or 0
                if kills < 30 then
                    SetLog("WARN", "Yama requires 30 Elite kills (Current: " .. tostring(kills) .. ")")
                    Config.AutoYama = false
                    return
                end
                local map = Workspace:FindFirstChild("Map")
                local waterfall = map and map:FindFirstChild("Waterfall")
                local sealed = waterfall and waterfall:FindFirstChild("SealedKatana")
                local handle = sealed and sealed:FindFirstChild("Handle")
                if handle then
                    Runtime.TaskName = "Pulling Yama (" .. tostring(kills) .. " Elites)"
                    RequestMoveTo(handle.CFrame, "OneShot", "AutoYama")
                    if (root.Position - handle.Position).Magnitude <= 14 and CheckAndCommitCooldown("YamaClick", 1.5) then
                        local trigOk, st = TryTriggerInteractables(sealed)
                        SetLog(trigOk and "ATTEMPT" or "WARN", "Yama Katana: " .. st)
                    end
                    return
                end
            end

            -- Fix #40 & #41: Verify torch particle/light state before marking torch lit
            if Config.AutoTushita and Runtime.CurrentSea == 3 and HasItem("Holy Torch", false) then
                local map = Workspace:FindFirstChild("Map")
                local turtle = map and map:FindFirstChild("Turtle")
                local torches = turtle and turtle:FindFirstChild("QuestTorches")
                if torches then
                    for i = 1, 5 do
                        local t = torches:FindFirstChild("Torch" .. tostring(i))
                        if t and t:IsA("BasePart") then
                            local fx = t:FindFirstChildOfClass("ParticleEmitter") or t:FindFirstChildOfClass("PointLight") or t:FindFirstChildOfClass("Fire")
                            local alreadyLit = (fx and fx.Enabled == true) or ( (t:GetAttribute("OllieTries") or 0) >= 4 )
                            if not alreadyLit then
                                Runtime.TaskName = "Tushita Torch " .. tostring(i)
                                EquipWeapon(nil, "Holy Torch")
                                RequestMoveTo(t.CFrame, "OneShot", "AutoTushita")
                                if (root.Position - t.Position).Magnitude <= 12 and CheckAndCommitCooldown("TorchTry_" .. tostring(i), 1.2) then
                                    TryTriggerInteractables(t)
                                    local tries = (t:GetAttribute("OllieTries") or 0) + 1
                                    t:SetAttribute("OllieTries", tries)
                                    local litNow = fx and fx.Enabled == true
                                    SetLog(litNow and "OK" or "ATTEMPT", string.format("Torch %d (Try %d/4)", i, tries))
                                end
                                return
                            end
                        end
                    end
                end
            end

            -- 8. Auto Chest Farm (Fixes #48, #49, #50: Weak-table cooldown + Beli/TouchInterest verification)
            if Config.AutoFarmChest then
                local now = os.clock()
                local bestChest, minD = nil, math.huge
                for ch in pairs(IndexedChests) do
                    local skipUntil = VisitedChests[ch] or 0
                    if ch.Parent and ch:FindFirstChild("TouchInterest") and now >= skipUntil then
                        local d = (ch.Position - root.Position).Magnitude
                        if d < minD then
                            minD = d
                            bestChest = ch
                        end
                    end
                end
                if bestChest then
                    Runtime.TaskName = "Farming Chest"
                    RequestMoveTo(bestChest.CFrame, "OneShot", "AutoFarmChest")
                    if (root.Position - bestChest.Position).Magnitude <= 8 then
                        local beliBefore = GetPlayerBeli()
                        TryTriggerInteractables(bestChest)
                        task.wait(0.25)
                        local collected = (not bestChest.Parent) or (not bestChest:FindFirstChild("TouchInterest")) or (GetPlayerBeli() > beliBefore)
                        VisitedChests[bestChest] = os.clock() + 30.0
                        SetLog(collected and "OK" or "ATTEMPT", collected and "Chest collected" or "Chest touched (unconfirmed)")
                    end
                    return
                end
            end

            -- 9. Auto Factory Core & Auto Pirate Raid (Fix #45)
            if Config.AutoFactory and Runtime.CurrentSea == 2 then
                local core = FindEnemy("Core", false)
                if core then
                    Runtime.TaskName = "Factory Core"
                    EngageMob(core, nil, "AutoFactory")
                    return
                end
            end

            if Config.AutoPirateRaid and Runtime.CurrentSea == 3 then
                local castleCF = CFrame.new(-5543.53, 313.80, -2964.25)
                local raidMob = FindEnemy(nil, false, castleCF.Position, 750)
                if raidMob and raidMob.Name ~= "Training Dummy" then
                    Runtime.TaskName = "Pirate Raid: " .. raidMob.Name
                    EngageMob(raidMob, nil, "AutoPirateRaid")
                    return
                elseif (root.Position - castleCF.Position).Magnitude > 600 then
                    Runtime.TaskName = "Moving to Castle Raid"
                    RequestMoveTo(castleCF, "HoverLock", "AutoPirateRaid")
                    return
                end
            end

            -- 10. Auto Elite Hunter (Fixes #46, #47: Uses event-indexed IndexedReplicatedElites)
            if Config.AutoEliteHunter and Runtime.CurrentSea == 3 then
                local elite = FindEnemy({"Diablo", "Deandre", "Urban"}, false)
                if elite then
                    if CheckAndCommitCooldown("EliteAccept", 5.0) then InvokeCommF("EliteHunter") end
                    Runtime.TaskName = "Elite: " .. elite.Name
                    EngageMob(elite, nil, "AutoEliteHunter")
                    return
                else
                    if CheckAndCommitCooldown("EliteAccept", 5.0) then InvokeCommF("EliteHunter") end
                    for repMob in pairs(IndexedReplicatedElites) do
                        if repMob.Parent then
                            local mr = repMob:FindFirstChild("HumanoidRootPart")
                            if mr then
                                Runtime.TaskName = "Tracking Elite: " .. repMob.Name
                                RequestMoveTo(mr.CFrame * CFrame.new(0, Config.FarmOffsetY, 0), "HoverLock", "AutoEliteHunter")
                                return
                            end
                        end
                    end
                end
            end

            -- 11. Auto Cake Prince / Dough King
            if Config.AutoFarmKatakuri and Runtime.CurrentSea == 3 then
                local boss = FindEnemy({"Cake Prince", "Dough King"}, false)
                if boss then
                    Runtime.TaskName = "Boss: " .. boss.Name
                    EngageMob(boss, nil, "AutoFarmKatakuri")
                    return
                else
                    if Config.AutoSpawnCakePrince and CheckAndCommitCooldown("CakeSpawner", 6.0) then
                        InvokeCommF("CakePrinceSpawner", true)
                    end
                    local cakeMob = FindEnemy({"Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker"}, false)
                    if cakeMob then
                        Runtime.TaskName = "Cake Mobs: " .. cakeMob.Name
                        EngageMob(cakeMob, cakeMob.Name, "AutoFarmKatakuri")
                    else
                        Runtime.TaskName = "Waiting Cake Loaf"
                        RequestMoveTo(CFrame.new(-2021.32, 65.0, -12028.72), "HoverLock", "AutoFarmKatakuri")
                    end
                    return
                end
            end

            -- 12. Auto Bone Farm
            if Config.AutoFarmBone and Runtime.CurrentSea == 3 then
                local boneMob = FindEnemy({"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"}, false)
                if boneMob then
                    Runtime.TaskName = "Bone Farm: " .. boneMob.Name
                    EngageMob(boneMob, boneMob.Name, "AutoFarmBone")
                else
                    Runtime.TaskName = "Moving Haunted Castle"
                    RequestMoveTo(CFrame.new(-9505.87, 172.10, 6158.99), "HoverLock", "AutoFarmBone")
                end
                return
            end

            -- 13. Auto Level Farm
            if Config.AutoFarmLevel then
                local lvl = GetReadyPlayerLevel()
                if not lvl then
                    Runtime.TaskName = "Waiting Data.Level"
                    return
                end
                local qData = GetQuestBracket(lvl)
                if qData then
                    if not CheckQuestUIMatch(qData.Mob) then
                        Runtime.TaskName = "Quest: " .. qData.QuestName
                        RequestMoveTo(qData.QuestPos, "HoverLock", "AutoFarmLevel")
                        if (root.Position - qData.QuestPos.Position).Magnitude <= 14 and CheckAndCommitCooldown("StartQuest", 1.8) then
                            local ok, _, semOk = InvokeCommF("StartQuest", qData.QuestName, qData.QuestLvl)
                            SetLog((ok and semOk) and "OK" or "ATTEMPT", "StartQuest: " .. qData.QuestName)
                        end
                    else
                        local mob = FindEnemy(qData.Mob, false)
                        if mob then
                            Runtime.TaskName = "Farming: " .. qData.Mob
                            EngageMob(mob, qData.Mob, "AutoFarmLevel")
                        else
                            Runtime.TaskName = "Waiting: " .. qData.Mob
                            RequestMoveTo(qData.MobPos * CFrame.new(0, 35, 0), "HoverLock", "AutoFarmLevel")
                        end
                    end
                end
                return
            end

            -- 14. Standalone Mastery, Bosses, or Nearest
            if Config.AutoFarmBosses or Config.AutoFarmNearest or Config.AutoFarmMastery then
                local owner = (Config.AutoFarmBosses and "AutoFarmBosses")
                    or (Config.AutoFarmNearest and "AutoFarmNearest")
                    or "AutoFarmMastery"
                local mob = FindEnemy(nil, Config.AutoFarmBosses)
                if mob then
                    Runtime.TaskName = "Engaging: " .. mob.Name
                    EngageMob(mob, Config.AutoFarmBosses and nil or mob.Name, owner)
                    return
                end
            end

            Runtime.TaskName = "Idle"
        end)
    end
end)

-- // 21. Verified Background Daemons (Fixes #26-#33, #84) //
task.spawn(function()
    while SessionActive and ScreenGui.Parent do
        task.wait(1.0)
        pcall(function()
            -- Fix #84: Periodically ensure metamethod hook remains active
            EnsureMetamethodHook()

            if Config.AutoStats and GetPlayerStatPoints() > 0 then
                local pts = math.min(GetPlayerStatPoints(), math.clamp(Config.StatBatch, 1, 100))
                InvokeCommF("AddPoint", Config.StatTarget, pts)
            end

            if Config.AutoKen and CheckAndCommitCooldown("KenActivate", 5.0) then
                FireCommE("Ken", true)
            end

            if Config.AutoRandomFruit and CheckAndCommitCooldown("CousinGacha", 8.0) then
                local _, res, semOk = InvokeCommF("Cousin", "Buy")
                SetLog(semOk and "OK" or "ATTEMPT", "Cousin Gacha: " .. tostring(res))
            end

            -- Fix #32 & #33: Actually check Bone count >= 50 before buying Random Surprise
            if Config.AutoTradeBones and CheckAndCommitCooldown("BonesTrade", 5.0) then
                local ok, boneCount = InvokeCommF("Bones", "Check")
                if ok and type(boneCount) == "number" and boneCount >= 50 then
                    local _, res, semOk = InvokeCommF("Bones", "Buy", 1, 1)
                    SetLog(semOk and "OK" or "ATTEMPT", "Traded 50 Bones (Left: " .. tostring(boneCount - 50) .. ")")
                end
            end

            -- Fix #27 & #28: Verify Beli delta before logging snipe success
            if Config.AutoSnipeFruit and CheckAndCommitCooldown("FruitSnipe", 5.0) then
                local ok, stock = InvokeCommF("GetFruits")
                if ok and type(stock) == "table" then
                    for _, entry in ipairs(stock) do
                        if type(entry) == "table" and entry.Name == Config.SniperFruitTarget and (entry.OnSale == true or entry.InStock == true) then
                            local beliBefore = GetPlayerBeli()
                            local _, res, semOk = InvokeCommF("PurchaseRawFruit", Config.SniperFruitTarget, false)
                            task.wait(0.3)
                            local bought = (GetPlayerBeli() < beliBefore) or (semOk and res == true)
                            SetLog(bought and "OK" or "FAIL", "Snipe " .. Config.SniperFruitTarget .. ": " .. tostring(res))
                            break
                        end
                    end
                end
            end

            -- Fix #26, #53, #54: Use FruitCodeMap + verify tool left Backpack/Character after StoreFruit
            if Config.AutoStoreFruit then
                local bp = LocalPlayer:FindFirstChild("Backpack")
                local ch = GetChar()
                for _, cont in ipairs({bp, ch}) do
                    if cont then
                        for _, item in ipairs(cont:GetChildren()) do
                            if item:IsA("Tool") then
                                local code = item:GetAttribute("OriginalName") or FruitCodeMap[item.Name]
                                if not code and (string.find(item.Name, "Fruit") or item:FindFirstChild("Fruit")) then
                                    local clean = string.gsub(item.Name, " Fruit", "")
                                    code = clean .. "-" .. clean
                                end
                                if code then
                                    InvokeCommF("StoreFruit", code, item)
                                    task.wait(0.2)
                                    if item.Parent ~= bp and item.Parent ~= ch then
                                        SetLog("OK", "Stored " .. item.Name)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Fix #29: Poll up to 1.5s for Special Microchip replication after buying Raid Chip
            if Config.AutoBuyChip and not HasItem("Special Microchip", false) and CheckAndCommitCooldown("BuyRaidChip", 4.5) then
                InvokeCommF("RaidsNpc", "Select", Config.SelectedRaid)
                for _ = 1, 5 do
                    if HasItem("Special Microchip", false) then
                        SetLog("OK", "Purchased Raid Chip: " .. Config.SelectedRaid)
                        break
                    end
                    task.wait(0.3)
                end
            end

            -- Fix #30 & #31: Actually check proximity to Awakening Room before invoking Awakener
            if Config.AutoAwaken and CheckAndCommitCooldown("AwakenCheck", 4.0) then
                local map = Workspace:FindFirstChild("Map")
                local awakenRoom = map and (map:FindFirstChild("AwakeningRoom") or map:FindFirstChild("RaidMap"))
                local root = GetRoot()
                local nearAwakener = false
                if awakenRoom and root then
                    local p = GetInstancePivotPart(awakenRoom)
                    if p and (p.Position - root.Position).Magnitude <= 250 then
                        nearAwakener = true
                    end
                end
                if nearAwakener then
                    InvokeCommF("Awakener", "Check")
                    local _, res, semOk = InvokeCommF("Awakener", "Awaken")
                    SetLog(semOk and "OK" or "ATTEMPT", "Awakener: " .. tostring(res))
                end
            end

            if Config.InfiniteGeppo or Config.NoDodgeCooldown then
                ApplyExperimentalGCPatch()
            end

            if Config.ESPPlayers or Config.ESPFruits or Config.ESPChests or Config.ESPFlowers or Config.ESPMirage or Config.ESPIslands then
                RefreshESP()
            else
                for k, entry in pairs(ESPPool) do
                    pcall(function() entry.Gui:Destroy() end)
                    ESPPool[k] = nil
                end
            end
        end)
    end
end)

-- // 22. Complete State-Restoring Teardown (Fixes #4, #21, #81, #83) //
getgenv().OllieBF_Teardown = function()
    SessionActive = false
    getgenv().OllieBF_HookEnabled = false

    -- Restore original __namecall metamethod if supported
    if Capabilities.HookMeta and getgenv().OllieBF_OriginalNamecall then
        pcall(function()
            raw_hookmetamethod(game, "__namecall", getgenv().OllieBF_OriginalNamecall)
        end)
        getgenv().OllieBF_HookActive = false
        getgenv().OllieBF_OriginalNamecall = nil
    end

    StopMovement(nil)
    RestoreCharacterCollisions()
    RestoreModifiedNPCs()
    RestoreWaterPlane()
    RestoreExperimentalGCPatch()
    Config.FullBright = false
    Config.RemoveFog = false
    SyncLightingState()

    table.clear(CooldownTimestamps)
    table.clear(BranchWatchdog)

    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(Connections)

    for k, entry in pairs(ESPPool) do
        pcall(function() entry.Gui:Destroy() end)
        ESPPool[k] = nil
    end

    if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
    if ESPFolder and ESPFolder.Parent then ESPFolder:Destroy() end
end
