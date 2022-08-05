dasdingo_4_modifier_poison = class({})

function dasdingo_4_modifier_poison:IsHidden()
	return false
end

function dasdingo_4_modifier_poison:IsPurgable()
	return true
end

function dasdingo_4_modifier_poison:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function dasdingo_4_modifier_poison:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local intervals = 0.75
	local damage = 30 * intervals

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability,
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
	}

	self.ability:AddBonus("_1_AGI", self.parent, -20, 0, 10)

	if IsServer() then
		self:StartIntervalThink(intervals)
	end
end

function dasdingo_4_modifier_poison:OnRefresh(kv)
end

function dasdingo_4_modifier_poison:OnRemoved()
	self.ability:RemoveBonus("_1_AGI", self.parent)
end

--------------------------------------------------------------------------------

function dasdingo_4_modifier_poison:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}

	return funcs
end

function dasdingo_4_modifier_poison:GetModifierAttackSpeedBonus_Constant()
	if self:GetParent():IsHero() then return 0 end
	return -35
end

function dasdingo_4_modifier_poison:OnIntervalThink()
	ApplyDamage(self.damageTable)
end

--------------------------------------------------------------------------------

function dasdingo_4_modifier_poison:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_corrosive_debuff.vpcf"
end

function dasdingo_4_modifier_poison:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end