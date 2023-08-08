hunter_u_modifier_passive = class({})

function hunter_u_modifier_passive:IsHidden() return true end
function hunter_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.delay = false

  if IsServer() then self:StartIntervalThink(0.1) end
end

function hunter_u_modifier_passive:OnRefresh(kv)
end

function hunter_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_u_modifier_passive:CheckState()
	local state = {
		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = self:GetParent():PassivesDisabled() == false
	}

	return state
end

function hunter_u_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_ATTACK_START
	}

	return funcs
end

function hunter_u_modifier_passive:OnAttackStart(keys)
  if keys.attacker == self.parent or keys.target == self.parent then return end
  self.delay = false
  if IsServer() then self:StartIntervalThink(0.1) end
end

function hunter_u_modifier_passive:OnIntervalThink()
  local has_tree = false
  local has_enemy = false
  local interval = 0.1

  if self.camo == nil and self.delay == true and self.parent:PassivesDisabled() == false and self.parent:IsAlive() then
    self.camo = AddModifier(self.parent, self.ability, "hunter_u_modifier_camouflage", {}, false)
    self.camo:SetEndCallback(function(interrupted)
      self.camo = nil
      self.delay = false
      if IsServer() then self:StartIntervalThink(0.1) end
    end)
  end

  local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), self.ability:GetSpecialValueFor("tree_radius"), false)
  if trees then
    for k, v in pairs(trees) do
      has_tree = true
      break
    end
  end

  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetSpecialValueFor("reveal_range"),
    DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, 0, false
  )

  for _,enemy in pairs(enemies) do
    has_enemy = true
    break
  end

  if has_tree == true and has_enemy == false then
    self.delay = true
    interval = self.ability:GetSpecialValueFor("delay_in")
  else
    self.delay = false
  end

  if IsServer() then self:StartIntervalThink(interval) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------