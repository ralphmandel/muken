hunter_2_modifier_passive = class({})

function hunter_2_modifier_passive:IsHidden() return true end
function hunter_2_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_2_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function hunter_2_modifier_passive:OnRefresh(kv)
end

function hunter_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_2_modifier_passive:CheckState()
	local state = {
		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true
	}

	return state
end

function hunter_2_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_UNIT_MOVED,
    MODIFIER_EVENT_ON_ATTACK_START
	}

	return funcs
end

function hunter_2_modifier_passive:OnUnitMoved(keys)
  if keys.unit == self.parent then
    local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), self.ability:GetSpecialValueFor("tree_radius"), false)
    local has_tree = false    
    if trees then
      for k, v in pairs(trees) do
        has_tree = true
        break
      end
    end

    if has_tree == true then
      self:StartDelay()
    else
      if IsServer() then self:StartIntervalThink(-1) end
    end
  else
    if keys.unit:GetTeamNumber() ~= self.parent:GetTeamNumber() then
      local dist = CalcDistanceBetweenEntityOBB(keys.unit, self.parent)
      if dist < self.ability:GetSpecialValueFor("reveal_range") then
        self:StartDelay()
      end
    end
  end

	if keys.unit == self.parent then return end
  if keys.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return end

  local dist = CalcDistanceBetweenEntityOBB(keys.unit, self.parent)
  if dist < self.ability:GetSpecialValueFor("reveal_range") then
  end
end

function hunter_2_modifier_passive:OnAttackStart(keys)
  if keys.attacker ~= self.parent and keys.target ~= self.parent then return end
  if IsServer() then self:StartIntervalThink(-1) end
end

function hunter_2_modifier_passive:OnIntervalThink()
  local interval = self.ability:GetSpecialValueFor("delay_in")

  if self.parent:PassivesDisabled() == false and self.parent:IsAlive() then
    if self.camo == nil then
      self.camo = AddModifier(self.parent, self.ability, "hunter_2_modifier_camouflage", {}, false)
      self.camo:SetEndCallback(function(interrupted)
        self.camo = nil
        if IsServer() then
          self:StartIntervalThink(self.ability:GetSpecialValueFor("delay_in"))
        end
      end)
    end

    interval = -1
  end

  if IsServer() then self:StartIntervalThink(interval) end
end

-- UTILS -----------------------------------------------------------

function hunter_2_modifier_passive:StartDelay()
  if self.camo == nil then
    if IsServer() then
      self:StartIntervalThink(self.ability:GetSpecialValueFor("delay_in"))
    end
  end
end

-- EFFECTS -----------------------------------------------------------