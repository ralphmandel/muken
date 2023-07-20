hunter_2_modifier_delay_end = class({})

function hunter_2_modifier_delay_end:IsHidden() return true end
function hunter_2_modifier_delay_end:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_2_modifier_delay_end:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function hunter_2_modifier_delay_end:OnRefresh(kv)
end

function hunter_2_modifier_delay_end:OnRemoved()
  local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), self.ability:GetSpecialValueFor("tree_radius"), false)
  if trees then
    for _,tree in pairs(trees) do return end
  end

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_invisible", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------