local Inventory = BCORE.Inventory
Inventory.DataBase = Inventory.DataBase or {}

-- Utility: Execute SQL Query with Error Handling
local function executeQuery(query)
    local result = sql.Query(query)
    if result == false then
        print("[BCORE Inventory] SQL Error: " .. (sql.LastError() or "Unknown error"))
    end
    return result
end

-- Create Database Tables
local function createTables()
    local query = [[
        CREATE TABLE IF NOT EXISTS bcore_inventories (
            steamid64 TEXT PRIMARY KEY,
            inventory_data TEXT
        );
    ]]
    executeQuery(query)
end

-- Save Inventory to Database
local function saveInventory(player)
    if not IsValid(player) then return end

    local steamID64 = player:SteamID64()
    local inventoryData = util.TableToJSON(player:GetInventory() or {})
    local safeData = sql.SQLStr(inventoryData)

    local query = string.format(
        [[
        INSERT INTO bcore_inventories (steamid64, inventory_data)
        VALUES (%s, %s)
        ON CONFLICT(steamid64) DO UPDATE SET inventory_data = %s;
        ]],
        sql.SQLStr(steamID64), safeData, safeData
    )

    if executeQuery(query) then
        print("[BCORE Inventory] Inventory saved for: " .. player:Nick())
    else
        print("[BCORE Inventory] Failed to save inventory for: " .. player:Nick())
    end
end

-- Load Inventory from Database
local function loadInventory(player)
    if not IsValid(player) then return end

    local query = string.format(
        "SELECT inventory_data FROM bcore_inventories WHERE steamid64 = %s;",
        sql.SQLStr(player:SteamID64())
    )
    local result = executeQuery(query)

    if result and result[1] then
        local inventoryData = util.JSONToTable(result[1].inventory_data or "{}")
        if inventoryData then
            print("[BCORE Inventory] Inventory loaded for: " .. player:Nick())
            return inventoryData
        else
            print("[BCORE Inventory] Failed to decode inventory for: " .. player:Nick())
        end
    else
        print("[BCORE Inventory] No inventory found for: " .. player:Nick())
    end
end

-- Public API: Save Inventory
function Inventory.DataBase:save(player)
    saveInventory(player)
end

-- Public API: Load Inventory
function Inventory.DataBase:load(player)
    return loadInventory(player)
end

-- Initialize Database
createTables()
