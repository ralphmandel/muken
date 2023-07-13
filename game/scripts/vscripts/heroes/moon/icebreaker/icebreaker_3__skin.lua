icebreaker_3__skin = class({})
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/moon/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/moon/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/moon/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/moon/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant", "heroes/moon/icebreaker/icebreaker__modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant_status_efx", "heroes/moon/icebreaker/icebreaker__modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_illusion", "heroes/moon/icebreaker/icebreaker__modifier_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bat_increased", "_modifiers/_modifier_bat_increased", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_3_modifier_skin", "heroes/moon/icebreaker/icebreaker_3_modifier_skin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_mana_regen", "_modifiers/_modifier_mana_regen", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function icebreaker_3__skin:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("cast_range")
  end

-- SPELL START

	function icebreaker_3__skin:OnSpellStart()
		local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    AddModifier(target, caster, self, "icebreaker_3_modifier_skin", {duration = self:GetSpecialValueFor("duration")}, true)
	end

-- EFFECTS