-- ====================================================================
--                 CONFIGURATION MODULE
-- ====================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Config = {}

-- Constants
Config.FOLDER = "OptimizedAutoFish"
Config.FILE = Config.FOLDER .. "/config_" .. LocalPlayer.UserId .. ".json"

-- Default settings
Config.Defaults = {
    AutoFish = false,
    AutoSell = false,
    AutoCatch = false,
    GPUSaver = false,
    BlatantMode = false,
    FishDelay = 0.9,
    CatchDelay = 0.2,
    SellDelay = 30,
    TeleportLocation = "Sisyphus Statue",
    AutoFavorite = true,
    FavoriteRarity = "Mythic"
}

-- Current settings
Config.Current = {}
for k, v in pairs(Config.Defaults) do 
    Config.Current[k] = v 
end

-- Ensure folder exists
function Config.ensureFolder()
    if not isfolder or not makefolder then return false end
    if not isfolder(Config.FOLDER) then
        pcall(function() makefolder(Config.FOLDER) end)
    end
    return isfolder(Config.FOLDER)
end

-- Save configuration
function Config.save()
    if not writefile or not Config.ensureFolder() then return false end
    local success = pcall(function()
        writefile(Config.FILE, HttpService:JSONEncode(Config.Current))
        print("[Config] Settings saved!")
    end)
    return success
end

-- Load configuration
function Config.load()
    if not readfile or not isfile or not isfile(Config.FILE) then return false end
    local success = pcall(function()
        local data = HttpService:JSONDecode(readfile(Config.FILE))
        for k, v in pairs(data) do
            if Config.Defaults[k] ~= nil then 
                Config.Current[k] = v 
            end
        end
        print("[Config] Settings loaded!")
    end)
    return success
end

-- Get setting
function Config.get(key)
    return Config.Current[key]
end

-- Set setting
function Config.set(key, value)
    if Config.Defaults[key] == nil then return false end
    Config.Current[key] = value
    Config.save()
    return true
end

return Config