icebreaker_2_modifier_path = class({})

--------------------------------------------------------------------------------

function icebreaker_2_modifier_path:IsHidden()
	return true
end

function icebreaker_2_modifier_path:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function icebreaker_2_modifier_path:OnCreated( kv )
	
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	
    self.range = self:GetAbility():GetSpecialValueFor( "distance" )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
	self.vision_radius = self:GetAbility():GetSpecialValueFor( "vision_radius" )
    self.delay = 0.5
	self.duration = 10
	
	-- set up data
	self.delayed = true
	self.targets = {}
	local start_range = 12

	self.direction = Vector( kv.x, kv.y, 0 )
	self.startpoint = self.parent:GetOrigin() + self.direction + start_range
	self.endpoint = self.startpoint + self.direction * self.range

	-- Start interval
	self:StartIntervalThink( self.delay )

	-- play effects
	self:PlayEffects1()
	self:PlayEffects2()
end

function icebreaker_2_modifier_path:OnRefresh( kv )
end

function icebreaker_2_modifier_path:OnRemoved()
end

function icebreaker_2_modifier_path:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove( self:GetParent() )
end

--------------------------------------------------------------------------------
-- Interval Effects
function icebreaker_2_modifier_path:OnIntervalThink()
	if self.delayed then
		-- after the delay
		self.delayed = false
		self:SetDuration( self.duration, false )
		self:StartIntervalThink( 0.25 )

		-- create vision along line
		local step = 0
		while step < self.range do
			local loc = self.startpoint + self.direction * step
			GridNav:DestroyTreesAroundPoint( loc, self.radius, true )
			AddFOWViewer(
				self.caster:GetTeamNumber(),
				loc,
				self.vision_radius,
				self.duration,
				false
			)

			step = step + self.radius
		end
		return
	end

	-- continuously find units in line
	local heroes = FindUnitsInLine(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.startpoint,	-- point, center point
		self.endpoint,
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		1,	-- int, team filter
		1,	-- int, type filter
		0	-- int, flag filter
	)

    for _,hero in pairs(heroes) do
		if hero:IsIllusion() == false then
			hero:AddNewModifier(self.caster, self.ability, "_modifier_path", {duration = 0.3})

			local mod = hero:FindAllModifiersByName("_modifier_movespeed_buff")
			for _,modifier in pairs(mod) do
				if modifier:GetAbility() == self.ability then modifier:Destroy() end
			end

			hero:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {
				duration = 0.3,
				percent = 30
			})
		end
	end
end

--------------------------------------------------------------------------------

function icebreaker_2_modifier_path:PlayEffects1()
	local particle_cast = "particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.startpoint )
	ParticleManager:SetParticleControl( effect_cast, 1, self.endpoint )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( 0, 0, self.delay ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function icebreaker_2_modifier_path:PlayEffects2()
	local particle_cast = "particles/units/heroes/hero_jakiro/jakiro_ice_path_b.vpcf" 
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.startpoint )
	ParticleManager:SetParticleControl( effect_cast, 1, self.endpoint )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.delay + self.duration, 0, 0 ) )
	ParticleManager:SetParticleControl( effect_cast, 9, self.startpoint )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		9,
		self.caster,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	if IsServer() then self.parent:EmitSound("Hero_Jakiro.IcePath") end
end