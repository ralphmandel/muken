genuine_4_modifier_channeling = class({})

function genuine_4_modifier_channeling:IsHidden() return true end
function genuine_4_modifier_channeling:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_4_modifier_channeling:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.bot_script = self.parent:FindModifierByName("_general_script")

  if IsServer() then self:StartIntervalThink(0.1) end
end

function genuine_4_modifier_channeling:OnRefresh(kv)
end

function genuine_4_modifier_channeling:OnRemoved()
  self.parent:InterruptChannel()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_4_modifier_channeling:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
	
	return funcs
end

function genuine_4_modifier_channeling:GetModifierConstantManaRegen()
  local ability = self:GetAbility()
	return -ability:GetManaCost(ability:GetLevel()) * (ability:GetSpecialValueFor("channel_time") / ability:GetChannelTime())
end

function genuine_4_modifier_channeling:OnIntervalThink()
  if self.bot_script then
    if self:CheckTargetPos(self.bot_script.attack_target) == false then self.ability:EndChannel(false) end
  end

  if self.parent:GetMana() < 10 then self:Destroy() return end
  if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

function genuine_4_modifier_channeling:CheckTargetPos(target)
  if target == nil then return false end
  if IsValidEntity(target) == false then return false end
  if self.parent:CanEntityBeSeenByMyTeam(target) == false then return false end

  local angle = VectorToAngles(target:GetOrigin() - self.parent:GetOrigin())
  local angle_diff = AngleDiff(self.parent:GetAngles().y, angle.y)
  local distance_diff = CalcDistanceBetweenEntityOBB(self.parent, target)
  local moved_distance = distance_diff * (math.sin(math.rad(angle_diff)))
  if moved_distance < 0 then moved_distance = 0 - moved_distance end
  if moved_distance > 50 then self.ability:EndChannel(false) end

  return true
end

-- EFFECTS -----------------------------------------------------------