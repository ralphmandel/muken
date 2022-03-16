icebreaker_x2_modifier_sight = class({})

--------------------------------------------------------------------------------
function icebreaker_x2_modifier_sight:IsHidden()
	return true
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