flea_1_modifier_dark_pact = class({})

function flea_1_modifier_dark_pact:IsHidden()
	return true
end

function flea_1_modifier_dark_pact:IsPurgable()
	return false
end

function flea_1_modifier_dark_pact:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_1_modifier_dark_pact:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.pulses = 7

	if IsServer() then
		self:StartIntervalThink(0.1)
		self:PlayEfxStart()
	end
end

function flea_1_modifier_dark_pact:OnRefresh(kv)
	self.pulses = 7

	if IsServer() then
		self:PlayEfxStart()
	end
end

function flea_1_modifier_dark_pact:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_1_modifier_dark_pact:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, 325,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,enemy in pairs(enemies) do
		ApplyDamage({
			damage = 20,
            attacker = self.caster,
            victim = enemy,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.ability
		})
	end

	self.pulses = self.pulses -1
	if self.pulses <= 0 then self:Destroy() return end

	if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function flea_1_modifier_dark_pact:PlayEfxStart()
	local particle_cast = "particles/econ/items/slark/slark_head_immortal/slark_immortal_dark_pact_pulses.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(self.radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("Hero_Slark.DarkPact.Cast.Immortal") end
end