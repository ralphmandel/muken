icebreaker_3_modifier_shard = class({})

function icebreaker_3_modifier_shard:IsHidden() return false end
function icebreaker_3_modifier_shard:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function icebreaker_3_modifier_shard:IsAura() return true end
function icebreaker_3_modifier_shard:GetModifierAura() return "icebreaker_3_modifier_aura_effect" end
function icebreaker_3_modifier_shard:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function icebreaker_3_modifier_shard:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function icebreaker_3_modifier_shard:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function icebreaker_3_modifier_shard:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_3_modifier_shard:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then
		self:PlayEfxStart(self.ability:GetSpecialValueFor("radius"))
		self:OnIntervalThink()
	end
end

function icebreaker_3_modifier_shard:OnRefresh(kv)
end

function icebreaker_3_modifier_shard:OnRemoved()
	if IsServer() then
		self.parent:StopSound("Hero_Icebreaker.Zero.Loop")
		self.parent:EmitSound("Ability.FrostNova")
	end

	if self.parent:IsAlive() then self.parent:Kill(self.ability, nil) end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_3_modifier_shard:CheckState()
	local state = {
		[MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true
	}

	return state
end

function icebreaker_3_modifier_shard:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
		MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_EVENT_ON_DEATH
	}
	
	return funcs
end

function icebreaker_3_modifier_shard:GetModifierIgnorePhysicalArmor()
	return 1
end

function icebreaker_3_modifier_shard:GetDisableHealing()
	return 1
end

function icebreaker_3_modifier_shard:GetVisualZDelta()
	return 350
end

function icebreaker_3_modifier_shard:GetBonusVisionPercentage()
	return self:GetAbility():GetSpecialValueFor("special_bonus_vision")
end

function icebreaker_3_modifier_shard:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("ms_limit")
end

function icebreaker_3_modifier_shard:OnDeath(keys)
	if keys.unit == self.parent then self:Destroy() end
end

function icebreaker_3_modifier_shard:OnIntervalThink()
	self:StartExplosionThink()

	if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

function icebreaker_3_modifier_shard:StartExplosionThink()
	local point = self.parent:GetOrigin()
	local radius = self.ability:GetSpecialValueFor("radius")
	local meteor_damage = self.ability:GetSpecialValueFor("special_meteor_damage")
	local explosion_radius = (radius * 0.2)

	if meteor_damage == 0 then return end

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

	self:PlayEfxExplosion(point)

	Timers:CreateTimer(0.68, function()
		local damageTable = {
			attacker = self.caster,
			damage = meteor_damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability
		}
	
		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(), point, nil, explosion_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			0, 0, false
		)
	
		for _,enemy in pairs(enemies) do
			self:PlayEfxHit(enemy)
			damageTable.victim = enemy
			ApplyDamage(damageTable)
		end
	end)
end

function icebreaker_3_modifier_shard:CalculateAngle(a, b)
    if a < 0 then
        if b > 0 then b = -b end
    else
		if b < 0 then b = -b end
    end
    return a - math.floor(b/4)
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_3_modifier_shard:GetEffectName()
	return "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf"
end

function icebreaker_3_modifier_shard:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_3_modifier_shard:PlayEfxStart(radius)
	local particle_1 = "particles/icebreaker/icebreaker_zero.vpcf"

	self.effect_cast = ParticleManager:CreateParticle(particle_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(radius, radius, radius * (radius * 0.002)))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	local particle_cast = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ambient.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then
		self.parent:EmitSound("Hero_Ancient_Apparition.ColdFeetCast")
		self.parent:EmitSound("Hero_Icebreaker.Zero.Loop")
	end
end

function icebreaker_3_modifier_shard:PlayEfxExplosion(point)
	local particle_cast = "particles/units/heroes/hero_crystalmaiden_persona/cm_persona_freezing_field_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, point)

	if IsServer() then self.parent:EmitSoundParams("hero_Crystal.freezingField.explosion", 1, 0.6, 0) end
end

function icebreaker_3_modifier_shard:PlayEfxHit(enemy)
	local caster = self:GetCaster()
	local hit_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
	ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin())
	ParticleManager:SetParticleControl(hit_pfx, 1, enemy:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(hit_pfx)

	if IsServer() then enemy:EmitSound("Hero_DrowRanger.Marksmanship.Target") end
end