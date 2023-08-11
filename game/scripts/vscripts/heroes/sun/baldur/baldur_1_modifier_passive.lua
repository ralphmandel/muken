baldur_1_modifier_passive = class({})

function baldur_1_modifier_passive:IsHidden() return false end
function baldur_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function baldur_1_modifier_passive:OnRefresh(kv)
end

function baldur_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function baldur_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
	}

	return funcs
end

function baldur_1_modifier_passive:GetModifierProcAttack_Feedback(keys)
  if self.parent:PassivesDisabled() then return end
  if self.ability:GetCurrentAbilityCharges() == 0 then return end

  self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() - 1)

  if IsServer() then self:IncrementStackCount() end
  
  local bonus_modifier = AddBonus(self.ability, "STR", self.parent, 1, 0, self.ability:GetSpecialValueFor("stack_duration"))

  bonus_modifier:SetEndCallback(function(interrupted)
    if IsServer() then self:DecrementStackCount() end
  end)

  if IsServer() then self:PlayEfxHit(keys.target) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function baldur_1_modifier_passive:PlayEfxHit(target)
  if IsServer() then target:EmitSound("Baldur.Hit") end
end