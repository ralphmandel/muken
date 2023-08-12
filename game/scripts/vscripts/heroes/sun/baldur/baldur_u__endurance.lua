baldur_u__endurance = class({})
LinkLuaModifier("baldur_u_modifier_endurance", "heroes/sun/baldur/baldur_u_modifier_endurance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function baldur_u__endurance:OnAbilityPhaseStart()
    local caster = self:GetCaster()

    Timers:CreateTimer(0.5, function()
      if IsServer() then caster:EmitSound("Hero_OgreMagi.Bloodlust.Cast") end
    end)

    return true
  end

	function baldur_u__endurance:OnSpellStart()
		local caster = self:GetCaster()

    caster:RemoveModifierByName("baldur_u_modifier_endurance")
    AddModifier(caster, self, "baldur_u_modifier_endurance", {}, false)
	end

-- EFFECTS