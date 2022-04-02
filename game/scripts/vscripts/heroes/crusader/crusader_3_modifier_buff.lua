crusader_3_modifier_buff = class({})

function crusader_3_modifier_buff:IsHidden()
    return false 
end

function crusader_3_modifier_buff:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function crusader_3_modifier_buff:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self:PlayEfxStart()
end

function crusader_3_modifier_buff:OnRefresh( kv )
end

function crusader_3_modifier_buff:OnRemoved( kv )
	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end
	if self.effect_cast_2 then ParticleManager:DestroyParticle(self.effect_cast_2, false) end
end

---------------------------------------------------------------------------------------------------

function crusader_3_modifier_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function crusader_3_modifier_buff:OnAttackLanded(keys)
end

--------------------------------------------------------------------------------------------------

function crusader_3_modifier_buff:GetEffectName()
	return "particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_ti8_immortal_pitofmalice_stun_light.vpcf"
end

function crusader_3_modifier_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function crusader_3_modifier_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function crusader_3_modifier_buff:StatusEffectPriority()
	return 4
end

function crusader_3_modifier_buff:PlayEfxLifesteal()
	local particle_cast = "particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

function crusader_3_modifier_buff:PlayEfxIncomingHeal()
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

function crusader_3_modifier_buff:PlayEfxStart()
	local particle_cast_special = "particles/crusader/crusader_trigger.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast_special, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)

	-- local particle_cast = "particles/units/heroes/hero_chaos_knight/chaos_knight_phantasm.vpcf"
	-- self.effect_cast_2 = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
	-- ParticleManager:SetParticleControl(self.effect_cast_2, 0, self.parent:GetOrigin())

	-- Timers:CreateTimer((0.2), function()
	-- 	print("oi111", self.effect_cast_2)
	-- 	if self.effect_cast_2 then ParticleManager:DestroyParticle(self.effect_cast_2, false) end
	-- end)
end