bloodstained_2__lifesteal = class({})
LinkLuaModifier("bloodstained_2_modifier_passive", "heroes/death/bloodstained/bloodstained_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained__modifier_extra_hp", "heroes/death/bloodstained/bloodstained__modifier_extra_hp", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bloodstained_2__lifesteal:Spawn()
        if self:IsTrained() == false then self:UpgradeAbility(true) end
    end

    function bloodstained_2__lifesteal:GetAOERadius()
        return self:GetSpecialValueFor("special_kill_radius")
    end

-- SPELL START

    function bloodstained_2__lifesteal:GetIntrinsicModifierName()
        return "bloodstained_2_modifier_passive"
    end

-- EFFECTS