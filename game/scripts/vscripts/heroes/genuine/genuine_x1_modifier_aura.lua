genuine_x1_modifier_aura = class({})

function genuine_x1_modifier_aura:IsHidden()
	return false
end

function genuine_x1_modifier_aura:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function genuine_x1_modifier_aura:IsAura()
	return (not self:GetCaster():PassivesDisabled())
end

function genuine_x1_modifier_aura:GetModifierAura()
	return "genuine_x1_modifier_aura_effect"
end

function genuine_x1_modifier_aura:GetAuraRadius()
	return self:GetAbility():GetCastRange(nil, nil)
end

function genuine_x1_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function genuine_x1_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function genuine_x1_modifier_aura:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.start_night = false

	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function genuine_x1_modifier_aura:OnRefresh(kv)
end

function genuine_x1_modifier_aura:OnRemoved(kv)
end

--------------------------------------------------------------------------------

function genuine_x1_modifier_aura:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION_UNIQUE
	}

	return funcs
end

function genuine_x1_modifier_aura:GetBonusNightVisionUnique()
	return self:GetAbility():GetSpecialValueFor("bonus_vision")
end

function genuine_x1_modifier_aura:OnIntervalThink()
	if GameRules:IsDaytime() then
		if self.ability:IsActivated() then self.ability:SetActivated(false) end
		self.start_night = false

		local mod = self.parent:FindAllModifiersByName("_modifier_invisible")
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self.ability then modifier:Destroy() end
		end
	else
		if self.start_night == false then
			self.start_night = true
			self.ability:SetActivated(true)
		end
	end
end

--------------------------------------------------------------------------------

function genuine_x1_modifier_aura:GetEffectName()
	return "particles/econ/events/diretide_2020/emblem/fall20_emblem_v2_effect.vpcf"
end

function genuine_x1_modifier_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end