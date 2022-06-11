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
                    local value = base_stats_target.res_total * 0.01
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - calc)
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
                        local value = (base_stats_caster.int_total - base_stats_target.res_total) * 0.01
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + calc)
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - calc)
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
        local att = caster:FindAbilityByName("dasdingo__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        return att.talents[4][upgrade]
    end

    function dasdingo_u__maledict:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local att = caster:FindAbilityByName("dasdingo__attributes")
        if att then
            if att:IsTrained() then
                att.talents[4][0] = true
            end
        end
        
        if self:GetLevel() == 1 then
			caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_RES"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_REC"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_MND"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true)
		end

        local charges = 1

        -- UP 4.11
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

        -- UP 4.21
        if self:GetRank(21) then
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
		if self:GetCurrentAbilityCharges() == 0 then return 60 end
		if self:GetCurrentAbilityCharges() == 1 then return 60 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return 45 end
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