icebreaker_4__shivas = class({})
LinkLuaModifier("icebreaker_4_modifier_shivas", "heroes/team_moon/icebreaker/icebreaker_4_modifier_shivas", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function icebreaker_4__shivas:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS