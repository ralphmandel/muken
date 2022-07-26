striker_1__blow = class({})
LinkLuaModifier("striker_1_modifier_passive", "heroes/striker/striker_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_1_modifier_immune", "heroes/striker/striker_1_modifier_immune", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_ban", "modifiers/_modifier_ban", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_1__blow:CalcStatus(duration, caster, target)
        local time = duration
        local base_stats_caster = nil
        local base_stats_target = nil

        if caster ~= nil then
            base_stats_caster = caster:FindAbilityByName("base_stats")
        end

        if target ~= nil then
            base_stats_target = target:FindAbilityByName("base_stats")
        end

        if caster == nil then
            if target ~= nil then
                if base_stats_target then
                    local value = base_stats_target.stat_total["RES"] * 0.4
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - (calc * 0.01))
                end
            end
        else
            if target == nil then
                if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
                else
                    if base_stats_caster and base_stats_target then
                        local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + (calc * 0.01))
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - (calc * 0.01))
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function striker_1__blow:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function striker_1__blow:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function striker_1__blow:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function striker_1__blow:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[1][0] = true
            Timers:CreateTimer(0.2, function()
				if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
			end)
        end

        self:CheckAbilityCharges(1)
    end

    function striker_1__blow:Spawn()
        self:SetCurrentAbilityCharges(0)
        if self:IsTrained() == false then self:UpgradeAbility(true) end
    end

-- SPELL START

    function striker_1__blow:GetIntrinsicModifierName()
        return "striker_1_modifier_passive"
    end

    function striker_1__blow:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if target:TriggerSpellAbsorb(self) then return false end

        caster:FindModifierByName(self:GetIntrinsicModifierName()):PerformBlink(target)
    end

    function striker_1__blow:GetAbilityTextureName()
        if self:GetCurrentAbilityCharges() == 0 then return "striker_blow" end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return "striker_blow_alter" end
        return "striker_blow"
    end

    -- function striker_1__blow:GetCastPoint()
    --     if self:GetCurrentAbilityCharges() == 0 then return 0 end
    --     if self:GetCurrentAbilityCharges() % 3 == 0 then return 0.5 end
    --     return 0
    -- end

    -- function striker_1__blow:GetCastAnimation()
    --     if self:GetCurrentAbilityCharges() == 0 then return 0 end
    --     if self:GetCurrentAbilityCharges() % 3 == 0 then return ACT_DOTA_CAST_ABILITY_4 end
    --     return 0
    -- end

    function striker_1__blow:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return 450 end
        return 0
    end

    function striker_1__blow:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then return DOTA_ABILITY_BEHAVIOR_PASSIVE end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE end
        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end

    function striker_1__blow:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()

        local result = UnitFilter(
            hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            0, caster:GetTeamNumber()
        )

        return result
    end

    function striker_1__blow:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then manacost = 125 end
        return manacost * level
    end

    function striker_1__blow:CheckAbilityCharges(charges)
        -- UP 1.31
        if self:GetRank(31) then
            charges = charges * 3
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS