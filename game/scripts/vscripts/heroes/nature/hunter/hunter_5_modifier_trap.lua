hunter_5_modifier_trap = class({})

function hunter_5_modifier_trap:IsHidden() return true end
function hunter_5_modifier_trap:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_5_modifier_trap:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.hits = self.ability:GetSpecialValueFor("hits") * 4
  self.min_health = self.hits

  Timers:CreateTimer(FrameTime(), function()
    self.parent:ModifyHealth(self.hits, self.ability, false, 0)
  end)

  self.fow = AddFOWViewer(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.ability:GetSpecialValueFor("vision_radius"), self:GetDuration(), false
  )

  AddModifier(self.parent, self.ability, "hunter_5_modifier_trap_invi", {}, false)

  if IsServer() then
    self:PlayEfxStart()
    self:StartIntervalThink(FrameTime())
	end
end

function hunter_5_modifier_trap:OnRefresh(kv)
end

function hunter_5_modifier_trap:OnRemoved()
  self.parent:SetModelScale(0)
  if IsServer() then self.parent:EmitSound("Hero_TemplarAssassin.Trap.Trigger") end
  if self.fow then RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow) end

  if self.parent:IsAlive() then self.parent:Kill(self.ability, nil) end
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_5_modifier_trap:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
    [MODIFIER_STATE_CANNOT_BE_MOTION_CONTROLLED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true,
    [MODIFIER_STATE_NO_TEAM_MOVE_TO] = true
	}

	return state
end

function hunter_5_modifier_trap:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTHBAR_PIPS,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
		MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function hunter_5_modifier_trap:GetModifierHealthBarPips(keys)
	return self:GetParent():GetMaxHealth() / 4
end

function hunter_5_modifier_trap:GetDisableHealing()
	return 1
end

function hunter_5_modifier_trap:GetMinHealth()
	return self.min_health
end

function hunter_5_modifier_trap:GetModifierExtraHealthBonus()
	return self.hits - 1
end

function hunter_5_modifier_trap:OnAttacked(keys)
	if keys.target ~= self.parent then return end
  self.min_health = self.min_health - GetPipHitDamage(keys.attacker)
end

function hunter_5_modifier_trap:OnIntervalThink()
  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
    self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
    self.ability:GetAbilityTargetFlags(), FIND_CLOSEST, false
  )

  for _,enemy in pairs(enemies) do
    AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.ability:GetSpecialValueFor("vision_radius"), 3, false)
    
    AddModifier(enemy, self.ability, "hunter_5_modifier_debuff", {
      duration = self.ability:GetSpecialValueFor("debuff_duration")
    }, true)

    AddModifier(enemy, self.ability, "_modifier_pull", {
      duration = 0.1, x = self.parent:GetOrigin().x, y = self.parent:GetOrigin().y
    }, false)

    self:Destroy()
  end

  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function hunter_5_modifier_trap:PlayEfxStart()
	local string = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_lookout.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
  self:AddParticle(particle, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Techies.RemoteMine.Plant") end
end