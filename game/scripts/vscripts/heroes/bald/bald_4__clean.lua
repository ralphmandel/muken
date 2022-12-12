bald_4__clean = class({})
LinkLuaModifier("bald_4_modifier_passive", "heroes/bald/bald_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_4_modifier_clean", "heroes/bald/bald_4_modifier_clean", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function bald_4__clean:GetIntrinsicModifierName()
        return "bald_4_modifier_passive"
    end

    function bald_4__clean:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")

        caster:AddNewModifier(caster, self, "bald_4_modifier_clean", {
            duration = CalcStatus(duration, caster, caster)
        })
    end

    function bald_4__clean:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

-- EFFECTS