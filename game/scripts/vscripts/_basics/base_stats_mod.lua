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
            
        if self.parent:IsHero() then
          self.ability:UpdatePanoramaPoints()
        else
          self.ability:IncrementSpenderPoints(0, 0)
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

      -- STR
      MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
      MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK,
      MODIFIER_PROPERTY_MAGICAL_CONSTANT_BLOCK,

      -- AGI
      MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
      MODIFIER_PROPERTY_MOVESPEED_LIMIT,
      MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
      MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
      MODIFIER_EVENT_ON_RESPAWN,

      -- INT
      MODIFIER_PROPERTY_MANA_BONUS,
      MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,

      -- CON
      MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
      MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
      MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
      MODIFIER_PROPERTY_HEALTH_BONUS,
      MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
      MODIFIER_EVENT_ON_HEAL_RECEIVED,

      --SECONDARY
      MODIFIER_PROPERTY_DODGE_PROJECTILE,
      MODIFIER_EVENT_ON_ATTACK,
      MODIFIER_PROPERTY_MISS_PERCENTAGE,
      MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
      MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
      MODIFIER_PROPERTY_STATUS_RESISTANCE,
      MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
    }
    return funcs
  end

  function base_stats_mod:OnTakeDamage(keys)
    if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
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

          if keys.inflictor:GetAbilityName() == "bloodstained_4__frenzy" then
            return
          end

          if keys.inflictor:GetAbilityName() == "bloodstained_u__seal" then
            return
          end

          if keys.inflictor:GetAbilityName() == "bloodstained_5__tear"
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
    if keys.damage_flags == DOTA_DAMAGE_FLAG_REFLECTION then return 0 end
    
    if keys.damage_type == DAMAGE_TYPE_PHYSICAL then
      return self.ability:GetTotalPhysicalDamagePercent() - 100
    end

    if keys.damage_type == DAMAGE_TYPE_MAGICAL then
      return self.ability:GetTotalMagicalDamagePercent() - 100
    end
  end

  function base_stats_mod:GetModifierTotalDamageOutgoing_Percentage(keys)
    if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return 0 end
    if keys.damage_flags == DOTA_DAMAGE_FLAG_REFLECTION then return 0 end

    if self.ability.has_crit == true then
      local crit_damage = self.ability:GetCriticalDamage()
      self.ability.force_crit_damage = nil
      return crit_damage
    end

    return 0
  end

-- STR

  function base_stats_mod:GetModifierBaseAttack_BonusDamage()
    return (self.ability.stat_total["STR"] + 1) * self.ability.damage
  end

  function base_stats_mod:GetModifierPhysical_ConstantBlock(keys)
    if self.parent:IsRangedAttacker() then return 0 end
    local physical_block_max_percent = self.ability.physical_block_max_percent
    local physical_block_min_percent = 0
    local physical_block_max_const = 0
    local physical_block_min_const = 0

    local mods = self.parent:FindAllModifiersByName("base_stats_mod_block_bonus")
    for _,mod in pairs(mods) do
      if mod.physical_block_max_percent > physical_block_max_percent then
        physical_block_max_percent = mod.physical_block_max_percent
      end
      if mod.physical_block_min_percent > physical_block_min_percent then
        physical_block_min_percent = mod.physical_block_min_percent
      end
      if mod.physical_block_max_const > physical_block_max_const then
        physical_block_max_const = mod.physical_block_max_const
      end
      if mod.physical_block_min_const > physical_block_min_const then
        physical_block_min_const = mod.physical_block_min_const
      end
    end

    local block_percent = physical_block_max_percent
    local block_const = physical_block_max_const

    if physical_block_min_percent < physical_block_max_percent then
      block_percent = RandomInt(physical_block_min_percent, physical_block_max_percent)
    end

    if physical_block_min_const < physical_block_max_const then
      block_const = RandomInt(physical_block_min_const, physical_block_max_const)
    end

    local calc = math.floor(keys.damage * block_percent * 0.01) + block_const
    return calc
  end

  function base_stats_mod:GetModifierMagical_ConstantBlock(keys)
    return 0
    -- if keys.damage_flags == DOTA_DAMAGE_FLAG_BYPASSES_BLOCK then return 0 end
    -- local magical_block_max_percent = self.ability.magical_block_max_percent
    -- local magical_block_min_percent = 0
    -- local magical_block_max_const = 0
    -- local magical_block_min_const = 0

    -- local mods = self.parent:FindAllModifiersByName("base_stats_mod_block_bonus")
    -- for _,mod in pairs(mods) do
    --     if mod.magical_block_max_percent > magical_block_max_percent then
    --         magical_block_max_percent = mod.magical_block_max_percent
    --     end
    --     if mod.magical_block_min_percent > magical_block_min_percent then
    --         magical_block_min_percent = mod.magical_block_min_percent
    --     end
    --     if mod.magical_block_max_const > magical_block_max_const then
    --         magical_block_max_const = mod.magical_block_max_const
    --     end
    --     if mod.magical_block_min_const > magical_block_min_const then
    --         magical_block_min_const = mod.magical_block_min_const
    --     end
    -- end

    -- local block_percent = magical_block_max_percent
    -- local block_const = magical_block_max_const

    -- if magical_block_min_percent < magical_block_max_percent then
    --     block_percent = RandomInt(magical_block_min_percent, magical_block_max_percent)
    -- end

    -- if magical_block_min_const < magical_block_max_const then
    --     block_const = RandomInt(magical_block_min_const, magical_block_max_const)
    -- end

    -- local calc = math.floor(keys.damage * block_percent * 0.01) + block_const
    -- if calc > 0 then return calc end
  end

-- AGI

  function base_stats_mod:GetModifierIgnoreMovespeedLimit()
    return 1
  end

  function base_stats_mod:GetModifierMoveSpeed_Limit()
    local min = 50
    local max = 2000
    local amount = math.floor((self.ability:GetBaseMS() - min) * self.ability:GetPercentMS()) + self.ability:GetBonusMS() + min
    if amount < min then amount = min end
    if amount > max then amount = max end

    return amount
  end

  function base_stats_mod:GetModifierAttackSpeedBonus_Constant()
    if self.parent:HasModifier("ancient_1_modifier_passive") then return 0 end
    return (self.ability.stat_total["AGI"] + 1) * self.ability.attack_speed
  end

  function base_stats_mod:GetModifierBaseAttackTimeConstant()
    return self.ability.attack_time
  end

  function base_stats_mod:OnRespawn(keys)
    if keys.unit == self.parent then
      self.ability:SetBaseAttackTime(0)
    end
  end

-- INT

  function base_stats_mod:GetModifierManaBonus()
    return self.ability.mana * (self.ability.stat_base["INT"])
  end

  function base_stats_mod:GetModifierConstantManaRegen()
    if IsServer() then
      return (self.ability.stat_total["INT"] + 1) * self.ability.mana_regen * self.ability.mp_regen_state
    end
  end

-- CON

  function base_stats_mod:GetModifierHealAmplify_PercentageTarget()
    return self.ability.heal_amp * (self.ability.stat_base["CON"])
  end

  function base_stats_mod:GetModifierHPRegenAmplify_Percentage()
    return self.ability.heal_amp * (self.ability.stat_base["CON"])
  end

  function base_stats_mod:GetModifierExtraHealthBonus()
    if IsServer() then
      if self:GetParent():IsHero() == false then
        return (self.ability.stat_total["CON"] + 1) * self.ability.health_bonus
      end
    end
  end

  function base_stats_mod:GetModifierHealthBonus()
    if IsServer() then
      if self:GetParent():IsHero() then
        return (self.ability.stat_total["CON"] + 1) * self.ability.health_bonus
      end
    end
  end

  function base_stats_mod:GetModifierConstantHealthRegen()
    if IsServer() then
      return (self.ability.stat_total["CON"] + 1) * self.ability.health_regen * self.ability.hp_regen_state
    end
  end

  function base_stats_mod:OnHealReceived(keys)
    if keys.unit ~= self.parent then return end
    if keys.inflictor == nil then return end
    if keys.gain < 1 then return end

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.unit, keys.gain, keys.unit)
  end

-- SECONDARY

  function base_stats_mod:GetModifierDodgeProjectile(keys)
    if BaseStats(keys.attacker) == nil then return end

    local crit = RandomFloat(1, 100) <= BaseStats(keys.attacker):GetCriticalChance()
    BaseStats(keys.attacker).force_crit_chance = nil
    BaseStats(keys.attacker).has_crit = crit

    if RandomFloat(1, 100) <= BaseStats(keys.attacker):GetMissPercent() or (crit == false and RandomFloat(1, 100) <= self.ability:GetDodgePercent()) then
      return 1
    end

    return 0
  end

  function base_stats_mod:OnAttack(keys)
    if BaseStats(keys.attacker) == nil then return end
    if keys.target ~= self.parent then return end
    if keys.attacker:GetAttackCapability() ~= DOTA_UNIT_CAP_MELEE_ATTACK
    and keys.no_attack_cooldown == false then return end

    local crit = RandomFloat(1, 100) <= BaseStats(keys.attacker):GetCriticalChance()
    BaseStats(keys.attacker).force_crit_chance = nil
    BaseStats(keys.attacker).has_crit = crit
    BaseStats(keys.attacker).missing = (RandomFloat(1, 100) <= BaseStats(keys.attacker):GetMissPercent() or (crit == false and RandomFloat(1, 100) <= self.ability:GetDodgePercent()))
  end

  function base_stats_mod:GetModifierMiss_Percentage(keys)
    if self.ability.missing == true then
      self.ability.missing = false
      return 100
    end
    return 0
  end

  function base_stats_mod:GetModifierPhysicalArmorBonus()
    return (self.ability.stat_total["DEF"] + 1) * self.ability.armor
  end

  function base_stats_mod:GetModifierMagicalResistanceBonus()
    local value = (self.ability.stat_total["RES"] + 1) * self.ability.magic_resist
    local calc = (value * 6) / (1 +  (value * 0.06))
    return calc
  end

  function base_stats_mod:GetModifierStatusResistance()
    return (self.ability.stat_total["RES"] + 1) * self.ability.status_resist
  end
  
  function base_stats_mod:GetModifierPercentageCooldown()
    local value = (self.ability.stat_total["REC"] + 1) * self.ability.cooldown
    local calc = (value * 6) / (1 +  (value * 0.06))
    return calc
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