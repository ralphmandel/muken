inquisitor_u_modifier_regenerate = class({})

--------------------------------------------------------------------------------

function inquisitor_u_modifier_regenerate:IsHidden()
	return false
end

function inquisitor_u_modifier_regenerate:IsPurgable()
    return true
end

--------------------------------------------------------------------------------

function inquisitor_u_modifier_regenerate:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.gain = 0
	self.lose = 0

	if IsServer() then
		self:SetStackCount(1)
		self:StartIntervalThink(0.2)
	end
	self:PlayEfxCast()
end

function inquisitor_u_modifier_regenerate:OnRefresh( kv )
end

function inquisitor_u_modifier_regenerate:OnRemoved( kv )
	local modify = self.parent:GetHealth() + self.gain - self.lose
	self.parent:ModifyHealth(modify, self.ability, true, 0)

	if self.particle ~= nil then ParticleManager:DestroyParticle(self.particle, false) end
end

--------------------------------------------------------------------------------

function inquisitor_u_modifier_regenerate:OnIntervalThink()
	self:SetStackCount(self.gain - self.lose)
end

function inquisitor_u_modifier_regenerate:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_HEAL_RECEIVED,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
	}
	
	return funcs
end

function inquisitor_u_modifier_regenerate:GetModifierIncomingDamage_Percentage(keys)
	self.lose = self.lose + keys.damage
	return -100
end

function inquisitor_u_modifier_regenerate:GetDisableHealing()
	return 1
end

function inquisitor_u_modifier_regenerate:OnHealReceived(keys)
	if keys.unit ~= self.parent then return end
	self.gain = self.gain + keys.gain
end

function inquisitor_u_modifier_regenerate:GetModifierHealAmplify_PercentageTarget()
    return 50
end

function inquisitor_u_modifier_regenerate:GetModifierHPRegenAmplify_Percentage()
    return 50
end

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

function inquisitor_u_modifier_regenerate:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_fatesedict.vpcf"
end

function inquisitor_u_modifier_regenerate:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function inquisitor_u_modifier_regenerate:PlayEfxCast()
	local particle = "particles/units/heroes/hero_oracle/oracle_false_promise_cast_enemy.vpcf"
	local effect = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( effect, 0, self.parent:GetOrigin() )

	if IsServer() then self.parent:EmitSound("Hero_SkywrathMage.AncientSeal.Target") end
end