icebreaker_3_modifier_aura_effect = class({})

function icebreaker_3_modifier_aura_effect:IsHidden() return true end
function icebreaker_3_modifier_aura_effect:IsPurgable() return true end
function icebreaker_3_modifier_aura_effect:GetPriority() return MODIFIER_PRIORITY_ULTRA end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_3_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then self:OnIntervalThink() end
end

function icebreaker_3_modifier_aura_effect:OnRefresh(kv)
end

function icebreaker_3_modifier_aura_effect:OnRemoved()
	local hypo_mod = self.parent:FindModifierByNameAndCaster("icebreaker__modifier_hypo", self.caster)
	if hypo_mod then hypo_mod:DecrementStackCount() end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_3_modifier_aura_effect:CheckState()
	local state = {}

	if self:GetAbility():GetSpecialValueFor("special_truesight") == 1 then
		table.insert(state, MODIFIER_STATE_INVISIBLE, false)
	end

	return state
end

function icebreaker_3_modifier_aura_effect:OnIntervalThink()
	if self.parent:HasModifier("icebreaker__modifier_frozen") == false then
		self.parent:AddNewModifier(self.caster, self.ability, "icebreaker__modifier_hypo", {
			duration = CalcStatus(self.ability:GetSpecialValueFor("stack_duration"), self.caster, self.parent),
			stack = 1
		})
	end

	if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("intervals")) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------