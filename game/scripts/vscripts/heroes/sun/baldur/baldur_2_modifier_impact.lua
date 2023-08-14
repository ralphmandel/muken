baldur_2_modifier_impact = class({})

function baldur_2_modifier_impact:IsHidden() return true end
function baldur_2_modifier_impact:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_2_modifier_impact:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.target = EntIndexToHScript(kv.target)
  self.damage = kv.damage
  self.stun_duration = kv.stun_duration

	if IsServer() then
		self.parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 2)
		self:StartIntervalThink(0.15)
	end
end

function baldur_2_modifier_impact:OnRefresh(kv)
end

function baldur_2_modifier_impact:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function baldur_2_modifier_impact:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true
	}

	return state
end

function baldur_2_modifier_impact:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING
	}

	return funcs
end

function baldur_2_modifier_impact:GetModifierDisableTurning()
	return 1
end

function baldur_2_modifier_impact:OnIntervalThink()
	if self.target == nil then return end
	if IsValidEntity(self.target) == false then return end

	if IsServer() then
		self.target:EmitSound("Hero_Bristleback.Attack")
    ApplyBash(self.target, self.ability, self.stun_duration, self.damage, true)
		self:StartIntervalThink(-1)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------