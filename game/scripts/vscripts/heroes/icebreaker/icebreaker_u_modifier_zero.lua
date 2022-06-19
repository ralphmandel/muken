icebreaker_u_modifier_zero = class({})

function icebreaker_u_modifier_zero:IsHidden()
	return false
end

function icebreaker_u_modifier_zero:IsPurgable()
	return false
end

function icebreaker_u_modifier_zero:IsAura()
	return true
end

function icebreaker_u_modifier_zero:GetModifierAura()
	return "icebreaker_u_modifier_aura_effect"
end

function icebreaker_u_modifier_zero:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function icebreaker_u_modifier_zero:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function icebreaker_u_modifier_zero:GetAuraSearchFlags()
	if self:GetAbility():GetCurrentAbilityCharges() == 0 then return DOTA_UNIT_TARGET_FLAG_NONE  end
	if self:GetAbility():GetCurrentAbilityCharges() == 1 then return DOTA_UNIT_TARGET_FLAG_NONE  end
	if self:GetAbility():GetCurrentAbilityCharges() % 2 == 0 then return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function icebreaker_u_modifier_zero:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

--------------------------------------------------------------------------------

function icebreaker_u_modifier_zero:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.true_vision = false
	local vision_bonus = 0

	-- UP 4.31
	if self.ability:GetRank(31) then
		self.true_vision = true
		vision_bonus = 50
	end

	if IsServer() then
		self:SetStackCount(vision_bonus)

		-- UP 4.41
		if self.ability:GetRank(41) then
			self:StartIntervalThink(0.3)
		end
	end

	Timers:CreateTimer((0.1), function()
		self.min_health = self.parent:GetMaxHealth()
	end)

	self:PlayEfxStart(self.ability:GetAOERadius())
end

function icebreaker_u_modifier_zero:OnRefresh( kv )
end

function icebreaker_u_modifier_zero:OnRemoved()
	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end

	if IsValidEntity(self.parent) then
		if IsServer() then
			self.parent:EmitSound("Ability.FrostNova")
			self.parent:StopSound("Hero_Icebreaker.Zero.Loop")
		end

		self.parent:SetModelScale(0.1)
		if self.parent:IsAlive() then
			self.parent:Kill(self.ability, nil)
		end
	end
end

--------------------------------------------------------------------------------

function icebreaker_u_modifier_zero:CheckState()
	local state = {
		[MODIFIER_STATE_FORCED_FLYING_VISION] = self.true_vision,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}

	return state
end

function icebreaker_u_modifier_zero:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MIN_HEALTH
	}
	return funcs
end

function icebreaker_u_modifier_zero:GetBonusVisionPercentage()
	return self:GetStackCount()
end

function icebreaker_u_modifier_zero:GetVisualZDelta()
	return 350
end

function icebreaker_u_modifier_zero:GetDisableHealing()
	return 1
end

function icebreaker_u_modifier_zero:GetMinHealth(keys)
	return self.min_health or 0
end

function icebreaker_u_modifier_zero:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	self.min_health = self.min_health - 1
end

function icebreaker_u_modifier_zero:OnIntervalThink()
	self:StartExplosionThink(self.ability:GetAOERadius())
	self:StartExplosionThink(self.ability:GetAOERadius())
end

function icebreaker_u_modifier_zero:StartExplosionThink(radius)
	local point = self.parent:GetOrigin()
	local explosion_damage = 25
	local explosion_radius = (radius * 0.2)

	local random_x
	local random_y

	local quarter = RandomInt(1,4)
	if quarter == 1 then
		random_x = RandomInt(-radius, radius)
		if random_x > 0 then
			random_y = RandomInt(-radius, 0)
		else
			random_y = RandomInt(-radius, 1)
		end
	elseif quarter == 2 then
		random_x = RandomInt(-radius, radius)
		if random_x > 0 then
			random_y = RandomInt(1, radius)
		else
			random_y = RandomInt(0, radius)
		end
	elseif quarter == 3 then
		random_y = RandomInt(-radius, radius)
		if random_y > 0 then
			random_x = RandomInt(-radius, 0)
		else
			random_x = RandomInt(-radius, 1)
		end
	elseif quarter == 4 then
		random_y = RandomInt(-radius, radius)
		if random_y > 0 then
			random_x = RandomInt(1, radius)
		else
			random_x = RandomInt(0, radius)
		end
	end

	local x = self:CalculateAngle(random_x, random_y)
	local y = self:CalculateAngle(random_y, random_x)

	point.x = point.x + x
	point.y = point.y + y

	local damageTable = {
		-- victim = target,
		attacker = self.caster,
		damage = explosion_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), point, nil, explosion_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(self.caster, self.ability, "icebreaker_1_modifier_instant", {duration = 0.1})
		damageTable.victim = enemy
		ApplyDamage(damageTable)
	end

	self:PlayEfxExplosion(point)
end

function icebreaker_u_modifier_zero:CalculateAngle(a, b)
    if a < 0 then
        if b > 0 then b = -b end
    else
		if b < 0 then b = -b end
    end
    return a - math.floor(b/4)
end

--------------------------------------------------------------------------------

function icebreaker_u_modifier_zero:GetEffectName()
	return "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf"
end

function icebreaker_u_modifier_zero:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_u_modifier_zero:PlayEfxStart(radius)
	local particle_1 = "particles/icebreaker/icebreaker_zero.vpcf"

	self.effect_cast = ParticleManager:CreateParticle(particle_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(radius, radius, radius * (radius * 0.002)))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	local particle_cast = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ambient.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Icebreaker.Zero.Loop") end
end

function icebreaker_u_modifier_zero:PlayEfxExplosion( point )
	local particle_cast = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, point)

	if IsServer() then self.parent:EmitSoundParams("hero_Crystal.freezingField.explosion", 1, 0.6, 0) end
end