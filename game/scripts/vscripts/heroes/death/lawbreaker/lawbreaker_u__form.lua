lawbreaker_u__form = class({})
LinkLuaModifier("lawbreaker_u_modifier_passive", "heroes/death/lawbreaker/lawbreaker_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("lawbreaker_u_modifier_form", "heroes/death/lawbreaker/lawbreaker_u_modifier_form", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_break", "_modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function lawbreaker_u__form:OnOwnerSpawned()
    self:SetActivated(true)
  end

  function lawbreaker_u__form:GetIntrinsicModifierName()
    return "lawbreaker_u_modifier_passive"
  end

-- SPELL START

	function lawbreaker_u__form:OnSpellStart()
		local caster = self:GetCaster()
    local attacker = nil
    if self.attacker then
      if IsValidEntity(self.attacker) then
        attacker = self.attacker:entindex()
      end
    end

    AddModifier(caster, self, "lawbreaker_u_modifier_form", {attacker = attacker}, false)
	end

  function lawbreaker_u__form:OnProjectileHit(hTarget, vLocation)
    if hTarget == nil then return end
    local caster = self:GetCaster()
    caster:PerformAttack(hTarget, false, true, true, true, false, false, false)
  end

-- EFFECTS