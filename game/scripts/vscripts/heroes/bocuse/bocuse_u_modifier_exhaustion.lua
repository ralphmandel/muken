bocuse_u_modifier_exhaustion = class ({})

function bocuse_u_modifier_exhaustion:IsHidden()
    return false
end

function bocuse_u_modifier_exhaustion:IsPurgable()
    return false
end

-----------------------------------------------------------

function bocuse_u_modifier_exhaustion:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

    self:PlayEfxStart()
	local channel = self.parent:FindAbilityByName("_channel")
	if channel then channel:SetStatusEffect("bocuse_u_modifier_exhaustion_status_efx", true) end
end

function bocuse_u_modifier_exhaustion:OnRefresh(kv)
end

function bocuse_u_modifier_exhaustion:OnRemoved()
	local channel = self.parent:FindAbilityByName("_channel")
	if channel then channel:SetStatusEffect("bocuse_u_modifier_exhaustion_status_efx", false) end
end

------------------------------------------------------------

function bocuse_u_modifier_exhaustion:CheckState()
	local state = {
        [MODIFIER_STATE_STUNNED] = true
	}

	return state
end

function bocuse_u_modifier_exhaustion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function bocuse_u_modifier_exhaustion:GetOverrideAnimation()
	return ACT_DOTA_DEFEAT
end

-----------------------------------------------------------

function bocuse_u_modifier_exhaustion:GetStatusEffectName()
	return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function bocuse_u_modifier_exhaustion:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function bocuse_u_modifier_exhaustion:PlayEfxStart()
    local particle_cast = "particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, self.parent:GetOrigin() )
    
	local particle_cast_1 = "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast_1, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
    self:AddParticle(self.effect_cast, false, false, -1, false, false)

    if IsServer() then self.parent:EmitSound("Hero_Techies.RemoteMine.Detonate") end
end