local Inventory = BCORE.Inventory

Inventory.actiontable = Inventory.actiontable or {}

-- Base Item Class
local BaseItem = {}
BaseItem.__index = BaseItem

function BaseItem:New(itemData)
    local newItem = setmetatable(itemData or {}, self)
    return newItem
end

function BaseItem:Drop(ply)
    local pos = ply:GetPos() + Vector(0, 0, 50) + ply:GetForward() * 60
    self:SpawnItem(pos)
    ply:RemoveItem(self)
end

function BaseItem:Destroy(ply)
    ply:RemoveItem(self)
end

-- Weapon Class (inherits from BaseItem)
local Weapon = setmetatable({}, BaseItem)
Weapon.__index = Weapon

function Weapon:Equip(ply)
    if ply:HasWeapon(self.className) then
        ply:ChatPrint("You already have this weapon equipped.")
        return
    end
    self:GiveWeapon(ply)
    ply:RemoveItem(self)
end

-- Entity Class (inherits from BaseItem)
local Entity = setmetatable({}, BaseItem)
Entity.__index = Entity

-- Register Item Types
function Inventory:RegisterType(typeName, itemClass)
    self.actiontable[typeName] = itemClass
end

-- Register specific item types
Inventory:RegisterType("weapon", Weapon)
Inventory:RegisterType("entity", Entity)