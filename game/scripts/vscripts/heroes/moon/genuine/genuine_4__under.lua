genuine_4__under = class({})
LinkLuaModifier("genuine_4_modifier_aura", "heroes/moon/genuine/genuine_4_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_4_modifier_aura_effect", "heroes/moon/genuine/genuine_4_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_4__under:Spawn()
    self:SetCurrentAbilityCharges(CYCLE_NIGHT)
  end
  
  function genuine_4__under:GetIntrinsicModifierName()
    return "genuine_4_modifier_aura"
  end

-- SPELL START

-- EFFECTS