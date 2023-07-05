bocuse_5__roux = class({})
LinkLuaModifier("bocuse_5_modifier_root", "heroes/team_death/bocuse/bocuse_5_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_5_modifier_roux", "heroes/team_death/bocuse/bocuse_5_modifier_roux", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_5_modifier_roux_aura_effect", "heroes/team_death/bocuse/bocuse_5_modifier_roux_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "_modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_pull", "_modifiers/_modifier_pull", LUA_MODIFIER_MOTION_HORIZONTAL)

-- INIT

-- SPELL START

	function bocuse_5__roux:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function bocuse_5__roux:OnSpellStart()
		local caster = self:GetCaster()

		CreateModifierThinker(caster, self, "bocuse_5_modifier_roux", {
			duration = self:GetSpecialValueFor("lifetime")
		}, self:GetCursorPosition(), caster:GetTeamNumber(), false)
	end

-- EFFECTS