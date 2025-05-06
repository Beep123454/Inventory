local Inventory = BCORE.Inventory
Inventory.Modifiers = Inventory.Modifiers or {}

-- Base Modifier Class
local Modifier = {}
Modifier.__index = Modifier

function Modifier:New(name, description, itemType, model, chance, color, onHit, modify, unmodify)
    local obj = setmetatable({}, self)
    obj.name = name or "Unknown Modifier"
    obj.description = description or "No description provided."
    obj.itemType = itemType or "Modifier"
    obj.model = model or "models/props_junk/garbage_metalcan001a.mdl"
    obj.chance = chance or 0.1
    obj.color = color or Color(255, 255, 255)
    obj.onHit = onHit or nil
    obj.modify = modify or nil
    obj.unmodify = unmodify or nil
    return obj
end

function Modifier:ApplyToItem(item, ply)
    if self.modify then
        self.modify(self, item, ply)
    end
end

function Modifier:RemoveFromItem(item, ply)
    if self.unmodify then
        self.unmodify(self, item, ply)
    end
end

function Modifier:OnHit(attacker, target, item)
    if self.onHit then
        self.onHit(attacker, target, item)
    end
end

-- Register Modifier
function Inventory:RegisterModifier(modifier)
    if not modifier.name then
        error("[BCORE Inventory] Modifier must have a name!")
    end
    Inventory.Modifiers[modifier.name] = modifier
end

-- Create Modifiers
local fireModifier = Modifier:New(
    "FIRE",
    "Ignites the target on hit.",
    "Modifier",
    "models/props_junk/garbage_metalcan001a.mdl",
    0.25,
    Color(255, 0, 0),
    function(attacker, target, item)
        if math.random() < item:GetProperty("Chance") then
            target:Ignite(item:GetProperty("Chance"), 0)
        end
    end
)

local freezeModifier = Modifier:New(
    "FREEZE",
    "Freezes the target in place.",
    "Modifier",
    "models/props_junk/garbage_metalcan001a.mdl",
    0.2,
    Color(0, 0, 255),
    function(attacker, target, item)
        if math.random() < item:GetProperty("Chance") then
            target:Freeze(true)
            timer.Simple(item:GetProperty("Chance"), function()
                if IsValid(target) then target:Freeze(false) end
            end)
        end
    end
)

local damageBoostModifier = Modifier:New(
    "DAMAGE_BOOST",
    "Increases weapon damage.",
    "Modifier",
    "models/props_junk/garbage_metalcan001a.mdl",
    0.3,
    Color(0, 255, 0),
    nil,
    function(self, weapon, ply)
        local originalDamage = weapon:GetProperty("Damage") or 1
        weapon:SetProperty("Damage", originalDamage * (1 + self.chance))
        ply:UpdateItem(weapon)
        self.unmodify = function()
            weapon:SetProperty("Damage", originalDamage)
            ply:UpdateItem(weapon)
        end
    end
)

-- Register Modifiers
Inventory:RegisterModifier(fireModifier)
Inventory:RegisterModifier(freezeModifier)
Inventory:RegisterModifier(damageBoostModifier)

-- Hook: Apply Modifier Effects on Hit
hook.Add("EntityTakeDamage", "Weapon_ModifierEffects", function(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() then return end

    local weapon = attacker:GetActiveWeapon()
    if not IsValid(weapon) or not weapon.isitem then return end

    if weapon.customData and weapon.customData.Modifiers then
        for _, modifierData in ipairs(weapon.customData.Modifiers) do
            local modifier = Inventory.Modifiers[modifierData.customData and modifierData.customData.Type]
            if modifier then
                modifier:OnHit(attacker, target, modifierData)
            end
        end
    end
end)

