genuine_3_modifier_passive = class({})

function genuine_3_modifier_passive:IsHidden()
	return false
end

function genuine_3_modifier_passive:IsPurgable()
	return false
end

-----------------------------------------------------------

function genuine_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(0) end
end

function genuine_3_modifier_passive:OnRefresh(kv)
end

function genuine_3_modifier_passive:OnRemoved(kv)
end

-----------------------------------------------------------

function genuine_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED
	}
	
	return funcs
end

function genuine_3_modifier_passive:OnHeroKilled(keys)
	if keys.attacker == nil or keys.target == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	self.ability:AddKillPoint(1)
	self:SetStackCount(self.ability.kills)
end

-----------------------------------------------------------

function genuine_3_modifier_passive:PlayEfxBuff()
	if self.effect_caster then ParticleManager:DestroyParticle(self.effect_caster, true) end

	local particle = "particles/genuine/morning_star/genuine_morning_star.vpcf"
	self.effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_caster, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 1, self.parent:GetOrigin())
	self:AddParticle(self.effect_caster, false, false, -1, false, false)
end

function genuine_3_modifier_passive:StopEfxBuff()
	if self.effect_caster then ParticleManager:DestroyParticle(self.effect_caster, false) end
end