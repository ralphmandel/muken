lawbreaker_2__combo = class({})
LinkLuaModifier("lawbreaker_2_modifier_passive", "heroes/team_death/lawbreaker/lawbreaker_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("lawbreaker_2_modifier_combo", "heroes/team_death/lawbreaker/lawbreaker_2_modifier_combo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function lawbreaker_2__combo:GetIntrinsicModifierName()
    return "lawbreaker_2_modifier_passive"
  end

  function lawbreaker_2__combo:OnOwnerSpawned()
    local caster = self:GetCaster()
    if IsServer() then caster:FindModifierByName(self:GetIntrinsicModifierName()):SetStackCount(0) end
  end

  function lawbreaker_2__combo:Spawn()
    self:SetCurrentAbilityCharges(0)
  end

  function lawbreaker_2__combo:OnUpgrade()
    local caster = self:GetCaster()
    caster:FindModifierByName(self:GetIntrinsicModifierName()):CheckShots()
  end

-- SPELL START

	function lawbreaker_2__combo:OnSpellStart()
		local caster = self:GetCaster()
    self.point = self:GetCursorPosition()
    caster:RemoveModifierByName("lawbreaker_2_modifier_combo")
    caster:AddNewModifier(caster, self, "lawbreaker_2_modifier_combo", {})
	end

  function lawbreaker_2__combo:OnProjectileHit(target, loc)
    local caster = self:GetCaster()
    caster:PerformAttack(target, false, false, true, false, false, false, false) -- skipCooldown == true FOR RANGED UNITS
    return true
  end

  function lawbreaker_2__combo:EnableShotRefresh(bEnable)
    local caster = self:GetCaster()
    local passive = caster:FindModifierByName(self:GetIntrinsicModifierName())
    local interval = -1
    if bEnable then interval = self:GetSpecialValueFor("recharge_time") end

    if IsServer() then passive:StartIntervalThink(interval) end
  end

-- EFFECTS