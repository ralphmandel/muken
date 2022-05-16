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

	self.break_damage = self.ability:GetSpecialValueFor("break_damage")
	self.heal = 0

	local channel = self.parent:FindAbilityByName("_channel")
	if channel then channel:SetStatusEffect("icebreaker_0_modifier_freeze_status_effect", true) end

	if IsServer() then
		self:SetStackCount(0)
		self:PlayEfxStart()
		self:StartIntervalThink(0.25)
	end
end

function icebreaker_0_modifier_freeze:OnRefresh( kv )
end

function icebreaker_0_modifier_freeze:OnRemoved( kv )
	local channel = self.parent:FindAbilityByName("_channel")
	if channel then channel:SetStatusEffect("icebreaker_0_modifier_freeze_status_effect", false) end

	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then
		local heal = self.heal * 0.5
		local mnd = self.caster:FindModifierByName("_2_MND_modifier")
		if mnd then heal = heal * mnd:GetHealPower() end
		if heal > 0 then self.parent:Heal(heal, self.ability_break) end
	else
		local damageTable = {
			victim = self.parent,
			attacker = self.caster,
			damage = self:GetStackCount(),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability_break
		}
		local value = ApplyDamage(damageTable)

		if self:GetStackCount() >= self.break_damage then
			self:PlayEfxDestroy()
		end

		if self.ability_break:GetAbilityName() == "icebreaker_3__blink" then
			-- UP 3.11
			if self.ability_break:GetRank(11) and self.parent:IsAlive() then
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

			-- UP 3.21
			if self.ability_break:GetRank(21) then
				local heal = self.heal
				local mnd = self.caster:FindModifierByName("_2_MND_modifier")
				if mnd then heal = heal * mnd:GetHealPower() end
				if heal > 0 then self.caster:Heal(heal, self.ability_break) end
			end

			-- UP 3.31
			if self.ability_break:GetRank(31) then
				self:PlayEfxSpread()

				local damageTable = {
					attacker = self.caster,
					damage = self.ability:GetSpecialValueFor("break_damage"),
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self.ability_break
				}

				local units = FindUnitsInRadius(
					self.caster:GetTeamNumber(), self.parent:GetOrigin(),
					nil, 275,
					DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
					0, 0, false
				)
			
				for _,unit in pairs(units) do
					if unit ~= self.parent then
						if IsServer() then unit:EmitSound("Hero_DrowRanger.Marksmanship.Target") end

						damageTable.victim = unit
						ApplyDamage(damageTable)

						if unit:IsAlive() then
							unit:AddNewModifier(self.caster, self.ability, "icebreaker_1_modifier_instant", {duration = 0.6})
							self.ability:AddSlow(unit, self.ability)
						end
					end
				end
			end
		end
	end
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
		MODIFIER_PROPERTY_AVOID_DAMAGE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end


function icebreaker_0_modifier_freeze:GetModifierAvoidDamage(keys)
	if keys.target ~= self.parent then return 0 end
	if keys.damage <= 0 then return 0 end

	if IsServer() then
		self:PlayEfxHit()
		local stack = self:GetStackCount() + keys.damage
		if stack >= self.break_damage then
			self:SetStackCount(self.break_damage)
			self.heal = self.break_damage
			self:Destroy()
		else
			self:SetStackCount(stack)
			self.heal = stack
		end
	end

	return 1
end

function icebreaker_0_modifier_freeze:OnAbilityExecuted(keys)
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then return end
	if keys.ability == nil then return end
	if keys.ability:GetAbilityName() ~= "icebreaker_3__blink" then return end
	self.ability_break = keys.ability
	
	if keys.unit == self.caster
	and keys.target == self.parent then
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

		-- UP 3.41
		local damage = self.break_damage
		if self.ability_break:GetRank(41) then
			damage = damage + 70
		end

		self.heal = self.break_damage
		self:SetStackCount(damage)
		self:PlayEfxBlink((keys.target:GetOrigin() - keys.unit:GetOrigin()), keys.unit:GetOrigin(), keys.target)
		self:Destroy()
	end
end

function icebreaker_0_modifier_freeze:OnIntervalThink()
	if self.parent:IsStunned() == false then self:Destroy() end
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