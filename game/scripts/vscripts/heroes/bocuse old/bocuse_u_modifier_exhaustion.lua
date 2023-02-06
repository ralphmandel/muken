bocuse_u_modifier_exhaustion = class({})

function bocuse_u_modifier_exhaustion:IsHidden()
	return false
end

function bocuse_u_modifier_exhaustion:IsPurgable()
	return true
end

function bocuse_u_modifier_exhaustion:IsDebuff()
	return true
end

function bocuse_u_modifier_exhaustion:IsStunDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_u_modifier_exhaustion:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bocuse_u_modifier_exhaustion_status_efx", true) end

	self:StartExplosion()
	self:PlayEfxStart()
end

function bocuse_u_modifier_exhaustion:OnRefresh(kv)
end

function bocuse_u_modifier_exhaustion:OnRemoved(kv)
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bocuse_u_modifier_exhaustion_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

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

function bocuse_u_modifier_exhaustion:StartExplosion()
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 350,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	0, false
	)

	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
			duration = CalcStatus(4, self.caster, enemy)
		})
	end
end

-- EFFECTS -----------------------------------------------------------

function bocuse_u_modifier_exhaustion:GetStatusEffectName()
	return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function bocuse_u_modifier_exhaustion:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function bocuse_u_modifier_exhaustion:PlayEfxStart()
    local particle_cast = "particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self.parent )
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

	particle_cast = "particles/units/heroes/hero_techies/techies_blast_off.vpcf"
    effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

	particle_cast = "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
    self:AddParticle(self.effect_cast, false, false, -1, false, false)

    if IsServer() then self.parent:EmitSound("Hero_Techies.RemoteMine.Detonate") end
end