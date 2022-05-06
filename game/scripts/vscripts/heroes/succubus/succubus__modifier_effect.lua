succubus__modifier_effect = class ({})

function succubus__modifier_effect:IsHidden()
    return true
end

function succubus__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function succubus__modifier_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.activity = "dagger_twirl"
	
end

function succubus__modifier_effect:OnRefresh(kv)
end

function succubus__modifier_effect:OnRemoved(kv)
end

------------------------------------------------------------

function succubus__modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}

	return funcs
end

function succubus__modifier_effect:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("Hero_QueenOfPain.ProjectileImpact") end
end

function succubus__modifier_effect:GetAttackSound(keys)
    return ""
end

function succubus__modifier_effect:GetActivityTranslationModifiers(keys)
    return self.activity
end

function succubus__modifier_effect:ChangeActivity(string)
    self.activity = string
end