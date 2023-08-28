dasdingo_2_modifier_aura_effect = class({})

function dasdingo_2_modifier_aura_effect:IsHidden() return false end
function dasdingo_2_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_2_modifier_aura_effect:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then
    AddModifier(self.parent, self.ability, "_modifier_truesight", {}, false)
  end

  if IsServer() then self:StartIntervalThink(1) end
end

function dasdingo_2_modifier_aura_effect:OnRefresh(kv)
end

function dasdingo_2_modifier_aura_effect:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_truesight", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

-- function dasdingo_2_modifier_aura_effect:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true
-- 	}

--   if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
--     state = {}
--   end

-- 	return state
-- end

-- function dasdingo_2_modifier_aura_effect:DeclareFunctions()
-- 	local funcs = {
--     MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
-- 	}

-- 	return funcs
-- end

-- function dasdingo_2_modifier_aura_effect:GetModifierConstantHealthRegen(keys)
--   if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then return 0 end
--   return self:GetAbility():GetSpecialValueFor("hp_regen")
-- end

function dasdingo_2_modifier_aura_effect:OnIntervalThink()
  if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then return end
  if self.parent:IsMagicImmune() then return end

  if RandomFloat(0, 100) < self.ability:GetSpecialValueFor("root_chance") then
    AddModifier(self.parent, self.ability, "_modifier_root", {
      duration = self.ability:GetSpecialValueFor("root_duration"),
      effect = 4
    })
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------