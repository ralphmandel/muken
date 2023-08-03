genuine_4_modifier_aura = class({})

function genuine_4_modifier_aura:IsHidden() return true end
function genuine_4_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function genuine_4_modifier_aura:IsAura() return true end
function genuine_4_modifier_aura:GetModifierAura() return "genuine_4_modifier_aura_effect" end
function genuine_4_modifier_aura:GetAuraRadius() return -1 end
function genuine_4_modifier_aura:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function genuine_4_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function genuine_4_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

function genuine_4_modifier_aura:GetAuraEntityReject(hEntity)
  return (self:GetParent() ~= hEntity)
end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_4_modifier_aura:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  --if IsServer() then self:OnIntervalThink() end
end

function genuine_4_modifier_aura:OnRefresh(kv)
end

function genuine_4_modifier_aura:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- function genuine_4_modifier_aura:OnIntervalThink()
--   if GameRules:IsDaytime() == false or GameRules:IsTemporaryNight() then
--     self.ability:SetCurrentAbilityCharges(GENUINE_UNDER_NIGHT)
--   else
--     self.ability:SetCurrentAbilityCharges(GENUINE_UNDER_DAY)
--   end

--   if IsServer() then self:StartIntervalThink(FrameTime()) end
-- end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------