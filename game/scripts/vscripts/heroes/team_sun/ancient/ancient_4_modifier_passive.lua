ancient_4_modifier_passive = class({})

function ancient_4_modifier_passive:IsHidden() return true end
function ancient_4_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_4_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddBonus(self.ability, "_2_RES", self.parent, self.ability:GetSpecialValueFor("res"), 0, nil)
end

function ancient_4_modifier_passive:OnRefresh(kv)
end

function ancient_4_modifier_passive:OnRemoved()
  RemoveBonus(self.ability, "_2_RES", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_4_modifier_passive:GetEffectName()
	return "particles/ancient/flesh/ancient_flesh_lvl2.vpcf"
end

function ancient_4_modifier_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end