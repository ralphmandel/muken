flea_3_modifier_jump = class({})

function flea_3_modifier_jump:IsHidden()
	return true
end

function flea_3_modifier_jump:IsPurgable()
	return false
end

function flea_3_modifier_jump:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_3_modifier_jump:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local movespeed = self.parent:GetIdealSpeed()
	local jump_speed = self.ability:GetSpecialValueFor("speed_mult") * movespeed
	local jump_distance = self.ability:GetSpecialValueFor("distance_mult") * movespeed
	local duration = jump_distance/jump_speed
	local height = 80 + math.floor(movespeed / 3)

	self.radius = self.ability:GetSpecialValueFor("radius")
	self.radius_impact = self.ability:GetSpecialValueFor("radius_impact")

	-- UP 3.12
	if self.ability:GetRank(12) then
		self.radius_impact = self.radius_impact + 75
	end

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
		0, FIND_CLOSEST, false
	)

	local target
	for _,enemy in pairs(enemies) do
		if not enemy:IsIllusion() then
			target = enemy
			break
		end
	end
	if not target then return end

	self:PerformImpact()
	self:Destroy()
end

-- UTILS -----------------------------------------------------------

function flea_3_modifier_jump:PerformImpact()
	self.parent:FadeGesture(ACT_DOTA_SLARK_POUNCE)

	local point = self.parent:GetOrigin()
	local ability = self.ability
	local radius_impact = self.radius_impact

	ability:FindTargets(radius_impact, point)

	-- UP 3.22
	if self.ability:GetRank(22) then
		-- TIMERS
        Timers:CreateTimer(0.75, function()
            ability:FindTargets(radius_impact, point)
        end)
	end

	CreateModifierThinker(
		self.caster, self.ability, "flea_3_modifier_effect", {duration = 2, radius = self.radius_impact},
		GetGroundPosition(self.parent:GetOrigin(), nil), self.caster:GetTeamNumber(), false
	)
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