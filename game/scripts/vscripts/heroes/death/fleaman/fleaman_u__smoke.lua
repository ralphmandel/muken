fleaman_u__smoke = class({})
LinkLuaModifier("fleaman_u_modifier_smoke", "heroes/death/fleaman/fleaman_u_modifier_smoke", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fleaman_u_modifier_aura_effect", "heroes/death/fleaman/fleaman_u_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fleaman_u_modifier_shadow", "heroes/death/fleaman/fleaman_u_modifier_shadow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "_modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "_modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind", "_modifiers/_modifier_blind", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind_stack", "_modifiers/_modifier_blind_stack", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function fleaman_u__smoke:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

  function fleaman_u__smoke:OnSpellStart()
		local caster = self:GetCaster()

		CreateModifierThinker(caster, self, "fleaman_u_modifier_smoke", {
      duration = self:GetSpecialValueFor("duration")
    }, self:GetCursorPosition(), caster:GetTeamNumber(), false)
	end

-- EFFECTS