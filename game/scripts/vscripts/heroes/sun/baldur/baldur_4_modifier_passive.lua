baldur_4_modifier_passive = class({})

function baldur_4_modifier_passive:IsHidden() return false end
function baldur_4_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_4_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.angle_back = 70
  self.angle_side = 110
end

function baldur_4_modifier_passive:OnRefresh(kv)
end

function baldur_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function baldur_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}

	return funcs
end

function baldur_4_modifier_passive:GetModifierPhysical_ConstantBlock(keys)
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return 0 end
  if keys.attacker:IsMagicImmune() then return 0 end
  if self.parent:PassivesDisabled() then return 0 end

  local chance_back = self.ability:GetSpecialValueFor("chance_back")
  local chance_side = self.ability:GetSpecialValueFor("chance_side")
  local facing_direction = self.parent:GetAnglesAsVector().y
  local attacker_vector = (keys.attacker:GetOrigin() - self.parent:GetOrigin()):Normalized()
  local attacker_direction = VectorToAngles(attacker_vector).y
  local angle_diff = AngleDiff(facing_direction, attacker_direction)
  angle_diff = math.abs(angle_diff)

  if angle_diff > (180 - self.angle_back) and RandomFloat(0, 100) < chance_back then
    self:PlayEfxHit(true, keys.attacker)

    AddModifier(keys.attacker, self.ability, "_modifier_stun", {
      duration = self.ability:GetSpecialValueFor("stun_duration")
    }, true)

    return keys.damage
  end
  
  if angle_diff > (180 - self.angle_side) and RandomFloat(0, 100) < chance_side then
    self:PlayEfxHit(false, keys.attacker)

    AddModifier(keys.attacker, self.ability, "_modifier_stun", {
      duration = self.ability:GetSpecialValueFor("stun_duration")
    }, true)
  end

  return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function baldur_4_modifier_passive:PlayEfxHit(bBack, attacker)
	local particle_cast_back = "particles/econ/items/bristleback/bristleback_2022_immortal/bristleback_2022_immortal_lrg_dmg.vpcf"
	local particle_cast_side = "particles/econ/items/bristleback/bristleback_2022_immortal/bristleback_2022_immortal_side_dmg.vpcf"
  local attacker_vector = (attacker:GetOrigin() - self.parent:GetOrigin()):Normalized()

  if bBack then
    local effect_cast_back = ParticleManager:CreateParticle(particle_cast_back, PATTACH_ABSORIGIN, self.parent)
    ParticleManager:SetParticleControlEnt(effect_cast_back, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
    ParticleManager:ReleaseParticleIndex(effect_cast_back)    
  else
    if attacker then
      if IsValidEntity(attacker) then
        local effect_cast_side = ParticleManager:CreateParticle(particle_cast_side, PATTACH_ABSORIGIN, self.parent)
        ParticleManager:SetParticleControlEnt(effect_cast_side, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetOrigin(), true)
        ParticleManager:SetParticleControlForward(effect_cast_side, 3, -attacker_vector)
        ParticleManager:ReleaseParticleIndex(effect_cast_side)
      end
    end
  end

  self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
  self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_2)

  if IsServer() then self.parent:EmitSound("Hero_Bristleback.PistonProngs.Bristleback") end
end