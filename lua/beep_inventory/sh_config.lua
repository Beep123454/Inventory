BCORE.Inventory.config = BCORE.Inventory.config or {}

BCORE.Inventory.config.MaxSlots = 44

BCORE.Inventory.config.Rarities = {
    ['Common'] = {color = Color(255,255,255), weight = 1, multiplier = 1.05,sockets = 0},
    ['Uncommon'] = {color = Color(0,255,0), weight = 2, multiplier = 1.10,sockets = 0},
    ['Rare'] = {color = Color(0,115,255), weight = 3, multiplier = 1.15,sockets = 0},
    ['Epic'] = {color = Color(175,2,255), weight = 4, multiplier = 1.20,sockets = 0},
    ['Legendary'] = {color = Color(255,208,0), weight = 5, multiplier = 1.25,sockets = 1},
    ['Mythical'] = {color = Color(255,0,234), weight = 6, multiplier = 1.30,sockets =2},
    ['Exotic'] = {color = Color(138,0,0), weight = 7, multiplier = 1.35,sockets=3},
    ['Anceint'] = {color = Color(128,128,0), weight = 8, multiplier = 1.40,sockets=4},
    ['Divine'] = {color = Color(255,128,0), weight = 9, multiplier = 1.50,sockets=5},
    ['Primordial'] = {color = Color(0,0,128), weight = 10, multiplier = 1.60,sockets=6},
}

function BCORE.Inventory:GetHighestRarity()
    local rarities = BCORE.Inventory.config.Rarities
    local highestRarity = nil
    local highestWeight = -math.huge

    for rarity, data in pairs(rarities) do
        if data.weight > highestWeight then
            highestWeight = data.weight
            highestRarity = rarity
        end
    end

    return highestRarity
end