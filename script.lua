-- ====================================================================
--                 AUTO FISH V4.3 - SAFE REQUIRE & MULTI-RARITY
-- ====================================================================

-- ====== CORE SERVICES ======
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ====== CONFIG ======
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
    FavoriteRarities = {"Mythic", "Secret"}
}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

-- ====== CONFIG FUNCTIONS ======
local function ensureFolder()
    if not isfolder or not makefolder then return false end
    if not isfolder(CONFIG_FOLDER) then pcall(makefolder, CONFIG_FOLDER) end
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
        for k,v in pairs(data) do if DefaultConfig[k] ~= nil then Config[k]=v end end
    end)
end

loadConfig()

-- ====== TELEPORT LOCATIONS ======
local LOCATIONS = {
    ["Spawn"] = CFrame.new(45.2788, 252.562, 2987.109),
    ["Sisyphus Statue"] = CFrame.new(-3728.216, -135.074, -1012.127),
    ["Coral Reefs"] = CFrame.new(-3114.78, 1.32, 2237.52)
}

-- ====== NETWORK EVENTS ======
local netModule = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0")
if not netModule then warn("[Auto Fish] Net module not found") return end
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

-- ====== SAFE MODULE REQUIRE ======
local ItemUtility, Replion, PlayerData

-- ItemUtility
local Shared = ReplicatedStorage:FindFirstChild("Shared")
if Shared then
    local module = Shared:FindFirstChild("ItemUtility")
    if module and module:IsA("ModuleScript") then
        local s,r = pcall(require,module)
        if s then ItemUtility=r else warn("Failed to require ItemUtility") end
    else warn("ItemUtility module not found") end
else warn("Shared folder not found") end

-- Replion & PlayerData
local Packages = ReplicatedStorage:FindFirstChild("Packages")
if Packages then
    local module = Packages:FindFirstChild("Replion")
    if module and module:IsA("ModuleScript") then
        local s,r = pcall(require,module)
        if s then 
            Replion=r
            if Replion.Client then PlayerData=Replion.Client:WaitReplion("Data") end
        else warn("Failed to require Replion") end
    else warn("Replion module not found") end
else warn("Packages folder not found") end

-- ====== RARITY SYSTEM ======
local RarityTiers = {Common=1,Uncommon=2,Rare=3,Epic=4,Legendary=5,Mythic=6,Secret=7}
local function getRarityValue(r) return RarityTiers[r] or 0 end
local function getFishRarity(itemData) if not itemData or not itemData.Data then return "Common" end return itemData.Data.Rarity or "Common" end

-- ====== TELEPORT FUNCTION ======
local Teleport = {}
function Teleport.to(locationName)
    local cframe = LOCATIONS[locationName]
    if not cframe then warn("Location not found: "..tostring(locationName)) return false end
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = cframe end
        end
    end)
end

-- ====== GPU SAVER ======
local gpuActive=false
local whiteScreen=nil
local function enableGPU()
    if gpuActive then return end
    gpuActive=true
    pcall(function()
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        game.Lighting.GlobalShadows=false
        game.Lighting.FogEnd=1
        setfpscap(8)
    end)
    whiteScreen=Instance.new("ScreenGui")
    whiteScreen.ResetOnSpawn=false
    whiteScreen.DisplayOrder=999999
    local frame=Instance.new("Frame")
    frame.Size=UDim2.new(1,0,1,0)
    frame.BackgroundColor3=Color3.new(0.1,0.1,0.1)
    frame.Parent=whiteScreen
    local label=Instance.new("TextLabel")
    label.Size=UDim2.new(0,400,0,100)
    label.Position=UDim2.new(0.5,-200,0.5,-50)
    label.BackgroundTransparency=1
    label.Text="🟢 GPU SAVER ACTIVE\nAuto Fish Running..."
    label.TextColor3=Color3.new(0,1,0)
    label.TextSize=28
    label.Font=Enum.Font.GothamBold
    label.TextXAlignment=Enum.TextXAlignment.Center
    label.Parent=frame
    whiteScreen.Parent=game.CoreGui
end
local function disableGPU()
    if not gpuActive then return end
    gpuActive=false
    pcall(function()
        settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic
        game.Lighting.GlobalShadows=true
        game.Lighting.FogEnd=100000
        setfpscap(0)
    end)
    if whiteScreen then whiteScreen:Destroy() whiteScreen=nil end
end

-- ====== ANTI-AFK ======
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ====== AUTO FAVORITE MULTI-RARITY ======
local favoritedItems={}
local function isItemFavorited(uuid)
    local success,result=pcall(function()
        local items = PlayerData and PlayerData:GetExpect("Inventory").Items
        if not items then return false end
        for _,i in ipairs(items) do if i.UUID==uuid then return i.Favorited==true end end
        return false
    end)
    return success and result or false
end

local function autoFavoriteByRarity()
    if not Config.AutoFavorite or not PlayerData or not ItemUtility then return end
    local targetRarities=Config.FavoriteRarities
    local favorited=0
    pcall(function()
        local items=PlayerData:GetExpect("Inventory").Items
        if not items then return end
        for _,item in ipairs(items) do
            local data=ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local rarity=getFishRarity(data)
                if table.find(targetRarities,rarity) and not isItemFavorited(item.UUID) and not favoritedItems[item.UUID] then
                    Events.favorite:FireServer(item.UUID)
                    favoritedItems[item.UUID]=true
                end
            end
        end
    end)
end
task.spawn(function()
    while true do
        task.wait(10)
        if Config.AutoFavorite then autoFavoriteByRarity() end
    end
end)

-- ====== FISHING LOGIC ======
local isFishing=false
local fishingActive=false

local function castRod()
    pcall(function()
        Events.equip:FireServer(1)
        task.wait(0.05)
        Events.charge:InvokeServer(1755848498.4834)
        task.wait(0.02)
        Events.minigame:InvokeServer(1.2854545116425,1)
    end)
end

local function reelIn()
    pcall(function()
        Events.fishing:FireServer()
    end)
end

local function blatantFishingLoop()
    while fishingActive and Config.BlatantMode do
        if not isFishing then
            isFishing=true
            task.spawn(function()
                Events.charge:InvokeServer(1755848498.4834)
                task.wait(0.01)
                Events.minigame:InvokeServer(1.2854545116425,1)
            end)
            task.wait(0.05)
            task.spawn(function()
                Events.charge:InvokeServer(1755848498.4834)
                task.wait(0.01)
                Events.minigame:InvokeServer(1.2854545116425,1)
            end)
            task.wait(Config.FishDelay)
            for i=1,5 do pcall(function() Events.fishing:FireServer() end) task.wait(0.01) end
            task.wait(Config.CatchDelay*0.5)
            isFishing=false
        else
            task.wait(0.01)
        end
    end
end

local function normalFishingLoop()
    while fishingActive and not Config.BlatantMode do
        if not isFishing then
            isFishing=true
            castRod()
            task.wait(Config.FishDelay)
            reelIn()
            task.wait(Config.CatchDelay)
            isFishing=false
        else task.wait(0.1) end
    end
end

local function fishingLoop()
    while fishingActive do
        if Config.BlatantMode then blatantFishingLoop() else normalFishingLoop() end
        task.wait(0.1)
    end
end

-- ====== AUTO CATCH ======
task.spawn(function()
    while true do
        if Config.AutoCatch and not isFishing then
            pcall(function() Events.fishing:FireServer() end)
        end
        task.wait(Config.CatchDelay)
    end
end)

-- ====== AUTO SELL ======
local function simpleSell()
    pcall(function() Events.sell:InvokeServer() end)
end
task.spawn(function()
    while true do
        task.wait(Config.SellDelay)
        if Config.AutoSell then simpleSell() end
    end
end)

-- ====== RAYFIELD UI ======
local Rayfield=loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window=Rayfield:CreateWindow({Name="🎣 RiooHub V4.3",LoadingTitle="Auto Fish",LoadingSubtitle="Safe Require + Multi-Rarity",ConfigurationSaving={Enabled=false}})

-- MAIN TAB
local MainTab=Window:CreateTab("Main",4483362458)
MainTab:CreateToggle({Name="⚡ Blatant Mode",CurrentValue=Config.BlatantMode,Callback=function(v) Config.BlatantMode=v saveConfig() end})
MainTab:CreateToggle({Name="🤖 Auto Fish",CurrentValue=Config.AutoFish,Callback=function(v) Config.AutoFish=v fishingActive=v if v then task.spawn(fishingLoop) end saveConfig() end})
MainTab:CreateToggle({Name="🎯 Auto Catch",CurrentValue=Config.AutoCatch,Callback=function(v) Config.AutoCatch=v saveConfig() end})
MainTab:CreateMultiDropdown({Name="Favorite Rarities",Options={"Common","Uncommon","Rare","Epic","Legendary","Mythic","Secret"},CurrentOptions=Config.FavoriteRarities,Callback=function(opts) Config.FavoriteRarities=opts saveConfig() end})
MainTab:CreateToggle({Name="⭐ Auto Favorite",CurrentValue=Config.AutoFavorite,Callback=function(v) Config.AutoFavorite=v saveConfig() end})
MainTab:CreateButton({Name="⭐ Favorite All Now",Callback=autoFavoriteByRarity})
MainTab:CreateToggle({Name="💰 Auto Sell",CurrentValue=Config.AutoSell,Callback=function(v) Config.AutoSell=v saveConfig() end})
MainTab:CreateButton({Name="💰 Sell All Now",Callback=simpleSell})

-- TELEPORT TAB
local TeleportTab=Window:CreateTab("Teleport")
for loc,_ in pairs(LOCATIONS) do
    TeleportTab:CreateButton({Name=loc,Callback=function() Teleport.to(loc) end})
end

-- SETTINGS TAB
local SettingsTab=Window:CreateTab("Settings")
SettingsTab:CreateToggle({Name="🖥️ GPU Saver",CurrentValue=Config.GPUSaver,Callback=function(v) Config.GPUSaver=v if v then enableGPU() else disableGPU() end saveConfig() end})

-- INFO TAB
local InfoTab=Window:CreateTab("Info")
InfoTab:CreateParagraph({Title="Features",Content=[[• Auto Fish with Blatant Mode
• Auto Catch
• Auto Sell (keeps favorited)
• Auto Favorite Multi-Rarity
• GPU Saver
• Anti-AFK
• Teleport System]]})

Rayfield:Notify({Title="Auto Fish Loaded",Content="Safe Require + Multi-Rarity Enabled",Duration=5})
print("🎣 RiooHub V4.3 Loaded!")