icebreaker_1__frost = class({})
LinkLuaModifier( "icebreaker_1_modifier_frost", "heroes/icebreaker/icebreaker_1_modifier_frost", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_1_modifier_instant", "heroes/icebreaker/icebreaker_1_modifier_instant", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "icebreaker_1_modifier_instant_status_efx", "heroes/icebreaker/icebreaker_1_modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function icebreaker_1__frost:CalcStatus(duration, caster, target)
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

    function icebreaker_1__frost:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function icebreaker_1__frost:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_1__frost:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function icebreaker_1__frost:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then base_hero.ranks[1][0] = true end

        local charges = 1

        -- UP 1.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function icebreaker_1__frost:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.kills = 0
    end

-- SPELL START

    function icebreaker_1__frost:GetIntrinsicModifierName()
        return "icebreaker_1_modifier_frost"
    end

    function icebreaker_1__frost:AddKillPoint(pts)
        local caster = self:GetCaster()
        self.kills = self.kills + pts

        local base_stats = caster:FindAbilityByName("base_stats")
	    if base_stats then base_stats:AddBaseStat("AGI", 1) end

        self:PlayEfxKill(caster)
    end

    function icebreaker_1__frost:GetCooldown(iLevel)
		if self:GetCurrentAbilityCharges() == 0 then return 0 end
		if self:GetCurrentAbilityCharges() == 1 then return 0 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return 5 end
	end

-- EFFECTS

    function icebreaker_1__frost:PlayEfxKill(target)
        local particle_cast = "particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
        ParticleManager:ReleaseParticleIndex(nFXIndex)
    end