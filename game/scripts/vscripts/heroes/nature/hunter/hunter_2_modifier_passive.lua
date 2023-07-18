hunter_2_modifier_passive = class({})

function hunter_2_modifier_passive:IsHidden() return true end
function hunter_2_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_2_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
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
    MODIFIER_EVENT_ON_ATTACK_START,
    MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function hunter_2_modifier_passive:OnUnitMoved(keys)
  local disable_invi = false

	if keys.unit == self.parent then
    disable_invi = true
    local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), self.ability:GetSpecialValueFor("tree_radius"), false)
    if trees then
      for _,tree in pairs(trees) do
        disable_invi = false
        break
      end
    end
  else
    if keys.unit:GetTeamNumber() ~= self.parent:GetTeamNumber() then
      if CalcDistanceBetweenEntityOBB(keys.unit, self.parent) < 90 then
        disable_invi = true
      end
    end
  end

  if disable_invi == true then
    self:SetCamouflage(false)
  end
end

function hunter_2_modifier_passive:OnAttackStart(keys)
  if keys.attacker ~= self.parent then return end
  self:SetCamouflage(false)
end

function hunter_2_modifier_passive:OnAttackLanded(keys)
  if keys.target ~= self.parent then return end
  self:SetCamouflage(false)
end

function hunter_2_modifier_passive:OnIntervalThink()
  local interval = self.ability:GetSpecialValueFor("delay_in")

  if self.parent:PassivesDisabled() == false and self.parent:IsAlive() then
    self:SetCamouflage(true)
    interval = -1
  end

  if IsServer() then self:StartIntervalThink(interval) end
end

-- UTILS -----------------------------------------------------------

function hunter_2_modifier_passive:SetCamouflage(bEnabled)
  if bEnabled then
    if self.invi == nil then
      self:PlayEfxCamouflage()
      self.invi = AddModifier(self.parent, self.caster, self.ability, "_modifier_invisible", {
        delay = 0, spell_break = 0, attack_break = 0
      }, false)

      self.invi:SetEndCallback(function(interrupted)
        self:StopEfxCamouflage()
        self.invi = nil
        if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("delay_in")) end
      end)
    end
  else
    if self.invi then
      if self.parent:HasModifier("hunter_2_modifier_delay_end") == false then
        AddModifier(self.parent, self.caster, self.ability, "hunter_2_modifier_delay_end", {
          duration = self.ability:GetSpecialValueFor("delay_out")
        }, false)      
      end
    else
      if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("delay_in")) end
    end
  end
end

-- EFFECTS -----------------------------------------------------------

function hunter_2_modifier_passive:PlayEfxCamouflage()
  self:StopEfxCamouflage()

	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_scurry_passive.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(125, 0, 0 ))

	self.effect_cast = effect_cast

  if IsServer() then self.parent:EmitSound("Hunter.Invi") end
end

function hunter_2_modifier_passive:StopEfxCamouflage()
	if not self.effect_cast then return end

	ParticleManager:DestroyParticle(self.effect_cast, false)
	ParticleManager:ReleaseParticleIndex(self.effect_cast)
end