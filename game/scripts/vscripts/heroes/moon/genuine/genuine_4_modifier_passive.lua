genuine_4_modifier_passive = class({})

function genuine_4_modifier_passive:IsHidden() return true end
function genuine_4_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_4_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:OnIntervalThink() end
end

function genuine_4_modifier_passive:OnRefresh(kv)
end

function genuine_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}
	
	return funcs
end

function genuine_4_modifier_passive:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("night_vision")
end

function genuine_4_modifier_passive:OnIntervalThink()
  if GameRules:IsDaytime() == false or GameRules:IsTemporaryNight() then
    self.ability:SetCurrentAbilityCharges(GENUINE_UNDER_NIGHT)
  else
    self.ability:SetCurrentAbilityCharges(GENUINE_UNDER_DAY)
  end

  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------