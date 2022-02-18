bloodstained__modifier_effect = class ({})

function bloodstained__modifier_effect:IsHidden()
    return true
end

function bloodstained__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function bloodstained__modifier_effect:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function bloodstained__modifier_effect:OnRefresh(kv)
end

------------------------------------------------------------

function bloodstained__modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function bloodstained__modifier_effect:OnAttackLanded(keys)
	if keys.attacker ~= self:GetParent() then return end
	if IsServer() then self:GetParent():EmitSound("Hero_Nightstalker.Attack") end
end

function bloodstained__modifier_effect:GetAttackSound(keys)
    return ""
end