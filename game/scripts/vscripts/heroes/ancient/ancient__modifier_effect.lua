ancient__modifier_effect = class ({})

function ancient__modifier_effect:IsHidden()
    return true
end

function ancient__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function ancient__modifier_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.activity = "et_2021"
end

function ancient__modifier_effect:OnRefresh(kv)
end

function ancient__modifier_effect:OnRemoved(kv)
end

------------------------------------------------------------

function ancient__modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}

	return funcs
end

function ancient__modifier_effect:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("Hero_ElderTitan.Attack") end
end

function ancient__modifier_effect:GetAttackSound(keys)
    return ""
end

function ancient__modifier_effect:GetActivityTranslationModifiers()
    return self.activity
end

function ancient__modifier_effect:ChangeActivity(string)
    self.activity = string
end

function ancient__modifier_effect:GetModifierConstantManaRegen()
	if self.parent:HasModifier("ancient_3_modifier_aura") then return 0 end
    return -5
end