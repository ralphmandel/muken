hunter_5_modifier_trap = class({})

function hunter_5_modifier_trap:IsHidden() return true end
function hunter_5_modifier_trap:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_5_modifier_trap:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.delay = 2

  AddModifier(self.parent, self.caster, self.ability, "_modifier_invisible", {delay = self.delay}, false)

  self.fow = AddFOWViewer(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.ability:GetSpecialValueFor("vision_radius"), self:GetDuration(), false
  )

  if IsServer() then
    self:PlayEfxStart()
    self:StartIntervalThink(0.2)
	end
end

function hunter_5_modifier_trap:OnRefresh(kv)
end

function hunter_5_modifier_trap:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_5_modifier_trap:OnIntervalThink()
  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
    self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
    self.ability:GetAbilityTargetFlags(), FIND_CLOSEST, false
  )

  for _,enemy in pairs(enemies) do
    if IsServer() then enemy:EmitSound("Hero_TemplarAssassin.Trap.Trigger") end
    if self.fow then RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow) end

    if self:GetElapsedTime() >= self.delay then
      AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.ability:GetSpecialValueFor("vision_radius"), 3, false)
      AddModifier(enemy, self.caster, self.ability, "hunter_5_modifier_debuff", {
        duration = self.ability:GetSpecialValueFor("debuff_duration")
      }, true)      
    end

    self:Destroy()
    return
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