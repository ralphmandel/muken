icebreaker_u_modifier_buff = class({})

function icebreaker_u_modifier_buff:IsHidden()
	return false
end

function icebreaker_u_modifier_buff:IsPurgable()
    return false
end

-----------------------------------------------------------

function icebreaker_u_modifier_buff:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local dex = self.ability:GetSpecialValueFor("dex")
	self.out_range = self.ability:GetSpecialValueFor("out_range")
	self.out = true

	self.parent:Purge(false, true, false, false, false)
	self.parent:AddNewModifier(self.caster, self.ability, "icebreaker_u_modifier_blur", {})
	self.ability:AddBonus("_2_DEX", self.parent, dex, 0, nil)

	-- UP 4.2
	if self.ability:GetRank(2) then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = 50})
	end

	self:StartIntervalThink(0.1)
end

function icebreaker_u_modifier_buff:OnRefresh( kv )
end

function icebreaker_u_modifier_buff:OnRemoved()
	self.parent:RemoveModifierByName("icebreaker_u_modifier_blur")
	self.ability:RemoveBonus("_2_DEX", self.parent)

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-----------------------------------------------------------


function icebreaker_u_modifier_buff:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = self.out,
		[MODIFIER_STATE_UNTARGETABLE] = self.out,
		[MODIFIER_STATE_UNSLOWABLE] = true,
	}

	return state
end

function icebreaker_u_modifier_buff:OnIntervalThink()
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.out_range,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		80,	0, false
	)

	for _,enemy in pairs(enemies) do
		self.out = false
		return
	end

	self.out = true
end

----------------------------------------------------------------------------

function icebreaker_u_modifier_buff:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_radiant.vpcf"
end

function icebreaker_u_modifier_buff:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function icebreaker_u_modifier_buff:GetEffectName()
	return "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf"
end

function icebreaker_u_modifier_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_u_modifier_buff:PlayEffects()
	local particle_1 = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_death.vpcf"
	local efx_1 = ParticleManager:CreateParticle(particle_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(efx_1, 0, self.parent:GetOrigin())

	local particle_3 = "particles/econ/items/phantom_assassin/pa_fall20_immortal_shoulders/pa_fall20_blur_ambient_warp.vpcf"
	local efx_3 = ParticleManager:CreateParticle(particle_3, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(efx_3, 0, self.parent:GetOrigin())

	local particle_4 = "particles/econ/items/effigies/status_fx_effigies/frosty_effigy_ambient_l2_radiant.vpcf"
	local efx_4 = ParticleManager:CreateParticle(particle_4, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(efx_4, 0, self.parent:GetOrigin())
end