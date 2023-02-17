flea_3_modifier_jump = class({})

function flea_3_modifier_jump:IsHidden() return true end
function flea_3_modifier_jump:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_3_modifier_jump:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
  self.ability = self:GetAbility()

	local movespeed = self.parent:GetIdealSpeed()
	local jump_speed = self.ability:GetSpecialValueFor("speed_mult") --* movespeed
	local jump_distance = self.ability:GetSpecialValueFor("distance_mult") --* movespeed
	local duration = jump_distance / jump_speed
	local height = 80 + math.floor(movespeed / 3)

	self.radius = self.ability:GetSpecialValueFor("radius")
	self.radius_impact = self.ability:GetSpecialValueFor("radius_impact")

	self.arc = self.parent:AddNewModifier(
		self.parent, self.ability,
		"_modifier_generic_arc",
		{
			speed = jump_speed,
			duration = duration,
			distance = jump_distance,
			height = height,
		}
	)

	self.arc:SetEndCallback(function( interrupted )
		if self:IsNull() then return end
		self.arc = nil
		self:Destroy()
	end)

	if IsServer() then
		self:SetDuration(duration, true)
		self.ability:SetActivated(false)
		self:StartIntervalThink(0.1)
		self:OnIntervalThink()
		self:PlayEfxStart(duration)
	end
end

function flea_3_modifier_jump:OnRefresh(kv)
end

function flea_3_modifier_jump:OnRemoved()
	if IsServer() then self.parent:EmitSound("Hero_Slark.Pounce.Impact.Immortal") end
end

function flea_3_modifier_jump:OnDestroy()
	self.ability:SetActivated(true)

	GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), self.radius_impact, false)

	if self.arc and not self.arc:IsNull() then
		self.arc:Destroy()
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_3_modifier_jump:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function flea_3_modifier_jump:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
	)

	for _,enemy in pairs(enemies) do
		self:PerformImpact(enemy:GetOrigin())
		break
	end
end

-- UTILS -----------------------------------------------------------

function flea_3_modifier_jump:PerformImpact(point)
	self.parent:FadeGesture(ACT_DOTA_SLARK_POUNCE)

	local bleeding_duration = self.ability:GetSpecialValueFor("special_bleeding_duration")
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), point, nil, self.radius_impact,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
	)

	for _,enemy in pairs(enemies) do
		if enemy:HasModifier("bloodstained_u_modifier_copy") == false
		and enemy:IsIllusion() then
			enemy:ForceKill(false)
		else
			self:PlayEfxHit(enemy)
			self.parent:PerformAttack(enemy, false, true, true, true, false, false, true)

			enemy:AddNewModifier(self.caster, self.ability, "_modifier_silence", {
				duration = CalcStatus(self.ability:GetSpecialValueFor("silence_duration"), self.caster, enemy),
				special = 3
			})

			if bleeding_duration > 0 then
				enemy:AddNewModifier(self.caster, self.ability, "flea_3_modifier_bleeding", {
					duration = CalcStatus(bleeding_duration, self.caster, enemy)
				})
			end
		end
	end

	CreateModifierThinker(
		self.caster, self.ability, "flea_3_modifier_effect", {duration = 2, radius = self.radius_impact},
		GetGroundPosition(self.parent:GetOrigin(), nil), self.caster:GetTeamNumber(), false
	)

	self:Destroy()
end

-- EFFECTS -----------------------------------------------------------

function flea_3_modifier_jump:GetEffectName()
	return "particles/econ/items/slark/slark_ti6_blade/slark_ti6_pounce_trail.vpcf"
end

function flea_3_modifier_jump:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function flea_3_modifier_jump:PlayEfxStart(duration)
	local particle_cast = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_pounce_start.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("Hero_Slark.Pounce.Cast.Immortal") end
	self.parent:StartGestureWithPlaybackRate(ACT_DOTA_SLARK_POUNCE, (0.85 / duration))
end

function flea_3_modifier_jump:PlayEfxHit(target)
	local string = "particles/units/heroes/hero_riki/riki_backstab.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then target:EmitSound("Hero_Riki.Backstab") end
end