hunter_u_modifier_passive = class({})

function hunter_u_modifier_passive:IsHidden() return true end
function hunter_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self:StartDelay()

  if IsServer() then self:StartIntervalThink(0.1) end
end

function hunter_u_modifier_passive:OnRefresh(kv)
end

function hunter_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_u_modifier_passive:CheckState()
	local state = {
		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = self:GetParent():PassivesDisabled() == false and self:GetAbility():IsCooldownReady()
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
  if keys.attacker ~= self.parent and keys.target ~= self.parent then return end
  if self.camo then return end

  self:StartDelay()
end

function hunter_u_modifier_passive:OnIntervalThink()
  if self.camo == nil and self.ability:IsCooldownReady()
  and self.parent:PassivesDisabled() == false and self.parent:IsAlive() then
    self.camo = AddModifier(self.parent, self.ability, "hunter_u_modifier_camouflage", {}, false)
    self.camo:SetEndCallback(function(interrupted)
      self.camo = nil
      self:StartDelay()
      if IsServer() then self:StartIntervalThink(0.1) end
    end)

    if IsServer() then self:StartIntervalThink(-1) end
    return
  end

  local has_tree = false
  local has_enemy = false

  local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), self.ability:GetSpecialValueFor("tree_radius"), false)
  if trees then
    for k, v in pairs(trees) do
      has_tree = true
      break
    end
  end

  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetSpecialValueFor("reveal_range"),
    DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_NONE, 0, false
  )

  for _,enemy in pairs(enemies) do
    has_enemy = true
    break
  end

  if has_tree == false or has_enemy == true then
    self:StartDelay()
  end

  if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

function hunter_u_modifier_passive:StartDelay()
  if self.camo then return end
  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

-- EFFECTS -----------------------------------------------------------