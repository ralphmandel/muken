lawbreaker_u__form = class({})
LinkLuaModifier("lawbreaker_u_modifier_form", "heroes/death/lawbreaker/lawbreaker_u_modifier_form", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_break", "_modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function lawbreaker_u__form:Spawn()
    self:SetCurrentAbilityCharges(0)
    self.second_hit = false
  end

  function lawbreaker_u__form:OnOwnerSpawned()
    self:SetActivated(true)
  end

-- SPELL START

	function lawbreaker_u__form:OnSpellStart()
		local caster = self:GetCaster()
    local duration = self:GetSpecialValueFor("duration") + self:GetSpecialValueFor("transform_duration")

    AddModifier(caster, caster, self, "lawbreaker_u_modifier_form", {duration = duration}, true)
	end

  function lawbreaker_u__form:OnProjectileHit(hTarget, vLocation)
    if hTarget == nil then return end
    local caster = self:GetCaster()
    local gunslinger = caster:FindAbilityByName("muerta_gunslinger")

    if gunslinger then
      gunslinger:SetCurrentAbilityCharges(0)
      gunslinger:SetLevel(1)
    end
    
    caster:PerformAttack(hTarget, false, true, true, true, false, false, false)
  end

-- EFFECTS