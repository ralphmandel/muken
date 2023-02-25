genuine_5__awakening = class({})
LinkLuaModifier("genuine_5_modifier_awakening", "heroes/genuine/genuine_5_modifier_awakening", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function genuine_5__awakening:OnSpellStart()
    local caster = self:GetCaster()
end

-- EFFECTS