genuine_5_modifier_passive = class({})

function genuine_5_modifier_passive:IsHidden() return true end
function genuine_5_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_5_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.max_mana = self.parent:GetMaxMana()

  if IsServer() then
    self.ability:ResetBarrier()
    self:OnIntervalThink()
  end
end

function genuine_5_modifier_passive:OnRefresh(kv)
end

function genuine_5_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_5_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION_UNIQUE
	}
	
	return funcs
end

function genuine_5_modifier_passive:GetBonusNightVisionUnique()
	return self:GetAbility():GetSpecialValueFor("night_vision")
end

-- UTILS -----------------------------------------------------------

function genuine_5_modifier_passive:OnIntervalThink()
  if self.max_mana ~= self.parent:GetMaxMana() then
    self.ability:ResetBarrier()
    self.max_mana = self.parent:GetMaxMana()
  end

  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- EFFECTS -----------------------------------------------------------