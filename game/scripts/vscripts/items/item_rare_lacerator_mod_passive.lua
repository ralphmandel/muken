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

	if IsServer() then self:SetStackCount(self.ability.stacks) end
end

function item_rare_lacerator_mod_passive:OnRefresh( kv )
end

function item_rare_lacerator_mod_passive:OnRemoved( kv )
	RemoveBonus(self.ability, "STR", self.parent)
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

	local distance = self.ability:GetSpecialValueFor("distance")
	local max_stack = self.ability:GetSpecialValueFor("max_stack")
	if CalcDistanceBetweenEntityOBB(keys.unit, self.parent) > distance then return end

	self.ability.stacks = self.ability.stacks + 1
	if self.ability.stacks > max_stack then
		self.ability.stacks = max_stack
	end

	if IsServer() then self:SetStackCount(self.ability.stacks) end
	self.ability:SetActivated(self:GetStackCount() >= max_stack)
end

function item_rare_lacerator_mod_passive:OnAbilityFullyCast(keys)
	if keys.unit ~= self.parent then return end
	if keys.ability:IsItem() == false then return end
	if keys.ability ~= self.ability then return end
	if keys.target == nil then return end

	ApplyDamage({
		victim = keys.target,
		attacker = self.caster,
		damage = self.ability:GetSpecialValueFor("damage_stack") * self:GetStackCount(),
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	})

	self.ability.stacks = 0
	if IsServer() then self:SetStackCount(self.ability.stacks) end

	if self.ability:GetLevel() < self.ability:GetMaxLevel() then
		self.ability:UpgradeAbility(true)
	end
end

function item_rare_lacerator_mod_passive:OnStackCountChanged(iStackCount)
	local str = math.floor(self:GetStackCount() / 3)
	RemoveBonus(self.ability, "STR", self.parent)

	if str > 0 then AddBonus(self.ability, "STR", self.parent, str, 0, nil) end
end