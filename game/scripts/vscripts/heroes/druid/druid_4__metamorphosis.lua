druid_4__metamorphosis = class({})
LinkLuaModifier("druid_4_modifier_metamorphosis", "heroes/druid/druid_4_modifier_metamorphosis", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_4_modifier_aura_effect", "heroes/druid/druid_4_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_4_modifier_strength", "heroes/druid/druid_4_modifier_strength", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_4_modifier_fear", "heroes/druid/druid_4_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_4_modifier_fear_status_efx", "heroes/druid/druid_4_modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_4__metamorphosis:CalcStatus(duration, caster, target)
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

    function druid_4__metamorphosis:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function druid_4__metamorphosis:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_4__metamorphosis:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function druid_4__metamorphosis:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[4][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function druid_4__metamorphosis:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function druid_4__metamorphosis:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:CalcStatus(self:GetSpecialValueFor("duration"), caster, caster)

        caster:AddNewModifier(caster, self, "druid_4_modifier_metamorphosis", {
            duration = duration
        })
    end

    function druid_4__metamorphosis:GetAOERadius()
        return self:GetSpecialValueFor("aura_radius")
    end

    function druid_4__metamorphosis:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function druid_4__metamorphosis:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS