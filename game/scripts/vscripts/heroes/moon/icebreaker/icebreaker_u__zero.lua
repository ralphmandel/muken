icebreaker_u__zero = class({})
LinkLuaModifier("icebreaker_u_modifier_aura", "heroes/moon/icebreaker/icebreaker_u_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_u_modifier_aura_effect", "heroes/moon/icebreaker/icebreaker_u_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_u_modifier_status_efx", "heroes/moon/icebreaker/icebreaker_u_modifier_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_slow", "heroes/moon/icebreaker/icebreaker__modifier_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/moon/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/moon/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/moon/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/moon/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bat_increased", "_modifiers/_modifier_bat_increased", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function icebreaker_u__zero:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local shard = CreateUnitByName("icebreaker_shard", point, true, caster, caster, caster:GetTeamNumber())

		shard:CreatureLevelUp(self:GetSpecialValueFor("rank"))
		shard:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
    AddModifier(shard, self, "icebreaker_u_modifier_aura", {duration = self:GetSpecialValueFor("duration")}, false)
	end

-- EFFECTS