osiris_4_modifier_debuff = class({})

function osiris_4_modifier_debuff:IsHidden()
	return false
end

function osiris_4_modifier_debuff:IsPurgable()
	return false
end

function osiris_4_modifier_debuff:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function osiris_4_modifier_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_break", {})
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
		percent = self.ability:GetSpecialValueFor("slow")
	})
end

function osiris_4_modifier_debuff:OnRefresh(kv)
end

function osiris_4_modifier_debuff:OnRemoved()
	local mod = self.parent:FindAllModifiersByName("_modifier_break")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------