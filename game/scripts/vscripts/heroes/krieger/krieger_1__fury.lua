krieger_1__fury = class({})
LinkLuaModifier("krieger_1_modifier_passive", "heroes/krieger/krieger_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("krieger_1_modifier_passive_status_efx", "heroes/krieger/krieger_1_modifier_passive_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("krieger_1_modifier_fury", "heroes/krieger/krieger_1_modifier_fury", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("krieger_1_modifier_fury_status_efx", "heroes/krieger/krieger_1_modifier_fury_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function krieger_1__fury:CalcStatus(duration, caster, target)
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

    function krieger_1__fury:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function krieger_1__fury:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function krieger_1__fury:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_sven" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function krieger_1__fury:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_sven" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[1][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function krieger_1__fury:Spawn()
        local caster = self:GetCaster()
        self:SetCurrentAbilityCharges(0)
        if self:IsTrained() == false then self:UpgradeAbility(true) end

        Timers:CreateTimer((0.2), function()
			if caster:IsIllusion() == false then
				caster:SetMana(0)
			end
		end)
    end

-- SPELL START

    function krieger_1__fury:GetIntrinsicModifierName()
        return "krieger_1_modifier_passive"
    end

    function krieger_1__fury:ModifyFury(value)
        local caster = self:GetCaster()
        if value > 0 then
            caster:GiveMana(value)
        else
            caster:ReduceMana(-value)
        end

        if caster:GetMaxMana() == caster:GetMana()
        and caster:HasModifier("krieger_1_modifier_fury") == false then
            caster:AddNewModifier(caster, self, "krieger_1_modifier_fury", {})
            return true
        end

        if caster:GetMana() == 0 then
            caster:RemoveModifierByNameAndCaster("krieger_1_modifier_fury", caster)
        end

        return false
    end

    function krieger_1__fury:OnOwnerSpawned()
        local caster = self:GetCaster()
        caster:SetMana(0)
    end

    function krieger_1__fury:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS