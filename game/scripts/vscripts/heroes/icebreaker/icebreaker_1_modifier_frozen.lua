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
	self.break_damage = self.ability:GetSpecialValueFor("break_damage")

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "icebreaker_1_modifier_frozen_status_efx", true) end

	self.parent:RemoveModifierByNameAndCaster("icebreaker_1_modifier_hypo", self.caster)

	if IsServer() then self:PlayEfxStart() end
end

function icebreaker_1_modifier_frozen:OnRefresh( kv )
end

function icebreaker_1_modifier_frozen:OnRemoved( kv )
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "icebreaker_1_modifier_frozen_status_efx", false) end

	if self.ability_break:GetAbilityName() == "icebreaker_u__blink" then
		self.ability_break.spell_lifesteal = true
	end

	ApplyDamage({
		victim = self.parent, attacker = self.caster,
		damage = self.break_damage, damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability_break
	})

	self:IceBreak(self.parent)
	self:PlayEfxDestroy()

	-- if self.ability_break:GetAbilityName() == "icebreaker_u__blink" then
	-- 	self:BlinkStrike(self.break_damage)
	-- end
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
		MODIFIER_PROPERTY_AVOID_DAMAGE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

function icebreaker_1_modifier_frozen:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned() == false then self:Destroy() end
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
	local ability_wave = self.caster:FindAbilityByName("icebreaker_4__wave")
	if ability_wave == nil then return end
	if ability_wave:IsTrained() == false then return end

	self.caster:FindModifierByName(ability_wave:GetIntrinsicModifierName()):DecrementStackCount()

	-- UP 4.12
	if ability_wave:GetRank(12) then
		self:ApplySpreadHypo(target)
	end
end

function icebreaker_1_modifier_frozen:ApplyMirror()
	local mirror = self.caster:FindAbilityByName("icebreaker_5__mirror")
	if mirror == nil then return end
	if mirror:IsTrained() == false then return end

	-- UP 5.41
	if mirror:GetRank(41) then
		mirror:CreateMirrors(self.parent, 1)
	end
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
	self:ApplyMirror()

	-- UP 6.41
	if self.ability_break:GetRank(41) then
		local damageTableSplash = {
			attacker = self.caster,
			damage = break_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability_break
		}

		local units = FindUnitsInRadius(
			self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil,
			self.ability_break:GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY,
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