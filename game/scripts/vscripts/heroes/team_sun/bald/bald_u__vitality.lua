bald_u__vitality = class({})
LinkLuaModifier("bald_u_modifier_vitality", "heroes/team_sun/bald/bald_u_modifier_vitality", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_u_modifier_vitality_status_efx", "heroes/team_sun/bald/bald_u_modifier_vitality_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function bald_u__vitality:OnAbilityPhaseStart()
        local caster = self:GetCaster()

        Timers:CreateTimer(0.5, function()
            if IsServer() then caster:EmitSound("Hero_OgreMagi.Bloodlust.Cast") end
        end)

        return true
    end

    function bald_u__vitality:OnSpellStart()
        local caster = self:GetCaster()
        caster:AddNewModifier(caster, self, "bald_u_modifier_vitality", {})
    end

-- EFFECTS
