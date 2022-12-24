striker_5_modifier_debuff = class({})

function striker_5_modifier_debuff:IsHidden() return true end
function striker_5_modifier_debuff:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_5_modifier_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
		percent = self.ability:GetSpecialValueFor("slow")
	})

	if IsServer() then self:StartIntervalThink(0.1) end
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

function striker_5_modifier_debuff:OnIntervalThink()
	ApplyDamage({
		victim = self.parent, attacker = self.caster, damage = 1,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	})

	if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function striker_5_modifier_debuff:GetEffectName()
	return "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_debuff.vpcf"
end

function striker_5_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end