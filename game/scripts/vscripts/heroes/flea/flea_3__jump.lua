flea_3__jump = class({})
LinkLuaModifier("flea_3_modifier_jump", "heroes/flea/flea_3_modifier_jump", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_3_modifier_effect", "heroes/flea/flea_3_modifier_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_3_modifier_bleeding", "heroes/flea/flea_3_modifier_bleeding", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_generic_arc", "modifiers/_modifier_generic_arc", LUA_MODIFIER_MOTION_BOTH)

-- INIT

-- SPELL START

	function flea_3__jump:OnOwnerSpawned()
		self:SetActivated(true)
	end

	function flea_3__jump:OnSpellStart()
		local caster = self:GetCaster()

		ProjectileManager:ProjectileDodge(caster)
		caster:RemoveModifierByName("flea_3_modifier_jump")
		caster:AddNewModifier(caster, self, "flea_3_modifier_jump", {})
	end

-- EFFECTS