templar_1__shield = class({})
LinkLuaModifier("templar_1_modifier_aura", "heroes/sun/templar/templar_1_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("templar_1_modifier_aura_effect", "heroes/sun/templar/templar_1_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_heal_amp", "_modifiers/_modifier_heal_amp", LUA_MODIFIER_MOTION_NONE)


-- INIT

  function templar_1__shield:Spawn()
    Timers:CreateTimer(0.2, function()
      if self:IsTrained() == false then
        self:UpgradeAbility(true)
        BaseStats(self:GetCaster()):AddManaExtra(self)
      end
    end)
  end

  function templar_1__shield:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

  function templar_1__shield:GetIntrinsicModifierName()
    return "templar_1_modifier_aura"
  end

-- SPELL START

  function templar_1__shield:UpdateCount(bPassivesDisabled)
    if not IsServer() then return end

    local caster = self:GetCaster()
    local hero_count = 1

    for _, hero in pairs(HeroList:GetAllHeroes()) do
      if hero:GetTeamNumber() == caster:GetTeamNumber()
      and hero:HasModifier("templar_1_modifier_aura_effect") then
        hero_count = hero_count + 1
      end
    end

    if caster:PassivesDisabled() then hero_count = 0 end

    for _, hero in pairs(HeroList:GetAllHeroes()) do
      if hero:GetTeamNumber() == caster:GetTeamNumber() then
        local modifier = hero:FindModifierByName("templar_1_modifier_aura_effect")
        if modifier then modifier:SetStackCount(hero_count) end        
      end
    end
  end

-- EFFECTS