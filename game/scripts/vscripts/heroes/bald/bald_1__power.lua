bald_1__power = class({})
LinkLuaModifier("bald_1_modifier_passive", "heroes/bald/bald_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_1_modifier_passive_stack", "heroes/bald/bald_1_modifier_passive_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bald_1__power:Spawn()
        if self:IsTrained() == false then self:UpgradeAbility(true) end
    end

-- SPELL START

    function bald_1__power:GetIntrinsicModifierName()
        return "bald_1_modifier_passive"
    end

-- EFFECTS