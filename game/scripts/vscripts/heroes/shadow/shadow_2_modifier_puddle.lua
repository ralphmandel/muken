shadow_2_modifier_puddle = class({})

function shadow_2_modifier_puddle:IsHidden()
	return true
end

function shadow_2_modifier_puddle:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function shadow_2_modifier_puddle:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.intervals = self.ability:GetSpecialValueFor("intervals")
	self.ticks = self.ability:GetSpecialValueFor("ticks")
	self.radius = self.ability:GetAOERadius()

	local pull_radius = self.radius
	self.silence = false

	-- UP 2.31
	if self.ability:GetRank(31) then
		pull_radius = pull_radius + 150
		self.silence = true
	end

	-- UP 2.42
	if self.ability:GetRank(42) then
		self.intervals = self.intervals - 0.25
		self.ticks = self.ticks + 4
	end

	if IsServer() then
		self:PullEnemies(pull_radius)
		self:StartIntervalThink(0.3)
	end
end

function shadow_2_modifier_puddle:OnRefresh( kv )
end

function shadow_2_modifier_puddle:OnRemoved()
	if self.fow then RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow) end
end

--------------------------------------------------------------------------------

function shadow_2_modifier_puddle:OnIntervalThink()
	if self.ticks < 1 then
		self:Destroy()
		self:StartIntervalThink(-1)
		return
	end

	self.ticks = self.ticks -1

	self:ApplyPulse()
	self:StartIntervalThink(self.intervals)
end

function shadow_2_modifier_puddle:PullEnemies(pull_radius)
	local point = self.parent:GetOrigin()
	self:PlayEfxPull(pull_radius)

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), point, nil, pull_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
	)

	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(self.caster, self.ability, "shadow_2_modifier_vacuum", {
			duration = 0.3,
			x = point.x,
			y = point.y
		})
	end

	self.fow = AddFOWViewer(self.caster:GetTeamNumber(), point, pull_radius, 10, true)
	GridNav:DestroyTreesAroundPoint(point, pull_radius * 0.8, false)
end

function shadow_2_modifier_puddle:ApplyPulse()
	local point = self.parent:GetOrigin()
	self:PlayEfxPulse(self.radius * 0.65)

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), point, nil, self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,enemy in pairs(enemies) do
		local toxin_ability = self.caster:FindAbilityByName("shadow_0__toxin")
		if toxin_ability ~= nil then
			enemy:AddNewModifier(self.caster, toxin_ability, "shadow_0_modifier_toxin", {})
			enemy:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {duration = 0.5, percent = 100})
		end

		if self.silence then
			self.silence = false
			enemy:AddNewModifier(self.caster, self.ability, "_modifier_silence", {
				duration = self.ability:CalcStatus(5, self.caster, enemy),
			})
		end
	end
end

--------------------------------------------------------------------------------

function shadow_2_modifier_puddle:PlayEfxPulse(radius)
	local particle_cast = "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("Hero_Nightstalker.Void") end
end

function shadow_2_modifier_puddle:PlayEfxPull(pull_radius)
	local particle_cast = "particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(pull_radius, pull_radius, pull_radius))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("Hero_Dark_Seer.Vacuum") end
end