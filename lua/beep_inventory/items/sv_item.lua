BCORE.Inventory.Item = {}
local Item = BCORE.Inventory.Item

Item.__index = Item

local usedIDs = {}
local nextItemID = 1

-- Utility: Generate Unique ID
local function GenerateUniqueID()
    local id = nextItemID

    while usedIDs[id] do
        nextItemID = nextItemID + 1
        id = nextItemID
    end

    usedIDs[id] = true
    nextItemID = nextItemID + 1

    return id
end

-- Constructor: Create a New Item
function Item:new(className, name, model, rarity, itemType, customData)
    local obj = setmetatable({}, self)
    obj.id = GenerateUniqueID()
    obj.className = className or "default"
    obj.name = name or "Unknown Item"
    obj.model = model or "models/props_junk/cardboard_box001a.mdl"
    obj.rarity = rarity or "Common"
    obj.itemType = itemType or "generic"
    obj.customData = customData or {}
    obj.onAction = {}
    obj.isitem = true
    return obj
end

-- Set Actions for the Item
function Item:setActions(actions)
    self.onAction = actions
end

-- Perform an Action on the Item
function Item:PerformAction(action, ply)
    if self.onAction and self.onAction[action] then
        return self.onAction[action](self, ply)
    else
        print("No action '" .. action .. "' found for item: " .. self.name)
    end
end

-- Spawn the Item as an Entity
function Item:SpawnItem(pos, ang)
    if not pos then return end

    local ent = ents.Create(self.className)
    if not IsValid(ent) then return end

    ent:SetModel(self.model)
    ent:SetPos(pos)
    if ang then ent:SetAngles(ang) end
    ent:Spawn()

    ent.className = self.className
    ent.name = self.name
    ent.rarity = self.rarity
    ent.itemType = self.itemType
    ent.customData = self.customData
    ent.isitem = true

    ent:SetNWString("ItemName", self.name)
    ent:SetNWString("ItemId", self.id)
    ent:SetNWString("ItemModel", self.model)
    ent:SetNWString("ItemRarity", self.rarity)
    ent:SetNWBool("IsItem", true)

    if self.customData then
        local i = 1
        for k, v in pairs(self.customData) do
            if k == "Modifiers" then continue end
            ent:SetNWString("Custom_" .. i, k .. ": " .. tostring(v))
            i = i + 1
        end
    end

    return ent
end

-- Give the Item as a Weapon to a Player
function Item:GiveWeapon(ply)
    ply:Give(self.className)
    ply:SelectWeapon(self.className)
    local wep = ply:GetWeapon(self.className)
    if IsValid(wep) then
        self:ApplyCustomizations(wep)
        wep.className = self.className
        wep.name = self.name
        wep.rarity = self.rarity
        wep.itemType = self.itemType
        wep.customData = self.customData
        wep.isitem = true
    end
    return wep
end

-- Set a Custom Property for the Item
function Item:SetProperty(key, value)
    self.customData[key] = value
end

-- Get a Custom Property from the Item
function Item:GetProperty(key)
    return self.customData[key]
end

-- Package the Item for Networking
function Item:Package()
    local safeData = {
        id = self.id,
        className = self.className,
        name = self.name,
        model = self.model,
        rarity = self.rarity,
        itemType = self.itemType,
        customData = table.Copy(self.customData)
    }

    if self.onAction then
        local actionKeys = {}
        for key, _ in pairs(self.onAction) do
            table.insert(actionKeys, key)
        end
        safeData.onAction = actionKeys
    end

    if safeData.customData["Modifiers"] then
        for _, modifier in ipairs(safeData.customData["Modifiers"]) do
            if modifier.onAction then
                local modActionKeys = {}
                for key, _ in pairs(modifier.onAction) do
                    table.insert(modActionKeys, key)
                end
                modifier.onAction = modActionKeys
            end
        end
    end

    return safeData
end



