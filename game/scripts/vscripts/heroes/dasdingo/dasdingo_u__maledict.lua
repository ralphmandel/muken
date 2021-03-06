dasdingo_u__maledict = class({})
LinkLuaModifier("dasdingo_u_modifier_maledict", "heroes/dasdingo/dasdingo_u_modifier_maledict", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_u_modifier_overtime", "heroes/dasdingo/dasdingo_u_modifier_overtime", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)


-- INIT

    function dasdingo_u__maledict:CalcStatus(duration, caster, target)
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

    function dasdingo_u__maledict:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function dasdingo_u__maledict:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_u__maledict:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[7][upgrade] end
    end

    function dasdingo_u__maledict:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[7][0] = true
            if self:GetLevel() == 1 then base_hero:SetHotkeys(self, true) end
        end

        local charges = 1

        -- UP 7.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function dasdingo_u__maledict:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_u__maledict:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function dasdingo_u__maledict:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local radius = self:GetSpecialValueFor("radius")
        local flag = 0

        -- UP 7.41
        if self:GetRank(41) then
            flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        end

        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), point, nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            flag, 0, false
        )

        for _,enemy in pairs(enemies) do
            enemy:AddNewModifier(caster, self, "dasdingo_u_modifier_maledict", {})
        end

        self:PlayEfxStart(point, radius)
    end

	function dasdingo_u__maledict:GetCooldown(iLevel)
        local cooldown = self:GetSpecialValueFor("cooldown")
        if self:GetCurrentAbilityCharges() == 0 then return cooldown end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return cooldown - 15 end
        return cooldown
	end

    function dasdingo_u__maledict:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function dasdingo_u__maledict:PlayEfxStart(point, radius)
        local caster = self:GetCaster()
        local particle = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect, 0, point)
        ParticleManager:SetParticleControl(effect, 1, Vector(radius, 2, radius * 2))
        ParticleManager:SetParticleControl(effect, 60, Vector(25, 5, 15))
        ParticleManager:SetParticleControl(effect, 61, Vector(1, 0, 0))
        ParticleManager:ReleaseParticleIndex(effect)

        if IsServer() then
            EmitSoundOnLocationWithCaster(point, "Hero_Dazzle.BadJuJu.Cast", caster)
            EmitSoundOnLocationWithCaster(point, "Hero_Oracle.FalsePromise.Damaged", caster)
        end

        AddFOWViewer(caster:GetTeamNumber(), point, radius, 2, false)
    end