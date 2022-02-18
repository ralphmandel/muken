crusader_3_modifier_call = class ({})

function crusader_3_modifier_call:IsHidden()
    return false
end

function crusader_3_modifier_call:IsPurgable()
    return true
end

function crusader_3_modifier_call:IsDebuff()
	return true
end

-----------------------------------------------------------

function crusader_3_modifier_call:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.parent:SetForceAttackTarget(self.caster)
	self.parent:MoveToTargetToAttack(self.caster)
	self.caster:AddNewModifier(self.caster, self.ability, "crusader_3_modifier_buff", {})

	local agi = self.parent:FindAbilityByName("_1_AGI")
	if agi then agi:SetBounds(50, 120) end
end

function crusader_3_modifier_call:OnRefresh(kv)
end

function crusader_3_modifier_call:OnRemoved(kv)
	self.parent:SetForceAttackTarget(nil)
	self.caster:RemoveModifierByName("crusader_3_modifier_buff")

	local agi = self.parent:FindAbilityByName("_1_AGI")
	if agi then agi:SetBounds(0, 120) end

	self.ability:SetActivated(true)
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

------------------------------------------------------------

function crusader_3_modifier_call:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function crusader_3_modifier_call:OnAttackLanded(keys)
	if keys.attacker ~= self.caster then return end
	if keys.target ~= self.parent then self:Destroy() end
end

-----------------------------------------------------------

function crusader_3_modifier_call:GetEffectName()
	return "particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_ti8_immortal_pitofmalice_stun_light.vpcf"
end

function crusader_3_modifier_call:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function crusader_3_modifier_call:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function crusader_3_modifier_call:StatusEffectPriority()
	return 4
end