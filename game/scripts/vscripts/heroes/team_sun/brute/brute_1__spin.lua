brute_1__spin = class({})
LinkLuaModifier("brute_1_modifier_spin", "heroes/team_sun/brute/brute_1_modifier_spin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function brute_1__spin:OnSpellStart()
		local caster = self:GetCaster()
    AddModifier(caster, caster, self, "brute_1_modifier_spin", {}, false)
	end

-- EFFECTS