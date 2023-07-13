fleaman_2__speed = class({})
LinkLuaModifier("fleaman_2_modifier_passive", "heroes/death/fleaman/fleaman_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fleaman_2_modifier_speed_stack", "heroes/death/fleaman/fleaman_2_modifier_speed_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function fleaman_2__speed:GetIntrinsicModifierName()
    return "fleaman_2_modifier_passive"
  end

-- SPELL START

	function fleaman_2__speed:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS