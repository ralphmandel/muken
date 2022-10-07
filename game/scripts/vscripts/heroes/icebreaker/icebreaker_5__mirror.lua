icebreaker_5__mirror = class({})
LinkLuaModifier("icebreaker_5_modifier_passive", "heroes/icebreaker/icebreaker_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_5_modifier_illusion", "heroes/icebreaker/icebreaker_5_modifier_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function icebreaker_5__mirror:CalcStatus(duration, caster, target)
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

    function icebreaker_5__mirror:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function icebreaker_5__mirror:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_5__mirror:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function icebreaker_5__mirror:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function icebreaker_5__mirror:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function icebreaker_5__mirror:GetIntrinsicModifierName()
        return "icebreaker_5_modifier_passive"
    end

    function icebreaker_5__mirror:CreateMirrors(target, number)
        local caster = self:GetCaster()
        local illusion_duration = self:GetSpecialValueFor("illusion_duration")
        local illu_array = CreateIllusions(caster, caster, {
            outgoing_damage = -100,
            incoming_damage = 0,
            bounty_base = 0,
            bounty_growth = 0,
            duration = illusion_duration
        }, number, 64, false, true)

        for _,illu in pairs(illu_array) do
            illu:AddNewModifier(caster, self, "icebreaker_5_modifier_illusion", {})

            local loc = target:GetAbsOrigin() + RandomVector(130)
            illu:SetAbsOrigin(loc)
            illu:SetForwardVector((target:GetAbsOrigin() - loc):Normalized())
            FindClearSpaceForUnit(illu, loc, true)
        end		
    end

    function icebreaker_5__mirror:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS