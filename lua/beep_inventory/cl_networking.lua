local thread = BCORE.netstream

for i = 1, 200 do
    BUi:CreateFont("BCORE.Inventory." .. i, "Montserrat", i, 500)
    BUi:CreateFont("BCORE.Inventorys." .. i, "Montserrat", i, 600)
    BUi:CreateFont("BCORE.Inventoryb." .. i, "Montserrat", i, 1024)
end

local function SaveInventoryToFile()
    local inventoryData = {
        items = {},
        modifiers = {}
    }

    for _, item in ipairs(LocalPlayer().BCORE_Inventory) do
        table.insert(inventoryData.items, { id = item.id, slot = item.slot, itemType = item.itemType })
    end

    for _, modifier in ipairs(LocalPlayer().BCORE_Inventory_Modifiers) do
        table.insert(inventoryData.modifiers, { id = modifier.id, slot = modifier.slot, itemType = modifier.itemType })
    end

    local jsonData = util.TableToJSON(inventoryData, true)
    file.Write("inventory_save.png", jsonData)
end

local function LoadInventoryFromFile()
    if not file.Exists("inventory_save.png", "DATA") then
        return { items = {}, modifiers = {} }
    end

    local jsonData = file.Read("inventory_save.png", "DATA")
    local inventoryData = util.JSONToTable(jsonData)
    
    if not inventoryData then
        return { items = {}, modifiers = {} }
    end

    return inventoryData
end

thread.Hook("InventorySync", function(inventoryData)
    local inventorySize = BCORE.Inventory.config.MaxSlots
    local modifierSize = BCORE.Inventory.config.MaxSlots
    local assignedSlots = {}
    local assignedModifierSlots = {}
    local inventoryById = {}
    local updatedInventory = {}
    local updatedModifiers = {}

    LocalPlayer().BCORE_Inventory = LocalPlayer().BCORE_Inventory or {}
    LocalPlayer().BCORE_Inventory_Modifiers = LocalPlayer().BCORE_Inventory_Modifiers or {}

    for _, existingItem in ipairs(LocalPlayer().BCORE_Inventory) do
        if existingItem.id then
            inventoryById[existingItem.id] = existingItem
            if existingItem.slot then
                assignedSlots[existingItem.slot] = true
            end
        end
    end

    for _, existingModifier in ipairs(LocalPlayer().BCORE_Inventory_Modifiers) do
        if existingModifier.id then
            inventoryById[existingModifier.id] = existingModifier
            if existingModifier.slot then
                assignedModifierSlots[existingModifier.slot] = true
            end
        end
    end

    for _, item in ipairs(inventoryData) do
        if item.id and inventoryById[item.id] then
            item.slot = inventoryById[item.id].slot
        else
            if item.itemType == "Modifier" then
                local slot = 1
                while assignedModifierSlots[slot] and slot <= modifierSize do
                    slot = slot + 1
                end
                
                if slot <= modifierSize then
                    item.slot = slot
                    assignedModifierSlots[slot] = true
                else
                    print("WARNING: No available modifier slots for item ID:", item.id)
                end
            else
                local slot = 1
                while assignedSlots[slot] and slot <= inventorySize do
                    slot = slot + 1
                end
                
                if slot <= inventorySize then
                    item.slot = slot
                    assignedSlots[slot] = true
                else
                    print("WARNING: No available slots for item ID:", item.id)
                end
            end
        end

        if item.itemType == "Modifier" then
            updatedModifiers[item.id] = item
        else
            updatedInventory[item.id] = item
        end
    end

    LocalPlayer().BCORE_Inventory = {}
    for _, item in pairs(updatedInventory) do
        table.insert(LocalPlayer().BCORE_Inventory, item)
    end

    LocalPlayer().BCORE_Inventory_Modifiers = {}
    for _, modifier in pairs(updatedModifiers) do
        table.insert(LocalPlayer().BCORE_Inventory_Modifiers, modifier)
    end

    if IsValid(BCORE.Inventory.Context) then
        if BCORE.Inventory.upgradesbool then 
            BCORE.Inventory.Context.Inventory:Load(LocalPlayer().BCORE_Inventory)
        else
            BCORE.Inventory.Context.Inventory:Load(LocalPlayer().BCORE_Inventory_Modifiers)
        end
    end

    print("Inventory updated successfully")
end)

hook.Add("ShutDown", "BCORE_SaveAllInventories_CL", function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            SaveInventoryToFile()
        end
    end
end)

gameevent.Listen("client_disconnect")
hook.Add("client_disconnect", "BCORE_Save_CL", function(data)
    print("Disconnected")
    SaveInventoryToFile()
end)

gameevent.Listen("player_activate")
hook.Add("player_activate", "BCORE_LOAD_CL", function(ply)
    timer.Simple(7, function()
        print("ACTIVATED")
        LocalPlayer().BCORE_Inventory = LocalPlayer().BCORE_Inventory or {}
        LocalPlayer().BCORE_Inventory_Modifiers = LocalPlayer().BCORE_Inventory_Modifiers or {}

        local savedInventory = LoadInventoryFromFile()
        local inventoryById = {}

        for _, item in ipairs(savedInventory.items) do
            inventoryById[item.id] = item.slot
        end

        for _, modifier in ipairs(savedInventory.modifiers) do
            inventoryById[modifier.id] = modifier.slot
        end

        for _, item in ipairs(LocalPlayer().BCORE_Inventory) do
            if inventoryById[item.id] then
                item.slot = inventoryById[item.id]
            end
        end

        for _, modifier in ipairs(LocalPlayer().BCORE_Inventory_Modifiers) do
            if inventoryById[modifier.id] then
                modifier.slot = inventoryById[modifier.id]
            end
        end
    end)
end)

net.Receive("BCORE.Inventory.Chat", function()
    chat.AddText(Color(73, 122, 214), "[INVENTORY]" .. " ", color_white, net.ReadString() or "")
end)

function BCORE.Inventory:RequestAction(itemID, action)
    thread.Start("BCORE.Inventory.RequestAction", itemID, action)
end
