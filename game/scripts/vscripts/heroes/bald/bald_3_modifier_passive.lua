bald_3_modifier_passive = class({})

function bald_3_modifier_passive:IsHidden()
	return false
end

function bald_3_modifier_passive:IsPurgable()
	return false
end

function bald_3_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.amount = self.ability:GetSpecialValueFor("amount")
	self.total_amount = 0
end

function bald_3_modifier_passive:OnRefresh(kv)
	self.amount = self.ability:GetSpecialValueFor("amount")
end

function bald_3_modifier_passive:OnRemoved()
	self.ability:RemoveBonus("_1_CON", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function bald_3_modifier_passive:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if self.parent:HasModifier("bald_3_modifier_inner") then return end
	if self.parent:PassivesDisabled() then return end

	self:IncrementAmount(keys.damage)
end

-- UTILS -----------------------------------------------------------

function bald_3_modifier_passive:IncrementAmount(damage)
	self.total_amount = self.total_amount + damage
	if self.total_amount > self.amount then
		--ADD STACK
		self.total_amount = self.total_amount - self.amount
		self:IncrementAmount(0)
	end
end

-- EFFECTS -----------------------------------------------------------