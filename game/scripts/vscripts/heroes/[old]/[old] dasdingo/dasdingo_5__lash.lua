dasdingo_5__lash = class({})
LinkLuaModifier("dasdingo_5_modifier_lash", "heroes/dasdingo/dasdingo_5_modifier_lash", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_ethereal_status_efx", "_modifiers/_modifier_ethereal_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bkb", "_modifiers/_modifier_bkb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_5__lash:CalcStatus(duration, caster, target)
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

    function dasdingo_5__lash:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function dasdingo_5__lash:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_5__lash:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function dasdingo_5__lash:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function dasdingo_5__lash:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_5__lash:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if target:TriggerSpellAbsorb(self) then
            caster:Interrupt()
        else
            target:AddNewModifier(caster, self, "dasdingo_5_modifier_lash", {duration = self:GetChannelTime()})
            if IsServer() then target:EmitSound("Hero_ShadowShaman.Shackles.Cast") end
        end
    end

    function dasdingo_5__lash:OnChannelFinish(bInterrupted)
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        if target then target:RemoveModifierByNameAndCaster("dasdingo_5_modifier_lash", caster) end
    end

    function dasdingo_5__lash:GetChannelTime()
        return CalcStatus(self:GetSpecialValueFor("channel_time"), self:GetCaster(), self:GetCursorTarget())
    end

    function dasdingo_5__lash:GetCastRange(vLocation, hTarget)
        return self:GetSpecialValueFor("cast_range")
    end

    function dasdingo_5__lash:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS