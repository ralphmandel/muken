icebreaker_3__shard = class({})
LinkLuaModifier("icebreaker_3_modifier_shard", "heroes/icebreaker/icebreaker_3_modifier_shard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function icebreaker_3__shard:OnSpellStart()
        local caster = self:GetCaster()
    end

-- EFFECTS