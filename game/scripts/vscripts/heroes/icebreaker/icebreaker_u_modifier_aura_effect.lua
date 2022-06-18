icebreaker_u_modifier_aura_effect = class({})

function icebreaker_u_modifier_aura_effect:IsHidden()
	return true
end

function icebreaker_u_modifier_aura_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function icebreaker_u_modifier_aura_effect:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local res = 0
	if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then
		if self.parent:HasModifier("icebreaker_0_modifier_passive_effect") then
			local cosmetics = self.parent:FindAbilityByName("cosmetics")
			if cosmetics then cosmetics:SetStatusEffect("icebreaker_u_modifier_status_efx", true) end
		end

		-- UP 4.12
		if self.ability:GetRank(12)
		and self.caster == self.parent then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = 50})
		end

		-- UP 4.31
		if self.ability:GetRank(31)
		or self.caster == self.parent then
			res = self.ability:GetSpecialValueFor("res")
		end
	else
		if IsServer() then self:StartIntervalThink(0.5) end
	end
	
	if res > 0 then self.ability:AddBonus("_2_RES", self.parent, res, 0, nil) end
end

function icebreaker_u_modifier_aura_effect:OnRefresh( kv )
end

function icebreaker_u_modifier_aura_effect:OnRemoved()
	if self.parent:HasModifier("icebreaker_0_modifier_passive_effect") then
		local cosmetics = self.parent:FindAbilityByName("cosmetics")
		if cosmetics then cosmetics:SetStatusEffect("icebreaker_u_modifier_status_efx", false) end
	end

	if self.caster == self.parent then self.ability:DestroyShard() end
	self.ability:RemoveBonus("_2_RES", self.parent)

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function icebreaker_u_modifier_aura_effect:CheckState()
	local state = {}

	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber()
	and self:GetParent():HasModifier("icebreaker_0_modifier_passive_effect") then
		state = {
			[MODIFIER_STATE_UNSLOWABLE] = true,
		}
	end

	return state
end

function icebreaker_u_modifier_aura_effect:OnIntervalThink()
	local ability_slow = self.caster:FindAbilityByName("icebreaker_0__slow")
	if ability_slow then
		if ability_slow:IsTrained() then
			ability_slow:AddSlow(self.parent, self.ability)
		end
	end
end

----------------------------------------------------------------------------

function icebreaker_u_modifier_aura_effect:GetStatusEffectName()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber()
	and self:GetParent():HasModifier("icebreaker_0_modifier_passive_effect") then
		return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_radiant.vpcf"
	end
end

function icebreaker_u_modifier_aura_effect:StatusEffectPriority()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber()
	and self:GetParent():HasModifier("icebreaker_0_modifier_passive_effect") then
		return MODIFIER_PRIORITY_SUPER_ULTRA
	end
end

function icebreaker_u_modifier_aura_effect:GetEffectName()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber()
	and self:GetParent():HasModifier("icebreaker_0_modifier_passive_effect") then
		return "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf"
	end
end

function icebreaker_u_modifier_aura_effect:GetEffectAttachType()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber()
	and self:GetParent():HasModifier("icebreaker_0_modifier_passive_effect") then
		return PATTACH_ABSORIGIN_FOLLOW
	end
end

function icebreaker_u_modifier_aura_effect:PlayEffects()
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