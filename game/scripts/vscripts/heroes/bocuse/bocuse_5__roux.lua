bocuse_5__roux = class({})
LinkLuaModifier("bocuse_5_modifier_roux", "heroes/bocuse/bocuse_5_modifier_roux", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function bocuse_5__roux:OnSpellStart()
    local caster = self:GetCaster()
end

-- EFFECTS