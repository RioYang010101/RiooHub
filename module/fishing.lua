-- ====================================================================
--                 FISHING MODULE (REMOTE EDITION)
-- ====================================================================

local Fishing = {}
Fishing.isActive = false
Fishing.isFishing = false
Fishing.useBlatantMode = false

-- ====================================================================
--                 REMOTE EVENT CONNECTION
-- ====================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ambil folder Remotes di ReplicatedStorage
local function getRemoteEvents()
    local remotes = ReplicatedStorage:WaitForChild("Remotes")

    return {
        fishing = remotes:WaitForChild("FishingCompleted"),
        sell = remotes:WaitForChild("SellAllItems"),
        charge = remotes:WaitForChild("ChargeFishingRod"),
        minigame = remotes:WaitForChild("RequestFishingMinigameStarted"),
        cancel = remotes:WaitForChild("CancelFishingInputs"),
        equip = remotes:WaitForChild("EquipToolFromHotbar"),
        unequip = remotes:WaitForChild("UnequipToolFromHotbar"),
        favorite = remotes:WaitForChild("FavoriteItem")
    }
end

local Events = getRemoteEvents()

-- ====================================================================
--                 FISHING CORE FUNCTIONS
-- ====================================================================

-- 🎣 Cast Rod
local function castRod()
    pcall(function()
        Events.equip:FireServer(1)
        task.wait(0.05)
        Events.charge:InvokeServer(1755848498.4834)
        task.wait(0.02)
        Events.minigame:InvokeServer(1.2854545116425, 1)
        print("[Fishing] 🎣 Cast")
    end)
end

-- 🪝 Reel In
local function reelIn()
    pcall(function()
        Events.fishing:FireServer()
        print("[Fishing] 🪝 Reel")
    end)
end

-- ====================================================================
--                 BLATANT MODE LOOP
-- ====================================================================
local function blatantLoop(config)
    while Fishing.isActive and Fishing.useBlatantMode do
        if not Fishing.isFishing then
            Fishing.isFishing = true

            -- Paralel cast dua kali untuk spam auto fish cepat
            pcall(function()
                Events.equip:FireServer(1)
                task.wait(0.01)

                task.spawn(function()
                    Events.charge:InvokeServer(1755848498.4834)
                    task.wait(0.01)
                    Events.minigame:InvokeServer(1.2854545116425, 1)
                end)

                task.wait(0.05)

                task.spawn(function()
                    Events.charge:InvokeServer(1755848498.4834)
                    task.wait(0.01)
                    Events.minigame:InvokeServer(1.2854545116425, 1)
                end)
            end)

            -- Delay casting dan catching
            task.wait(config.FishDelay)

            -- Spam reel agar cepat dapet ikan
            for i = 1, 5 do
                pcall(function()
                    Events.fishing:FireServer()
                end)
                task.wait(0.01)
            end

            task.wait(config.CatchDelay * 0.5)
            Fishing.isFishing = false
        else
            task.wait(0.01)
        end
    end
end

-- ====================================================================
--                 NORMAL MODE LOOP
-- ====================================================================
local function normalLoop(config)
    while Fishing.isActive and not Fishing.useBlatantMode do
        if not Fishing.isFishing then
            Fishing.isFishing = true

            castRod()
            task.wait(config.FishDelay)
            reelIn()
            task.wait(config.CatchDelay)

            Fishing.isFishing = false
        else
            task.wait(0.1)
        end
    end
end

-- ====================================================================
--                 START / STOP SYSTEM
-- ====================================================================

function Fishing.start(config, blatantMode)
    if Fishing.isActive then return end

    Fishing.isActive = true
    Fishing.useBlatantMode = blatantMode or false

    print("[Fishing] ▶️ Started", blatantMode and "(Blatant Mode)" or "(Normal Mode)")

    task.spawn(function()
        while Fishing.isActive do
            if Fishing.useBlatantMode then
                blatantLoop(config)
            else
                normalLoop(config)
            end
            task.wait(0.1)
        end
    end)
end

function Fishing.stop()
    Fishing.isActive = false
    Fishing.isFishing = false

    pcall(function()
        Events.unequip:FireServer()
    end)

    print("[Fishing] ⏹️ Stopped")
end

function Fishing.setBlatantMode(enabled)
    Fishing.useBlatantMode = enabled
end

-- ====================================================================
--                 RETURN MODULE
-- ====================================================================
return Fishing