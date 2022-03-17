icebreaker_x2_modifier_sight = class({})

--------------------------------------------------------------------------------
function icebreaker_x2_modifier_sight:IsHidden()
	return false
end

function icebreaker_x2_modifier_sight:IsPurgable()
    return false
end

function icebreaker_x2_modifier_sight:IsDebuff()
    return true
end
--------------------------------------------------------------------------------

function icebreaker_x2_modifier_sight:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
    self.tick = 0.8

	self:StartIntervalThink(self.tick)
end

function icebreaker_x2_modifier_sight:OnRefresh( kv )
end

function icebreaker_x2_modifier_sight:OnRemoved( kv )
end

--------------------------------------------------------------------------------

function icebreaker_x2_modifier_sight:OnIntervalThink()
	local damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = self.tick * self.parent:GetMaxHealth() * 0.01,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self.ability
	} 
	ApplyDamage(damageTable)
end

function icebreaker_x2_modifier_sight:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function icebreaker_x2_modifier_sight:GetModifierHealAmplify_PercentageTarget()
    return -30
end

function icebreaker_x2_modifier_sight:GetModifierHPRegenAmplify_Percentage()
    return -30
end