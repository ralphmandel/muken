striker_5_modifier_debuff = class({})

function striker_5_modifier_debuff:IsHidden()
	return true
end

function striker_5_modifier_debuff:IsPurgable()
	return true
end

function striker_5_modifier_debuff:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_5_modifier_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local slow = self.ability:GetSpecialValueFor("slow")
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = slow})
end

function striker_5_modifier_debuff:OnRefresh(kv)
end

function striker_5_modifier_debuff:OnRemoved()
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_5_modifier_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true
	}

	return state
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function striker_5_modifier_debuff:GetEffectName()
	return "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_debuff.vpcf"
end

function striker_5_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end