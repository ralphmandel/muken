striker_2__shield = class({})
LinkLuaModifier("striker_2_modifier_shield", "heroes/striker/striker_2_modifier_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_2__shield:CalcStatus(duration, caster, target)
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

    function striker_2__shield:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function striker_2__shield:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function striker_2__shield:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function striker_2__shield:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[2][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function striker_2__shield:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function striker_2__shield:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if target == caster then
            caster:StartGesture(ACT_DOTA_CAST_ABILITY_6)
        else
            caster:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
        end

        return true
    end

    function striker_2__shield:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if target then
            if target == caster then
                caster:FadeGesture(ACT_DOTA_CAST_ABILITY_6)
            else
                caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
            end
        end
    end

    function striker_2__shield:OnSpellStart()
        local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local duration = self:GetSpecialValueFor("duration")

        if caster ~= target then caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1) end

		target:AddNewModifier(caster, self, "striker_2_modifier_shield", {
            duration = self:CalcStatus(duration, caster, target)
        })
    end

    function striker_2__shield:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS