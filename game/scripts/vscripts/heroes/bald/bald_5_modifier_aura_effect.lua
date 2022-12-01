bald_5_modifier_aura_effect = class({})

function bald_5_modifier_aura_effect:IsHidden() return false end
function bald_5_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_5_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function bald_5_modifier_aura_effect:OnRefresh(kv)
end

function bald_5_modifier_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_5_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end

function bald_5_modifier_aura_effect:GetModifierIncomingDamage_Percentage(keys)
	local damage_percent = self.ability:GetSpecialValueFor("damage_percent")
	print(keys.original_damage, "original_damage")

	local total = ApplyDamage({
		damage = keys.original_damage * damage_percent * 0.01,
		attacker = keys.attacker,
		victim = self.caster,
		damage_type = keys.damage_type,
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
		ability = keys.inflictor
	})

	print(total, "total")

	self:PlayEfxHit()

	return -damage_percent
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_5_modifier_aura_effect:PlayEfxHit()
	local particle_cast = "particles/econ/items/dark_seer/dark_seer_ti8_immortal_arms/dark_seer_ti8_immortal_ion_shell_dmg_golden.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)
end