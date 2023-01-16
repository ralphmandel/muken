icebreaker_5__shivas = class({})
LinkLuaModifier("icebreaker_5_modifier_shivas", "heroes/icebreaker/icebreaker_5_modifier_shivas", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function icebreaker_5__shivas:OnSpellStart()
    local caster = self:GetCaster()
end

-- EFFECTS