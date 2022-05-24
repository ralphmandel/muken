genuine__modifier_effect = class ({})

function genuine__modifier_effect:IsHidden()
    return true
end

function genuine__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function genuine__modifier_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.activity = "ti6"
end

function genuine__modifier_effect:OnRefresh(kv)
end

function genuine__modifier_effect:OnRemoved(kv)
end

------------------------------------------------------------

function genuine__modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}

	return funcs
end

function genuine__modifier_effect:OnAttack(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("Hero_DrowRanger.Attack") end
end

function genuine__modifier_effect:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("Hero_DrowRanger.ProjectileImpact") end
end

function genuine__modifier_effect:GetAttackSound(keys)
    return ""
end

function genuine__modifier_effect:GetActivityTranslationModifiers(keys)
    return self.activity
end

function genuine__modifier_effect:ChangeActivity(string)
    self.activity = string
end