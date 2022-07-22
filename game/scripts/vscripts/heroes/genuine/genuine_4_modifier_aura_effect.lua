genuine_4_modifier_aura_effect = class({})

function genuine_4_modifier_aura_effect:IsHidden()
	return true
end

function genuine_4_modifier_aura_effect:IsPurgable()
	return false
end

function genuine_4_modifier_aura_effect:IsDebuff()
	return true
end

-----------------------------------------------------------

function genuine_4_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()

	if self.caster:IsIllusion() then
		self:SetupAbility()
	else
		self.ability = self:GetAbility()
	end

	local res = self.ability:GetSpecialValueFor("res")

	-- UP 4.41
	if self.ability:GetRank(41) then
		res = res + 10
	end

	self.ability:AddBonus("_2_RES", self.parent, -res, 0, nil)

	if IsServer() then
		self:PlayEfxRadiance()
		self:StartIntervalThink(FrameTime())
	end
end

function genuine_4_modifier_aura_effect:OnRefresh(kv)
end

function genuine_4_modifier_aura_effect:OnRemoved(kv)
	if self.particle then ParticleManager:DestroyParticle(self.particle, false) end
	self.ability:RemoveBonus("_2_RES", self.parent)
end

-----------------------------------------------------------

function genuine_4_modifier_aura_effect:OnIntervalThink()
	if self.particle then ParticleManager:SetParticleControl(self.particle, 1, self.caster:GetAbsOrigin()) end
	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

function genuine_4_modifier_aura_effect:SetupAbility()
	local original_hero = nil
	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then original_hero = base_stats:FindOriginalHero() end
	
	if original_hero then
		self.ability = original_hero:FindAbilityByName(self:GetAbility():GetAbilityName())
	end
end

-----------------------------------------------------------

function genuine_4_modifier_aura_effect:PlayEfxRadiance()
	if self.particle then ParticleManager:DestroyParticle(self.particle, false) end

	local string_2 = "particles/econ/events/ti9/radiance_ti9.vpcf"
	self.particle = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, self.caster:GetAbsOrigin())
	self:AddParticle(self.particle, false, false, -1, false, false)
end