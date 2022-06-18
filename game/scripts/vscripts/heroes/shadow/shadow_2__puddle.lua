shadow_2__puddle = class({})
LinkLuaModifier("shadow_2_modifier_puddle", "heroes/shadow/shadow_2_modifier_puddle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_2_modifier_vacuum", "heroes/shadow/shadow_2_modifier_vacuum", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadow_2__puddle:CalcStatus(duration, caster, target)
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

    function shadow_2__puddle:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function shadow_2__puddle:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadow_2__puddle:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function shadow_2__puddle:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then base_hero.ranks[2][0] = true end

        local charges = 1

        -- UP 2.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        -- UP 2.41
        if self:GetRank(41) then
            charges = charges * 3
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function shadow_2__puddle:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function shadow_2__puddle:OnSpellStart()
        local caster = self:GetCaster()
		local point = self:GetCursorPosition()
        
		local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
		for _,smoke in pairs(thinkers) do
			if smoke:GetOwner() == caster and smoke:HasModifier("shadow_2_modifier_puddle") then
				smoke:Kill(self, nil)
			end
		end

		CreateModifierThinker(caster, self, "shadow_2_modifier_puddle", {}, point, caster:GetTeamNumber(), false)
    end

    function shadow_2__puddle:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function shadow_2__puddle:GetCooldown(iLevel)
        local cooldown = self:GetSpecialValueFor("cooldown")
		if self:GetCurrentAbilityCharges() == 0 then return cooldown end
		if self:GetCurrentAbilityCharges() == 1 then return cooldown end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return cooldown - 5 end
        return cooldown
	end

    function shadow_2__puddle:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        if self:GetCurrentAbilityCharges() == 1 then return cast_range end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return 0 end
        return cast_range
    end

    function shadow_2__puddle:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS