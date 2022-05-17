icebreaker__modifier_effect = class ({})

function icebreaker__modifier_effect:IsHidden()
    return true
end

function icebreaker__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function icebreaker__modifier_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self:PlayEffects()

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("icebreaker__modifier_status_effect", true) end
end

function icebreaker__modifier_effect:OnRefresh(kv)
end

------------------------------------------------------------

function icebreaker__modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_EVENT_ON_RESPAWN
	}

	return funcs
end

function icebreaker__modifier_effect:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("Hero_Riki.Attack") end
end

function icebreaker__modifier_effect:GetAttackSound(keys)
    return ""
end

function icebreaker__modifier_effect:OnRespawn(keys)
    if keys.unit == self.parent then
    end
end

function icebreaker__modifier_effect:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_radiant.vpcf"
end

function icebreaker__modifier_effect:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function icebreaker__modifier_effect:PlayEffects()

    if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end
	local particle_cast = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ambient.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )

	ParticleManager:SetParticleControlEnt(
		self.effect_cast,
		1,
		self.parent,
		PATTACH_ABSORIGIN_FOLLOW,
		"",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	self:AddParticle(
		self.effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end