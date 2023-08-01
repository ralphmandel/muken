base_stats_mod = class ({})

-- MOD PROPERTIES

  function base_stats_mod:IsHidden() return true end
  function base_stats_mod:IsPermanent() return true end
  function base_stats_mod:IsPurgable() return false end

-- INIT

  function base_stats_mod:OnCreated(kv)
    if IsServer() then
      self.caster = self:GetCaster()
      self.parent = self:GetParent()
      self.ability = self:GetAbility()

      self.ability.missing = false
      self.ability.has_crit = false

      if self.parent:IsIllusion() then
        self.ability:LoadDataForIllusion()
      else
        self.ability:AddBaseStatsPoints()
        self.ability:UpdatePanoramaPoints()
            
        if self.parent:IsHero() == false then
          --self.ability:IncrementSpenderPoints(0, 0)
        end
      end

      self.ability:LoadSpecialValues()
    end
  end

  function base_stats_mod:OnRefresh(kv)
  end

-- DECLARE FUNCTIONS AND STATES

  function base_stats_mod:DeclareFunctions()
    local funcs = {
      MODIFIER_EVENT_ON_TAKEDAMAGE, -- POPUP DAMAGE TYPES
      MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, -- PHYS./MAGIC. AMP
      MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, --CRITICAL ATTACKS
      MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
      
      -- STR
      MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
      MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,

      -- AGI
      MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
      MODIFIER_PROPERTY_MOVESPEED_LIMIT,
      MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
      MODIFIER_EVENT_ON_RESPAWN,

      -- INT
      MODIFIER_PROPERTY_MANA_BONUS,
      MODIFIER_PROPERTY_MANACOST_PERCENTAGE,

      -- CON
      MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
      MODIFIER_PROPERTY_HEALTH_BONUS,
      MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
      MODIFIER_EVENT_ON_HEAL_RECEIVED,

      --DEF
      MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
      MODIFIER_PROPERTY_STATUS_RESISTANCE,

      --RES
      MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,

      --DEX
      MODIFIER_PROPERTY_DODGE_PROJECTILE,
      MODIFIER_EVENT_ON_ATTACK,
      MODIFIER_PROPERTY_MISS_PERCENTAGE,
      MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,

      --REC
      MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
      MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
    }

    if self:GetParent():IsHero() or self:GetParent():IsConsideredHero() then
      table.insert(funcs, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT)
    end

    return funcs
  end

-- AMP

  function base_stats_mod:OnTakeDamage(keys)
    if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK
    or keys.damage_flags == 1024 then
      if keys.attacker == nil then return end
      if keys.attacker:IsBaseNPC() == false then return end
      if keys.attacker ~= self.parent then return end
      if self.ability.has_crit == true then
        self:PopupSpellCrit(keys.damage, keys.unit, DAMAGE_TYPE_PHYSICAL)
      end
    else
      if keys.unit ~= self.parent then return end
      local efx = nil
      if keys.damage_type == DAMAGE_TYPE_MAGICAL then
        efx = OVERHEAD_ALERT_BONUS_SPELL_DAMAGE
      end

      if keys.inflictor ~= nil then
        if keys.inflictor:GetClassname() == "ability_lua" then
          if keys.inflictor:GetAbilityName() == "shadowmancer_1__weapon" 
          or keys.inflictor:GetAbilityName() == "osiris_1__poison"
          or keys.inflictor:GetAbilityName() == "dasdingo_4__tribal" then
            efx = OVERHEAD_ALERT_BONUS_POISON_DAMAGE
          end

          if keys.inflictor:GetAbilityName() == "bloodstained_2__frenzy" then
            return
          end

          if keys.inflictor:GetAbilityName() == "bloodstained_u__seal" then
            return
          end

          if keys.inflictor:GetAbilityName() == "bloodstained_4__tear"
          and keys.damage_type == DAMAGE_TYPE_PURE then
            return
          end
        end
      end

      if keys.damage_type == DAMAGE_TYPE_PURE then
        self:PopupDamage(math.floor(keys.damage), Vector(255, 225, 175), self.parent)
      end

      if efx ~= nil then
        SendOverheadEventMessage(nil, efx, self.parent, keys.damage, self.parent)
      end
    end
  end

  function base_stats_mod:GetModifierSpellAmplify_Percentage(keys)
    if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then return 0 end

    if keys.damage_flags ~= 31 then
      if keys.damage_type == DAMAGE_TYPE_PHYSICAL then
        return self.ability:GetTotalPhysicalDamagePercent() - 100
      end
  
      if keys.damage_type == DAMAGE_TYPE_MAGICAL then
        return self.ability:GetTotalMagicalDamagePercent() - 100
      end
    end
    
    return 0
  end

  function base_stats_mod:GetModifierTotalDamageOutgoing_Percentage(keys)
    if keys.damage_flags ~= 1024 then
      if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return 0 end

      if keys.damage_flags ~= 31 then
        if self.ability.has_crit == true then
          local crit_damage = self.ability:GetTotalCriticalDamage()
          self.ability.force_crit_damage = nil
          return crit_damage
        end
      end
    end

    if keys.damage_flags ~= 31 then
      if self.ability.has_crit == true then
        local crit_damage = self.ability:GetTotalCriticalDamage()
        self.ability.force_crit_damage = nil
        return crit_damage
      end
    end

    return 0
  end

  function base_stats_mod:GetModifierPhysical_ConstantBlock(keys)
    local average = self.ability.physical_block_max_percent
    local block_percent = RandomInt(average - 5, average + 5)

    return math.floor(keys.damage * block_percent * 0.01)
  end

-- STR

  function base_stats_mod:GetModifierBaseAttack_BonusDamage()
    return self.ability.stat_total["STR"] * self.ability.base_atk_damage * self.ability.damage_percent * 0.01
  end

  function base_stats_mod:GetModifierProcAttack_BonusDamage_Physical(keys)
    return self.ability:GetBonusAtkDamage()
  end

-- AGI

  function base_stats_mod:GetModifierIgnoreMovespeedLimit()
    return 1
  end

  function base_stats_mod:GetModifierMoveSpeed_Limit()
    return self:GetAbility():GetTotalMS()
  end

  function base_stats_mod:GetModifierAttackSpeedBonus_Constant()
    if self.parent:HasModifier("ancient_1_modifier_passive") then return 0 end
    return self.ability.stat_total["AGI"] * self.ability.attack_speed
  end

  function base_stats_mod:GetModifierBaseAttackTimeConstant()
    return self.ability:GetBAT()
  end

  function base_stats_mod:OnRespawn(keys)
  end

-- INT

  function base_stats_mod:GetModifierManaBonus()
    if self.parent:HasModifier("ancient_1_modifier_passive") then
      if self.parent:HasModifier("ancient_u_modifier_passive") == false then
        return 0
      else
        return 750 + (self.ability:GetStatBase("INT") * self.ability.mana)
      end
    end
    
    return (self.ability:GetStatBase("INT") * self.ability.mana)
  end

  function base_stats_mod:GetModifierPercentageManacost(keys)
    if self:GetParent():IsHero() == false then return 0 end
    return 100 - (100 / (self:GetAbility():GetLevel() * 0.5))
  end

-- CON

  function base_stats_mod:GetModifierExtraHealthBonus()
    if IsServer() then
      if self:GetParent():IsHero() == false then
        return self.ability.stat_total["CON"] * self.ability.health_bonus
      end
    end
  end

  function base_stats_mod:GetModifierHealthBonus()
    if IsServer() then
      if self:GetParent():IsHero() then
        return self.ability.stat_total["CON"] * self.ability.health_bonus
      end
    end
  end

  function base_stats_mod:GetModifierHealAmplify_PercentageTarget()
    return self.ability:GetHealAmp()
  end

  function base_stats_mod:OnHealReceived(keys)
    if keys.unit ~= self.parent then return end
    if keys.inflictor == nil then return end
    if keys.gain < 1 then return end

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.unit, keys.gain, keys.unit)
    if IsServer() then self.parent:EmitSound("Effect.Heal") end
  end

-- DEF

  function base_stats_mod:GetModifierPhysicalArmorBonus()
    return 10 + (self.ability.stat_total["DEF"] * self.ability.armor)
  end

  function base_stats_mod:GetModifierStatusResistance()
    return self.ability:GetStatBase("DEF") * self.ability.status_resist
  end

-- RES

  function base_stats_mod:GetModifierMagicalResistanceBonus()
    local value = 10 + (self.ability.stat_total["RES"] * self.ability.magic_resist)
    local calc = (value * 6) / (1 +  (value * 0.06))
    return calc
  end

-- DEX

  function base_stats_mod:GetModifierDodgeProjectile(keys)
    if BaseStats(keys.attacker) == nil then return end

    local crit = RandomFloat(0, 100) < BaseStats(keys.attacker):GetCriticalChance()
    BaseStats(keys.attacker).force_crit_chance = nil
    BaseStats(keys.attacker).has_crit = crit

    if RandomFloat(0, 100) < BaseStats(keys.attacker):GetMissPercent() or (crit == false and RandomFloat(0, 100) < self.ability:GetDodgePercent()) then
      return 1
    end

    return 0
  end

  function base_stats_mod:OnAttack(keys)
    if BaseStats(keys.attacker) == nil then return end
    if keys.target ~= self.parent then return end
    if keys.attacker:GetAttackCapability() ~= DOTA_UNIT_CAP_MELEE_ATTACK
    and keys.no_attack_cooldown == false then return end

    local crit = RandomFloat(0, 100) < BaseStats(keys.attacker):GetCriticalChance()
    BaseStats(keys.attacker).force_crit_chance = nil
    BaseStats(keys.attacker).has_crit = crit
    BaseStats(keys.attacker).missing = (RandomFloat(0, 100) < BaseStats(keys.attacker):GetMissPercent() or (crit == false and RandomFloat(0, 100) < self.ability:GetDodgePercent()))
  end

  function base_stats_mod:GetModifierMiss_Percentage(keys)
    if self.ability.missing == true then
      self.ability.missing = false
      return 100
    end
    return 0
  end

  function base_stats_mod:GetModifierConstantHealthRegen()
    if IsServer() then
      return self.ability:GetBonusHPRegen() * self.ability.hp_regen_state
    end
  end

-- REC

  function base_stats_mod:GetModifierConstantManaRegen()
    if IsServer() then
      return self.ability:GetBonusMPRegen() * self.ability.mp_regen_state
    end
  end
  
  function base_stats_mod:GetModifierPercentageCooldown()
    local value = 1 + (self.ability:GetStatBase("REC") * self.ability.cooldown * 0.01)
    return 100 - (100 / value)
  end

-- EFFECTS

  function base_stats_mod:PopupSpellCrit(damage, target, damage_type)
    if damage_type == DAMAGE_TYPE_PHYSICAL then
      SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, math.floor(damage), target)
      if IsServer() then target:EmitSound("Item_Desolator.Target") end
    end

    if damage_type == DAMAGE_TYPE_MAGICAL then
      SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, math.floor(damage), target)
      --self:PopupDamage(math.floor(damage), Vector(153, 0, 204), target)
      if IsServer() then target:EmitSound("Crit_Magical") end
    end
  end

  function base_stats_mod:PopupDamage(damage, color, target)
    if damage < 1 then return end

    local digits = 1
    if damage < 10 then digits = 2 end
    if damage > 9 and damage < 100 then digits = 3 end
    if damage > 99 and damage < 1000 then digits = 4 end
    if damage > 999 then digits = 5 end

    local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(pidx, 1, Vector(0, damage, 4))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
  end