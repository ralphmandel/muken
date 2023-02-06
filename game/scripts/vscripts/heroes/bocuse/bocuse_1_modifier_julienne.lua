bocuse_1_modifier_julienne = class({})

function bocuse_1_modifier_julienne:IsHidden() return true end
function bocuse_1_modifier_julienne:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_1_modifier_julienne:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.parent:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
	self.total_slashes = self.ability:GetSpecialValueFor("max_cut")

	local base_hero_mod = self.parent:FindModifierByName("base_hero_mod")
	if base_hero_mod then base_hero_mod:ChangeActivity("") end

	if IsServer() then self:OnIntervalThink() end
end

function bocuse_1_modifier_julienne:OnRefresh(kv)
end

function bocuse_1_modifier_julienne:OnRemoved()
	self.parent:FadeGesture(ACT_DOTA_ATTACK)

	local base_hero_mod = self.parent:FindModifierByName("base_hero_mod")
	if base_hero_mod then base_hero_mod:ChangeActivity("trapper") end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_1_modifier_julienne:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true
	}

	return state
end

function bocuse_1_modifier_julienne:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_ORDER
	}

	return funcs
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
	if self.total_slashes == 0 then
		self:Destroy()
	else
		self.ability:PerformSlash(self.total_slashes)
		self.total_slashes = self.total_slashes - 1
	end
	
	if IsServer() then self:StartIntervalThink(0.26) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------