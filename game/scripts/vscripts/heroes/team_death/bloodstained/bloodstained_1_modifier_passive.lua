bloodstained_1_modifier_passive = class({})

function bloodstained_1_modifier_passive:IsHidden() return true end
function bloodstained_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddStatusEfx(self.ability, "bloodstained_1_modifier_passive_status_efx", self.caster, self.parent)
end

function bloodstained_1_modifier_passive:OnRefresh(kv)
end

function bloodstained_1_modifier_passive:OnRemoved()
  RemoveStatusEfx(self.ability, "bloodstained_1_modifier_passive_status_efx", self.caster, self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained_1_modifier_passive:GetStatusEffectName()
  return "particles/bloodstained/status_efx/status_effect_bloodstained.vpcf"
end

function bloodstained_1_modifier_passive:StatusEffectPriority()
return MODIFIER_PRIORITY_NORMAL
end