druid_1_modifier_channel = class ({})

function druid_1_modifier_channel:IsHidden()
    return true
end

function druid_1_modifier_channel:IsPurgable()
    return false
end

-----------------------------------------------------------

function druid_1_modifier_channel:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local mod_efx = self.parent:FindModifierByName("druid__modifier_effect")
	if mod_efx then mod_efx:ChangeActivity("suffer") end

	local time = self:GetRemainingTime()
	local think = time - 1.65

	if think < 0 then
		local rate = 1 / (time / 1.65 )
		self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CAST4_STATUE, rate)
		return
	end

	self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, 0.8)
	self:StartIntervalThink(think)
end

function druid_1_modifier_channel:OnRefresh(kv)
end

function druid_1_modifier_channel:OnRemoved(kv)
	self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
	self.parent:FadeGesture(ACT_DOTA_CAST4_STATUE)

	local mod_efx = self.parent:FindModifierByName("druid__modifier_effect")
	if mod_efx then mod_efx:ChangeActivity("when_nature_attacks") end
end

------------------------------------------------------------

function druid_1_modifier_channel:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PRE_ATTACK
    }
    return funcs
end

function druid_1_modifier_channel:GetModifierPreAttack(keys)
    if keys.attacker == self.parent then self:Destroy() end
end

function druid_1_modifier_channel:OnIntervalThink()
	self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
	self.parent:StartGesture(ACT_DOTA_CAST4_STATUE)
	self:StartIntervalThink(-1)
end