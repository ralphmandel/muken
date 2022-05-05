item_rare_lacerator_mod_passive = class({})

function item_rare_lacerator_mod_passive:IsHidden()
    return false
end

function item_rare_lacerator_mod_passive:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_rare_lacerator_mod_passive:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.max_stack = self.ability:GetSpecialValueFor("max_stack")
	self.distance = self.ability:GetSpecialValueFor("distance")
	self.damage_stack = self.ability:GetSpecialValueFor("damage_stack") * 0.01

	if IsServer() then
		self:SetStackCount(0)
	end
end

function item_rare_lacerator_mod_passive:OnRefresh( kv )
end

function item_rare_lacerator_mod_passive:OnRemoved( kv )
	self.ability:RemoveBonus("_1_STR", self.parent)
	self.ability:SetActivated(true)
end

-----------------------------------------------------------

function item_rare_lacerator_mod_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}

	return funcs
end

function item_rare_lacerator_mod_passive:OnDeath(keys)
	if keys.unit == self.parent then self:SetStackCount(0) end
	if keys.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.unit:IsHero() then return end
	if CalcDistanceBetweenEntityOBB(keys.unit, self.parent) > self.distance then return end

	self:IncrementStackCount()
end

function item_rare_lacerator_mod_passive:OnAbilityFullyCast(keys)
	if keys.unit ~= self.parent then return end
	if keys.ability:IsItem() == false then return end
	if keys.ability ~= self.ability then return end
	if keys.target == nil then return end

	local damage = self.damage_stack * self:GetStackCount()
	local damageTable = {
		victim = keys.target,
		attacker = self.caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_PURE,
		ability = keys.ability
	}

	ApplyDamage(damageTable)
	self:SetStackCount(0)

	if self.ability:GetLevel() < self.ability:GetMaxLevel() then
		self.ability:UpgradeAbility(true)
		self.max_stack = self.ability:GetSpecialValueFor("max_stack")
	end
end

function item_rare_lacerator_mod_passive:OnStackCountChanged(iStackCount)
	if self:GetStackCount() > self.max_stack then
		self:SetStackCount(self.max_stack)
	end

	self.ability:RemoveBonus("_1_STR", self.parent)
	self.ability:AddBonus("_1_STR", self.parent, self:GetStackCount(), 0, nil)

	self.ability:SetActivated(self:GetStackCount() >= self.max_stack)
end