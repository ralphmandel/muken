icebreaker_4__mirror = class({})
LinkLuaModifier("icebreaker_4_modifier_mirror", "heroes/icebreaker/icebreaker_4_modifier_mirror", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function icebreaker_4__mirror:OnSpellStart()
    local caster = self:GetCaster()
end

-- EFFECTS