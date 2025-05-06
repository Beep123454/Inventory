local upgradeablewep = {}

upgradeablewep.Equip = function(item, ply)
    if item.isitem and item.itemType == "UpgradableWeapon" then
        local weaponClass = item.className
        if not ply:HasWeapon(weaponClass) then 
            ply:Give(weaponClass)
            local weapon = ply:GetWeapon(weaponClass)

            if IsValid(weapon) then
                weapon.className = item.className
                weapon.id = item.id
                weapon.name = item.name
                weapon.model = item.model
                weapon.rarity = item.rarity
                weapon.itemType = item.itemType
                weapon.customData = item.customData
                weapon.isitem = item.isitem 

                weapon:SetNWInt("Damage", item:GetProperty("Damage") or 100)
                weapon:SetNWFloat("Recoil", item:GetProperty("Recoil") or 1)
                weapon:SetNWInt("ClipSize", item:GetProperty("ClipSize") or 30)
                weapon:SetNWFloat("Spread", item:GetProperty("Spread") or 0.5)
                weapon:SetNWInt("RPM", item:GetProperty("RPM") or 100)
                weapon:SetNWInt("Accuracy", item:GetProperty("Accuracy") or 100)
                weapon:SetNWInt("Shots", item:GetProperty("Shots") or 1)

                weapon.Primary.Damage = weapon:GetNWInt("Damage")
                weapon.Primary.Recoil = weapon:GetNWFloat("Recoil")
                weapon.Primary.ClipSize = weapon:GetNWInt("ClipSize")
                weapon.Primary.Spread = weapon:GetNWFloat("Spread")
                weapon.Primary.RPM = weapon:GetNWInt("RPM")
                weapon.Primary.IronAccuracy = weapon:GetNWInt("Accuracy")
                weapon.Primary.NumShots = weapon:GetNWInt("Shots")
            end

            timer.Simple(0, function()
                if IsValid(ply) and ply:HasWeapon(weaponClass) then
                    ply:SelectWeapon(weaponClass)
                end
            end)

            BCORE.Inventory:Chat("You equipped a " .. item.name, ply)

            ply:RemoveItem(item)
        else
            BCORE.Inventory:Chat("You already have this weapon equipped!", ply)
        end
    end
end

upgradeablewep.Drop = function(item, ply)
    local pos = ply:GetPos() + Vector(0, 0, 50) + ply:GetForward() * 60
    item:SpawnItem(pos)
    ply:RemoveItem(item)
end

upgradeablewep.Destroy = function(item, ply)
    ply:RemoveItem(item)
end  

upgradeablewep.Upgrade = function(item, ply)
    local wep_base = weapons.Get(item.className)
    if not wep_base then
        print("[ERROR] " .. item.className .. " not found in weapons.Get!")
        return
    end

    local rarities = BCORE.Inventory.config.Rarities
    local currentRarity = item.rarity
    if currentRarity == BCORE.Inventory:GetHighestRarity() then return end

    local nextRarity = BCORE.Inventory:GetNextRarity(currentRarity)
    local multiplier = rarities[currentRarity] and rarities[currentRarity].multiplier or 1.05

    item:SetProperty("Damage", (item:GetProperty("Damage") or wep_base.Primary.Damage) * multiplier)
    item:SetProperty("Accuracy", (item:GetProperty("Accuracy") or wep_base.Primary.IronAccuracy) * multiplier)
    item:SetProperty("Recoil", (item:GetProperty("Recoil") or wep_base.Primary.Recoil) / multiplier) 
    item:SetProperty("ClipSize", math.ceil((item:GetProperty("ClipSize") or wep_base.Primary.ClipSize) * multiplier))
    item:SetProperty("Spread", (item:GetProperty("Spread") or wep_base.Primary.Spread) / multiplier) 
    item:SetProperty("RPM", (item:GetProperty("RPM") or wep_base.Primary.RPM) * multiplier)
    item:SetProperty("Shots", (item:GetProperty("Shots") or wep_base.Primary.NumShots) * multiplier)

    item.rarity = nextRarity
    ply:UpdateItem(item)
    BCORE.Inventory:Chat("Your " .. item.name .. " has been upgraded to " .. nextRarity .. "!", ply)
end

upgradeablewep.Socket = function(item, ply)

end

BCORE.Inventory:RegisterType("UpgradableWeapon", upgradeablewep)
