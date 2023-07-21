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

function hunter_2_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_UNIT_MOVED,
    MODIFIER_EVENT_ON_ATTACK_START,
    MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function hunter_2_modifier_passive:OnUnitMoved(keys)
	if keys.unit == self.parent then
    local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), self.ability:GetSpecialValueFor("tree_radius"), false)
    if trees then
      for k, v in pairs(trees) do
        return
      end
    end
    self:StartDelay()
  else
    if keys.unit:GetTeamNumber() ~= self.parent:GetTeamNumber() then
      if CalcDistanceBetweenEntityOBB(keys.unit, self.parent) < 100 then
        self:StartDelay()
      end
    end
  end
end

function hunter_2_modifier_passive:OnAttackStart(keys)
  if keys.attacker ~= self.parent then return end
  self:StartDelay()
end

function hunter_2_modifier_passive:OnAttackLanded(keys)
  if keys.target ~= self.parent then return end
  self:StartDelay()
end

function hunter_2_modifier_passive:OnIntervalThink()
  local interval = self.ability:GetSpecialValueFor("delay_in")

  if self.parent:PassivesDisabled() == false and self.parent:IsAlive() then
    if self.camo == nil then
      self.camo = AddModifier(self.parent, self.caster, self.ability, "hunter_2_modifier_camouflage", {}, false)
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