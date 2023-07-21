paladin_u_modifier_passive = class({})

function paladin_u_modifier_passive:IsHidden() return true end
function paladin_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  BaseStats(self.parent):AddBaseStat("CON", self.ability:GetSpecialValueFor("con"))
  BaseStats(self.parent):AddBaseStat("RES", self.ability:GetSpecialValueFor("res"))
end

function paladin_u_modifier_passive:OnRefresh(kv)
end

function paladin_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------