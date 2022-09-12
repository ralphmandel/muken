druid_u_modifier_channel = class({})

function druid_u_modifier_channel:IsHidden()
	return true
end

function druid_u_modifier_channel:IsPurgable()
	return false
end

function druid_u_modifier_channel:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_u_modifier_channel:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.interval = self.ability:GetSpecialValueFor("interval")

	if IsServer() then
		self:StartIntervalThink(self.interval)
		self:SoundLoop(self.parent)
		self:PlayEfxStart()
	end
end

function druid_u_modifier_channel:OnRefresh(kv)
end

function druid_u_modifier_channel:OnRemoved()
	if self.efx_channel then ParticleManager:DestroyParticle(self.efx_channel, false) end
	if self.efx_channel2 then ParticleManager:DestroyParticle(self.efx_channel2, false) end
	if self.fow then RemoveFOWViewer(self.parent:GetTeamNumber(), self.fow) end
	if IsServer() then self.parent:StopSound("Druid.Channel") end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_u_modifier_channel:OnIntervalThink()
	local chance_lvl = self.ability:GetSpecialValueFor("chance_lvl")
	local base_stats = self.parent:FindAbilityByName("base_stats")

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.ability.point, nil, self.ability:GetAOERadius(),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_CREEP,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,unit in pairs(units) do
		local unit_lvl = unit:GetLevel()
		local chance = 100 / (unit_lvl * chance_lvl)
		if base_stats then chance = chance * base_stats:GetCriticalChance() end

		if RandomFloat(1, 100) <= chance
		and unit:GetUnitName() ~= "summoner_spider" then
			unit:Purge(false, true, false, false, false)
			unit:AddNewModifier(self.caster, self.ability, "druid_u_modifier_conversion", {})
		end
	end

	self.parent:SpendMana(self.ability:GetManaCost(self.ability:GetLevel()), self.ability)
	if self.parent:GetMana() == 0 then self.parent:InterruptChannel() return end

	if IsServer() then self:StartIntervalThink(self.interval) end
end

-- UTILS -----------------------------------------------------------

function druid_u_modifier_channel:SoundLoop(target)
	self.fow = AddFOWViewer(target:GetTeamNumber(), self.ability.point, self.ability:GetAOERadius(), 3, true)
	if IsServer() then target:EmitSound("Druid.Channel") end

	Timers:CreateTimer((3), function()
		if target then
			if IsValidEntity(target) then
				local mod = target:FindModifierByName("druid_u_modifier_channel")
				if mod then mod:SoundLoop(target) end
			end
		end
	end)
end

-- EFFECTS -----------------------------------------------------------

function druid_u_modifier_channel:PlayEfxStart()
	self.efx_channel = ParticleManager:CreateParticle("particles/druid/druid_skill1_channeling.vpcf", PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(self.efx_channel, 0, self.parent:GetOrigin())

	self.efx_channel2 = ParticleManager:CreateParticle("particles/druid/druid_skill1_channeling.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.efx_channel2, 0, self.ability.point)
	ParticleManager:SetParticleControl(self.efx_channel2, 5, Vector(math.floor(self.ability:GetAOERadius() * 0.1), 0, 0))
end