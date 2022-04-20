druid_u_modifier_aura = class({})

function druid_u_modifier_aura:IsHidden()
	return true
end

function druid_u_modifier_aura:IsPurgable()
	return false
end

function druid_u_modifier_aura:IsAura()
	return (not self:GetCaster():PassivesDisabled())
end

function druid_u_modifier_aura:GetModifierAura()
	return "druid_u_modifier_aura_effect"
end

function druid_u_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function druid_u_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function druid_u_modifier_aura:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

--------------------------------------------------------------------------------

function druid_u_modifier_aura:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.extra_hp = self.ability:GetSpecialValueFor("extra_hp")
	self.heal_amp = self.ability:GetSpecialValueFor("heal_amp")

	if IsServer() then
		self:PlayEfxStart()
	end
end

function druid_u_modifier_aura:OnRefresh(kv)
end

function druid_u_modifier_aura:OnRemoved()
end

--------------------------------------------------------------------------------

-- function druid_u_modifier_aura:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_MAGIC_IMMUNE] = true
-- 	}

-- 	return state
-- end

function druid_u_modifier_aura:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET
	}

	return funcs
end

function druid_u_modifier_aura:GetModifierExtraHealthBonus()
    return self.extra_hp
end

function druid_u_modifier_aura:GetModifierHealAmplify_PercentageTarget()
    return self.heal_amp
end

--------------------------------------------------------------------------------

function druid_u_modifier_aura:PlayEfxStart()
	local string = "particles/druid/druid_ult_passive.vpcf"
	local effect_aura = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_aura, 0, self.parent:GetOrigin())
	self:AddParticle(effect_aura, false, false, -1, false, false)

	-- local string2 = "particles/druid/druid_seed_buff.vpcf"
	-- local effect_cast = ParticleManager:CreateParticle(string2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	-- ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	-- ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	-- self:AddParticle(effect_cast, false, false, -1, false, false)
end