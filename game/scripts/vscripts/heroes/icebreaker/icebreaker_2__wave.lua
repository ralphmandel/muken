icebreaker_2__wave = class({})
LinkLuaModifier("icebreaker_2_modifier_wave", "heroes/icebreaker/icebreaker_2_modifier_wave", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function icebreaker_2__wave:OnSpellStart()
        local caster = self:GetCaster()
    end

-- EFFECTS