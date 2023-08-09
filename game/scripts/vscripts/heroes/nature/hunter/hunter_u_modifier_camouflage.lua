hunter_u_modifier_camouflage = class({})

function hunter_u_modifier_camouflage:IsHidden() return false end
function hunter_u_modifier_camouflage:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_u_modifier_camouflage:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.moved = false
  self.records = {}

  self.invi = AddModifier(self.parent, self.ability, "_modifier_invisible", {
    delay = 0, spell_break = 0, attack_break = 0
  }, false)

  if IsServer() then self:SetEfxCamouflage(true) end
end

function hunter_u_modifier_camouflage:OnRefresh(kv)
end

function hunter_u_modifier_camouflage:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_invisible", self.ability)
end

function hunter_u_modifier_camouflage:OnDestroy(kv)
  if self.endCallback then self.endCallback(self.interrupted) end
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_u_modifier_camouflage:CheckState()
	local state = {
		[MODIFIER_STATE_FORCED_FLYING_VISION] = true
	}

	return state
end

function hunter_u_modifier_camouflage:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
    MODIFIER_EVENT_ON_ATTACK,
    MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_RECORD_DESTROY,
    MODIFIER_EVENT_ON_STATE_CHANGED,
    MODIFIER_EVENT_ON_UNIT_MOVED
	}

	return funcs
end

function hunter_u_modifier_camouflage:GetModifierInvisibilityLevel()
	return 1
end

function hunter_u_modifier_camouflage:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("vision_range")
end

function hunter_u_modifier_camouflage:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("vision_range")
end

function hunter_u_modifier_camouflage:GetModifierAttackRangeBonus()
  return self:GetAbility():GetSpecialValueFor("atk_range")
end

function hunter_u_modifier_camouflage:GetModifierProcAttack_BonusDamage_Physical(keys)
	if self.records[keys.record] then
    return self.records[keys.record] * self.ability:GetSpecialValueFor("bonus_damage") * 0.01
	end
end

function hunter_u_modifier_camouflage:OnAttack(keys)
	if keys.attacker ~= self.parent then return end

  self.records[keys.record] = CalcDistanceBetweenEntityOBB(self.parent, keys.target)
end

function hunter_u_modifier_camouflage:OnAttackStart(keys)
  if keys.attacker ~= self.parent then return end
  AddModifier(keys.target, self.ability, "_modifier_no_vision_attacker", {duration = 0.5}, false)
end

function hunter_u_modifier_camouflage:OnAttackRecordDestroy(keys)
	self.records[keys.record] = nil
end

function hunter_u_modifier_camouflage:OnStateChanged(keys)
  if keys.unit ~= self.parent then return end
  if self.parent:PassivesDisabled() then self:Destroy() end
end

function hunter_u_modifier_camouflage:OnUnitMoved(keys)
	if keys.unit == self.parent then
    local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), self.ability:GetSpecialValueFor("tree_radius"), false)
    local has_tree = false    
    if trees then
      for k, v in pairs(trees) do
        has_tree = true
        break
      end
    end

    if IsServer() then
      if has_tree == true then
        self.moved = false
        self:StartIntervalThink(-1)
      else
        if self.moved == false then
          self.moved = true
          self:StartIntervalThink(self.ability:GetSpecialValueFor("delay_out"))            
        end
      end
    end
  else
    if keys.unit:GetTeamNumber() ~= self.parent:GetTeamNumber() then
      local dist = CalcDistanceBetweenEntityOBB(keys.unit, self.parent)
      if dist < self.ability:GetSpecialValueFor("reveal_range") then
        self:Destroy()
      end
    end
  end
end

function hunter_u_modifier_camouflage:OnIntervalThink()
  if IsServer() then
    local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), self.ability:GetSpecialValueFor("tree_radius"), false)
    if trees then
      for k, v in pairs(trees) do
        self:StartIntervalThink(-1)
        return
      end
    end

    self:Destroy()
  end
end

-- UTILS -----------------------------------------------------------

function hunter_u_modifier_camouflage:SetEndCallback(func)
	self.endCallback = func
end

-- EFFECTS -----------------------------------------------------------

function hunter_u_modifier_camouflage:SetEfxCamouflage(bEnabled)
  if bEnabled then
    local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_scurry_passive.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(effect_cast, 2, Vector(125, 0, 0 ))
    self:AddParticle(effect_cast, false, false, -1, false, false)
  
    if IsServer() then self.parent:EmitSound("Hunter.Invi") end
  end
end