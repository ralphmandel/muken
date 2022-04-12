bocuse_2_modifier_casting = class ({})

function bocuse_2_modifier_casting:IsHidden()
    return true
end

function bocuse_2_modifier_casting:IsPurgable()
    return false
end

-----------------------------------------------------------

function bocuse_2_modifier_casting:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if self.ability.target == self.parent then
		self.parent:AddActivityModifier("trapper")
		self.parent:StartGestureWithPlaybackRate(ACT_DOTA_VICTORY, 2)
	else
		local rand = RandomInt(1,3)
		--if rand == 1 then self.parent:AddActivityModifier("ti10_pudge") end
		if rand == 2 then self.parent:AddActivityModifier("ftp_dendi_back") end
		if rand == 3 then self.parent:AddActivityModifier("trapper") end
		self.parent:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		self:StartIntervalThink(0.4)
	end
end

function bocuse_2_modifier_casting:OnRefresh(kv)
end

function bocuse_2_modifier_casting:OnRemoved()
    self.parent:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
    self.parent:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_1)
    self.parent:FadeGesture(ACT_DOTA_VICTORY)
	self.parent:ClearActivityModifiers()
end

-----------------------------------------------------------

function bocuse_2_modifier_casting:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PRE_ATTACK
    }
    return funcs
end

function bocuse_2_modifier_casting:GetModifierPreAttack(keys)
    if keys.attacker == self.parent then self:Destroy() end
end

function bocuse_2_modifier_casting:OnIntervalThink()
	self.parent:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	self.parent:StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)
	self:StartIntervalThink(-1)
end