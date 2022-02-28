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

	self.delay_sound = 0
	self:StartIntervalThink(0.2)
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
			self.parent:EmitSound("Hero_Juggernaut.Attack")
		end
	end
end

function slayer__modifier_effect:GetAttackSound(keys)
    return ""
end

function slayer__modifier_effect:OnIntervalThink()
    if self.delay_sound > 0 then
		self.delay_sound = self.delay_sound - 1
		return
	end

	if RandomInt(1, 100) <= 10 
	and self.parent:IsMoving() then
		if IsServer() then self.parent:EmitSound("Hero_Slayer.Chain2") end
		self.delay_sound = 5
	end
end