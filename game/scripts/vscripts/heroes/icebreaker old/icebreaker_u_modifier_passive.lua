icebreaker_u_modifier_passive = class({})

function icebreaker_u_modifier_passive:IsHidden()
	return true
end

function icebreaker_u_modifier_passive:IsPurgable()
	return false
end

function icebreaker_u_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_u_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function icebreaker_u_modifier_passive:OnRefresh(kv)
end

function icebreaker_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function icebreaker_u_modifier_passive:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.inflictor == nil then return end
	if keys.inflictor:GetAbilityName() ~= "icebreaker_u__blink" then return end

	if self.ability.spell_lifesteal == true then
		local lifesteal = self.ability:GetSpecialValueFor("lifesteal") * 0.01
		local heal = keys.original_damage * lifesteal
		self.parent:Heal(heal, self.ability)
		self:PlayEfxSpellLifesteal(self.parent)
		self.ability.spell_lifesteal = false
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker_u_modifier_passive:PlayEfxSpellLifesteal(target)
	local particle = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)
end