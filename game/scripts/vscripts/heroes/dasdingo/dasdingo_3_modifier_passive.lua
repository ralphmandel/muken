dasdingo_3_modifier_passive = class({})

function dasdingo_3_modifier_passive:IsHidden()
	return false
end

function dasdingo_3_modifier_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.atk_range = 0

	self.fire_duration = self.ability:GetSpecialValueFor("fire_duration")
end

function dasdingo_3_modifier_passive:OnRefresh(kv)
	-- UP 3.22
	if self.ability:GetRank(22) then
		self.atk_range = 200
	end
end

function dasdingo_3_modifier_passive:OnRemoved()
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function dasdingo_3_modifier_passive:GetModifierAttackRangeBonus()
	return self.atk_range
end

function dasdingo_3_modifier_passive:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	-- UP 3.22
	if self.ability:GetRank(22) then
		self:AddFire(keys.target)
	end
end

function dasdingo_3_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	self:AddFire(keys.target)
end

function dasdingo_3_modifier_passive:AddFire(target)
	--local bStunned = false
	-- local mod = target:FindAllModifiersByName("_modifier_stun")
	-- for _,modifier in pairs(mod) do
	-- 	if modifier:GetAbility() == self.ability then bStunned = true end
	-- end
	if self.ability:IsCooldownReady() == false then return end

	local mod = target:FindModifierByNameAndCaster("dasdingo_3_modifier_fire", self.caster)
	if mod then
		mod:IncrementStackCount()
	else
		target:AddNewModifier(self.caster, self.ability, "dasdingo_3_modifier_fire", {
			duration = CalcStatus(self.fire_duration, self.caster, target)
		})
	end
end