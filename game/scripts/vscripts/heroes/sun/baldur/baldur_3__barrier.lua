baldur_3__barrier = class({})
LinkLuaModifier("baldur_3_modifier_passive", "heroes/sun/baldur/baldur_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("baldur_3_modifier_barrier", "heroes/sun/baldur/baldur_3_modifier_barrier", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function baldur_3__barrier:GetIntrinsicModifierName()
    return "baldur_3_modifier_passive"
  end

-- SPELL START

	function baldur_3__barrier:OnSpellStart()
		local caster = self:GetCaster()

    AddModifier(caster, self, "baldur_3_modifier_barrier", {
      stack = caster:FindModifierByName(self:GetIntrinsicModifierName()):GetStackCount()
    })

    RemoveBonus(self, "DEF", caster)
	end

-- EFFECTS