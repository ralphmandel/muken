striker_6_modifier_debuff = class({})

function striker_6_modifier_debuff:IsHidden()
	return true
end

function striker_6_modifier_debuff:IsPurgable()
	return true
end

function striker_6_modifier_debuff:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_6_modifier_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	-- UP 6.31
	if self.ability:GetRank(31) then
		ApplyDamage({
			victim = self.parent, attacker = self.caster,
			damage = 100, damage_type = DAMAGE_TYPE_PURE,
			ability = self.ability
		})

		if self.parent:IsAlive() then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_disarm", {})
		end
	end

	local slow = self.ability:GetSpecialValueFor("slow")
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = slow})
end

function striker_6_modifier_debuff:OnRefresh(kv)
	-- UP 6.31
	if self.ability:GetRank(31) then
		ApplyDamage({
			victim = self.parent, attacker = self.caster,
			damage = 100, damage_type = DAMAGE_TYPE_PURE,
			ability = self.ability
		})

		if self.parent:IsAlive() then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_disarm", {})
		end
	end
end

function striker_6_modifier_debuff:OnRemoved()
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_disarm")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function striker_6_modifier_debuff:GetEffectName()
	return "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_debuff.vpcf"
end

function striker_6_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end