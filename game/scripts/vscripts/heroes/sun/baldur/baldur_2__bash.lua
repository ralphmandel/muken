bald_2__bash = class({})
LinkLuaModifier("bald_2_modifier_heap", "heroes/sun/bald/bald_2_modifier_heap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_2_modifier_dash", "heroes/sun/bald/bald_2_modifier_dash", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bald_2_modifier_impact", "heroes/sun/bald/bald_2_modifier_impact", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bald_2_modifier_gesture", "heroes/sun/bald/bald_2_modifier_gesture", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function bald_2__bash:Spawn()
    self.dash = false
  end

-- SPELL START

  function bald_2__bash:OnSpellStart()
    local caster = self:GetCaster()

    if self.dash == true then
      self:PerformDash()
    else
      self:PrepareDash()
    end
  end

  function bald_2__bash:PrepareDash()
    local caster = self:GetCaster()
    caster:AddNewModifier(caster, self, "bald_2_modifier_heap", {})
  end

  function bald_2__bash:PerformDash()
    local caster = self:GetCaster()
    self.target = self:GetCursorTarget()

    local heap = caster:FindModifierByName("bald_2_modifier_heap")
    if heap then
      caster:AddNewModifier(caster, self, "bald_2_modifier_dash", {
        duration = (heap.time + heap.max_charge) * 0.06
      })

      heap:Destroy()
    end
  end

  function bald_2__bash:ApplyImpact(target)
    local caster = self:GetCaster()
    if target:IsInvisible() then return end

    RemoveAllModifiersByNameAndAbility(target, "_modifier_stun", self)
    self:PlayEfxImpact(target)

    target:AddNewModifier(caster, self, "_modifier_stun", {
      duration = CalcStatus(self.stun, caster, target)
    })
  
    target:AddNewModifier(caster, nil, "modifier_knockback", {
      duration = 0.25,
      knockback_duration = 0.25,
      knockback_distance = self.stun * 50,
      center_x = caster:GetAbsOrigin().x + 1,
      center_y = caster:GetAbsOrigin().y + 1,
      center_z = caster:GetAbsOrigin().z,
      knockback_height = self.stun * 20,
    })

    ApplyDamage({
      damage = self.damage,
      attacker = caster,
      victim = target,
      damage_type = self:GetAbilityDamageType(),
      ability = self,
      damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
    })
  end

  function bald_2__bash:OnOwnerSpawned()
    self:SetActivated(true)
  end

  function bald_2__bash:GetAbilityTextureName()
    if self:GetCaster():HasModifier("bald_2_modifier_heap") then
      return "bald_bash_2"
    else
      return "bald_bash"
    end
  end

  function bald_2__bash:GetBehavior()
    if self:GetCaster():HasModifier("bald_2_modifier_heap") then
      return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
    else
      return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
  end

-- EFFECTS

  function bald_2__bash:PlayEfxImpact(target)
    local sound_cast = "Hero_Spirit_Breaker.GreaterBash.Creep"
    if target:IsHero() then sound_cast = "Hero_Spirit_Breaker.GreaterBash" end 

    local particle_cast = "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then target:EmitSound(sound_cast) end
  end