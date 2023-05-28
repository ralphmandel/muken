template_3__sk3 = class({})
LinkLuaModifier("template_3_modifier_sk3", "heroes/team_id_team/template/template_3_modifier_sk3", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function template_3__sk3:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS