icebreaker_2_modifier_path = class({})

function icebreaker_2_modifier_path:IsHidden() return true end
function icebreaker_2_modifier_path:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_2_modifier_path:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	
  self.distance = self.ability:GetSpecialValueFor("distance")
	self.vision_radius = self.ability:GetSpecialValueFor("radius") + 25
	self.radius = self.ability:GetSpecialValueFor("radius")
	self.duration = kv.lifetime
	self.delay = 0.5
	self.delayed = true
	self.targets = {}

	local start_range = 12
	self.direction = Vector( kv.x, kv.y, 0 )
	self.startpoint = self.parent:GetOrigin() + self.direction + start_range
	self.endpoint = self.startpoint + self.direction * self.distance

	self:StartIntervalThink(self.delay)
	self:PlayEfxStart()
end

function icebreaker_2_modifier_path:OnRefresh( kv )
end

function icebreaker_2_modifier_path:OnRemoved()
end

function icebreaker_2_modifier_path:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_2_modifier_path:OnIntervalThink()
	if self.delayed then
		self.delayed = false
		self:SetDuration(self.duration, false)
		
		local step = 0
		while step < self.distance do
			local loc = self.startpoint + self.direction * step
			GridNav:DestroyTreesAroundPoint( loc, self.radius, true )
			AddFOWViewer(self.caster:GetTeamNumber(), loc, self.vision_radius, self.duration, false)
			step = step + self.radius
		end

		self:StartIntervalThink(0.25)
		return
	end

	local units = FindUnitsInLine(
		self.caster:GetTeamNumber(), self.startpoint, self.endpoint, nil, self.radius,
		DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE
	)

  for _,unit in pairs(units) do
		if unit:GetTeamNumber() == self.caster:GetTeamNumber() then
			unit:AddNewModifier(self.caster, self.ability, "_modifier_path", {duration = 1})
		else
			if unit:HasModifier("icebreaker__modifier_frozen") == false then
				unit:AddNewModifier(self.caster, self.ability, "icebreaker__modifier_hypo", {
					duration = 1, stack_min = self.ability:GetSpecialValueFor("stack_min")
				})
			end
		end
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker_2_modifier_path:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.startpoint)
	ParticleManager:SetParticleControl(effect_cast, 1, self.endpoint)
	ParticleManager:SetParticleControl(effect_cast, 2, Vector( 0, 0, self.delay ))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	local particle_castb = "particles/units/heroes/hero_jakiro/jakiro_ice_path_b.vpcf" 
	local effect_castb = ParticleManager:CreateParticle(particle_castb, PATTACH_WORLDORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_castb, 0, self.startpoint)
	ParticleManager:SetParticleControl(effect_castb, 1, self.endpoint)
	ParticleManager:SetParticleControl(effect_castb, 2, Vector(self.delay + self.duration, 0, 0))
	ParticleManager:SetParticleControl(effect_castb, 9, self.startpoint)
	ParticleManager:SetParticleControlEnt(effect_castb, 9, self.caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_castb)

	if IsServer() then self.parent:EmitSound("Hero_Jakiro.IcePath") end
end