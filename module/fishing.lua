-- ====================================================================
--                 FISHING MODULE
-- ====================================================================

local Fishing = {}
Fishing.isActive = false
Fishing.isFishing = false
Fishing.useBlatantMode = false

local Network = require(script.Parent.network)

-- Cast rod
local function castRod()
    pcall(function()
        local Events = Network.Events
        Events.equip:FireServer(1)
        task.wait(0.05)
        Events.charge:InvokeServer(1755848498.4834)
        task.wait(0.02)
        Events.minigame:InvokeServer(1.2854545116425, 1)
        print("[Fishing] Cast")
    end)
end

-- Reel in
local function reelIn()
    pcall(function()
        Network.Events.fishing:FireServer()
        print("[Fishing] Reel")
    end)
end

-- Blatant fishing loop
local function blatantLoop(config)
    while Fishing.isActive and Fishing.useBlatantMode do
        if not Fishing.isFishing then
            Fishing.isFishing = true

            local Events = Network.Events

            -- Parallel casts
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

            task.wait(config.FishDelay)

            -- Spam reel
            for i = 1, 5 do
                pcall(function() Events.fishing:FireServer() end)
                task.wait(0.01)
            end

            task.wait(config.CatchDelay * 0.5)
            Fishing.isFishing = false
        else
            task.wait(0.01)
        end
    end
end

-- Normal fishing loop
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

-- Start fishing
function Fishing.start(config, blatantMode)
    if Fishing.isActive then return end

    Fishing.isActive = true
    Fishing.useBlatantMode = blatantMode

    print("[Fishing] Started", blatantMode and "(Blatant)" or "(Normal)")

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

-- Stop fishing
function Fishing.stop()
    Fishing.isActive = false
    Fishing.isFishing = false

    pcall(function()
        Network.Events.unequip:FireServer()
    end)

    print("[Fishing] Stopped")
end

-- Toggle blatant mode
function Fishing.setBlatantMode(enabled)
    Fishing.useBlatantMode = enabled
end

return Fishing