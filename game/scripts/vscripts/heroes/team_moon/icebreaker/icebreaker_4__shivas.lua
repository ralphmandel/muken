icebreaker_4__shivas = class({})
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_dps", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_dps", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant", "heroes/team_moon/icebreaker/icebreaker__modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_illusion", "heroes/team_moon/icebreaker/icebreaker__modifier_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_4_modifier_shivas", "heroes/team_moon/icebreaker/icebreaker_4_modifier_shivas", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function icebreaker_4__shivas:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS