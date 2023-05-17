icebreaker_u__zero = class({})
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_dps", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_dps", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant", "heroes/team_moon/icebreaker/icebreaker__modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_illusion", "heroes/team_moon/icebreaker/icebreaker__modifier_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bat_increased", "modifiers/_modifier_bat_increased", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_u_modifier_aura", "heroes/team_moon/icebreaker/icebreaker_u_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_u_modifier_aura_effect", "heroes/team_moon/icebreaker/icebreaker_u_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_u_modifier_status_efx", "heroes/team_moon/icebreaker/icebreaker_u_modifier_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function icebreaker_u__zero:GetCastRange(vLocation, hTarget)
    return 200
  end

-- SPELL START

  function icebreaker_u__zero:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local shard = CreateUnitByName("icebreaker_shard", point, true, caster, caster, caster:GetTeamNumber())

		shard:CreatureLevelUp(self:GetSpecialValueFor("rank"))
		shard:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
    AddModifier(shard, caster, self, "icebreaker_u_modifier_aura", {duration = self:GetSpecialValueFor("duration")}, false)
	end

-- EFFECTS