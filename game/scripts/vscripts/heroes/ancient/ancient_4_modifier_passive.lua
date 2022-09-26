ancient_4_modifier_passive = class({})

function ancient_4_modifier_passive:IsHidden()
	return true
end

function ancient_4_modifier_passive:IsPurgable()
	return false
end

function ancient_4_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_4_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.status_resist = self.ability:GetSpecialValueFor("status_resist")
end

function ancient_4_modifier_passive:OnRefresh(kv)
	-- UP 4.11
	if self.ability:GetRank(11) then
		self.status_resist = self.ability:GetSpecialValueFor("status_resist") + 10
	end
end

function ancient_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function ancient_4_modifier_passive:GetModifierStatusResistanceStacking()
	if self:GetParent():PassivesDisabled() then return 0 end
	return self.status_resist
end

function ancient_4_modifier_passive:GetBonusDayVision()
	if self:GetParent():PassivesDisabled() then return 0 end

	if self.ability:GetCurrentAbilityCharges() % 2 == 0 then
		return 300
	end

	return 0
end

function ancient_4_modifier_passive:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	local ult = self.parent:FindAbilityByName("ancient_u__final")
	if ult == nil then return end
	if ult:IsTrained() == false then return end

	-- UP 4.21
	if self.ability:GetRank(21) then
		ult:AddEnergy(self.ability, keys.attaker)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_4_modifier_passive:GetEffectName()
	return "particles/ancient/flesh/ancient_flesh_lvl2.vpcf"
end

function ancient_4_modifier_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end