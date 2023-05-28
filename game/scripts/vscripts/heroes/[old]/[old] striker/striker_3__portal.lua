striker_3__portal = class({})
LinkLuaModifier("striker_3_modifier_portal", "heroes/team_sun/striker/striker_3_modifier_portal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_3_modifier_buff", "heroes/team_sun/striker/striker_3_modifier_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_3_modifier_debuff", "heroes/team_sun/striker/striker_3_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_pull", "_modifiers/_modifier_pull", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function striker_3__portal:GetAOERadius()
        return self:GetSpecialValueFor("portal_radius")
    end

    function striker_3__portal:OnSpellStart()
        self:PerformAbility(self:GetCursorPosition())
    end

    function striker_3__portal:PerformAbility(loc)
        local caster = self:GetCaster()

        CreateModifierThinker(
            caster, self, "striker_3_modifier_portal",
            {duration = self:GetSpecialValueFor("portal_duration")},
            loc, caster:GetTeamNumber(), false
        )

        return true
    end

-- EFFECTS