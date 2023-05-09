druid_4_modifier_fear = class ({})

function druid_4_modifier_fear:IsHidden() return false end
function druid_4_modifier_fear:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_4_modifier_fear:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.target = self.parent:GetAggroTarget()

  AddStatusEfx(self.ability, "druid_4_modifier_fear_status_efx", self.caster, self.parent)

  self.parent:AddNewModifier(self.caster, self.ability, "_modifier_percent_movespeed_debuff", {percent = 50})

	if IsServer() then self:OnIntervalThink() end
end

function druid_4_modifier_fear:OnRefresh(kv)
end

function druid_4_modifier_fear:OnRemoved(kv)
	if self.target then
		self.parent:MoveToTargetToAttack(self.target)
	else
		self.parent:Stop()
	end

  RemoveStatusEfx(self.ability, "druid_4_modifier_fear_status_efx", self.caster, self.parent)
end

function druid_4_modifier_fear:OnDestroy()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_4_modifier_fear:CheckState()
	local state = {
    [MODIFIER_STATE_FEARED] = true,
    [MODIFIER_STATE_COMMAND_RESTRICTED] = true
  }

	return state
end

-- UTILS -----------------------------------------------------------

function druid_4_modifier_fear:OnIntervalThink()
	local direction = (self.caster:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized() * -250
	local pos = self.parent:GetOrigin() + direction
	self.parent:MoveToPosition(pos)

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- EFFECTS -----------------------------------------------------------

function druid_4_modifier_fear:GetStatusEffectName()
  return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function druid_4_modifier_fear:StatusEffectPriority()
  return MODIFIER_PRIORITY_HIGH
end

function druid_4_modifier_fear:GetEffectName()
 return "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf"
end

function druid_4_modifier_fear:GetEffectAttachType()
 return PATTACH_ABSORIGIN_FOLLOW
end