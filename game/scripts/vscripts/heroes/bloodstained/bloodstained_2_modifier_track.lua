bloodstained_2_modifier_track = class({})

--------------------------------------------------------------------------------

function bloodstained_2_modifier_track:IsHidden()
	return true
end

function bloodstained_2_modifier_track:IsPurgable()
	return false
end

function bloodstained_2_modifier_track:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function bloodstained_2_modifier_track:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self:PlayEfxStart()
	if IsServer() then self:StartIntervalThink(0.1) end
end

function bloodstained_2_modifier_track:OnRefresh(kv)
end

function bloodstained_2_modifier_track:OnRemoved()
end

--------------------------------------------------------------------------------

function bloodstained_2_modifier_track:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function bloodstained_2_modifier_track:GetModifierHealAmplify_PercentageTarget()
    return -75
end

function bloodstained_2_modifier_track:GetModifierHPRegenAmplify_Percentage(keys)
    return -75
end

function bloodstained_2_modifier_track:OnIntervalThink()
	AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), 50, 0.2, false)
	if self.parent:GetHealthPercent() > 20 then self:Destroy() end
end

--------------------------------------------------------------------------------

function bloodstained_2_modifier_track:PlayEfxStart()
	if self.particle_trail_fx then ParticleManager:DestroyParticle(self.efx_bkb, false) end

	local particle_cast = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail.vpcf"
	self.particle_trail_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	--self.particle_trail_fx = ParticleManager:CreateParticleForTeam(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent, self.caster:GetTeamNumber())
	ParticleManager:SetParticleControl(self.particle_trail_fx, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(self.particle_trail_fx, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.particle_trail_fx, 8, Vector(1,0,0))
	self:AddParticle(self.particle_trail_fx, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Marci.Grapple.Cast") end
end