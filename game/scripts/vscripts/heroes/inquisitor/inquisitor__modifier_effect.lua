inquisitor__modifier_effect = class ({})

function inquisitor__modifier_effect:IsHidden()
    return true
end

function inquisitor__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function inquisitor__modifier_effect:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function inquisitor__modifier_effect:OnRefresh(kv)
end

------------------------------------------------------------

function inquisitor__modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function inquisitor__modifier_effect:OnAttackLanded(keys)
	if keys.attacker ~= self:GetParent() then return end
	if IsServer() then self:GetParent():EmitSound("Hero_Dawnbreaker.Attack") end
end

function inquisitor__modifier_effect:GetAttackSound(keys)
    return ""
end

-----------------------------------------------------------

function inquisitor__modifier_effect:GetStatusEffectName()
	--return "particles/econ/items/effigies/status_fx_effigies/se_effigy_ti6_lvl2.vpcf"
	--return "particles/econ/items/effigies/status_fx_effigies/se_effigy_fm16_rad_lvl2.vpcf"
	--return "particles/status_fx/status_effect_slardar_crush.vpcf"
end

function inquisitor__modifier_effect:StatusEffectPriority()
	return MODIFIER_PRIORITY_LOW
end