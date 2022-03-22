ancient_1_modifier_berserk = class ({})

function ancient_1_modifier_berserk:IsHidden()
    return false
end

function ancient_1_modifier_berserk:IsPurgable()
    return false
end

-----------------------------------------------------------

function ancient_1_modifier_berserk:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local agi_mod = self.parent:FindModifierByName("_1_AGI_modifier")
	if agi_mod then agi_mod:SetBaseAttackTime(0) end
end

function ancient_1_modifier_berserk:OnRefresh(kv)
end

function ancient_1_modifier_berserk:OnRemoved(kv)
end

------------------------------------------------------------

function ancient_1_modifier_berserk:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BASE_OVERRIDE,
	}
	
	return funcs
end

function ancient_1_modifier_berserk:GetModifierAttackSpeedBaseOverride(keys)
	return 1.25
end