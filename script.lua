-- ====================================================================
--                 AUTO FISH V4.2 - RAYFIELD UI EDITION (SAFE REQUIRE)
-- ====================================================================

-- ====== CRITICAL DEPENDENCY VALIDATION ======
local success, errorMsg = pcall(function()
    local services = {
        game = game,
        workspace = workspace,
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        HttpService = game:GetService("HttpService")
    }

    for serviceName, service in pairs(services) do
        if not service then
            error("Critical service missing: " .. serviceName)
        end
    end

    local LocalPlayer = game:GetService("Players").LocalPlayer
    if not LocalPlayer then
        error("LocalPlayer not available")
    end

    return true
end)

if not success then
    error("❌ [Auto Fish] Critical dependency check failed: " .. tostring(errorMsg))
    return
end

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
--                    CONFIGURATION
-- ====================================================================
local CONFIG_FOLDER = "OptimizedAutoFish"
local CONFIG_FILE = CONFIG_FOLDER .. "/config_" .. LocalPlayer.UserId .. ".json"

local DefaultConfig = {
    AutoFish = false,
    AutoSell = false,
    AutoCatch = false,
    GPUSaver = false,
    BlatantMode = false,
    FishDelay = 0.9,
    CatchDelay = 0.2,
    SellDelay = 30,
    TeleportLocation = "Sisyphus Statue",
    AutoFavorite = false,
    FavoriteRarities = {"Mythic","Secret"} -- MULTI-RARITY DEFAULT
}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

-- ====================================================================
--                     TELEPORT LOCATIONS
-- ====================================================================
local LOCATIONS = {
    ["Spawn"] = CFrame.new(45.2788, 252.562, 2987.109),
    ["Sisyphus Statue"] = CFrame.new(-3728.216, -135.074, -1012.127),
    ["Coral Reefs"] = CFrame.new(-3114.78, 1.32, 2237.52),
    ["Esoteric Depths"] = CFrame.new(3248.37, -1301.53, 1403.82),
    ["Crater Island"] = CFrame.new(1016.49, 20.09, 5069.27),
    ["Lost Isle"] = CFrame.new(-3618.15, 240.83, -1317.45)
}

-- ====================================================================
--                     CONFIG FUNCTIONS
-- ====================================================================
local function ensureFolder()
    if not isfolder or not makefolder then return false end
    if not isfolder(CONFIG_FOLDER) then
        pcall(function() makefolder(CONFIG_FOLDER) end)
    end
    return isfolder(CONFIG_FOLDER)
end

local function saveConfig()
    if not writefile or not ensureFolder() then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
    end)
end

local function loadConfig()
    if not readfile or not isfile or not isfile(CONFIG_FILE) then return end
    pcall(function()
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        for k, v in pairs(data) do
            if DefaultConfig[k] ~= nil then Config[k] = v end
        end
    end)
end

loadConfig()

-- ====================================================================
--                     NETWORK EVENTS
-- ====================================================================
local netModule = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0")
if not netModule then
    warn("[Auto Fish] Net module not found")
    return
end
local net = require(netModule).net

local Events = {
    fishing = net:WaitForChild("RE/FishingCompleted"),
    sell = net:WaitForChild("RF/SellAllItems"),
    charge = net:WaitForChild("RF/ChargeFishingRod"),
    minigame = net:WaitForChild("RF/RequestFishingMinigameStarted"),
    equip = net:WaitForChild("RE/EquipToolFromHotbar"),
    unequip = net:WaitForChild("RE/UnequipToolFromHotbar"),
    favorite = net:WaitForChild("RE/FavoriteItem")
}

-- ====================================================================
--                     SAFE MODULE REQUIRE
-- ====================================================================
local function safeRequire(path)
    if not path then return nil end
    local success, result = pcall(require, path)
    if success then return result else warn("[Auto Fish] Failed to require: "..tostring(path)) return nil end
end

local Shared = ReplicatedStorage:FindFirstChild("Shared")
local ItemUtility = Shared and safeRequire(Shared:FindFirstChild("ItemUtility"))

local Packages = ReplicatedStorage:FindFirstChild("Packages")
local Replion = Packages and safeRequire(Packages:FindFirstChild("Replion"))
local PlayerData = Replion and Replion.Client:WaitReplion("Data")

if not ItemUtility then warn("[Auto Fish] ItemUtility module missing") end
if not Replion then warn("[Auto Fish] Replion module missing") end
if not PlayerData then warn("[Auto Fish] PlayerData missing") end

-- ====================================================================
--                     RARITY SYSTEM
-- ====================================================================
local RarityTiers = {Common=1,Uncommon=2,Rare=3,Epic=4,Legendary=5,Mythic=6,Secret=7}
local function getRarityValue(rarity) return RarityTiers[rarity] or 0 end
local function getFishRarity(itemData) if not itemData or not itemData.Data then return "Common" end return itemData.Data.Rarity or "Common" end

-- ====================================================================
--                     TELEPORT SYSTEM
-- ====================================================================
local Teleport = {}
function Teleport.to(locationName)
    local cframe = LOCATIONS[locationName]
    if not cframe then warn("Location not found: "..tostring(locationName)) return false end
    local success = pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        rootPart.CFrame = cframe
    end)
    return success
end

-- ====================================================================
--                     GPU SAVER
-- ====================================================================
local gpuActive=false
local whiteScreen=nil
local function enableGPU()
    if gpuActive then return end gpuActive=true
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 game.Lighting.GlobalShadows=false game.Lighting.FogEnd=1 setfpscap(8) end)
    whiteScreen=Instance.new("ScreenGui") whiteScreen.ResetOnSpawn=false whiteScreen.DisplayOrder=999999
    local frame=Instance.new("Frame") frame.Size=UDim2.new(1,0,1,0) frame.BackgroundColor3=Color3.new(0.1,0.1,0.1) frame.Parent=whiteScreen
    local label=Instance.new("TextLabel") label.Size=UDim2.new(0,400,0,100) label.Position=UDim2.new(0.5,-200,0.5,-50)
    label.BackgroundTransparency=1 label.Text="🟢 GPU SAVER ACTIVE\nAuto Fish Running..." label.TextColor3=Color3.new(0,1,0)
    label.TextSize=28 label.Font=Enum.Font.GothamBold label.TextXAlignment=Enum.TextXAlignment.Center label.Parent=frame
    whiteScreen.Parent=game.CoreGui
end
local function disableGPU()
    if not gpuActive then return end gpuActive=false
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic game.Lighting.GlobalShadows=true game.Lighting.FogEnd=100000 setfpscap(0) end)
    if whiteScreen then whiteScreen:Destroy() whiteScreen=nil end
end

-- ====================================================================
--                     ANTI-AFK
-- ====================================================================
LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)

-- ====================================================================
--                     AUTO FAVORITE MULTI-RARITY
-- ====================================================================
local favoritedItems={}
local function isItemFavorited(uuid)
    local success,result=pcall(function()
        local items = PlayerData and PlayerData:GetExpect("Inventory").Items
        if not items then return false end
        for _, item in ipairs(items) do if item.UUID==uuid then return item.Favorited==true end end
        return false
    end)
    return success and result or false
end

local function autoFavoriteByRarity()
    if not Config.AutoFavorite or not PlayerData or not ItemUtility then return end
    local targetRarities=Config.FavoriteRarities
    local favorited=0
    pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        if not items then return end
        for _,item in ipairs(items) do
            local data=ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local rarity=getFishRarity(data)
                if table.find(targetRarities,rarity) and not isItemFavorited(item.UUID) and not favoritedItems[item.UUID] then
                    Events.favorite:FireServer(item.UUID)
                    favoritedItems[item.UUID]=true
                    favorited=favorited+1
                end
            end
        end
    end)
end
task.spawn(function() while true do task.wait(10) if Config.AutoFavorite then autoFavoriteByRarity() end end end)

-- ====================================================================
--                     FISHING LOGIC
-- ====================================================================
local isFishing=false fishingActive=false
local function castRod() pcall(function() Events.equip:FireServer(1) task.wait(0.05) Events.charge:InvokeServer(1755848498.4834) task.wait(0.02) Events.minigame:InvokeServer(1.2854545116425,1) end) end
local function reelIn() pcall(function() Events.fishing:FireServer() end) end
local function blatantFishingLoop() while fishingActive and Config.BlatantMode do if not isFishing then isFishing=true task.spawn(function() Events.charge:InvokeServer(1755848498.4834) task.wait(0.01) Events.minigame:InvokeServer(1.2854545116425,1) end) task.wait(0.05) task.spawn(function() Events.charge:InvokeServer(1755848498.4834) task.wait(0.01) Events.minigame:InvokeServer(1.2854545116425,1) end) task.wait(Config.FishDelay) for i=1,5 do pcall(function() Events.fishing:FireServer() end) task.wait(0.01) end task.wait(Config.CatchDelay*0.5) isFishing=false else task.wait(0.01) end end end
local function normalFishingLoop() while fishingActive and not Config.BlatantMode do if not isFishing then isFishing=true castRod() task.wait(Config.FishDelay) reelIn() task.wait(Config.CatchDelay) isFishing=false else task.wait(0.1) end end end
local function fishingLoop() while fishingActive do if Config.BlatantMode then blatantFishingLoop() else normalFishingLoop() end task.wait(0.1) end end

-- ====================================================================
--                     AUTO CATCH
-- ====================================================================
task.spawn(function() while true do if Config.AutoCatch and not isFishing then pcall(function() Events.fishing:FireServer() end) end task.wait(Config.CatchDelay) end end)

-- ====================================================================
--                     AUTO SELL
-- ====================================================================
local function simpleSell() pcall(function() Events.sell:InvokeServer() end) end
task.spawn(function() while true do task.wait(Config.SellDelay) if Config.AutoSell then simpleSell() end end end)

-- ====================================================================
--                     RAYFIELD UI
-- ====================================================================
local Rayfield=loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window=Rayfield:CreateWindow({Name="🎣 RiooHub V4.2",LoadingTitle="Ultra-Fast Fishing",LoadingSubtitle="v4.2 Safe Require",ConfigurationSaving={Enabled=false}})

-- ===== MAIN TAB =====
local MainTab=Window:CreateTab("Main",4483362458)
MainTab:CreateToggle({Name="⚡ Blatant Mode",CurrentValue=Config.BlatantMode,Callback=function(v) Config.BlatantMode=v saveConfig() end})
MainTab:CreateToggle({Name="🤖 Auto Fish",CurrentValue=Config.AutoFish,Callback=function(v) Config.AutoFish=v fishingActive=v if v then task.spawn(fishingLoop) end saveConfig() end})
MainTab:CreateToggle({Name="🎯 Auto Catch",CurrentValue=Config.AutoCatch,Callback=function(v) Config.AutoCatch=v saveConfig() end})
MainTab:CreateMultiDropdown({Name="Favorite Rarities",Options={"Common","Uncommon","Rare","Epic","Legendary","Mythic","Secret"},CurrentOptions=Config.FavoriteRarities,Callback=function(options) Config.FavoriteRarities=options saveConfig() end})
MainTab:CreateToggle({Name="⭐ Auto Favorite",CurrentValue=Config.AutoFavorite,Callback=function(v) Config.AutoFavorite=v saveConfig() end})
MainTab:CreateButton({Name="⭐ Favorite All Now",Callback=autoFavoriteByRarity})
MainTab:CreateToggle({Name="💰 Auto Sell",CurrentValue=Config.AutoSell,Callback=function(v) Config.AutoSell=v saveConfig() end})
MainTab:CreateButton({Name="💰 Sell All Now",Callback=simpleSell})

-- ===== Teleport Tab =====
local TeleportTab=Window:CreateTab("Teleport")
for loc,_ in pairs(LOCATIONS) do
    TeleportTab:CreateButton({Name=loc,Callback=function() Teleport.to(loc) end})
end

-- ===== Settings Tab =====
local SettingsTab=Window:CreateTab("Settings")
SettingsTab:CreateToggle({Name="🖥️ GPU Saver",CurrentValue=Config.GPUSaver,Callback=function(v) Config.GPUSaver=v if v then enableGPU() else disableGPU() end saveConfig() end})

-- ===== Info Tab =====
local InfoTab=Window:CreateTab("Info")
InfoTab:CreateParagraph({Title="Features",Content=[[• Auto Fish with Blatant Mode
• Auto Catch
• Auto Sell (keeps favorited)
• Auto Favorite Multi-Rarity
• GPU Saver
• Anti-AFK
• Teleport System]]})

Rayfield:Notify({Title="Auto Fish Loaded",Content="Ready to fish!",Duration=5})
print("🎣 RiooHub V4.2 Loaded! Safe Require Enabled ✅")