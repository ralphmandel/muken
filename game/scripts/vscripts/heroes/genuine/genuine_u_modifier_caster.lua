genuine_u_modifier_caster = class({})

function genuine_u_modifier_caster:IsHidden()
	return false
end

function genuine_u_modifier_caster:IsPurgable()
	return false
end

-----------------------------------------------------------

function genuine_u_modifier_caster:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function genuine_u_modifier_caster:OnRefresh(kv)
end

function genuine_u_modifier_caster:OnRemoved(kv)
end

-----------------------------------------------------------

function genuine_u_modifier_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
		MODIFIER_EVENT_ON_HERO_KILLED
	}
	
	return funcs
end

function genuine_u_modifier_caster:GetModifierOverrideAttackDamage(keys)
	if keys.target == nil then return 0 end
	if keys.target:IsBaseNPC() == false then return 0 end
	if keys.target:HasModifier("genuine_u_modifier_target") then return 0 end
	return 1
end

function genuine_u_modifier_caster:GetAbsoluteNoDamagePhysical(keys)
	if keys.attacker == nil then return 0 end
	if keys.attacker:IsBaseNPC() == false then return 0 end
	if keys.attacker:HasModifier("genuine_u_modifier_target") then return 0 end
	return 1
end

function genuine_u_modifier_caster:GetAbsoluteNoDamageMagical(keys)
	if keys.attacker == nil then return 0 end
	if keys.attacker:IsBaseNPC() == false then return 0 end
	if keys.attacker:HasModifier("genuine_u_modifier_target") then return 0 end
	return 1
end

function genuine_u_modifier_caster:GetAbsoluteNoDamagePure(keys)
	if keys.attacker == nil then return 0 end
	if keys.attacker:IsBaseNPC() == false then return 0 end
	if keys.attacker:HasModifier("genuine_u_modifier_target") then return 0 end
	return 1
end

function genuine_u_modifier_caster:OnHeroKilled(keys)
	if keys.target == nil then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.target:HasModifier("genuine_u_modifier_target") == false then return end

	self.ability:EndCooldown()
end

-----------------------------------------------------------

function genuine_u_modifier_caster:PlayEfxBuff()
	if self.effect_caster then ParticleManager:DestroyParticle(self.effect_caster, true) end

	local particle = "particles/genuine/morning_star/genuine_morning_star.vpcf"
	self.effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_caster, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 1, self.parent:GetOrigin())
	self:AddParticle(self.effect_caster, false, false, -1, false, false)
end