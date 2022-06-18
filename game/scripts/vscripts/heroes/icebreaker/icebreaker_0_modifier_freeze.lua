icebreaker_0_modifier_freeze = class({})

--------------------------------------------------------------------------------

function icebreaker_0_modifier_freeze:IsHidden()
	return false
end

function icebreaker_0_modifier_freeze:IsPurgable()
    return false
end

function icebreaker_0_modifier_freeze:IsStunDebuff()
	return true
end

function icebreaker_0_modifier_freeze:GetTexture()
	return "icebreaker_frozen"
end

function icebreaker_0_modifier_freeze:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

--------------------------------------------------------------------------------

function icebreaker_0_modifier_freeze:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.ability_break = self:GetAbility()

	self.take_damage = false
	self.heal = 0

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("icebreaker_0_modifier_freeze_status_efx", true) end

	if IsServer() then
		self:PlayEfxStart()
		self:StartIntervalThink(FrameTime())
	end
end

function icebreaker_0_modifier_freeze:OnRefresh( kv )
end

function icebreaker_0_modifier_freeze:OnRemoved( kv )
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("icebreaker_0_modifier_freeze_status_efx", false) end
	local break_damage = self.ability_break:GetSpecialValueFor("break_damage")

	local damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = 0,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability_break
	}

	if self.take_damage then
		damageTable.damage = break_damage
		self:PlayEfxDestroy()
	end

	if self.ability_break:GetAbilityName() == "icebreaker_3__blink" then self:BlinkStrike(break_damage) end
	if damageTable.damage > 0 then ApplyDamage(damageTable) end
end

function icebreaker_0_modifier_freeze:BlinkStrike(break_damage)
	local base_stats = self.caster:FindAbilityByName("base_stats")

	-- UP 3.11
	if self.ability_break:GetRank(11) then
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

	-- UP 3.41
	if self.ability_break:GetRank(41) then
		self:PlayEfxSpread()

		local damageTableSplash = {
			attacker = self.caster,
			damage = break_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability_break
		}

		local units = FindUnitsInRadius(
			self.caster:GetTeamNumber(), self.parent:GetOrigin(),
			nil, 250,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			0, 0, false
		)
	
		for _,unit in pairs(units) do
			if unit ~= self.parent then
				if IsServer() then unit:EmitSound("Hero_DrowRanger.Marksmanship.Target") end

				if base_stats then
					base_stats:SetForceCritSpell(0, true, DAMAGE_TYPE_MAGICAL)
					damageTableSplash.victim = unit
					ApplyDamage(damageTableSplash)
				end
				
				if unit:IsAlive() then
					unit:AddNewModifier(self.caster, self.ability, "icebreaker_1_modifier_instant", {
						duration = self.ability:CalcStatus(1.5, self.caster, unit)
					})
					self.ability:AddSlow(unit, self.ability)
				end
			end
		end
	end

	-- UP 3.31
	if self.ability_break:GetRank(31) then
		self.ability_break.blink_lifesteal = true
	end

	if base_stats then base_stats:SetForceCritSpell(0, true, DAMAGE_TYPE_MAGICAL) end
end

--------------------------------------------------------------------------------

function icebreaker_0_modifier_freeze:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

function icebreaker_0_modifier_freeze:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_AVOID_DAMAGE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end

function icebreaker_0_modifier_freeze:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	if not self.hits then self.hits = self.ability:GetSpecialValueFor("hits") end
	self.hits = self.hits - 1

	if self.hits < 1 then
		self.take_damage = true
		self:Destroy()
	end
end

function icebreaker_0_modifier_freeze:GetModifierAvoidDamage(keys)
	if keys.target ~= self.parent then return 0 end
	if keys.damage <= 0 then return 0 end

	self:PlayEfxHit()
	return 1
end

function icebreaker_0_modifier_freeze:OnAbilityExecuted(keys)
	if keys.unit == nil then return end
	if keys.target == nil then return end
	if keys.ability == nil then return end
	if keys.unit ~= self.caster then return end
	if keys.target ~= self.parent then return end
	if keys.ability:GetAbilityName() ~= "icebreaker_3__blink" then return end

	self.ability_break = keys.ability

	Timers:CreateTimer((0.1), function()
		if self.ability_break ~= nil then
			if IsValidEntity(self.ability_break) then
				self.ability_break:EndCooldown()
			end
		end
	end)
	
	local frost = keys.unit:FindAbilityByName("icebreaker_1__frost")
	if frost then
		if frost:IsTrained() then
			frost:EndCooldown()
		end
	end

	self:PlayEfxBlink((keys.target:GetOrigin() - keys.unit:GetOrigin()), keys.unit:GetOrigin(), keys.target)
	self.take_damage = true
	self:Destroy()
end

function icebreaker_0_modifier_freeze:OnIntervalThink()
	if self.parent:IsStunned() == false then
		self:Destroy()
		return
	end

	self:StartIntervalThink(FrameTime())
end

--------------------------------------------------------------------------------

function icebreaker_0_modifier_freeze:GetEffectName()
	return "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf"
end

function icebreaker_0_modifier_freeze:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_0_modifier_freeze:GetStatusEffectName()
	return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function icebreaker_0_modifier_freeze:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function icebreaker_0_modifier_freeze:PlayEfxBlink(direction, origin, target)
	local particle_cast = "particles/units/heroes/hero_centaur/centaur_double_edge.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
	ParticleManager:SetParticleControlForward(effect_cast, 0, direction:Normalized())
	ParticleManager:SetParticleControl(effect_cast, 1, origin + direction)
	ParticleManager:ReleaseParticleIndex(effect_cast)
	
	if IsServer() then target:EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Cast") end
	if IsServer() then target:EmitSound("Hero_Icebreaker.Break") end
end

function icebreaker_0_modifier_freeze:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_Ancient_Apparition.IceBlast.Tracker") end
end

function icebreaker_0_modifier_freeze:PlayEfxHit()
	if IsServer() then self.parent:EmitSound("Hero_Lich.ProjectileImpact") end
end

function icebreaker_0_modifier_freeze:PlayEfxDestroy()
	local particle = "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_start.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	local particle_2 = "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/cm_arcana_pup_flee.vpcf"
	local effect_cast_2 = ParticleManager:CreateParticle(particle_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast_2, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("Hero_Lich.IceSpire.Destroy") end
end

function icebreaker_0_modifier_freeze:PlayEfxSpread()
	local particle = "particles/econ/items/ancient_apparition/aa_blast_ti_5/ancient_apparition_ice_blast_explode_ti5.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
end