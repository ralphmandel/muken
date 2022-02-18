icebreaker_u_modifier_zero = class({})

function icebreaker_u_modifier_zero:IsHidden()
	return false
end

function icebreaker_u_modifier_zero:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function icebreaker_u_modifier_zero:OnCreated( kv )
	self.caster = self:GetCaster():GetOwner()
	self.parent = self:GetParent()
	self.ability = self.caster:FindAbilityByName("icebreaker_u__zero")

	local duration = self.ability:GetSpecialValueFor("duration")
	self.radius = self.ability:GetSpecialValueFor("radius")
	self.true_vision = false
	self.delay = true
	self.time_buff = 0
	local vision_bonus = 0

	self.caster:AddNewModifier(self.caster, self.ability, "icebreaker_u_modifier_buff", {})

	-- UP 4.6
	if self.ability:GetRank(6) then
		self.true_vision = true
		self.radius = 1500
		vision_bonus = 100
	end

	if IsServer() then
		self:SetStackCount(vision_bonus)
	end

	self:SetDuration(self.ability:CalcStatus(duration, self.caster, nil), true)
	self:StartIntervalThink(0.1)
	self:PlayEffects2()
end

function icebreaker_u_modifier_zero:OnRefresh( kv )
end

function icebreaker_u_modifier_zero:OnRemoved()
	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end
	self.caster:RemoveModifierByName("icebreaker_u_modifier_buff")

	if IsValidEntity(self.parent) then
		if IsServer() then
			self.parent:EmitSound("Ability.FrostNova")
			self.parent:StopSound("Hero_Lich.ChainFrostLoop.TI8")
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
		MODIFIER_PROPERTY_AVOID_DAMAGE,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
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

function icebreaker_u_modifier_zero:GetModifierAvoidDamage()
	return 1
end

function icebreaker_u_modifier_zero:OnAttackLanded(keys)
	if keys.target == self.parent then
		local value = self.parent:GetHealth() - 1
		self.parent:ModifyHealth(value, self.ability, true, 0)
	end
end

function icebreaker_u_modifier_zero:OnIntervalThink()
	self.time_buff = self.time_buff + 1
	if self.delay then
		self.parent:ModifyHealth(100, self.ability, false, 0)
		self.delay = false
		self:PlayEffects()
	end

	-- check caster in radius
	if self.parent:GetRangeToUnit(self.caster) > self.radius then
		self.parent:Kill(self.ability, nil)
		return
	end

	-- inflicts frost stacks
	self.enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		16,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(self.enemies) do
		-- UP 4.4
		if self.ability:GetRank(4)
		or enemy:IsMagicImmune() == false then
			local ability_slow = self.caster:FindAbilityByName("icebreaker_0__slow")
			if ability_slow then
				if ability_slow:IsTrained() then
					ability_slow:AddSlow(enemy, self.ability)
				end
			end
		end

		-- UP 4.3
		if self.ability:GetRank(3) then
			enemy:AddNewModifier(self.caster, self.ability, "icebreaker_u_modifier_degen", {duration = 1})
		end
	end

	local heroes = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,hero in pairs(heroes) do
		if hero:HasModifier("icebreaker_0_modifier_illusion")
		or hero == self.caster then
			hero:AddNewModifier(self.caster, self.ability, "_modifier_no_bar", {duration = 1})
		end
	end

	-- UP 4.5
	if self.ability:GetRank(5) then
		local explosion_interval = (3000 / self.radius)
		if self.time_buff % explosion_interval == 0 then
			self:StartExplosionThink()
		end
	end
end

function icebreaker_u_modifier_zero:StartExplosionThink()
	local point = self.parent:GetOrigin()
	local explosion_damage = 45
	local explosion_radius = (self.radius * 0.2)

	local random_x
	local random_y

	local quarter = RandomInt(1,4)
	if quarter == 1 then
		random_x = RandomInt(-self.radius, self.radius)
		if random_x > 0 then
			random_y = RandomInt(-self.radius, 0)
		else
			random_y = RandomInt(-self.radius, 1)
		end
	elseif quarter == 2 then
		random_x = RandomInt(-self.radius, self.radius)
		if random_x > 0 then
			random_y = RandomInt(1, self.radius)
		else
			random_y = RandomInt(0, self.radius)
		end
	elseif quarter == 3 then
		random_y = RandomInt(-self.radius, self.radius)
		if random_y > 0 then
			random_x = RandomInt(-self.radius, 0)
		else
			random_x = RandomInt(-self.radius, 1)
		end
	elseif quarter == 4 then
		random_y = RandomInt(-self.radius, self.radius)
		if random_y > 0 then
			random_x = RandomInt(1, self.radius)
		else
			random_x = RandomInt(0, self.radius)
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
		ability = self.ability, --Optional.
	}

	-- Explode at point
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		point,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		explosion_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	-- damage units
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(self.caster, self.ability, "icebreaker_1_modifier_instant", {duration = 0.3})
		damageTable.victim = enemy
		ApplyDamage(damageTable)

		--if enemy:GetUnitName() == "npc_dota_hero_pudge" then self.temp = self.temp + 1 end
	end

	-- Play effects
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

function icebreaker_u_modifier_zero:PlayEffects()
	local particle_1 = "particles/icebreaker/icebreaker_zero.vpcf"

	self.effect_cast = ParticleManager:CreateParticle(particle_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector( self.radius, self.radius, self.radius * (self.radius * 0.002)))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Lich.ChainFrostLoop.TI8") end
end

function icebreaker_u_modifier_zero:PlayEffects2()
	local particle_cast = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ambient.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)
end

function icebreaker_u_modifier_zero:PlayEfxExplosion( point )
	local particle_cast = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, point)

	if IsServer() then self.parent:EmitSoundParams("hero_Crystal.freezingField.explosion", 1, 0.6, 0) end
end