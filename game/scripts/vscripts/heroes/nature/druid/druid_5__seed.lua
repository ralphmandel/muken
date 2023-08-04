druid_5__seed = class({})
LinkLuaModifier("druid_5_modifier_wind_effect", "heroes/nature/druid/druid_5_modifier_wind_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_5_modifier_aura", "heroes/nature/druid/druid_5_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_5_modifier_aura_effect", "heroes/nature/druid/druid_5_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function druid_5__seed:OnOwnerSpawned()
    self:OnToggle()
  end

  function druid_5__seed:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

  function druid_5__seed:OnToggle()
    local caster = self:GetCaster()

    if self:GetToggleState() then
      AddModifier(caster, self, "druid_5_modifier_aura", {}, false)
    else
      caster:RemoveModifierByName("druid_5_modifier_aura")
    end
  end

  function druid_5__seed:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if not hTarget then return end

    hTarget:Heal(ExtraData.amount, self)
    self:PlayEfxHeal(hTarget)
  end

  function druid_5__seed:OnTreeCut(loc)
    local caster = self:GetCaster()
    if caster:HasModifier("druid_5_modifier_aura") == false then return end
    if (caster:GetOrigin() - loc):Length2D() > self:GetAOERadius() then return end

    local branches = {
      [1] = "item_branch_red",
      [2] = "item_branch_green",
      [3] = "item_branch_green"
    }
  
    if self:GetSpecialValueFor("special_branch") == 1 then
      local item = CreateItem(branches[RandomInt(1, 3)], nil, nil)
      local drop = CreateItemOnPositionSync(loc, item)
      local pos_launch = loc + RandomVector(RandomInt(150,200))
      item:LaunchLoot(false, 100, 0.5, pos_launch)
      self:PlayEfxDropItem(pos_launch)
    end

    self:CreateSeedFromTree(loc)
  end

  function druid_5__seed:CreateSeedFromTree(loc)
    local caster = self:GetCaster()
    self:CreateSeed(nil, caster, loc)
  
    local tree_seed_extra = self:GetSpecialValueFor("special_tree_seed_extra")
    local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, -1, 1, 1, 0, 0, false)
  
    for _,ally in pairs(allies) do
      if tree_seed_extra > 0 and ally ~= caster
      and ally:HasModifier("druid_5_modifier_aura_effect") then
        self:CreateSeed(nil, ally, loc)
        tree_seed_extra = tree_seed_extra - 1
      end
    end
  end

  function druid_5__seed:CreateSeed(source, target, loc)
    local caster = self:GetCaster()
    self:PlayEfxSeed(source, target)

    ProjectileManager:CreateTrackingProjectile({
      Target = target,
      Source = source,
      vSourceLoc = loc,
      Ability = self,
      EffectName = "particles/druid/druid_ult_projectile.vpcf",
      iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
      iMoveSpeed = self:GetSpecialValueFor("seed_speed"),
      flExpireTime = GameRules:GetGameTime() + self:GetSpecialValueFor("seed_lifetime"),
      bReplaceExisting = false,
      bProvidesVision = true,
      iVisionRadius = 75,
      iVisionTeamNumber = caster:GetTeamNumber(),
      ExtraData = {amount = self:GetSpecialValueFor("seed_base_heal") * BaseStats(caster):GetHealPower()},
      bDodgeable = false
    })
  end

-- EFFECTS

  function druid_5__seed:PlayEfxHeal(target)
    local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
    local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
    ParticleManager:ReleaseParticleIndex(effect)
  end

  function druid_5__seed:PlayEfxSeed(source, target)
    if source then
      local string = "particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf"
      local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, source)
      ParticleManager:SetParticleControl(particle, 0, source:GetOrigin())
      ParticleManager:ReleaseParticleIndex(particle)
    end
  
    if IsServer() then target:EmitSound("Hero_Treant.LeechSeed.Tick") end
  end

  function druid_5__seed:PlayEfxDropItem(pos_launch)
    local string = "particles/neutral_fx/neutral_item_drop_lvl1.vpcf"
    local particle = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle, 0, pos_launch)
    ParticleManager:ReleaseParticleIndex(particle)
  
    if IsServer() then EmitSoundOnLocationForAllies(pos_launch, "NeutralLootDrop.Spawn", self:GetCaster()) end
  end