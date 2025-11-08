-- ====================================================================
--                 FISHING MODULE (COMPATIBLE WITH NETWORK MODULE)
-- ====================================================================

local Fishing = {}
Fishing.isActive = false
Fishing.isFishing = false
Fishing.useBlatantMode = false

-- Import Network
local Network = require(script.Parent.network)

-- Pastikan network sudah siap
if not next(Network.Events) then
    Network.initialize()
end

local Events = Network.Events

-- ====================================================================
--                 CORE ACTIONS
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
--                 LOOP: BLATANT MODE
-- ====================================================================

local function blatantLoop(config)
    while Fishing.isActive and Fishing.useBlatantMode do
        if not Fishing.isFishing then
            Fishing.isFishing = true

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
--                 LOOP: NORMAL MODE
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
--                 CONTROL
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