template_1__sk1 = class({})
LinkLuaModifier("template_1_modifier_sk1", "heroes/team_id_team/template/template_1_modifier_sk1", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function template_1__sk1:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS