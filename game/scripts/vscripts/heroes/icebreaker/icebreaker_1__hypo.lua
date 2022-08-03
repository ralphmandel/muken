icebreaker_1__hypo = class({})
LinkLuaModifier("icebreaker_1_modifier_passive", "heroes/icebreaker/icebreaker_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_passive_status_efx", "heroes/icebreaker/icebreaker_1_modifier_passive_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_hypo", "heroes/icebreaker/icebreaker_1_modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_hypo_status_efx", "heroes/icebreaker/icebreaker_1_modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_frozen", "heroes/icebreaker/icebreaker_1_modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_frozen_status_efx", "heroes/icebreaker/icebreaker_1_modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_instant", "heroes/icebreaker/icebreaker_1_modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_instant_status_efx", "heroes/icebreaker/icebreaker_1_modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function icebreaker_1__hypo:CalcStatus(duration, caster, target)
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

    function icebreaker_1__hypo:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function icebreaker_1__hypo:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_1__hypo:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function icebreaker_1__hypo:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[1][0] = true
            Timers:CreateTimer(0.2, function()
				if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
			end)
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function icebreaker_1__hypo:Spawn()
        self.kills = 0
        self:SetCurrentAbilityCharges(0)
        if self:IsTrained() == false then self:UpgradeAbility(true) end
    end

-- SPELL START

    function icebreaker_1__hypo:GetIntrinsicModifierName()
        return "icebreaker_1_modifier_passive"
    end

    function icebreaker_1__hypo:AddSlow(target, ability, stacks, bIncrement)
        if not IsServer() then return end
        if target == nil then return end
        if (not IsValidEntity(target)) then return end
        if target:HasModifier("icebreaker_1_modifier_frozen") then return end

        local caster = self:GetCaster()
        local hypo_duration = self:GetSpecialValueFor("hypo_duration")
        local modifier_hypo = target:FindModifierByName("icebreaker_1_modifier_hypo")

        -- UP 1.41
	    if self:GetRank(41) then
            hypo_duration = hypo_duration + 3
        end

        hypo_duration = self:CalcStatus(hypo_duration, caster, target)

        if modifier_hypo == nil then
            modifier_hypo = target:AddNewModifier(caster, self, "icebreaker_1_modifier_hypo", {})
        end

        if modifier_hypo == nil then return end
        local mod_stack = modifier_hypo:GetStackCount()

        if bIncrement then
            modifier_hypo:SetStackCount(mod_stack + stacks)
        else
            if mod_stack < stacks then modifier_hypo:SetStackCount(stacks) end
        end

        if hypo_duration > modifier_hypo:GetRemainingTime() then
            modifier_hypo:SetDuration(hypo_duration, true)
        end
    end

    function icebreaker_1__hypo:AddKillPoint(pts)
        local caster = self:GetCaster()
        self.kills = self.kills + pts

        local base_stats = caster:FindAbilityByName("base_stats")
	    if base_stats then base_stats:AddBaseStat("AGI", 1) end

        self:PlayEfxKill(caster)
    end

    function icebreaker_1__hypo:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function icebreaker_1__hypo:PlayEfxKill(target)
        local particle_cast = "particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
        ParticleManager:ReleaseParticleIndex(nFXIndex)
    end