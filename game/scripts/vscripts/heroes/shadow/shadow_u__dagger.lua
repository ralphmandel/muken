shadow_u__dagger = class({})
LinkLuaModifier("shadow_u_modifier_passive", "heroes/shadow/shadow_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadow_u__dagger:CalcStatus(duration, caster, target)
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

    function shadow_u__dagger:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function shadow_u__dagger:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadow_u__dagger:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function shadow_u__dagger:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then base_hero.ranks[4][0] = true end

        local charges = 1

        -- UP 4.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        -- UP 4.21
        if self:GetRank(21) then
            charges = charges * 3
        end

        -- UP 4.41
        if self:GetRank(41) then
            charges = charges * 5
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function shadow_u__dagger:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function shadow_u__dagger:GetIntrinsicModifierName()
        return "shadow_u_modifier_passive"
    end

    function shadow_u__dagger:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local dagger_speed = self:GetSpecialValueFor("dagger_speed")
        local dagger_name = "particles/shadowmancer/dagger/shadowmancer_stifling_dagger_arcana_combined.vpcf"

        -- UP 4.21
        if self:GetRank(21) then
            dagger_speed = dagger_speed + 1000
        end

        local info = {
			Target = target,
			Source = caster,
			Ability = self,	
			EffectName = dagger_name,
			iMoveSpeed = dagger_speed,
			bReplaceExisting = false,
			bProvidesVision = true,
			iVisionRadius = 150,
			iVisionTeamNumber = caster:GetTeamNumber()
		}

        ProjectileManager:CreateTrackingProjectile(info)
		if IsServer() then caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast") end
    end

    function shadow_u__dagger:OnProjectileHit(hTarget, vLocation)
		if hTarget == nil then return end
		if hTarget:IsInvulnerable() then return end
		if hTarget:TriggerSpellAbsorb(self) then return end
        if IsServer() then hTarget:EmitSound("Hero_PhantomAssassin.Dagger.Target") end

        local caster = self:GetCaster()
        local multiplier = self:GetSpecialValueFor("multiplier")
        local target_toxin = hTarget:FindModifierByName("shadow_0_modifier_toxin")
        if target_toxin == nil then return end

		-- UP 4.21
		if self:GetRank(21) == false
        and hTarget:IsMagicImmune() then
			return
		end

        -- UP 4.31
        if self:GetRank(31) then
            self.target = hTarget
            self.health_percent = hTarget:GetHealthPercent()
        end

		local damageTable = {
			victim = hTarget,
			attacker = caster,
			damage = target_toxin.total_toxin * multiplier * 0.01,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		}
		
		local total = ApplyDamage(damageTable)
		self:PlayEfxHit(hTarget)

		if hTarget:IsAlive() then
			hTarget:RemoveModifierByName("shadow_0_modifier_toxin")
		else
			self:EndCooldown()
		end

        self.health_percent = nil
        self.target = nil
	end

    function shadow_u__dagger:OnHeroDiedNearby(hVictim, hKiller, kv)
		if hVictim == nil or hKiller == nil then return end
        if self.health_percent == nil then return end
        if self.target == nil then return end

        local caster = self:GetCaster()

		if hVictim == self.target and hKiller == caster then
			local new_respawnTime = hVictim:GetRespawnTime() + (self.health_percent * 0.5)
			hVictim:SetTimeUntilRespawn(new_respawnTime)
		end
	end

    function shadow_u__dagger:CastFilterResultTarget(hTarget)
		local caster = self:GetCaster()
		local flag = 0

		-- UP 4.21
		if self:GetCurrentAbilityCharges() % 3 == 0 then
			flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		end

		local result = UnitFilter(
			hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			flag, caster:GetTeamNumber()
		)
		
		if result ~= UF_SUCCESS then
			return result
		end

		return UF_SUCCESS
	end

    function shadow_u__dagger:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        if self:GetCurrentAbilityCharges() % 5 == 0 then return 0 end
        return cast_range
    end

    function shadow_u__dagger:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level =  (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function shadow_u__dagger:PlayEfxHit(target)
        local caster = self:GetCaster()
        local particle_cast = "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

        AddFOWViewer(caster:GetTeamNumber(), target:GetOrigin(), 75, 1.5, false)
        if IsServer() then target:EmitSound("Hero_QueenOfPain.ShadowStrike") end
    end