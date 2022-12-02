bald_5__spike = class({})
LinkLuaModifier("bald_5_modifier_spike_caster", "heroes/bald/bald_5_modifier_spike_caster", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_5_modifier_spike_target", "heroes/bald/bald_5_modifier_spike_target", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bald_5__spike:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return duration end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
    end

    function bald_5__spike:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bald_5__spike:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bald_5__spike:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_bristleback" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function bald_5__spike:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_bristleback" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function bald_5__spike:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bald_5__spike:OnOwnerSpawned()
        self:SetActivated(true)
    end

    function bald_5__spike:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local duration = self:GetSpecialValueFor("duration")

        target:AddNewModifier(caster, self, "bald_5_modifier_spike_target", {
            duration = self:CalcStatus(duration, caster, target)
        })
    end

    function bald_5__spike:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
        if caster == hTarget then return UF_FAIL_CUSTOM end

        local result = UnitFilter(
            hTarget, self:GetAbilityTargetTeam(),
            self:GetAbilityTargetType(),
            0, caster:GetTeamNumber()
        )
        
        if result ~= UF_SUCCESS then return result end

        return UF_SUCCESS
    end

    function bald_5__spike:GetCustomCastErrorTarget(hTarget)
        if self:GetCaster() == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
    end

    function bald_5__spike:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return cast_range
    end

    function bald_5__spike:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bald_5__spike:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS