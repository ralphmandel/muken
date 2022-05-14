template__modifier_effect = class ({})

function template__modifier_effect:IsHidden()
    return true
end

function template__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function template__modifier_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function template__modifier_effect:OnRefresh(kv)
end

function template__modifier_effect:OnRemoved(kv)
end

------------------------------------------------------------

function template__modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
	}

	return funcs
end

function template__modifier_effect:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("") end
end

function template__modifier_effect:GetAttackSound(keys)
    return ""
end