bloodstained_x2_modifier_blood = class({})

function bloodstained_x2_modifier_blood:IsHidden()
    return true 
end

function bloodstained_x2_modifier_blood:IsPurgable()
    return false 
end

---------------------------------------------------------------------------------------------------

function bloodstained_x2_modifier_blood:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.start = false
	self.damage = math.ceil(kv.damage * 0.2)
	self:PlayEfxStart()
end

function bloodstained_x2_modifier_blood:OnRefresh( kv )

end

function bloodstained_x2_modifier_blood:OnRemoved( kv )
	if self.effect_cast ~= nil then ParticleManager:DestroyParticle(self.effect_cast, false) end
end
---------------------------------------------------------------------------------------------------

function bloodstained_x2_modifier_blood:PlayEfxStart()
	local particle_cast = "particles/bloodstained/bloodstained_x2_blood.vpcf"
    self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.effect_cast, 1, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(self.effect_cast, 5, Vector(self.damage, self.damage, self.parent:GetAbsOrigin().z))

	-- buff particle
	self:AddParticle(
		self.effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end