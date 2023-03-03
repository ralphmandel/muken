druid_4__form = class({})
LinkLuaModifier("druid_4_modifier_form", "heroes/druid/druid_4_modifier_form", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function druid_4__form:OnSpellStart()
    local caster = self:GetCaster()
end

-- EFFECTS