local thread = BCORE.netstream

-- Networking: Add Network Strings
util.AddNetworkString("BCORE.Inventory.Chat")

-- Utility: Send Chat Message
function BCORE.Inventory:Chat(message, ply)
    net.Start("BCORE.Inventory.Chat")
    net.WriteString(message)

    if ply then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

-- Utility: Sync Player Inventory
function BCORE.Inventory:SyncInventory(ply)
    if not IsValid(ply) then return end

    local inventory = ply:PackageInventory()
    if not inventory then
        print("[ERROR] Inventory is nil for player " .. ply:Nick())
        return
    end

    thread.Start(ply, "InventorySync", inventory)
end

-- Hook: Handle Inventory Action Requests
thread.Hook("BCORE.Inventory.RequestAction", function(ply, itemID, action)
    if not IsValid(ply) or not itemID or not action then return end

    local inventory = ply:GetInventory()
    if not inventory then return end

    for _, item in ipairs(inventory) do
        if item.id == itemID then
            if item.onAction and item.onAction[action] then
                local success = item:PerformAction(action, ply)
                if success then
                    BCORE.Inventory:SyncInventory(ply)
                else
                    ply:ChatPrint("Failed to perform the action on this item.")
                end
            else
                ply:ChatPrint("This action is not available for this item.")
            end
            return
        end
    end

    ply:ChatPrint("Item not found in your inventory.")
end)
