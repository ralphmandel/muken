fleaman_1__precision = class({})
LinkLuaModifier("fleaman_1_modifier_gesture", "heroes/team_death/fleaman/fleaman_1_modifier_gesture", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fleaman_1_modifier_precision", "heroes/team_death/fleaman/fleaman_1_modifier_precision", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fleaman_1_modifier_precision_stack", "heroes/team_death/fleaman/fleaman_1_modifier_precision_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fleaman_1_modifier_precision_status_efx", "heroes/team_death/fleaman/fleaman_1_modifier_precision_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function fleaman_1__precision:Spawn()
    if self:IsTrained() == false then
      self:UpgradeAbility(true)
    end 
  end

-- SPELL START

  function fleaman_1__precision:OnSpellStart()
    local caster = self:GetCaster()

    caster:RemoveModifierByName("fleaman_1_modifier_gesture")
    caster:AttackNoEarlierThan(10, 20)
    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 2)

    self:StartCooldown(0.4)

    caster:Purge(false, true, false, false, false)
    AddModifier(caster, caster, self, "fleaman_1_modifier_precision",  {}, false)

    Timers:CreateTimer(0.35, function()
      if caster:IsAlive() then
        caster:AttackNoEarlierThan(1, 1)
        AddModifier(caster, caster, self, "fleaman_1_modifier_gesture",  {duration = 0.6}, false)
      end
    end)
  end

-- EFFECTS