ancient_1_modifier_berserk = class({})

function ancient_1_modifier_berserk:IsHidden()
	return true
end

function ancient_1_modifier_berserk:IsPurgable()
	return false
end

function ancient_1_modifier_berserk:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_1_modifier_berserk:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then base_stats:SetBaseAttackTime(0) end
end

function ancient_1_modifier_berserk:OnRefresh(kv)
end

function ancient_1_modifier_berserk:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_1_modifier_berserk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function ancient_1_modifier_berserk:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if self.parent:PassivesDisabled() then return end

	keys.unit:AddNewModifier(self.caster, self.ability, "_modifier_stun", {duration = keys.damage * 0.01})
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------