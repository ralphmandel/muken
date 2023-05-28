genuine_1__shooting = class({})
LinkLuaModifier("genuine_1_modifier_orb", "heroes/team_moon/genuine/genuine_1_modifier_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_1_modifier_starfall_stack", "heroes/team_moon/genuine/genuine_1_modifier_starfall_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine__modifier_fear", "heroes/team_moon/genuine/genuine__modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine__modifier_fear_status_efx", "heroes/team_moon/genuine/genuine__modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

	function genuine_1__shooting:Spawn()
		if self:IsTrained() == false then self:UpgradeAbility(true) end
	end

-- SPELL START

	function genuine_1__shooting:GetIntrinsicModifierName()
		return "genuine_1_modifier_orb"
	end

	function genuine_1__shooting:GetProjectileName()
		return "particles/genuine/shooting_star/genuine_shooting.vpcf"
	end

	function genuine_1__shooting:OnOrbFire(keys)
		local caster = self:GetCaster()
		if IsServer() then caster:EmitSound("Hero_DrowRanger.FrostArrows") end
	end

	function genuine_1__shooting:OnOrbImpact(keys)
		local caster = self:GetCaster()
		local starfall_tick = self:GetSpecialValueFor("special_starfall_tick")

		if starfall_tick > 0 then
			keys.target:AddNewModifier(caster, self, "genuine_1_modifier_starfall_stack", {
				duration = starfall_tick
			})
		end

		if RandomFloat(0, 100) < self:GetSpecialValueFor("special_fear_chance") then
			keys.target:AddNewModifier(caster, self, "genuine__modifier_fear", {
				duration = CalcStatus(self:GetSpecialValueFor("special_fear_duration"), caster, keys.target)
			})
		end

		if IsServer() then keys.target:EmitSound("Hero_DrowRanger.Marksmanship.Target") end

		ApplyDamage({
			victim = keys.target, attacker = caster,
			damage = self:GetSpecialValueFor("damage"),
			damage_type = self:GetAbilityDamageType(),
			ability = self
		})
	end

	function genuine_1__shooting:OnOrbFail(keys)
	end

	function genuine_1__shooting:CreateStarfall(target)
		local caster = self:GetCaster()
		local point = target:GetOrigin()
		self:PlayEfxStarfall(target)

		Timers:CreateTimer(self:GetSpecialValueFor("starfall_delay"), function()
			local enemies = FindUnitsInRadius(
				caster:GetTeamNumber(), point, nil,
				self:GetSpecialValueFor("starfall_radius"),
				DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
			)
		
			for _,enemy in pairs(enemies) do
				if IsServer() then
					enemy:EmitSound("Hero_Mirana.Starstorm.Impact")
					break
				end
			end

			for _,enemy in pairs(enemies) do
				ApplyDamage({
					attacker = caster, victim = enemy,
					damage = self:GetSpecialValueFor("starfall_damage"),
					damage_type = DAMAGE_TYPE_MAGICAL, ability = self
				})
			end		
		end)
	end

-- EFFECTS

	function genuine_1__shooting:PlayEfxStarfall(target)
		local particle_cast = "particles/genuine/starfall/genuine_starfall_attack.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
		ParticleManager:ReleaseParticleIndex(effect_cast)

		if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Cast") end
	end