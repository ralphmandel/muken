ancient_4_modifier_radiance_aura_effect = class({})

function ancient_4_modifier_radiance_aura_effect:IsHidden()
	return true
end

function ancient_4_modifier_radiance_aura_effect:IsPurgable()
	return false
end

function ancient_4_modifier_radiance_aura_effect:IsDebuff()
	return true
end

-----------------------------------------------------------

function ancient_4_modifier_radiance_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then
		self:OnIntervalThink()
		self:PlayEfxRadiance()
	end
end

function ancient_4_modifier_radiance_aura_effect:OnRefresh(kv)
end

function ancient_4_modifier_radiance_aura_effect:OnRemoved(kv)
	if self.particle then ParticleManager:DestroyParticle(self.particle, false) end
end

-----------------------------------------------------------

function ancient_4_modifier_radiance_aura_effect:OnIntervalThink()
	local damage = self.caster:GetMana() * 0.05
	local intervals = 0.6

	ApplyDamage({
		victim = self.parent, attacker = self.caster,
		damage = damage * intervals, damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	})

	if IsServer() then self:StartIntervalThink(intervals) end
end

-----------------------------------------------------------

function ancient_4_modifier_radiance_aura_effect:PlayEfxRadiance()
	if self.particle then ParticleManager:DestroyParticle(self.particle, false) end

	local string = "particles/econ/events/fall_2022/radiance_target_fall2022.vpcf"
	self.particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, self.caster:GetAbsOrigin())
	self:AddParticle(self.particle, false, false, -1, false, false)

	self:UpdateEfx()
end

function ancient_4_modifier_radiance_aura_effect:UpdateEfx()
	Timers:CreateTimer((0.03), function()
		if self.particle then
			ParticleManager:SetParticleControl(self.particle, 1, self.caster:GetAbsOrigin())
		end
	end)
end