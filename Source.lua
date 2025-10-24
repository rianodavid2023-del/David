-- ServerScriptService/AdminWeaponDuplicator.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local remote = ReplicatedStorage:WaitForChild("RequestDuplicateWeapon")
local weaponsFolder = ServerStorage:WaitForChild("Weapons")

-- CONFIG: pon aquí los UserId de los admins que pueden usar el duplicador
local ADMINS = {
    [12345678] = true, -- reemplaza con tu UserId
    [87654321] = true, -- otro admin
}

-- si quieres permitir al Owner del juego automáticamente:
local creatorId = game.CreatorId
if creatorId and creatorId > 0 then
    ADMINS[creatorId] = true
end

local COOLDOWN = 1 -- segundos entre duplicados (admins)
local adminLast = {} -- track cooldown por admin

remote.OnServerEvent:Connect(function(player, weaponName)
    if typeof(weaponName) ~= "string" then return end

    if not ADMINS[player.UserId] then
        warn(player.Name .. " intentó usar el duplicador sin permiso.")
        return
    end

    local last = adminLast[player.UserId] or 0
    if os.clock() - last < COOLDOWN then
        -- opcional: avisar al admin mediante RemoteEvent de vuelta
        return
    end

    local template = weaponsFolder:FindFirstChild(weaponName)
    if not template then
        warn("Template no encontrado: "..tostring(weaponName))
        return
    end

    local clone = template:Clone()
    clone.Name = weaponName .. "_admincopy_" .. tostring(math.random(1000,9999))

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        clone.Parent = backpack
    else
        clone.Parent = player.Character or workspace
    end

    adminLast[player.UserId] = os.clock()
    print(("Admin %s duplicó %s"):format(player.Name, weaponName))
end)
