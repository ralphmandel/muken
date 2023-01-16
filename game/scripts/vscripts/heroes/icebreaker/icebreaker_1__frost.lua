icebreaker_1__frost = class({})
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant", "heroes/icebreaker/icebreaker__modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_passive", "heroes/icebreaker/icebreaker_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant_status_efx", "heroes/icebreaker/icebreaker__modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_1_modifier_passive_status_efx", "heroes/icebreaker/icebreaker_1_modifier_passive_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

	function icebreaker_1__frost:Spawn()
		self.kills = 0
		if self:IsTrained() == false then self:UpgradeAbility(true) end
	end

-- SPELL START

  function icebreaker_1__frost:GetIntrinsicModifierName()
    return "icebreaker_1_modifier_passive"
  end

-- EFFECTS