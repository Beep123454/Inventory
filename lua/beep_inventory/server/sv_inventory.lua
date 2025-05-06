local PLAYER = FindMetaTable("Player")
local Inventory = BCORE.Inventory

-- Utility Functions
local function randomizeStat(baseValue)
    return math.Round(baseValue * math.Rand(1, 2), 0)
end

-- PLAYER Inventory Initialization
function PLAYER:Initialize()
    if not self.BCORE_Inventory then
        self.BCORE_Inventory = {}
    end
end

-- Inventory Management
function PLAYER:LoadInventory()
    self:Initialize()
    self.BCORE_Inventory = BCORE.Inventory.DataBase:load(self) or {}

    for _, item in ipairs(self.BCORE_Inventory) do
        setmetatable(item, BCORE.Inventory.Item)
        item:setActions(Inventory.actiontable[item.itemType])
    end

    BCORE.Inventory:SyncInventory(self)
    print("Loaded inventory for: " .. self:Nick())
end

function PLAYER:SaveInventory()
    self:Initialize()
    BCORE.Inventory.DataBase:save(self)
    print("Saved inventory for: " .. self:Nick())
end

function PLAYER:GetInventory()
    self:Initialize()
    return self.BCORE_Inventory
end

function PLAYER:ClearInventory()
    self:Initialize()
    self.BCORE_Inventory = {}
    self:SaveInventory()
    BCORE.Inventory:SyncInventory(self)
end

-- Item Management
function PLAYER:AddItem(item)
    self:Initialize()
    table.insert(self.BCORE_Inventory, item)
    BCORE.Inventory:SyncInventory(self)
end

function PLAYER:RemoveItem(item)
    self:Initialize()
    for i, invItem in ipairs(self.BCORE_Inventory) do
        if invItem.id == item.id then
            table.remove(self.BCORE_Inventory, i)
            BCORE.Inventory:SyncInventory(self)
            return
        end
    end
end

function PLAYER:UpdateItem(item)
    for i, invItem in ipairs(self.BCORE_Inventory or {}) do
        if invItem.id == item.id then
            self.BCORE_Inventory[i] = item
            BCORE.Inventory:SyncInventory(self)
            return
        end
    end
end

function PLAYER:GetItemByID(itemID)
    for _, item in ipairs(self.BCORE_Inventory or {}) do
        if item.id == itemID then
            return item
        end
    end
    return nil
end

function PLAYER:RemoveItemByID(itemID)
    self:Initialize()
    for i, invItem in ipairs(self.BCORE_Inventory) do
        if invItem.id == itemID then
            table.remove(self.BCORE_Inventory, i)
            return
        end
    end
end

function PLAYER:HasItem(itemID)
    self:Initialize()
    for _, invItem in ipairs(self.BCORE_Inventory) do
        if invItem.id == itemID then
            return true
        end
    end
    return false
end

-- Item Packaging
function PLAYER:PackageInventory()
    self:Initialize()
    local items = {}

    for _, item in ipairs(self:GetInventory()) do
        if getmetatable(item) ~= BCORE.Inventory.Item then
            setmetatable(item, BCORE.Inventory.Item)
        end

        if item.Package then
            table.insert(items, item:Package())
        end
    end

    return items
end

-- Item Pickup
function PLAYER:PickUp()
    local ent = self:GetEyeTrace().Entity
    if not IsValid(ent) then return end

    if ent.isitem then
        local item = BCORE.Inventory.Item:new(ent.className, ent.name, ent:GetModel(), ent.rarity, ent.itemType, ent.customData)
        item:setActions(Inventory.actiontable[item.itemType])
        self:AddItem(item)
        ent:Remove()
        BCORE.Inventory:Chat("You picked up a " .. ent.name, self)
    else
        BCORE.Inventory:Chat("This is not a valid item!", self)
    end
end

-- Weapon Holstering
function PLAYER:Holster()
    local weapon = self:GetActiveWeapon()
    if not IsValid(weapon) then return end

    if weapon.isitem then
        local item = BCORE.Inventory.Item:new(weapon.className, weapon.name, weapon:GetWeaponWorldModel(), weapon.rarity, weapon.itemType, weapon.customData)
        item:setActions(Inventory.actiontable[item.itemType])
        self:AddItem(item)
        self:StripWeapon(weapon:GetClass())
        BCORE.Inventory:Chat("You holstered a " .. weapon.name, self)
    else
        local wep_base = weapons.Get(weapon:GetClass())
        if not wep_base then
            print("[ERROR] Weapon not found in weapons.Get!")
            return
        end

        local newWeapon = BCORE.Inventory.Item:new(
            wep_base.ClassName,
            wep_base.PrintName,
            wep_base.WorldModel or "models/props_c17/pulleywheels_large01.mdl",
            "Common",
            "UpgradableWeapon",
            {
                Damage = wep_base.Primary and randomizeStat(wep_base.Primary.Damage or 50),
                Accuracy = wep_base.Primary and randomizeStat(wep_base.Primary.IronAccuracy or 85),
                Recoil = wep_base.Primary and randomizeStat(wep_base.Primary.Recoil or wep_base.Primary.KickUp or 1.2),
                ClipSize = wep_base.Primary and randomizeStat(wep_base.Primary.ClipSize or 30),
                Spread = wep_base.Primary and randomizeStat(wep_base.Primary.Spread or 0.05),
                RPM = wep_base.Primary and randomizeStat(wep_base.Primary.RPM or 600),
                Shots = wep_base.Primary and randomizeStat(wep_base.Primary.NumShots or 1),
            }
        )
        newWeapon:setActions(Inventory.actiontable[newWeapon.itemType])
        self:AddItem(newWeapon)
        self:StripWeapon(weapon:GetClass())
    end
end

-- Rarity Management
function Inventory:GetNextRarity(currentRarity)
    local rarities = BCORE.Inventory.config.Rarities
    local currentWeight = rarities[currentRarity] and rarities[currentRarity].weight

    if not currentWeight then
        return currentRarity
    end

    for rarity, data in pairs(rarities) do
        if data.weight == currentWeight + 1 then
            return rarity
        end
    end

    return currentRarity
end

concommand.Add("wipe", function(ply, cmd, args)
    if IsValid(ply) and ply:IsAdmin() then
        for _, v in ipairs(player.GetAll()) do
            v:ClearInventory()
        end
    end
end)

concommand.Add("GiveFireModifier", function(ply, cmd, args)
    if IsValid(ply) and ply:IsAdmin() then
        local item = BCORE.Inventory.Item:new("FIRE_MODIFIER", "Fire Modifier", "models/props_junk/garbage_metalcan001a.mdl", "Common", "Modifier")
        item:setActions(Inventory.actiontable.Modifier)
        ply:AddItem(item)
    end
end)