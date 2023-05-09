icebreaker_1_modifier_illusion = class({})

function icebreaker_1_modifier_illusion:IsHidden() return true end
function icebreaker_1_modifier_illusion:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_1_modifier_illusion:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function icebreaker_1_modifier_illusion:OnRefresh(kv)
end

function icebreaker_1_modifier_illusion:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_1_modifier_illusion:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function icebreaker_1_modifier_illusion:OnAttackLanded(keys)
  if keys.attacker ~= self.parent then return end
  if keys.target:IsMagicImmune() then return end
  if self.parent:PassivesDisabled() then return end

  if RandomFloat(0, 100) < 25 then
    keys.target:AddNewModifier(self.caster, self.ability, "icebreaker__modifier_hypo", {stack = 1})
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------