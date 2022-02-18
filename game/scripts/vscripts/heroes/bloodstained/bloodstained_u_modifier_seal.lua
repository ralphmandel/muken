bloodstained_u_modifier_seal = class({})

--------------------------------------------------------------------------------

function bloodstained_u_modifier_seal:OnCreated()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.radius = self.ability:GetSpecialValueFor("radius")
	self:StartIntervalThink( 0.1 )
	self:PlayEfxStart()

	AddFOWViewer(self.caster:GetTeam(), self.parent:GetOrigin(), self.radius, self:GetDuration(), false)
	GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), self.radius, true)
end

function bloodstained_u_modifier_seal:OnRemoved()
	if self.effect_cast2 ~= nil then ParticleManager:DestroyParticle(self.effect_cast2, false) end
	if IsServer() then self.parent:StopSound("bloodstained.Seal") end
end

--------------------------------------------------------------------------------

function bloodstained_u_modifier_seal:OnIntervalThink()
	self:PlayEfxLoop()

	local flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		flag,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

    for _,unit in pairs(units) do
		if unit:IsIllusion() == false
		and unit:HasModifier("bloodstained_u_modifier_status") == false then
			unit:AddNewModifier(self.caster, self.ability, "bloodstained_u_modifier_status", {})
		end
	end
end

--------------------------------------------------------------------------------

function bloodstained_u_modifier_seal:PlayEfxStart()

	local point = self.parent:GetAbsOrigin()
	point.z = point.z - 2

	local particle_cast = "particles/bloodstained/bloodstained_u_bubbles.vpcf"
    self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast, 0, point )
	--ParticleManager:SetParticleControl( self.effect_cast, 1, Vector( self.radius, self.radius, self.radius ) )

	local particle_cast2 = "particles/bloodstained/bloodstained_seal_war.vpcf"
    local effect_cast2 = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( effect_cast2, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast2, 1, Vector( self.radius, self.radius, self.radius ) )
	
	-- buff particle
	self:AddParticle(
		effect_cast2,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
    )

	local particle_cast3 = "particles/bloodstained/bloodstained_seal_impact.vpcf"
    local effect_cast3 = ParticleManager:CreateParticle( particle_cast3, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( effect_cast3, 0, self.parent:GetOrigin() )

	if IsServer() then self.parent:EmitSound("bloodstained.seal") end
end

function bloodstained_u_modifier_seal:PlayEfxLoop()
	local point = self.parent:GetAbsOrigin()
	local particle_cast = "particles/bloodstained/bloodstained_field_replica.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, point)
end