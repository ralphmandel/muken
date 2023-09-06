paladin_3__hammer = class({})
LinkLuaModifier("paladin_3_modifier_hammer", "heroes/sun/paladin/paladin_3_modifier_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function paladin_3__hammer:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

	function paladin_3__hammer:OnSpellStart()
		local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if caster:GetTeamNumber() ~= target:GetTeamNumber() then
      if target:TriggerSpellAbsorb(self) then return end
    end

    local random_mult = RandomInt(self:GetSpecialValueFor("min_mult"), self:GetSpecialValueFor("max_mult"))

    if IsServer() then self:PlayEfxHammer(target, random_mult, self:GetAOERadius()) end
    AddFOWViewer(caster:GetTeamNumber(), target:GetOrigin(), self:GetAOERadius(), 1, true)

    local units = FindUnitsInRadius(
      caster:GetTeamNumber(), target:GetOrigin(), nil, self:GetAOERadius(),
      self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
      self:GetAbilityTargetFlags(), 0, false
    )

    for _,unit in pairs(units) do
      local mult = random_mult

      if unit:GetTeamNumber() == caster:GetTeamNumber() then
        -- if target == unit then unit:Purge(false, true, false, true, false) end
        unit:Heal(CalcHeal(caster, self:GetSpecialValueFor("heal") * mult), self)
      else
        -- if target == unit then
        --   AddModifier(unit, self, "_modifier_stun", {duration = self:GetSpecialValueFor("stun_duration")}, true)
        -- end
        
        if unit:IsIllusion() then
          unit:Kill(self, caster)
        else
          ApplyDamage({
            victim = unit, attacker = caster, damage = self:GetSpecialValueFor("damage") * mult,
            damage_type = self:GetAbilityDamageType(),
            ability = self
          })
        end
      end
    end
	end

-- EFFECTS

  function paladin_3__hammer:PlayEfxHammer(target, level, radius)
    local caster = self:GetCaster()
    local particle = "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf"
    local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())

    local particle2 = "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf"
    local effect2 = ParticleManager:CreateParticle(particle2, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(effect2, 0, caster:GetOrigin())
    ParticleManager:SetParticleControl(effect2, 1, target:GetOrigin())

    local particle3 = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_gold_call.vpcf"
    local effect3 = ParticleManager:CreateParticle(particle3, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(effect3, 0, target:GetOrigin() )
    ParticleManager:SetParticleControl(effect3, 2, Vector(radius, radius, radius))

    local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, target)
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(level, 1, level))

    if IsServer() then target:EmitSound("Hero_Omniknight.Purification.Wingfall") end
  end