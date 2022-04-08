ancient_u_modifier_pos = class ({})

function ancient_u_modifier_pos:IsHidden()
    return true
end

function ancient_u_modifier_pos:IsPurgable()
    return false
end

function ancient_u_modifier_pos:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

-----------------------------------------------------------

function ancient_u_modifier_pos:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.delay = true

	if IsServer() then
        self.parent:FindModifierByName("ancient__modifier_effect"):ChangeActivity("")
        self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_1)
		self:StartIntervalThink(0.55)
	end
end

function ancient_u_modifier_pos:OnRefresh(kv)
end

function ancient_u_modifier_pos:OnRemoved(kv)
    self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
	self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_5)
    self.parent:FindModifierByName("ancient__modifier_effect"):ChangeActivity("et_2021")
end

------------------------------------------------------------

function ancient_u_modifier_pos:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_PRE_ATTACK
    }
    return funcs
end

function ancient_u_modifier_pos:GetModifierPreAttack(keys)
    if keys.attacker == self.parent then self:Destroy() end
end

function ancient_u_modifier_pos:OnIntervalThink()
    if self.delay == true then
        self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
        self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_5)
        self.delay = false
        self:StartIntervalThink(0.1)
        return
    end

	if self.parent:IsMoving() then self:Destroy() end
end