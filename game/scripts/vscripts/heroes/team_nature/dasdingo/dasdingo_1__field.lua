dasdingo_1__field = class({})
LinkLuaModifier("dasdingo_1_modifier_field", "heroes/team_nature/dasdingo/dasdingo_1_modifier_field", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function dasdingo_1__field:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS