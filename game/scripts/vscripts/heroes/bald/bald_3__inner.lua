bald_3__inner = class({})
LinkLuaModifier("bald_3_modifier_passive", "heroes/bald/bald_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_3_modifier_passive_stack", "heroes/bald/bald_3_modifier_passive_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_3_modifier_inner", "heroes/bald/bald_3_modifier_inner", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bald_3__inner:CalcStatus(duration, caster, target)
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

    function bald_3__inner:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bald_3__inner:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bald_3__inner:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_bristleback" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
    end

    function bald_3__inner:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_bristleback" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[3][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function bald_3__inner:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bald_3__inner:GetIntrinsicModifierName()
        return "bald_3_modifier_passive"
    end

    function bald_3__inner:OnSpellStart()
        local caster = self:GetCaster()
        local buff_duration = self:GetSpecialValueFor("buff_duration")
        local def = caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):GetStackCount()

        caster:AddNewModifier(caster, self, "bald_3_modifier_inner", {
            duration = self:CalcStatus(buff_duration, caster, caster),
            def = def
        })

        local mod = caster:FindAllModifiersByName("bald_3_modifier_passive_stack")
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bald_3__inner:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then return DOTA_ABILITY_BEHAVIOR_PASSIVE end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return DOTA_ABILITY_BEHAVIOR_NO_TARGET end
        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end

    function bald_3__inner:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return manacost * level end
        return 0
    end

    function bald_3__inner:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS