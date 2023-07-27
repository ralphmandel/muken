fountain_modifier_aura_effect = class({})

function fountain_modifier_aura_effect:IsHidden() return false end
function fountain_modifier_aura_effect:IsPurgable() return false end

function fountain_modifier_aura_effect:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.team = self.parent:GetTeamNumber()

	if IsServer() then
    self:StartIntervalThink(1)
  end
end

function fountain_modifier_aura_effect:OnRefresh( kv )
end

function fountain_modifier_aura_effect:OnRemoved()
end

--------------------------------------------------------------------------------------------------------------------------

function fountain_modifier_aura_effect:CheckState()
	local state = {
    [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
    [MODIFIER_STATE_ALLOW_PATHING_THROUGH_FISSURE] = true,
    [MODIFIER_STATE_ALLOW_PATHING_THROUGH_OBSTRUCTIONS] = true,
    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
    [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true,
  }

	return state
end

function fountain_modifier_aura_effect:OnIntervalThink()
  local interval = 0.2

  if SHRINE_INFO[self.team]["shrine_state"] == SHRINE_STATE_ENABLED then
    local allies = FindUnitsInRadius(
      self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, 200,
      DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,
      DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, FIND_CLOSEST, false
    )
  
    for _,ally in pairs(allies) do
      if ally:GetHealthPercent() < 50 then
        self:ApplyRecovery(ally)
        SHRINE_INFO[self.team]["shrine_state"] = SHRINE_STATE_DISABLED
        self:PlayEfxRecovery()
        interval = 120
        break
      end
    end
  elseif SHRINE_INFO[self.team]["shrine_state"] == SHRINE_STATE_DISABLED then
    self:PlayEfxAmbient()
    SHRINE_INFO[self.team]["shrine_state"] = SHRINE_STATE_ENABLED
  end

  if IsServer() then self:StartIntervalThink(interval) end
end

function fountain_modifier_aura_effect:ApplyRecovery(target)
  local recovery = 300 + target:GetMaxMana() * 0.2
  if target:GetUnitName() == "npc_dota_hero_elder_titan" then recovery = 0 end
  IncreaseMana(target, recovery)
  target:Heal(1500, nil)
end

--------------------------------------------------------------------------------------------------------------------------

function fountain_modifier_aura_effect:PlayEfxRecovery()
  if self.ambient then ParticleManager:DestroyParticle(self.ambient, true) self.ambient = nil end
  if self.fow then RemoveFOWViewer(self.parent:GetTeamNumber(), self.fow) self.fow = nil end

	local particle_cast = "particles/world_shrine/radiant_shrine_active.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

  if IsServer() then
    self.parent:StopSound("Shrine.Recharged")
    self.parent:EmitSound("Shrine.Cast")
  end
end

function fountain_modifier_aura_effect:PlayEfxAmbient()
  self.fow = AddFOWViewer(self.parent:GetTeamNumber(), self.parent:GetOrigin(), 200, 9999, false)

	local particle_cast = "particles/world_shrine/radiant_shrine_ambient.vpcf"
	self.ambient = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.ambient, 0, self.parent:GetOrigin())

  if IsServer() then self.parent:EmitSoundParams("Shrine.Recharged", 0, 3, 0) end
end

-- function fountain_modifier_aura_effect:PlayEfxHeal(target)
-- 	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
-- 	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
-- 	ParticleManager:SetParticleControl(effect_cast, 1, target:GetOrigin())
-- 	ParticleManager:ReleaseParticleIndex(effect_cast)
-- end

-- function fountain_modifier_aura_effect:PlayEfxMana(target)
-- 	local particle_cast = "particles/generic/give_mana.vpcf"
-- 	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
-- 	ParticleManager:SetParticleControl(effect_cast, 1, target:GetOrigin())
-- 	ParticleManager:ReleaseParticleIndex(effect_cast)
-- end

-- function fountain_modifier_aura_effect:PlayEfxStart()
-- 	if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end

-- 	local string = nil
-- 	if self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_1 then
-- 		string = "particles/econ/events/fall_2022/regen/fountain_regen_fall2022_lvl3.vpcf"
-- 	elseif self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_2 then
-- 		string = "particles/econ/events/ti7/fountain_regen_ti7_lvl3.vpcf"
-- 	elseif self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_3 then
-- 		string = "particles/econ/events/spring_2021/fountain_regen_spring_2021_lvl3.vpcf"
-- 	elseif self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_4 then
-- 		string = "particles/econ/events/fall_major_2016/radiant_fountain_regen_fm06_lvl3.vpcf"
-- 	end

-- 	if string == nil then return end

-- 	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
-- 	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
-- 	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
-- 	self:AddParticle(effect_cast, false, false, -1, false, false)
-- end