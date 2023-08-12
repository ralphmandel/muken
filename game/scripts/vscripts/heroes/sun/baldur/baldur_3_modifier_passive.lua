baldur_3_modifier_passive = class({})

function baldur_3_modifier_passive:IsHidden() return false end
function baldur_3_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_3_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.damage_taken = 0
end

function baldur_3_modifier_passive:OnRefresh(kv)
end

function baldur_3_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function baldur_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function baldur_3_modifier_passive:OnTakeDamage(keys)
  if keys.unit ~= self.parent then return end
  if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
  if self.parent:PassivesDisabled() then return end
  if self.parent:HasModifier("baldur_3_modifier_barrier") then return end
  if not IsServer() then return end

  self.damage_taken = self.damage_taken + keys.damage

  if self.damage_taken >= self.ability:GetSpecialValueFor("damage_taken") then
    self:IncrementStackCount()

    local bonus_modifier = AddBonus(self.ability, "DEF", self.parent, 1, 0, self.ability:GetSpecialValueFor("stack_duration"))

    bonus_modifier:SetEndCallback(function(interrupted)
      if IsServer() then self:DecrementStackCount() end
    end)
  
    self:PlayEfxHit(keys.attacker)
    self:OnIntervalThink()
  else
    self:StartIntervalThink(self.ability:GetSpecialValueFor("decay_time"))
  end
end

function baldur_3_modifier_passive:OnIntervalThink()
  self.damage_taken = 0
  if IsServer() then self:StartIntervalThink(-1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function baldur_3_modifier_passive:PlayEfxHit(attacker)
	local particle_cast_back = "particles/units/heroes/hero_bristleback/bristleback_back_dmg.vpcf"
	local particle_cast_side = "particles/units/heroes/hero_bristleback/bristleback_side_dmg.vpcf"

  local effect_cast_back = ParticleManager:CreateParticle(particle_cast_back, PATTACH_ABSORIGIN, self.parent)
  ParticleManager:SetParticleControlEnt(effect_cast_back, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
	ParticleManager:ReleaseParticleIndex(effect_cast_back)

  if attacker then
    if IsValidEntity(attacker) then
      local attacker_vector = (attacker:GetOrigin() - self.parent:GetOrigin()):Normalized()
      local effect_cast_side = ParticleManager:CreateParticle(particle_cast_side, PATTACH_ABSORIGIN, self.parent)
      ParticleManager:SetParticleControlEnt(effect_cast_side, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
      ParticleManager:SetParticleControlForward(effect_cast_side, 3, -attacker_vector)
      ParticleManager:ReleaseParticleIndex(effect_cast_side)      
    end
  end

  --if IsServer() then self.parent:EmitSound("Hero_Bristleback.PistonProngs.Bristleback") end
end