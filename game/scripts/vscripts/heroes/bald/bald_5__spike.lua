bald_5__spike = class({})
LinkLuaModifier("bald_5_modifier_spike_caster", "heroes/bald/bald_5_modifier_spike_caster", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_5_modifier_spike_target", "heroes/bald/bald_5_modifier_spike_target", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bald_5__spike:OnUpgrade()
        local caster = self:GetCaster()

        if caster:HasModifier("bald_5_modifier_spike_caster") == false then
            self:SetCurrentAbilityCharges(self:GetSpecialValueFor("charges"))
        end
    end

    function bald_5__spike:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bald_5__spike:OnOwnerSpawned()
        self:SetActivated(true)
        self:SetCurrentAbilityCharges(self:GetSpecialValueFor("charges"))
    end

    function bald_5__spike:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local duration = CalcStatus(self:GetSpecialValueFor("duration"), caster, target)

        local caster_mod = caster:FindModifierByName("bald_5_modifier_spike_caster")
        if caster_mod then duration = caster_mod:GetRemainingTime() end

        if caster == target then
            caster:AddNewModifier(caster, self, "bald_5_modifier_spike_caster", {duration = duration})
            return
        end

        target:AddNewModifier(caster, self, "bald_5_modifier_spike_target", {duration = duration})
    end

    -- function bald_5__spike:CastFilterResultTarget(hTarget)
    --     local caster = self:GetCaster()
    --     if caster == hTarget then return UF_FAIL_CUSTOM end

    --     local result = UnitFilter(
    --         hTarget, self:GetAbilityTargetTeam(),
    --         self:GetAbilityTargetType(),
    --         0, caster:GetTeamNumber()
    --     )
        
    --     if result ~= UF_SUCCESS then return result end

    --     return UF_SUCCESS
    -- end

    function bald_5__spike:GetCustomCastErrorTarget(hTarget)
        if self:GetCaster() == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
    end

-- EFFECTS