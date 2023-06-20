ancient_u__final = class({})
LinkLuaModifier("ancient_u_modifier_passive", "heroes/team_sun/ancient/ancient_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function ancient_u__final:Spawn()
    self.kills = 0
    self.casting = false
    self.energy = 0
  end

  function ancient_u__final:OnOwnerSpawned()
    local respawned_mana = 0
    self:GetCaster():SetMana(respawned_mana)
    self:UpdateCON()
  end

  function ancient_u__final:GetCastRange(vLocation, hTarget)    
    return self:GetManaCost(self:GetLevel()) * self:GetSpecialValueFor("cast_range_mult")
  end
  
-- SPELL START

  function ancient_u__final:GetIntrinsicModifierName()
    return "ancient_u_modifier_passive"
  end

  function ancient_u__final:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    caster:RemoveModifierByName("ancient_2_modifier_leap")
    self.damage = self:GetCaster():GetMana() * self:GetSpecialValueFor("damage")
    self.distance = self:GetCastRange(self:GetCursorPosition(), nil)

    ChangeActivity(caster, "")
    
    self:PlayEfxPre()

    return true
  end

  function ancient_u__final:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    ChangeActivity(caster, "et_2021")

    self:StopEfxPre(true)
  end

  function ancient_u__final:OnSpellStart()
    local caster = self:GetCaster()
    local caster_position = caster:GetAbsOrigin()
    local target_point = self:GetCursorPosition()

    local effect_delay = self:GetSpecialValueFor("crack_time")
    local crack_width = self:GetSpecialValueFor("crack_width")
    local crack_distance = self.distance
    local caster_fw = caster:GetForwardVector()
    local crack_ending = caster_position + caster_fw * crack_distance

    GridNav:DestroyTreesAroundPoint(target_point, crack_width, false)
    ChangeActivity(caster, "et_2021")
    self:PlayEfxStart(caster_position, crack_ending, effect_delay)
    self:StopEfxPre(false)
    self:UpdateCON()
      
    Timers:CreateTimer(effect_delay, function()
      local enemies = FindUnitsInLine(
        caster:GetTeamNumber(), caster_position, crack_ending, nil, crack_width,
        self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags()
      )

      for _, enemy in pairs(enemies) do
        enemy:Interrupt()
        local closest_point = self:FindNearestPointFromLine(caster_position, caster_fw, enemy:GetAbsOrigin())
        FindClearSpaceForUnit(enemy, closest_point, false)
        AddModifier(enemy, caster, self, "_modifier_percent_movespeed_debuff", {duration = 2}, true)

        ApplyDamage({
          victim = enemy, attacker = caster, damage = self.damage,
          damage_type = self:GetAbilityDamageType(), ability = self,
          damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
        })
      end

      self:PlayEfxDestroy()
    end)
  end

  function ancient_u__final:FindNearestPointFromLine(caster, dir, affected)
    local castertoaffected = affected - caster
    local len = castertoaffected:Dot(dir)
    local ntgt = Vector(dir.x * len, dir.y * len, caster.z)
    return caster + ntgt
  end

  function ancient_u__final:UpdateCON()
    local caster = self:GetCaster()
    local total_con = math.floor(caster:GetMana() * self:GetSpecialValueFor("con_mult"))

    RemoveBonus(self, "_1_CON", caster)
    AddBonus(self, "_1_CON", caster, total_con, 0, nil)
    caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):UpdateAmbients()
  end

-- EFFECTS

  function ancient_u__final:PlayEfxPre()
    local caster = self:GetCaster()

    local particle_cast = "particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(effect_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
    self.effect_cast = effect_cast
    self.casting = true

    if IsServer() then caster:EmitSound("Ancient.Final.Pre") end
  end

  function ancient_u__final:StopEfxPre(interrupted)
    local caster = self:GetCaster()
    ParticleManager:DestroyParticle(self.effect_cast, interrupted)
    ParticleManager:ReleaseParticleIndex(self.effect_cast)
    self.casting = false
  end

  function ancient_u__final:PlayEfxStart(caster_position, crack_ending, effect_delay)
    local caster = self:GetCaster()
    local string = "particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf"
    self.pfx_start = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(self.pfx_start, 0, caster_position)
    ParticleManager:SetParticleControl(self.pfx_start, 1, crack_ending)
    ParticleManager:SetParticleControl(self.pfx_start, 3, Vector(0, effect_delay, 0))
    EmitSoundOn("Hero_ElderTitan.EarthSplitter.Cast", caster)
  end

  function ancient_u__final:PlayEfxDestroy()
    local caster = self:GetCaster()
    if self.pfx_start then ParticleManager:ReleaseParticleIndex(self.pfx_start) end
    EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)
  end