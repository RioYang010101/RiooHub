-- ====================================================================
--                 TELEPORT MODULE (REMOTE VERSION)
-- ====================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = require(script.Parent.network)

-- Pastikan remotes sudah diinisialisasi
if not next(Network.Events) then
    Network.initialize()
end

local Teleport = {}

-- ====================================================================
--                 TELEPORT FUNCTION
-- ====================================================================

function Teleport.to(locationName)
    pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes")
        local teleportEvent = remotes:FindFirstChild("TeleportPlayer")

        if teleportEvent then
            teleportEvent:FireServer(locationName)
            print("[Teleport] ✅ Request dikirim ke server:", locationName)
        else
            warn("[Teleport] ⚠️ Remote 'TeleportPlayer' tidak ditemukan di ReplicatedStorage.Remotes")
        end
    end)
end

return Teleport