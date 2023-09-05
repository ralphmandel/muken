hunter_3_modifier_radar = class({})

function hunter_3_modifier_radar:IsHidden() return true end
function hunter_3_modifier_radar:IsPurgable() return false end

local RADAR_STATE_SEARCHING = 1
local RADAR_STATE_FOW = 2
local RADAR_STATE_REVEAL = 3

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_3_modifier_radar:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.radius = self.ability:GetAOERadius()
  self.bonus_radius = self.ability:GetSpecialValueFor("bonus_radius")
  self.state = RADAR_STATE_SEARCHING

  local loc = self.parent:GetOrigin()
  local search_time = self.ability:GetSpecialValueFor("search_time")

  MinimapEvent(self.caster:GetTeamNumber(), self.caster, loc.x, loc.y, DOTA_MINIMAP_EVENT_RADAR, search_time)

  if IsServer() then
    EmitSoundOnLocationForAllies(self.parent:GetOrigin(), "scan_minimap.activate", self.caster)
    self:SetDuration(search_time, true)
    self:StartIntervalThink(1)
  end
end

function hunter_3_modifier_radar:OnRefresh(kv)
end

function hunter_3_modifier_radar:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_3_modifier_radar:OnIntervalThink()
  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius,
    self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
    self.ability:GetAbilityTargetFlags(), 0, false
  )

  if self.state == RADAR_STATE_SEARCHING then
    if IsServer() then EmitSoundOnLocationForAllies(self.parent:GetOrigin(), "minimap_radar.cycle", self.caster) end

    for _,enemy in pairs(enemies) do
      if self.caster:CanEntityBeSeenByMyTeam(enemy) == false then
        self.state = RADAR_STATE_FOW
        self:SetDuration(self.ability:GetSpecialValueFor("fow_time"), true)
        if IsServer() then self:StartIntervalThink(0.1) end
        return
      end
    end
  end

  if self.state == RADAR_STATE_FOW then
    if IsServer() then EmitSoundOnLocationForAllies(self.parent:GetOrigin(), "minimap_radar.target", self.caster) end

    local loc = self.parent:GetOrigin()
    MinimapEvent(self.caster:GetTeamNumber(), self.caster, loc.x, loc.y, DOTA_MINIMAP_EVENT_RADAR_TARGET, 1)
    AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.bonus_radius, self:GetDuration(), false)
    self.state = RADAR_STATE_REVEAL
  end

  if self.state == RADAR_STATE_REVEAL then
    for _,enemy in pairs(enemies) do
      RemoveAllModifiersByNameAndAbility(enemy, "_modifier_truesight", self.ability)
      AddModifier(enemy, self.ability, "_modifier_truesight", {duration = 1}, false)
    end
  end

  if IsServer() then self:StartIntervalThink(0.5) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------