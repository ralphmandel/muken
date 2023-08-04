hunter_2_modifier_camouflage = class({})

function hunter_2_modifier_camouflage:IsHidden() return false end
function hunter_2_modifier_camouflage:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_2_modifier_camouflage:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.moved = false

  self.invi = AddModifier(self.parent, self.ability, "_modifier_invisible", {
    delay = 0, spell_break = 0, attack_break = 0
  }, false)

  AddBonus(self.ability, "AGI", self.parent, self.ability:GetSpecialValueFor("agi"), 0, nil)

  if IsServer() then
    self:SetStackCount(self.ability:GetSpecialValueFor("hits"))
    self:PlayEfxCamouflage()
  end
end

function hunter_2_modifier_camouflage:OnRefresh(kv)
end

function hunter_2_modifier_camouflage:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_invisible", self.ability)
  RemoveBonus(self.ability, "AGI", self.parent)
end

function hunter_2_modifier_camouflage:OnDestroy(kv)
  if self.endCallback then self.endCallback(self.interrupted) end
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_2_modifier_camouflage:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_UNIT_MOVED,
    MODIFIER_EVENT_ON_ATTACK_START
	}

	return funcs
end

function hunter_2_modifier_camouflage:OnUnitMoved(keys)
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
      if self.invi then
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
    end
  else
    if keys.unit:GetTeamNumber() ~= self.parent:GetTeamNumber() then
      local dist = CalcDistanceBetweenEntityOBB(keys.unit, self.parent)
      if dist < self.ability:GetSpecialValueFor("reveal_range") and self.invi then
        self:Destroy()
      end
    end
  end
end

function hunter_2_modifier_camouflage:OnAttackStart(keys)
  if keys.attacker ~= self.parent then return end
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_invisible", self.ability)
  self.invi = nil

  if IsServer() then
    self:DecrementStackCount()

    if self.invi then
      self.invi = nil
      RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_invisible", self.ability)
      self:StartIntervalThink("buff_duration")
    end
  end
end

function hunter_2_modifier_camouflage:OnIntervalThink()
  if IsServer() then
    if self.invi then
      local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), self.ability:GetSpecialValueFor("tree_radius"), false)
      if trees then
        for k, v in pairs(trees) do
          self:StartIntervalThink(-1)
          return
        end
      end      
    end

    self:Destroy()
  end
end

function hunter_2_modifier_camouflage:OnStackCountChanged(old)
  if self:GetStackCount() ~= old and self:GetStackCount() == 0 then self:Destroy() end
end

-- UTILS -----------------------------------------------------------

function hunter_2_modifier_camouflage:SetEndCallback(func)
	self.endCallback = func
end

-- EFFECTS -----------------------------------------------------------

function hunter_2_modifier_camouflage:PlayEfxCamouflage()
	local particle_cast = "particles/units/heroes/hero_hoodwink/hoodwink_scurry_passive.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(125, 0, 0 ))
  self:AddParticle(effect_cast, false, false, -1, false, false)

  if IsServer() then self.parent:EmitSound("Hunter.Invi") end
end