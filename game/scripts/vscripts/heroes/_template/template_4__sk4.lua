template_4__sk4 = class({})
LinkLuaModifier("template_4_modifier_sk4", "heroes/template/template_4_modifier_sk4", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function template_4__sk4:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS