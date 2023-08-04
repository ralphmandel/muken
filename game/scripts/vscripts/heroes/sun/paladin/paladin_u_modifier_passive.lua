paladin_u_modifier_passive = class({})

function paladin_u_modifier_passive:IsHidden() return true end
function paladin_u_modifier_passive:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function paladin_u_modifier_passive:IsAura() return true end
function paladin_u_modifier_passive:GetModifierAura() return "paladin_u_modifier_aura_effect" end
function paladin_u_modifier_passive:GetAuraRadius() return -1 end
function paladin_u_modifier_passive:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function paladin_u_modifier_passive:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function paladin_u_modifier_passive:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddBonus(self.ability, "CON", self.parent, 0, self.ability:GetSpecialValueFor("con"), nil)
end

function paladin_u_modifier_passive:OnRefresh(kv)
end

function paladin_u_modifier_passive:OnRemoved()
  RemoveBonus(self.ability, "CON", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------