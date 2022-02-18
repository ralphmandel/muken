crusader_u_modifier_ban = class({})

function crusader_u_modifier_ban:IsHidden()
	return true
end

function crusader_u_modifier_ban:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function crusader_u_modifier_ban:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.parent:AddActivityModifier("expired")
	self.parent:StartGesture(ACT_DOTA_DIE)
	self.parent:ClearActivityModifiers()

	self:StartIntervalThink(self:GetRemainingTime() - 0.5)
end

function crusader_u_modifier_ban:OnRefresh(kv)
end

function crusader_u_modifier_ban:OnRemoved(kv)
	local reborn_duration = self.ability:GetSpecialValueFor("reborn_duration")

	-- UP 4.4
	if self.ability:GetRank(4) then
		reborn_duration = reborn_duration  + 3
	end

	self.parent:AddNewModifier(self.caster, self.ability, "crusader_u_modifier_reborn", {duration = reborn_duration})
end

-----------------------------------------------------------

function crusader_u_modifier_ban:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

	return state
end

function crusader_u_modifier_ban:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}

	return funcs
end

function crusader_u_modifier_ban:GetMinHealth()
    return 1
end

function crusader_u_modifier_ban:OnIntervalThink()
	self.parent:FadeGesture(ACT_DOTA_DIE)
    self.parent:StartGesture(ACT_DOTA_SPAWN)
	self:StartIntervalThink(-1)
end