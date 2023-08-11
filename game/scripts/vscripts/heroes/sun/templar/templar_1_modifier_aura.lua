templar_1_modifier_aura = class({})

function templar_1_modifier_aura:IsHidden() return true end
function templar_1_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function templar_1_modifier_aura:IsAura() return true end
function templar_1_modifier_aura:GetModifierAura() return "templar_1_modifier_aura_effect" end
function templar_1_modifier_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function templar_1_modifier_aura:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function templar_1_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function templar_1_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

-- CONSTRUCTORS -----------------------------------------------------------

function templar_1_modifier_aura:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.passives_desabled = false

  if IsServer() then self:StartIntervalThink(0.1) end
end

function templar_1_modifier_aura:OnRefresh(kv)
end

function templar_1_modifier_aura:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function templar_1_modifier_aura:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_STATE_CHANGED
	}

	return funcs
end

function templar_1_modifier_aura:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end

  if self.passives_desabled == false then
    if self.parent:PassivesDisabled() then
      self.passives_desabled = true
      self.ability:UpdateCount()
    end
  else
    if self.parent:PassivesDisabled() == false then
      self.passives_desabled = false
      self.ability:UpdateCount()
    end
  end
end

function templar_1_modifier_aura:OnIntervalThink()
  if GameRules:IsDaytime() and GameRules:IsTemporaryNight() == false then
    self.ability:SetCurrentAbilityCharges(CYCLE_DAY)
  else
    self.ability:SetCurrentAbilityCharges(CYCLE_NIGHT)
  end

  if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------