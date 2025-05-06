local thread = BCORE.netstream
local Inventory = BCORE.Inventory

-- Utility: Apply Modifier to Item
local function applyModifier(ply, item, modifier)
    if not (item and modifier) then return end

    item.customData.Modifiers = item.customData.Modifiers or {}

    local modType = modifier.itemType
    local registeredModifier = Inventory.Modifiers[modType]

    if registeredModifier and registeredModifier.modify then
        registeredModifier:ApplyToItem(item, ply)
    end

    table.insert(item.customData.Modifiers, modifier)
    ply:RemoveItem(modifier)
    ply:UpdateItem(item)
end

-- Utility: Remove Modifier from Item
local function removeModifier(ply, item, modifier)
    if not (item and modifier) then return end

    for i, mod in ipairs(item.customData.Modifiers or {}) do
        if mod.id == modifier.id then
            table.remove(item.customData.Modifiers, i)

            local modType = modifier.itemType
            local registeredModifier = Inventory.Modifiers[modType]

            if registeredModifier and registeredModifier.unmodify then
                registeredModifier:RemoveFromItem(item, ply)
            end

            ply:UpdateItem(item)
            setmetatable(modifier, Inventory.Item)
            modifier:setActions(Inventory.actiontable[modifier.itemType])
            ply:AddItem(modifier)
            break
        end
    end
end

-- Hook: Socket Modifier into Item
thread.Hook("BCORE.Inventory.Socket", function(ply, itemID, modifierID)
    if not IsValid(ply) then return end

    local item = ply:GetItemByID(itemID)
    local modifier = ply:GetItemByID(modifierID)

    if not item or not modifier then
        ply:ChatPrint("Invalid item or modifier.")
        return
    end

    applyModifier(ply, item, modifier)
    ply:ChatPrint("Modifier successfully applied to item.")
end)

-- Hook: Unsocket Modifier from Item
thread.Hook("BCORE.Inventory.UnSocket", function(ply, itemID, modifierID)
    if not IsValid(ply) then return end

    local item = ply:GetItemByID(itemID)
    local modifier = ply:GetItemByID(modifierID)

    if not item or not modifier then
        ply:ChatPrint("Invalid item or modifier.")
        return
    end

    removeModifier(ply, item, modifier)
    ply:ChatPrint("Modifier successfully removed from item.")
end)
