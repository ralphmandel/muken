genuine_4__nightfall = class({})
LinkLuaModifier("genuine_4_modifier_nightfall", "heroes/genuine/genuine_4_modifier_nightfall", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function genuine_4__nightfall:OnSpellStart()
    local caster = self:GetCaster()
end

-- EFFECTS