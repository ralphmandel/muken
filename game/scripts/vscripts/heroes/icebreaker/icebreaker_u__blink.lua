icebreaker_u__blink = class({})
LinkLuaModifier("icebreaker_u_modifier_blink", "heroes/icebreaker/icebreaker_u_modifier_blink", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function icebreaker_u__blink:OnSpellStart()
    local caster = self:GetCaster()
end

-- EFFECTS