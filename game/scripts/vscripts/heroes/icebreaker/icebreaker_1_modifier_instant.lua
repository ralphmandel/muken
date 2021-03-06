icebreaker_1_modifier_instant = class({})

--------------------------------------------------------------------------------

function icebreaker_1_modifier_instant:IsHidden()
	return true
end

function icebreaker_1_modifier_instant:IsPurgable()
    return false
end

function icebreaker_1_modifier_instant:IsStunDebuff()
	return true
end

function icebreaker_1_modifier_instant:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

--------------------------------------------------------------------------------

function icebreaker_1_modifier_instant:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self:PlayEfxStart()
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "icebreaker_1_modifier_instant_status_efx", true) end
end

function icebreaker_1_modifier_instant:OnRefresh( kv )
end

function icebreaker_1_modifier_instant:OnRemoved( kv )
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "icebreaker_1_modifier_instant_status_efx", false) end
end

--------------------------------------------------------------------------------

function icebreaker_1_modifier_instant:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

--------------------------------------------------------------------------------

function icebreaker_1_modifier_instant:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_radiant.vpcf"
end

function icebreaker_1_modifier_instant:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function icebreaker_1_modifier_instant:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_Icebreaker.Paralyse") end
end