druid_u__conversion = class({})
LinkLuaModifier("druid_u_modifier_conversion", "heroes/druid/druid_u_modifier_conversion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function druid_u__conversion:OnSpellStart()
    local caster = self:GetCaster()
end

-- EFFECTS