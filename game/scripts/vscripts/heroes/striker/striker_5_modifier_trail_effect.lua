striker_5_modifier_trail_effect = class({})

function striker_5_modifier_trail_effect:IsHidden()
	return true
end

function striker_5_modifier_trail_effect:IsPurgable()
	return false
end

function striker_5_modifier_trail_effect:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_5_modifier_trail_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = 30})

	if IsServer() then self:StartIntervalThink(0.5) end
end

function striker_5_modifier_trail_effect:OnRefresh(kv)
end

function striker_5_modifier_trail_effect:OnRemoved()
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_5_modifier_trail_effect:OnIntervalThink()
	ApplyDamage({
		victim = self.parent, attacker = self.caster,
		damage = RandomInt(5, 10),
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	})

	if IsServer() then self:StartIntervalThink(0.5) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function striker_5_modifier_trail_effect:GetEffectName()
	return "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_debuff.vpcf"
end

function striker_5_modifier_trail_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end