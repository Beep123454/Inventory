local Inventory = BCORE.Inventory

-- Save Inventories on Server Shutdown
hook.Add("ShutDown", "BCORE_SaveAllInventories", function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            ply:SaveInventory()
        end
    end
end)

-- Save Player Inventory on Disconnect
hook.Add("PlayerDisconnected", "BCORE_SavePlayerInventory", function(ply)
    ply:SaveInventory()
end)

-- Load Inventory on Player Spawn
local loadQueue = {}

hook.Add("PlayerInitialSpawn", "BCORE_Inventory_Load", function(ply)
    loadQueue[ply] = true
end)

hook.Add("StartCommand", "BCORE_Inventory_Load_Special", function(ply, cmd)
    if loadQueue[ply] and not cmd:IsForced() then
        loadQueue[ply] = nil
        ply:LoadInventory()
    end
end)

-- Handle Player Use (Crouch Pickup and Weapon Pickup)
hook.Add("PlayerUse", "BCORE_CrouchPickup", function(ply, ent)
    if ply:Crouching() then
        ply:PickUp()
        return false
    end

    if ent.isitem and (ent.itemType == "weapon" or ent.itemType == "UpgradableWeapon") then
        local weaponClass = ent.className

        if not ply:HasWeapon(weaponClass) then
            ply:Give(weaponClass)
            local weapon = ply:GetWeapon(weaponClass)

            if IsValid(weapon) then
                Inventory:ConfigureWeapon(weapon, ent)
            end

            timer.Simple(0, function()
                if IsValid(ply) and ply:HasWeapon(weaponClass) then
                    ply:SelectWeapon(weaponClass)
                end
            end)

            BCORE.Inventory:Chat("You picked up a " .. ent.name, ply)
            ent:Remove()
        else
            BCORE.Inventory:Chat("You already have this weapon equipped!", ply)
        end

        return false
    end
end)

-- Handle Player Chat Commands
hook.Add("PlayerSay", "INVENTORY_COMMANDS", function(ply, text)
    local textLower = string.lower(text)

    if textLower == "/invholster" then
        ply:Holster()
        return ""
    elseif textLower == "/drop" then
        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) then return "" end

        if weapon.isitem then
            local item = Inventory:CreateItemFromWeapon(weapon)
            local pos = ply:GetPos() + ply:GetForward() * 50 + Vector(0, 0, 50)
            item:SpawnItem(pos)

            ply:StripWeapon(weapon:GetClass())
            BCORE.Inventory:Chat("You dropped " .. weapon.name .. ".", ply)
        end

        return ""
    end
end)

-- Disable Auto Weapon Pickup
hook.Add("PlayerCanPickupWeapon", "DisableAutoPickupWeapons", function(ply, weapon)
    return not weapon.isitem
end)

-- Utility: Configure Weapon from Entity Data
function Inventory:ConfigureWeapon(weapon, ent)
    weapon.id = ent.id
    weapon.className = ent.className
    weapon.name = ent.name
    weapon.model = ent.model
    weapon.rarity = ent.rarity
    weapon.itemType = ent.itemType
    weapon.customData = ent.customData
    weapon.onAction = {}
    weapon.isitem = ent.isitem

    if ent.itemType == "UpgradableWeapon" then
        weapon:SetNWInt("Damage", ent.customData.Damage or 100)
        weapon:SetNWFloat("Recoil", ent.customData.Recoil or 1)
        weapon:SetNWInt("ClipSize", ent.customData.ClipSize or 30)
        weapon:SetNWFloat("Spread", ent.customData.Spread or 0.5)
        weapon:SetNWInt("RPM", ent.customData.RPM or 100)
        weapon:SetNWInt("Accuracy", ent.customData.Accuracy or 100)
        weapon:SetNWInt("Shots", ent.customData.Shots or 1)

        weapon.Primary.Damage = weapon:GetNWInt("Damage")
        weapon.Primary.Recoil = weapon:GetNWFloat("Recoil")
        weapon.Primary.ClipSize = weapon:GetNWInt("ClipSize")
        weapon.Primary.Spread = weapon:GetNWFloat("Spread")
        weapon.Primary.RPM = weapon:GetNWInt("RPM")
        weapon.Primary.IronAccuracy = weapon:GetNWInt("Accuracy")
        weapon.Primary.NumShots = weapon:GetNWInt("Shots")
    end
end

-- Utility: Create Item from Weapon
function Inventory:CreateItemFromWeapon(weapon)
    local item = BCORE.Inventory.Item:new(
        weapon.className,
        weapon.name,
        weapon:GetWeaponWorldModel(),
        weapon.rarity,
        weapon.itemType,
        weapon.customData
    )

    if weapon.itemType == "weapon" then
        item:setActions(Inventory.actiontable.weapon)
    else
        item:setActions(Inventory.actiontable.UpgradableWeapon)
    end

    return item
end

