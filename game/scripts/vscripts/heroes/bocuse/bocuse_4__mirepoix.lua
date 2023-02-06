bocuse_4__mirepoix = class({})
LinkLuaModifier("bocuse_4_modifier_mirepoix", "heroes/bocuse/bocuse_4_modifier_mirepoix", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function bocuse_4__mirepoix:OnSpellStart()
    local caster = self:GetCaster()
end

-- EFFECTS