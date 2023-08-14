baldur_2__dash = class({})
LinkLuaModifier("baldur_2_modifier_dash", "heroes/sun/baldur/baldur_2_modifier_dash", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("baldur_2_modifier_charge", "heroes/sun/baldur/baldur_2_modifier_charge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("baldur_2_modifier_gesture", "heroes/sun/baldur/baldur_2_modifier_gesture", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("baldur_2_modifier_impact", "heroes/sun/baldur/baldur_2_modifier_impact", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function baldur_2__dash:Spawn()
    self:SetCurrentAbilityCharges(BALDUR_READY)
  end

  function baldur_2__dash:GetBehavior()
    if self:GetCurrentAbilityCharges() == BALDUR_CHARGING then
      return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
    else
      return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
  end

  function baldur_2__dash:GetAbilityTextureName()
    if self:GetCurrentAbilityCharges() == BALDUR_CHARGING then
      return "bald_dash_2"
    else
      return "bald_dash"
    end
  end

-- SPELL START

	function baldur_2__dash:OnSpellStart()
		local caster = self:GetCaster()

    if self:GetCurrentAbilityCharges() == BALDUR_READY then
      caster:RemoveModifierByName("baldur_2_modifier_dash")
      AddModifier(caster, self, "baldur_2_modifier_charge", {}, false)
      self:EndCooldown()
      self:StartCooldown(0.5)
      self:SetCurrentAbilityCharges(BALDUR_CHARGING)
      return
    end

    if self:GetCurrentAbilityCharges() == BALDUR_CHARGING then
      local modifier = caster:FindModifierByName("baldur_2_modifier_charge")
      local damage = 0
      local stun_duration = 0

      if modifier then      
        damage = (self:GetSpecialValueFor("damage_max") * modifier:GetElapsedTime()) / modifier.max_charge
        stun_duration = (self:GetSpecialValueFor("stun_max") * modifier:GetElapsedTime()) / modifier.max_charge

        AddModifier(caster, self, "baldur_2_modifier_dash", {
          duration = (modifier.time + modifier.max_charge) * 0.06,
          damage = damage, stun_duration = stun_duration,
          target = self:GetCursorTarget():entindex()
        }, false)

        modifier:EndCharge(false)
      end

      self:SetCurrentAbilityCharges(BALDUR_READY)
      return
    end
	end

-- EFFECTS