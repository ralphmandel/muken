ancient_1__berserk = class({})
LinkLuaModifier("ancient_1_modifier_passive", "heroes/ancient/ancient_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_1_modifier_punch", "heroes/ancient/ancient_1_modifier_punch", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function ancient_1__berserk:CalcStatus(duration, caster, target)
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

    function ancient_1__berserk:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function ancient_1__berserk:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function ancient_1__berserk:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function ancient_1__berserk:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[1][0] = true
            Timers:CreateTimer(0.2, function()
				if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
			end)
        end

        self:CheckAbilityCharges(1)
    end

    function ancient_1__berserk:Spawn()
        self:SetCurrentAbilityCharges(0)
        if self:IsTrained() == false then self:UpgradeAbility(true) end
    end

-- SPELL START

    function ancient_1__berserk:GetIntrinsicModifierName()
        return "ancient_1_modifier_passive"
    end

    function ancient_1__berserk:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then
            return DOTA_ABILITY_BEHAVIOR_PASSIVE
        end

        if self:GetCurrentAbilityCharges() % 3 == 0 then
            return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST + DOTA_ABILITY_BEHAVIOR_ATTACK
        end

        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end

    function ancient_1__berserk:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return self:GetCaster():Script_GetAttackRange() + 50 end
        return 0
    end

    function ancient_1__berserk:GetCooldown(iLevel)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return 20 end
        return 0
    end

    function ancient_1__berserk:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return 100 end
        return manacost * level
    end

    function ancient_1__berserk:CheckAbilityCharges(charges)
        -- UP 1.21
        if self:GetRank(21) then
            charges = charges * 2 -- unhide modifier
        end

        -- UP 1.31
        if self:GetRank(31) then
            charges = charges * 3 -- autocast ability
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS