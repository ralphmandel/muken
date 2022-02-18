summon_spiders_modifier = class({})

function summon_spiders_modifier:IsHidden()
	return true
end

function summon_spiders_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function summon_spiders_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function summon_spiders_modifier:OnRefresh( kv )
end

function summon_spiders_modifier:OnRemoved()
	if self.parent:IsAlive() then self.parent:Kill(self.ability, self.caster) end
end

--------------------------------------------------------------------------------

function summon_spiders_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function summon_spiders_modifier:OnDeath(keys)
	if keys.unit == self.caster then self:Destroy() end
end