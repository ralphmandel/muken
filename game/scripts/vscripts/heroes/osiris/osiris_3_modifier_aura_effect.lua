osiris_3_modifier_aura_effect = class({})

function osiris_3_modifier_aura_effect:IsHidden()
	if self:GetCaster() == self:GetParent() then
		return false
	end

	return true
end

function osiris_3_modifier_aura_effect:IsPurgable()
	return false
end

function osiris_3_modifier_aura_effect:IsDebuff()
	if self:GetCaster() == self:GetParent() then
		return false
	end

	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function osiris_3_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.regen = self.ability:GetSpecialValueFor("regen")
	--self:SetBuffTime()
	self:ApplyDebuffs()
end

function osiris_3_modifier_aura_effect:OnRefresh(kv)
end

function osiris_3_modifier_aura_effect:OnRemoved()
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_blind")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function osiris_3_modifier_aura_effect:CheckState()
	local state = {}

	if self:GetCaster() == self:GetParent() then
		state = {
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true
		}
	end

	return state
end

function osiris_3_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}

	return funcs
end

function osiris_3_modifier_aura_effect:GetModifierConstantHealthRegen()
	if self:GetCaster() == self:GetParent() then
		return self:GetCaster():GetMaxHealth() * self.regen * 0.01
	end

	return 0
end

-- UTILS -----------------------------------------------------------

function osiris_3_modifier_aura_effect:SetBuffTime()
	if self.caster ~= self.parent then return end
	if self.ability.mod_thinker == nil then return end
	local mod = self.ability.mod_thinker:FindModifierByNameAndCaster("osiris_3_modifier_storm", self.caster)
	if mod == nil then return end

	self:SetDuration(mod:GetRemainingTime(), true)
end

function osiris_3_modifier_aura_effect:ApplyDebuffs()
	if self.caster == self.parent then return end
	local slow = self.ability:GetSpecialValueFor("slow")
	local blind = self.ability:GetSpecialValueFor("blind")

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
		percent = slow
	})

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_blind", {
		percent = blind, miss_chance = 0
	})
end

-- EFFECTS -----------------------------------------------------------