icebreaker_1_modifier_frozen = class({})

function icebreaker_1_modifier_frozen:IsHidden()
	return false
end

function icebreaker_1_modifier_frozen:IsPurgable()
    return false
end

function icebreaker_1_modifier_frozen:IsStunDebuff()
	return true
end

function icebreaker_1_modifier_frozen:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_1_modifier_frozen:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.ability_break = self:GetAbility()
	self.break_damage = 0

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "icebreaker_1_modifier_frozen_status_efx", true) end

	self.parent:RemoveModifierByNameAndCaster("icebreaker_1_modifier_hypo", self.caster)

	if IsServer() then self:PlayEfxStart() end
end

function icebreaker_1_modifier_frozen:OnRefresh( kv )
end

function icebreaker_1_modifier_frozen:OnRemoved( kv )
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "icebreaker_1_modifier_frozen_status_efx", false) end

	local damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = self.break_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability_break
	}

	-- if self.ability_break:GetAbilityName() == "icebreaker_u__blink" then
	-- 	self:BlinkStrike(self.break_damage)
	-- end

	if damageTable.damage > 0 then
		ApplyDamage(damageTable)
		self:IceBreak(self.parent)
		self:PlayEfxDestroy()
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_1_modifier_frozen:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_TEAM_SELECT] = true
	}

	return state
end

function icebreaker_1_modifier_frozen:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_AVOID_DAMAGE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

function icebreaker_1_modifier_frozen:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned() == false then self:Destroy() end
end

function icebreaker_1_modifier_frozen:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	if keys.attacker:IsIllusion() then return end
	if keys.attacker:IsHero() == false then return end

	if self:GetElapsedTime() > (self:GetDuration() / 2) then
		self.break_damage = self.ability:GetSpecialValueFor("break_damage")
		self:Destroy()
	end
end

function icebreaker_1_modifier_frozen:GetModifierAvoidDamage(keys)
	if keys.target ~= self.parent then return 0 end
	if keys.damage <= 0 then return 0 end

	self:PlayEfxHit()
	return 1
end

function icebreaker_1_modifier_frozen:OnAbilityExecuted(keys)
	if keys.unit == nil then return end
	if keys.target == nil then return end
	if keys.ability == nil then return end
	if keys.unit ~= self.caster then return end
	if keys.target ~= self.parent then return end
	if keys.ability:GetAbilityName() ~= "icebreaker_u__blink" then return end

	self.ability_break = keys.ability

	Timers:CreateTimer((0.1), function()
		if self.ability_break ~= nil then
			if IsValidEntity(self.ability_break) then
				self.ability_break:EndCooldown()
			end
		end
	end)


	self:PlayEfxBlink((keys.target:GetOrigin() - keys.unit:GetOrigin()), keys.unit:GetOrigin(), keys.target)
	self.break_damage = self.ability_break:GetSpecialValueFor("break_damage")
	self:BlinkStrike(self.break_damage)
	self:Destroy()
end

-- UTILS -----------------------------------------------------------

function icebreaker_1_modifier_frozen:IceBreak(target)
	local mirror = self.caster:FindAbilityByName("icebreaker_4__mirror")
	local ability_wave = self.caster:FindAbilityByName("icebreaker_5__wave")

	-- UP 4.21
	if mirror ~= nil then
		if mirror:GetRank(21)
		and target:IsAlive() then
			mirror:CreateMirrors(target, 1)
		end
	end
	
	if ability_wave == nil then return end
	if ability_wave:IsTrained() == false then return end

	self.caster:FindModifierByName(ability_wave:GetIntrinsicModifierName()):DecrementStackCount()

	-- UP 5.12
	if ability_wave:GetRank(12) then
		self:ApplySpreadHypo(target)
	end

	-- UP 5.31
	if ability_wave:GetRank(31)
	and self.ability_break:GetAbilityName() == "icebreaker_u__blink" then
		self:BreakHeal(target)
	end
end

function icebreaker_1_modifier_frozen:BreakHeal(target)
	local heal = target:GetMaxHealth() * 0.1

	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then heal = heal * base_stats:GetHealPower() end
	if heal > 0 then self.caster:Heal(heal, self.ability_break) end
end

function icebreaker_1_modifier_frozen:ApplySpreadHypo(target)
	self:PlayEfxSpread(target)

	Timers:CreateTimer((0.1), function()
		if target ~= nil then
			if IsValidEntity(target) then
				local units = FindUnitsInRadius(
					self.caster:GetTeamNumber(), target:GetOrigin(),
					nil, 350, DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, 0, false
				)
				for _,unit in pairs(units) do
					if unit ~= target
					and unit:IsAlive() then
						if IsServer() then unit:EmitSound("Hero_DrowRanger.Marksmanship.Target") end
						self.ability:AddSlow(unit, self.ability, 2, true)
					end
				end
			end
		end
	end)
end

function icebreaker_1_modifier_frozen:BlinkStrike(break_damage)
	-- UP 7.12
	if self.ability_break:GetRank(12) then
		local knockbackProperties =
		{
			duration = 0.5,
			knockback_duration = 0.5,
			knockback_distance = 125,
			center_x = self.caster:GetAbsOrigin().x + 1,
			center_y = self.caster:GetAbsOrigin().y + 1,
			center_z = self.caster:GetAbsOrigin().z,
			knockback_height = 12,
		}

		self.parent:AddNewModifier(self.caster, nil, "modifier_knockback", knockbackProperties)
		if IsServer() then self.parent:EmitSound("Hero_Spirit_Breaker.Charge.Impact") end
	end

	-- UP 7.41
	if self.ability_break:GetRank(41) then
		local damageTableSplash = {
			attacker = self.caster,
			damage = break_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability_break
		}

		local units = FindUnitsInRadius(
			self.caster:GetTeamNumber(), self.parent:GetOrigin(),
			nil, 250, DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
		)
	
		for _,unit in pairs(units) do
			if unit ~= self.parent then
				if unit:HasModifier("icebreaker_1_modifier_frozen") then
					unit:RemoveModifierByNameAndCaster("icebreaker_1_modifier_frozen", self.caster)
					--base_stats:SetForceCritSpell(0, true, DAMAGE_TYPE_MAGICAL)
					damageTableSplash.victim = unit
					ApplyDamage(damageTableSplash)

					self:PlayEfxBlink((unit:GetOrigin() - self.caster:GetOrigin()), self.caster:GetOrigin(), unit)
					self:IceBreak(unit)
				else
					--base_stats:SetForceCritSpell(0, true, DAMAGE_TYPE_MAGICAL)
					damageTableSplash.victim = unit
					ApplyDamage(damageTableSplash)
				end
			end
		end
	end

	--if base_stats then base_stats:SetForceCritSpell(0, true, DAMAGE_TYPE_MAGICAL) end
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_1_modifier_frozen:GetEffectName()
	return "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf"
end

function icebreaker_1_modifier_frozen:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_1_modifier_frozen:GetStatusEffectName()
	return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function icebreaker_1_modifier_frozen:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function icebreaker_1_modifier_frozen:PlayEfxBlink(direction, origin, target)
	local particle_cast = "particles/units/heroes/hero_centaur/centaur_double_edge.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
	ParticleManager:SetParticleControlForward(effect_cast, 0, direction:Normalized())
	ParticleManager:SetParticleControl(effect_cast, 1, origin + direction)
	ParticleManager:ReleaseParticleIndex(effect_cast)
	
	if IsServer() then target:EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Cast") end
	if IsServer() then target:EmitSound("Hero_Icebreaker.Break") end
end

function icebreaker_1_modifier_frozen:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_Ancient_Apparition.IceBlast.Tracker") end
end

function icebreaker_1_modifier_frozen:PlayEfxHit()
	if IsServer() then self.parent:EmitSound("Hero_Lich.ProjectileImpact") end
end

function icebreaker_1_modifier_frozen:PlayEfxDestroy()
	local particle = "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_start.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	local particle_2 = "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/cm_arcana_pup_flee.vpcf"
	local effect_cast_2 = ParticleManager:CreateParticle(particle_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast_2, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("Hero_Lich.IceSpire.Destroy") end
end

function icebreaker_1_modifier_frozen:PlayEfxSpread(target)
	local particle = "particles/econ/items/ancient_apparition/aa_blast_ti_5/ancient_apparition_ice_blast_explode_ti5.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
end