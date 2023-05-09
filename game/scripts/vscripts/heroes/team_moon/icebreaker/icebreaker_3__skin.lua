icebreaker_3__skin = class({})
LinkLuaModifier("icebreaker_3_modifier_skin", "heroes/team_moon/icebreaker/icebreaker_3_modifier_skin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function icebreaker_3__skin:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS