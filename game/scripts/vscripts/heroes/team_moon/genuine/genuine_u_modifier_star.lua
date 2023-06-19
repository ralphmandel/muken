genuine_u_modifier_star = class({})

function genuine_u_modifier_star:IsHidden() return false end
function genuine_u_modifier_star:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_u_modifier_star:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  if (self.parent:GetMana() > self.caster:GetMana()) then
    AddModifier(self.parent, self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
      percent = 50, duration = 1
    }, false)
  end

  AddModifier(self.caster, self.caster, self.ability, "genuine_u_modifier_vision", {}, false)

	if IsServer() then
		self:PlayEfxStart()
    self:OnIntervalThink()
    self:ExchangeMana()
	end
end

function genuine_u_modifier_star:OnRefresh(kv)
end

function genuine_u_modifier_star:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.caster, "genuine_u_modifier_vision", self.ability)

  if self.parent:IsAlive() == false then
    local cd = self.ability:GetCooldownTimeRemaining()
    self.ability:EndCooldown()
    if self.ability:GetSpecialValueFor("special_reset") == 0 then
      self.ability:StartCooldown(cd / 2)
    end
  end
  
	if IsServer() then self.parent:StopSound("Genuine.Curse.Loop") end
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_u_modifier_star:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    MODIFIER_PROPERTY_BONUS_DAY_VISION
	}
	
	return funcs
end

function genuine_u_modifier_star:GetBonusNightVision()
	return -self:GetAbility():GetSpecialValueFor("night_vision")
end

function genuine_u_modifier_star:GetBonusDayVision()
	return -self:GetAbility():GetSpecialValueFor("special_day_vision")
end

function genuine_u_modifier_star:OnIntervalThink()
	if (self.parent:GetMana() > self.caster:GetMana()) then
    self:PlayEfxPurge()

    if self.ability:GetSpecialValueFor("special_slow") == 1 and self.parent:IsMagicImmune() == false then
      AddModifier(self.parent, self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
        percent = 50, duration = 0.5
      }, false)
    end

    if self.ability:GetSpecialValueFor("special_starfall") == 1 then
      CreateStarfall(self.parent, self.ability)
    end
	end

	if IsServer() then
		self:StartIntervalThink(self.ability:GetSpecialValueFor("special_interval"))
	end
end

-- UTILS -----------------------------------------------------------

function genuine_u_modifier_star:ExchangeMana()
  if self.ability:GetSpecialValueFor("special_swap") == 1 then
    if self.parent:GetMaxMana() > 0 then
      local target_mana = self.parent:GetMana()
      local caster_mana = self.caster:GetMana()
      self.parent:SetMana(caster_mana)
      self.caster:SetMana(target_mana)

      local diff_mana = target_mana - caster_mana
      local mana_deficit = self.caster:GetMaxMana() - caster_mana
      if diff_mana > mana_deficit then diff_mana = mana_deficit end
      if diff_mana > 0 then
        local genuine_barrier = self.caster:FindModifierByName("genuine_5_modifier_barrier")
        if genuine_barrier then genuine_barrier:UpdateBarrier(diff_mana, false) end
      end
    end
    return
  end
  
  local mana_steal = self.parent:GetMaxMana() * self.ability:GetSpecialValueFor("mana_steal") * 0.01
  StealMana(self.parent, self.caster, self.ability, mana_steal, false)
end

-- EFFECTS -----------------------------------------------------------

function genuine_u_modifier_star:PlayEfxStart()
	local particle = "particles/genuine/genuine_ultimate.vpcf"

	local effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(effect_caster, 0, self.caster:GetOrigin())
	self:AddParticle(effect_caster, false, false, -1, false, false)

  local effect_target = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_target, 0, self.parent:GetOrigin())
	self:AddParticle(effect_target, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Genuine.Curse.Loop") end
end

function genuine_u_modifier_star:PlayEfxPurge()
	local particle_cast = "particles/genuine/ult_deny/genuine_deny_v2.vpcf"

	local effect_caster = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(effect_caster, 0, self.caster, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_caster, 1, self.caster, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_caster)

  local effect_target = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_target, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_target, 1, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_target)
end