icebreaker__modifier_illusion = class({})

function icebreaker__modifier_illusion:IsHidden() return true end
function icebreaker__modifier_illusion:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__modifier_illusion:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function icebreaker__modifier_illusion:OnRefresh(kv)
end

function icebreaker__modifier_illusion:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker__modifier_illusion:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function icebreaker__modifier_illusion:OnAttackLanded(keys)
  if keys.attacker ~= self.parent then return end
  if keys.target:IsMagicImmune() then return end
  if self.parent:PassivesDisabled() then return end

  if RandomFloat(0, 100) < 20 then
    AddModifier(keys.target, self.ability, "icebreaker__modifier_hypo", {stack = 1}, false)
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------