bocuse_1_modifier_julienne = class({})

function bocuse_1_modifier_julienne:IsHidden() return true end
function bocuse_1_modifier_julienne:IsPurgable() return false end
function bocuse_1_modifier_julienne:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end
-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_1_modifier_julienne:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	ChangeActivity(self.parent, "")

	if IsServer() then self:OnIntervalThink() end
end

function bocuse_1_modifier_julienne:OnRefresh(kv)
end

function bocuse_1_modifier_julienne:OnRemoved()
	self.parent:FadeGesture(ACT_DOTA_ATTACK)
	ChangeActivity(self.parent, "trapper")
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_1_modifier_julienne:CheckState()
	local state = {[MODIFIER_STATE_DISARMED] = true}

  if self:GetAbility():GetSpecialValueFor("special_invulnerable") == 1 then
		table.insert(state, MODIFIER_STATE_STUNNED, false)
		table.insert(state, MODIFIER_STATE_HEXED, false)
	end

	return state
end

function bocuse_1_modifier_julienne:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_ORDER
	}

	return funcs
end

function bocuse_1_modifier_julienne:GetModifierAttackRangeBonus(keys)
	return 99999
end

function bocuse_1_modifier_julienne:GetModifierMoveSpeed_Limit(keys)
	return 200
end

function bocuse_1_modifier_julienne:GetModifierDisableTurning()
	return 1
end

function bocuse_1_modifier_julienne:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned() or self.parent:IsHexed() or self.parent:IsFrozen() then
		self:Destroy()
	end
end

function bocuse_1_modifier_julienne:OnOrder(keys)
	if keys.unit ~= self.parent then return end
	if keys.order_type > 4 and keys.order_type < 9 then
		self.interrupted = true
		self:Destroy()
	end
end

function bocuse_1_modifier_julienne:OnIntervalThink()
	if self.ability.total_slashes == 0 then
		self:Destroy()
	else
		self.ability:PerformSlash(self.ability.total_slashes)
		self.ability.total_slashes = self.ability.total_slashes - 1
	end
	
	if IsServer() then self:StartIntervalThink(1.33 / self.ability.cut_speed) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------