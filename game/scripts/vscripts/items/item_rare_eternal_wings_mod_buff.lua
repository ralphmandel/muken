item_rare_eternal_wings_mod_buff = class({})

function item_rare_eternal_wings_mod_buff:IsHidden()
    return false
end

function item_rare_eternal_wings_mod_buff:IsPurgable()
    return true
end

---------------------------------------------------------------------------------------------------

function item_rare_eternal_wings_mod_buff:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self:PlayEfxStart()
end

function item_rare_eternal_wings_mod_buff:OnRefresh( kv )
end

function item_rare_eternal_wings_mod_buff:OnRemoved( kv )
end


--------------------------------------------------------------------------------------------------

function item_rare_eternal_wings_mod_buff:CheckState()
	local state = {
		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true
	}

	return state
end

--------------------------------------------------------------------------------------------------

function item_rare_eternal_wings_mod_buff:GetStatusEffectName()
	return "particles/status_fx/status_effect_guardian_angel.vpcf"
end

function item_rare_eternal_wings_mod_buff:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function item_rare_eternal_wings_mod_buff:PlayEfxStart()
	local particle_wings = "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf"

	if self.parent:GetUnitName() == "npc_dota_hero_shadow_demon"
	or self.parent:GetUnitName() == "npc_dota_hero_pudge" then
		particle_wings = "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
	end

	self.particle_wings_fx = ParticleManager:CreateParticle(particle_wings, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle_wings_fx, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(self.particle_wings_fx, 5, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	self:AddParticle(self.particle_wings_fx, false, false, -1, false, false)

	local particle_halo = "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_halo_buff.vpcf"
	self.particle_halo_fx = ParticleManager:CreateParticle(particle_halo, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.particle_halo_fx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)    
	self:AddParticle(self.particle_halo_fx, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Eternal_Wings.Active") end
end