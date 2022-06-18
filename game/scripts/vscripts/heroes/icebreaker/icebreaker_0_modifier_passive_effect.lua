icebreaker_0_modifier_passive_effect = class ({})

function icebreaker_0_modifier_passive_effect:IsHidden()
    return true
end

function icebreaker_0_modifier_passive_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function icebreaker_0_modifier_passive_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self:PlayEffects()
end

function icebreaker_0_modifier_passive_effect:OnRefresh(kv)
end

------------------------------------------------------------

function icebreaker_0_modifier_passive_effect:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_radiant.vpcf"
end

function icebreaker_0_modifier_passive_effect:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function icebreaker_0_modifier_passive_effect:PlayEffects()

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