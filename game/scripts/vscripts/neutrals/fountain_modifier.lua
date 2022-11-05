fountain_modifier = class({})

function fountain_modifier:IsHidden()
	return false
end

function fountain_modifier:IsPurgable()
    return false
end

function fountain_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

    self.hp_percent = self.ability:GetSpecialValueFor("hp_percent") * 0.01
    self.mp_percent = self.ability:GetSpecialValueFor("mp_percent") * 0.01
    self.radius = self.ability:GetSpecialValueFor("radius")

	self:StartIntervalThink(0.25)
	--self:PlayEfxStart()
end

function fountain_modifier:OnRefresh( kv )
end

function fountain_modifier:OnRemoved()
	ParticleManager:DestroyParticle(self.pfx, true)
	self.pfx = nil
end

--------------------------------------------------------------------------------------------------------------------------

function fountain_modifier:OnIntervalThink()
	-- if GameRules:IsDaytime() then

	-- else
	-- 	if self.pfx ~= nil then
	-- 		ParticleManager:DestroyParticle(self.pfx, true)
	-- 		self.pfx = nil
	-- 	end
	-- end

	if self.pfx == nil then self:PlayEfxStart() end
	local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
	local units = FindUnitsInRadius(
		self.parent:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		flags,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	for _,unit in pairs(units) do
		if GameRules:IsDaytime() then
			unit:AddNewModifier(self.caster, self.ability, "_modifier_truesight", {duration = 0.3})
			local heal = self.hp_percent * unit:GetMaxHealth() * 0.2
			unit:Heal(heal, self.ability)
			self:PlayEfxHeal(unit)
		else
			local recovery = self.mp_percent * unit:GetMaxMana() * 0.3
			if unit:GetUnitName() == "npc_dota_hero_elder_titan" then recovery = 1 end
			unit:GiveMana(recovery)
			self:PlayEfxMana(unit)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, unit, recovery, unit)
		end
	end

	if GameRules:IsDaytime() then
		AddFOWViewer(DOTA_TEAM_CUSTOM_1, self.parent:GetOrigin(), self.radius, 1, true)
		AddFOWViewer(DOTA_TEAM_CUSTOM_2, self.parent:GetOrigin(), self.radius, 1, true)
		AddFOWViewer(DOTA_TEAM_CUSTOM_3, self.parent:GetOrigin(), self.radius, 1, true)
		AddFOWViewer(DOTA_TEAM_CUSTOM_4, self.parent:GetOrigin(), self.radius, 1, true)
		AddFOWViewer(DOTA_TEAM_CUSTOM_5, self.parent:GetOrigin(), self.radius, 1, true)
	end
end

--------------------------------------------------------------------------------------------------------------------------

function fountain_modifier:PlayEfxStart()
	self.pfx = ParticleManager:CreateParticle(
		"particles/econ/events/ti7/fountain_regen_ti7_lvl3.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self:GetParent()
	)

	-- ParticleManager:CreateParticle(
	-- 	"particles/econ/events/fall_major_2016/radiant_fountain_regen_fm06_lvl3.vpcf",
	-- 	PATTACH_ABSORIGIN_FOLLOW,
	-- 	self:GetParent()
	-- )
end

function fountain_modifier:PlayEfxHeal(target)
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 1, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

function fountain_modifier:PlayEfxMana(target)
	local particle_cast = "particles/generic/give_mana.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 1, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end