icebreaker_u__shard = class({})
LinkLuaModifier( "icebreaker_u_modifier_zero", "heroes/icebreaker/icebreaker_u_modifier_zero", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_u_modifier_buff", "heroes/icebreaker/icebreaker_u_modifier_buff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_u_modifier_blur", "heroes/icebreaker/icebreaker_u_modifier_blur", LUA_MODIFIER_MOTION_NONE )

-- SPELL START

    function icebreaker_u__shard:GetIntrinsicModifierName()
        return "icebreaker_u_modifier_zero"
    end

    function icebreaker_u__shard:OnOwnerDied()
        self:GetCaster():RemoveModifierByName("icebreaker_u_modifier_zero")
    end

-- EFFECTS