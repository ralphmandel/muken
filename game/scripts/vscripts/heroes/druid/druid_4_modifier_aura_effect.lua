druid_4_modifier_aura_effect = class({})

function druid_4_modifier_aura_effect:IsHidden()
	return false
end

function druid_4_modifier_aura_effect:IsPurgable()
	return false
end

function druid_4_modifier_aura_effect:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_4_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.aspd = self.ability:GetSpecialValueFor("aspd")

	-- UP 4.21
	if self.ability:GetRank(21) then
		self.aspd = self.aspd + 10
	end
end

function druid_4_modifier_aura_effect:OnRefresh(kv)
end

function druid_4_modifier_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_4_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function druid_4_modifier_aura_effect:GetModifierAttackSpeedPercentage()
    return self.aspd
end

function druid_4_modifier_aura_effect:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end

	-- UP 4.21
	if self.ability:GetRank(21) then
		local heal = keys.original_damage * 0.1
		keys.attacker:Heal(heal, self.ability)
		self:PlayEfxLifesteal(keys.attacker)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_4_modifier_aura_effect:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end

function druid_4_modifier_aura_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function druid_4_modifier_aura_effect:PlayEfxLifesteal(attacker)
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(effect_cast, 1, attacker:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end