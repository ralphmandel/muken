slayer__modifier_effect = class ({})

function slayer__modifier_effect:IsHidden()
    return true
end

function slayer__modifier_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function slayer__modifier_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function slayer__modifier_effect:OnRefresh(kv)
end

function slayer__modifier_effect:OnRemoved(kv)
end

------------------------------------------------------------

function slayer__modifier_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function slayer__modifier_effect:GetModifierPreAttack(keys)
	if IsServer() then self.parent:EmitSound("Hero_Slayer.Chain") end
end

function slayer__modifier_effect:OnAttack(keys)
	if keys.attacker == self.parent then
		if IsServer() then self.parent:EmitSound("Hero_Slayer.Chain") end
	end
end

function slayer__modifier_effect:OnAttackLanded(keys)
	if keys.attacker == self.parent then
		if IsServer() then
			self.parent:EmitSound("Hero_Centaur.Attack")
		end
	end
end

function slayer__modifier_effect:GetAttackSound(keys)
    return ""
end