striker_3__portal = class({})
LinkLuaModifier("striker_3_modifier_portal", "heroes/striker/striker_3_modifier_portal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_3_modifier_buff", "heroes/striker/striker_3_modifier_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_3_modifier_debuff", "heroes/striker/striker_3_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_pull", "modifiers/_modifier_pull", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)

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
        local portal_duration = self:GetSpecialValueFor("portal_duration")

        -- UP 3.41
        if self:GetRank(41) then
            portal_duration = portal_duration + 30
        end

        CreateModifierThinker(
            caster, self, "striker_3_modifier_portal",
            {duration = portal_duration},
            loc, caster:GetTeamNumber(), false
        )

        return true
    end

-- EFFECTS