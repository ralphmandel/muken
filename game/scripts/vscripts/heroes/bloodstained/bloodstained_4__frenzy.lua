bloodstained_4__frenzy = class({})
LinkLuaModifier("bloodstained_4_modifier_passive", "heroes/bloodstained/bloodstained_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_4_modifier_frenzy", "heroes/bloodstained/bloodstained_4_modifier_frenzy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained__modifier_bleeding", "heroes/bloodstained/bloodstained__modifier_bleeding", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained__modifier_bleeding_status_efx", "heroes/bloodstained/bloodstained__modifier_bleeding_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_unslowable", "modifiers/_modifier_unslowable", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function bloodstained_4__frenzy:GetIntrinsicModifierName()
        return "bloodstained_4_modifier_passive"
    end

-- EFFECTS