icebreaker_3_modifier_aura_effect = class({})

function icebreaker_3_modifier_aura_effect:IsHidden()
	return true
end

function icebreaker_3_modifier_aura_effect:IsPurgable()
    return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_3_modifier_aura_effect:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.min_stack = self.ability:GetSpecialValueFor("min_stack")

	-- UP 3.21
	if self.ability:GetRank(21) then
		self.min_stack = self.min_stack + 1
	end

	if self.caster == self.parent then
		local cosmetics = self.parent:FindAbilityByName("cosmetics")
		if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "icebreaker_3_modifier_aura_effect_status_efx", true) end
		
		-- UP 3.12
		if self.ability:GetRank(12) then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = 50})
		end
	end

	if self.caster:GetTeamNumber() ~= self.parent:GetTeamNumber() then
		if IsServer() then
			self:ApplyMirror()
			self:StartIntervalThink(FrameTime())
		end
	end
end

function icebreaker_3_modifier_aura_effect:OnRefresh( kv )
end

function icebreaker_3_modifier_aura_effect:OnRemoved()
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	if self.caster == self.parent then
		local cosmetics = self.parent:FindAbilityByName("cosmetics")
		if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "icebreaker_3_modifier_aura_effect_status_efx", false) end
		self.ability:DestroyShard()
	end

	-- UP 3.31
	if self.ability:GetRank(31) then
		self:AddFrozenState()
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_3_modifier_aura_effect:CheckState()
	local state = {}

	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber()
	and self:GetParent():HasModifier("icebreaker_0_modifier_passive_effect") then
		state = {
			[MODIFIER_STATE_UNSLOWABLE] = true,
		}
	end

	return state
end

function icebreaker_3_modifier_aura_effect:OnIntervalThink()
	local ability_hypo = self.caster:FindAbilityByName("icebreaker_1__hypo")
	if ability_hypo then
		if ability_hypo:IsTrained() then
			ability_hypo:AddSlow(self.parent, self.ability, self.min_stack, false)
		end
	end

	if IsServer() then
		self:StartIntervalThink(-1)
		self:StartIntervalThink(FrameTime())
	end
end

-- UTILS -----------------------------------------------------------

function icebreaker_3_modifier_aura_effect:AddFrozenState()
	if self.ability.shard_alive == false then return end
	if self.parent:IsHero() == false then return end
	if self.parent:IsMagicImmune() then return end
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then return end

	local ability_hypo = self.caster:FindAbilityByName("icebreaker_1__hypo")
	if ability_hypo == nil then return end
	if ability_hypo:IsTrained() == false then return end
		
	self.parent:AddNewModifier(self.caster, ability_hypo, "icebreaker_1_modifier_frozen", {
		duration = self.ability:CalcStatus(5, self.caster, self.parent) 
	}) 
end

function icebreaker_3_modifier_aura_effect:ApplyMirror()
	local mirror = self.caster:FindAbilityByName("icebreaker_4__mirror")
	if mirror == nil then return end

	-- UP 4.21
	if mirror:GetRank(21) then
		mirror:CreateMirrors(self.parent, 1)
	end
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_3_modifier_aura_effect:GetStatusEffectName()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber()
	and self:GetParent():HasModifier("icebreaker_0_modifier_passive_effect") then
		return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_radiant.vpcf"
	end
end

function icebreaker_3_modifier_aura_effect:StatusEffectPriority()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber()
	and self:GetParent():HasModifier("icebreaker_0_modifier_passive_effect") then
		return MODIFIER_PRIORITY_SUPER_ULTRA
	end
end

function icebreaker_3_modifier_aura_effect:GetEffectName()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber()
	and self:GetParent():HasModifier("icebreaker_0_modifier_passive_effect") then
		return "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf"
	end
end

function icebreaker_3_modifier_aura_effect:GetEffectAttachType()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber()
	and self:GetParent():HasModifier("icebreaker_0_modifier_passive_effect") then
		return PATTACH_ABSORIGIN_FOLLOW
	end
end

function icebreaker_3_modifier_aura_effect:PlayEffects()
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