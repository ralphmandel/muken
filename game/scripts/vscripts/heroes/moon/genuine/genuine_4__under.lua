genuine_4__under = class({})
LinkLuaModifier("genuine_4_modifier_under", "heroes/moon/genuine/genuine_4_modifier_under", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_4_modifier_passive", "heroes/moon/genuine/genuine_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "_modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "_modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_4__under:Spawn()
    self:SetCurrentAbilityCharges(GENUINE_UNDER_NIGHT)
  end

  function genuine_4__under:GetBehavior()
    if self:GetCurrentAbilityCharges() == GENUINE_UNDER_NIGHT then
      return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end
    if self:GetCurrentAbilityCharges() == GENUINE_UNDER_DAY then
      return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end
  end

  function genuine_4__under:GetIntrinsicModifierName()
    return "genuine_4_modifier_passive"
  end

-- SPELL START

	function genuine_4__under:OnSpellStart()
		local caster = self:GetCaster()
    AddModifier(caster, caster, self, "genuine_4_modifier_under", {duration = self:GetSpecialValueFor("invi_duration")}, true)
	end

-- EFFECTS