-- ====================================================================
--                 CONFIGURATION MODULE (REMOTE EDITION)
-- ====================================================================

-- ✅ Service Setup
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- ====================================================================
--                 MODULE TABLE
-- ====================================================================
local Config = {}

-- Constants
Config.FOLDER = "OptimizedAutoFish"
Config.FILE = Config.FOLDER .. "/config_" .. LocalPlayer.UserId .. ".json"

-- Default Settings
Config.Defaults = {
    AutoFish = false,
    AutoSell = false,
    AutoCatch = false,
    GPUSaver = false,
    AntiLag = false,
    BlatantMode = false,
    FishDelay = 0.9,
    CatchDelay = 0.2,
    SellDelay = 30,
    TeleportLocation = "Sisyphus Statue",
    AutoFavorite = false,
    FavoriteRarity = "Mythic"
}

-- Active Settings
Config.Current = table.clone(Config.Defaults)

-- ====================================================================
--                 FILE & FOLDER SAFETY CHECKS
-- ====================================================================
function Config.ensureFolder()
    if not isfolder or not makefolder then 
        warn("[Config] ⚠️ Folder functions unavailable in this executor.")
        return false 
    end

    if not isfolder(Config.FOLDER) then
        local ok, err = pcall(function() makefolder(Config.FOLDER) end)
        if not ok then 
            warn("[Config] ❌ Failed to create folder:", err) 
            return false 
        end
    end

    return isfolder(Config.FOLDER)
end

-- ====================================================================
--                 SAVE FUNCTION
-- ====================================================================
function Config.save()
    if not writefile or not Config.ensureFolder() then 
        warn("[Config] ⚠️ Writefile not supported on this executor.")
        return false 
    end

    local ok, err = pcall(function()
        local json = HttpService:JSONEncode(Config.Current)
        writefile(Config.FILE, json)
    end)

    if ok then
        print("[Config] 💾 Settings saved successfully!")
    else
        warn("[Config] ❌ Failed to save:", err)
    end

    return ok
end

-- ====================================================================
--                 LOAD FUNCTION
-- ====================================================================
function Config.load()
    if not readfile or not isfile or not isfile(Config.FILE) then 
        print("[Config] ℹ️ No existing config file found. Using defaults.")
        return false 
    end

    local ok, result = pcall(function()
        local raw = readfile(Config.FILE)
        local data = HttpService:JSONDecode(raw)
        for k, v in pairs(data) do
            if Config.Defaults[k] ~= nil then
                Config.Current[k] = v
            end
        end
    end)

    if ok then
        print("[Config] ✅ Configuration loaded successfully!")
    else
        warn("[Config] ⚠️ Failed to load configuration:", result)
    end

    return ok
end

-- ====================================================================
--                 GET / SET HELPERS
-- ====================================================================
function Config.get(key)
    return Config.Current[key]
end

function Config.set(key, value)
    if Config.Defaults[key] == nil then 
        warn("[Config] ⚠️ Invalid key:", key)
        return false 
    end

    Config.Current[key] = value
    Config.save()
    return true
end

-- ====================================================================
--                 RESET FUNCTION
-- ====================================================================
function Config.reset()
    Config.Current = table.clone(Config.Defaults)
    Config.save()
    print("[Config] 🔄 Settings reset to default.")
end

-- ====================================================================
--                 AUTO LOAD ON START
-- ====================================================================
task.spawn(function()
    Config.load()
end)

return Config