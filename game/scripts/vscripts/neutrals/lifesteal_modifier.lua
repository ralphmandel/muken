lifesteal_modifier = class({})

function lifesteal_modifier:IsHidden()
	return false
end

function lifesteal_modifier:IsPurgable()
    return false
end

function lifesteal_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

    self.percent = self.ability:GetSpecialValueFor("percent")
end

function lifesteal_modifier:OnRefresh( kv )
	self.percent = self.ability:GetSpecialValueFor("percent")
end

function lifesteal_modifier:OnRemoved()
end

--------------------------------------------------------------------------------------------------------------------------

function lifesteal_modifier:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }    
    return funcs
end

function lifesteal_modifier:OnAttackLanded(keys)

	if self.parent:PassivesDisabled() then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	local heal = keys.damage * self.percent * 0.01

	self.parent:Heal(heal, self.ability)
	self:PlayEfxHeal(keys.attacker)
end

--------------------------------------------------------------------------------------------------------------------------

function lifesteal_modifier:PlayEfxHeal(target)
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end