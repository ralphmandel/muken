bocuse_3_modifier_passive = class({})

function bocuse_3_modifier_passive:IsHidden() return true end
function bocuse_3_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_3_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function bocuse_3_modifier_passive:OnRefresh(kv)
end

function bocuse_3_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function bocuse_3_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

  local duration = self.ability:GetSpecialValueFor("duration")
	local duration_reduction = self.ability:GetSpecialValueFor("duration_reduction")
  local mod_sauce = keys.target:FindModifierByNameAndCaster("bocuse_3_modifier_sauce", self.caster)

  if mod_sauce then
    if mod_sauce:GetStackCount() < self.ability:GetSpecialValueFor("max_stack") and mod_sauce.delay == false then
      duration = duration - (duration_reduction * mod_sauce:GetStackCount())
      AddModifier(keys.target, self.caster, self.ability, "bocuse_3_modifier_sauce", {duration = duration}, true)
    end
    return
  end

  AddModifier(keys.target, self.caster, self.ability, "bocuse_3_modifier_sauce", {duration = duration}, true)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------