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
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function summon_spiders_modifier:OnDeath(keys)
	if keys.unit == self.caster then self:Destroy() end
end

function summon_spiders_modifier:OnAttackLanded(keys)
	if keys.attacker ~= self.unit then return end
	if IsServer() then self.unit:EmitSound("Hero_Broodmother.Attack") end
end

function summon_spiders_modifier:GetAttackSound(keys)
    return ""
end