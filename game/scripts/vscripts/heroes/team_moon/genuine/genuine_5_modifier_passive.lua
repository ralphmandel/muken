genuine_5_modifier_passive = class({})

function genuine_5_modifier_passive:IsHidden() return true end
function genuine_5_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_5_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function genuine_5_modifier_passive:OnRefresh(kv)
end

function genuine_5_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_5_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION_UNIQUE,
    MODIFIER_EVENT_ON_ATTACK_START,
	}
	
	return funcs
end

function genuine_5_modifier_passive:GetBonusNightVisionUnique()
	return self:GetAbility():GetSpecialValueFor("night_vision")
end

function genuine_5_modifier_passive:OnAttackStart(keys)
	if keys.attacker ~= self.parent then return end
  if self.ability:GetSpecialValueFor("special_invi") == 0 then return end

  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------